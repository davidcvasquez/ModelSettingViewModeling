//===----------------------------------------------------------------------===//
//
// This source file is part of the ModelSettingViewModeling open source project
//
// Copyright (c) 2026 David C. Vasquez and the ModelSettingViewModeling project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See the project's LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

import SwiftUI
import Combine
import UniformTypeIdentifiers
import NDGeometry
import LocalizableStringBundle

@Observable
@preconcurrency public class Document: ReferenceFileDocument {
    public let objectWillChange = ObservableObjectPublisher()

    // ModelSettingContainerCollection conformance.
    public var revision: UInt = 0

    /// - Returns: Convenience accessor for trim size from metadata.
    public var trimSize: NDSize {
        self.metadata.trimSize
    }

    public required init(configuration: ReadConfiguration) throws {
        let wrapper = configuration.file
        
        guard let bookJSON = wrapper.fileWrappers?[Book.preferredFilename]?.regularFileContents,
              let newBook = Book(json: bookJSON) else {
            throw CocoaError(.fileReadCorruptFile)
        }
        self.book = newBook
        
        guard let metadataJSON = wrapper.fileWrappers?[Metadata.preferredFilename]?.regularFileContents,
              let newMetadata = Metadata(json: metadataJSON) else {
            throw CocoaError(.fileReadCorruptFile)
        }
        self.metadata = newMetadata
        
        // [TODO] Read thumbnail image preview via sub-wrappers
    }
    
    init(metadata: Metadata, book: Book) {
        self.metadata = metadata
        self.book = book
        self.startTrackingLayer()
    }
    
    init() {
        self.metadata = Metadata(trimSize: .usLetterPixelsAt300dpi)
        self.book = Book()
        self.startTrackingLayer()
    }
    
    init(metadata: Metadata) {
        self.metadata = metadata
        self.book = Book()
        self.startTrackingLayer()
    }
    
    // Workaround for XCTest crash during deallocation.
    // Reproduces when module is built with default isolation set to MainActor.
    // https://github.com/swiftlang/swift/issues/87316
    nonisolated deinit {}

    public func notifyEdit() {
        self.revision &+= 1
        self.objectWillChange.send()
#if os(iOS)
        self.autosaveIfPossible()
#endif
    }
    
    public typealias Snapshot = Data
    
    public static var readableContentTypes: [UTType] {
        [
            .importedDocument,
            .importedMetadata,
            .importedBook
        ]
    }
    public static var writeableContentTypes: [UTType] {
        [
            .exportedDocument,
            .exportedMetadata,
            .exportedBook
        ]
    }
    
    public func snapshot(contentType: UTType) throws -> Data {
        if contentType == .exportedMetadata {
            return try metadata.json
        }
        else if contentType == .exportedBook {
            return try book.json
        }
        else if contentType == .exportedDocument {
            return Data()
        }
        else {
            throw CocoaError(.coderInvalidValue)
        }
    }
    
    /// Helper that builds the package structure as a FileWrapper.
    func makeFileWrapper() throws -> FileWrapper {
        var children: [String: FileWrapper] = [:]
        
        let metadata = (try? self.snapshot(contentType: .exportedMetadata)) ?? Data()
        children[Metadata.preferredFilename] = FileWrapper(regularFileWithContents: metadata)
        
        let bookData = (try? self.snapshot(contentType: .exportedBook)) ?? Data()
        children[Book.preferredFilename] = FileWrapper(regularFileWithContents: bookData)
        
        // [TODO] Add thumbnail preview
        
        return FileWrapper(directoryWithFileWrappers: children)
    }
    
    // FileDocument version:
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        try makeFileWrapper()
    }
    
    // https://gist.github.com/pd95/6c561bcfbb5edb6e1a972334ae668679
    public func fileWrapper(
        snapshot: Data,
        configuration: WriteConfiguration
    ) throws -> FileWrapper {
        // Create a directory file wrapper representing the package
        let directory = FileWrapper(directoryWithFileWrappers: [:])

        let metaData = (try? self.snapshot(contentType: .exportedMetadata)) ?? Data()
        directory.addRegularFile(
            withContents: metaData, preferredFilename: Metadata.preferredFilename)

        let bookData = (try? self.snapshot(contentType: .exportedBook)) ?? Data()
        directory.addRegularFile(
            withContents: bookData, preferredFilename: Book.preferredFilename)

        return directory
    }

    private static func decode(
        from wrapper: FileWrapper
    ) throws -> (metadata: Metadata, book: Book) {
        guard
            let metadataJSON = wrapper.fileWrappers?[Metadata.preferredFilename]?.regularFileContents,
            let metadata = Metadata(json: metadataJSON),
            let bookJSON = wrapper.fileWrappers?[Book.preferredFilename]?.regularFileContents,
            let book = Book(json: bookJSON)
        else {
            throw CocoaError(.fileReadCorruptFile)
        }
        return (metadata, book)
    }

    static func load(from url: URL) throws -> Document {
        // Read the package (directory) into a wrapper tree.
        let wrapper = try FileWrapper(url: url, options: [.immediate])

        // Decode using the same logic as init(configuration:)
        let package = try Self.decode(from: wrapper)

        // Build the document from the decoded model.
        return Document(metadata: package.metadata, book: package.book)
    }

#if os(iOS)
    @ObservationIgnored
    private var autosaveTask: Task<Void, Never>?

    @ObservationIgnored
    private var isSaving = false

    func autosaveIfPossible() {
        guard let url = fileURL else { return }
        guard !isExportingVideo else { return } // avoid conflict with long-running tasks

        // Cancel any pending autosave to debounce rapid edits
        autosaveTask?.cancel()

        // Debounce ~0.5s after the last edit
        autosaveTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 500_000_000)
            await self?.saveIfNeeded(to: url)
        }
    }

    @MainActor
    private func saveIfNeeded(to url: URL) async {
        guard !isSaving else { return }
        isSaving = true
        defer { isSaving = false }

        do {
            // Produce the package wrapper with current state
            let wrapper = try makeFileWrapper()

            // Ensure directory exists
            try FileManager.default.createDirectory(
                at: url.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )

            // Write atomically
            try wrapper.write(to: url, options: .atomic, originalContentsURL: nil)

            // Optionally log success
            // print("Autosaved to \(url.lastPathComponent)")
        } catch {
            // Handle/Log error
            // print("Autosave failed: \(error)")
        }
    }
#endif

    var fileURL: URL?

    var metadata: Metadata {
        didSet {
            self.notifyEdit()
        }
    }

    var book: Book {
        didSet {
            self.startTrackingLayer()
            self.notifyEdit()
        }
    }

    var trackingLayer: Layer? {
        didSet { }
    }

    var subLayerCount: Int {
        guard let page = self.book.selectedPage else {
            return 0
        }
        guard let selectedLayer = page.selectedLayer else {
            return 0
        }

        guard case let .mandala(layer) = selectedLayer.properties else {
            return 0
        }
        return layer.subLayers.count
    }

    func startTrackingLayer() {
        guard let selectedPage = self.book.selectedPage,
              let selectedLayer = selectedPage.selectedLayer else {
            return
        }

        self.trackingLayer = selectedLayer
    }

    func endTrackingLayer() {
        self.trackingLayer = nil
    }

    public func page(by id: String) -> Page? {
        return self.book.pages[id]
    }

    public func installUndoManager(_ undoManager: UndoManager) {
        self.undoManager = undoManager
    }

    public var canUndo: Bool {
        self.undoManager?.canUndo ?? false
    }

    public var canRedo: Bool {
        self.undoManager?.canRedo ?? false
    }

    public var undoActionName: String {
        self.undoManager?.undoActionName ?? ""
    }

    public var redoActionName: String {
        self.undoManager?.redoActionName ?? ""
    }

    public func undo() {
        self.undoManager?.undo()
    }

    public func redo() {
        self.undoManager?.redo()
    }

    private var undoManager: UndoManager?

    private var inUndoGroup: Bool = false

    public func startUndoGroup() {
        self.inUndoGroup = true
        self.undoManager?.beginUndoGrouping()
    }

    func undoablyPerform(
        operation: String,
        startGroupIfNotInGroup: Bool = false,
        endGroupIfInGroup: Bool = false,
        doit: () -> Void
    ) {
        let oldBook = self.book
        let oldMetadata = self.metadata

        if startGroupIfNotInGroup && !inUndoGroup {
            self.startUndoGroup()
        }
        self.undoManager?.registerUndo(withTarget: self) { [weak self] document in
            // perform the undo undoably (i.e. allow redo)
            self?.undoablyPerform(operation: operation) {
                document.book = oldBook
                document.metadata = oldMetadata
                document.startTrackingLayer()
            }
        }

        self.undoManager?.setActionName(operation)

        doit()

        self.startTrackingLayer()

        if endGroupIfInGroup && self.inUndoGroup {
            self.inUndoGroup = false
        }
    }

    public func endUndoGroup() {
        self.inUndoGroup = false
        self.undoManager?.endUndoGrouping()
    }

    public func undoablyPerform(
        actionName: LocalizedStringKey,
        startGroupIfNotInGroup: Bool = false,
        endGroupIfInGroup: Bool = false,
        doit: () -> Void
    ) {
        self.undoablyPerform(operation: actionName.stringValue,
                             startGroupIfNotInGroup: startGroupIfNotInGroup,
                             endGroupIfInGroup: endGroupIfInGroup,
                             doit: doit)
    }
}

public extension LocalizedStringKey {
    nonisolated var stringKey: String {
        let description = "\(self)"

        // Compact way to get "THE KEY" from in-between the argument name and the trailing comma.
        let components = description.components(separatedBy: "key: \"").map { $0.components(separatedBy: "\",") }

        guard !components.isEmpty else {
            return "key.not.found"
        }

        return components[1][0]
    }

    nonisolated var stringValue: String {
        String(localized: String.LocalizationValue(self.stringKey))
    }
}
