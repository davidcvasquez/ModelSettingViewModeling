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
import NDGeometry
import LocalizableStringBundle
import Metal

// TODO: Move this into NDGeometry
/// Enables passing either the NDAngle or SwiftUI Angle type to code that only uses initializers and get and set for degrees and radians.
public protocol AnyAngle: Comparable, Strideable, Codable, Sendable {
    associatedtype Scalar: BinaryFloatingPoint & Comparable

    init()
    init(degrees: Scalar)
    init(radians: Scalar)

    /// Radians in the native scalar for this type (Double for SwiftUI.Angle, NDFloat for NDAngle, etc.)
    var radians: Scalar { get set }
    var degrees: Scalar { get set }
}

extension Angle: AnyAngle {
    public typealias Scalar = Double
}

extension NDAngle: AnyAngle {
    public typealias Scalar = NDFloat
}

public enum PackageShaders {
    public static let library: ShaderLibrary = {
        // Use the package module bundle instead of the main app bundle.
        ShaderLibrary.bundle(.module)
    }()
}

/// Displays a measure of angle value using an angular wedge on top of a circular background, and a grabber to adjust the value.
public struct AngleComponentView<
    MoA: AnyAngle,
    ViewModel: ModelSettingViewModel
>: ViewModelComponentView {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(LocalizationRuntime.self) private var localization
    @Environment(\.isPreview) private var isPreview

    public let viewModel: ViewModel

    public init(
        viewModel: ViewModel,
        isPopover: Bool = false,
        labelText: LocalizationKey,
        value: Binding<MoA>,
        in bounds: ClosedRange<MoA> = MoA()...MoA(degrees: 360.0),
        isTrackingInput: Binding<Bool>
    ) {
        self.viewModel = viewModel
        self.isPopover = isPopover
        self.labelText = labelText
        self._rotation = value
        self.bounds = bounds
        self._isTrackingInput = isTrackingInput
    }

    private var isPopover: Bool
    private var labelText: LocalizationKey
    @Binding public var rotation: MoA

    let bounds: ClosedRange<MoA>

    @Binding public var isTrackingInput: Bool

    @State private var dragEffectT: CGFloat = 0  // 0 = frosted, 1 = glass

    private func updateDragEffectT() {
        withAnimation(.easeInOut(duration: 0.20)) {
            dragEffectT = isDragging ? 1 : 0
        }
    }

    public var body: some View {
// If shader fails in preview, add this check.
//        let disableShaders = isPreview || PreviewHeuristics.isRunningInPreviews
        let shaderLibrary = PackageShaders.library

        HStack {
            if !isPopover {
                RenamableLabelTextComponentView(
                    viewModel: viewModel,
                    isTrackingInput: $isTrackingInput,
                    labelText: labelText,
                    verticalAlignment: .center
                )
            }

            AngleWedge(angle: self.rotation,
                       size: self.dialSize)
            .frame(width: self.dialDiameter, height: self.dialDiameter,
                   alignment: .center)
            .opacity(self.dialOpacity)
            .visualEffect { [isDragging, grabberPosition, dialSize, dragEffectT] content, proxy in
                let tf = Float(dragEffectT)               // 0...1

                // Compute shader center using a nonisolated helper.
                let center = self.normalizedPosition(for: grabberPosition, in: dialSize)
                return content.layerEffect(
                    shaderLibrary.donutShader(
                        .float2(dialSize.cgSize),
                        .float2(center.x, center.y),        // center
                        .float(lerp(0.17, 0.20, tf)),       // radius
                        .float(isDragging ? 0.85 : 0.75),   // refraction (strength)
                        .float(lerp(0.50, 0.2, tf)),        // refractionThickness
                        .float(lerp(0.08, 0.16, tf)),       // shadowOpacity
                        .float(lerp(0.01, 0.015, tf)),      // shadowOffset
                        .float(isDragging ? 0.015 : 0.02),  // shadowBlur
                        .float(lerp(0.9, 0.6, tf)),         // edgeThickness
                        .float(0.2)                         // chromaticAmount
                    ),
                    maxSampleOffset: CGSize(width: 50, height: 50)
                )
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { drag in
                        if !self.isDragging {
                            self.isDragging = true
                            self.initialDragValue = self.rotation
                            self.isTrackingInput = true
                        }
                        self.rotation.degrees =
                            MoA.Scalar(CGFloat(self.initialDragValue.degrees) +
                                   (drag.startLocation.y - drag.location.y) * 0.5)
                    }
                    .onEnded { _ in
                        self.isDragging = false
                        self.isTrackingInput = false
                    }
            )
            .simultaneousGesture(
                TapGesture(count: 2)
                    .onEnded {
                        self.isTrackingInput = true

                        withAnimation(.spring()) {
                            self.rotation.degrees = 0
                        }

                        DispatchQueue.main.async {
                            self.isTrackingInput = false
                        }
                    }
            )
        }
        .padding(self.padding)
        .onChange(of: isDragging) {
            updateDragEffectT()
        }
        .onAppear {
            dragEffectT = isDragging ? 1 : 0
        }
    }

    nonisolated private func normalizedPosition(
        for point: NDPoint, in size: NDSize
    ) -> CGPoint {
        return CGPoint(
            x: (point.x + 1) / size.width,
            y: (point.y + 1) / size.height
        )
    }

    var dialOpacity: NDFloat {
        self.isEnabled ? 0.95 : 0.25
    }

    var captionOpacity: NDFloat {
        self.isEnabled ? 0.75 : 0.33
    }

    var grabberOffset: NDFloat {
        if isPopover {
            return isDragging ? 6.0 : 8.0
        }
        else {
            return isDragging ? 4.0 : 5.0
        }
    }

    var grabberPosition: NDPoint {
        let zeroPoint = CGPoint(
            x: self.dialDiameter * 0.5 - self.grabberWidth * 0.5,
            y: self.dialDiameter * 0.5 - self.grabberHeight * 0.5)
        let position = zeroPoint.applying(
            TransformedCapsule.grabberTransform(
            zeroPoint: NDPoint(zeroPoint),
            offset: NDSize(width: self.dialDiameter * 0.21 + grabberOffset, height: 0.0),
            rotation: self.rotation
        ))
        return NDPoint(x: position.x + self.dialDiameter * 0.5 - grabberWidth * 0.5,
                       y: position.y + self.dialDiameter * 0.5 - grabberHeight * 0.5)
    }

    @State private var isDragging = false
    @State private var initialDragValue = MoA()

    var inflate: CGFloat {
        isPopover ? 8.0 : 4.0
    }

    var padding: CGFloat {
        isPopover ? 10.0 : 0.0
    }

    var dialDiameter: CGFloat {
        isPopover ? 73 : 37
    }
    var dialSize: NDSize { NDSize(width: dialDiameter, height: dialDiameter) }
    var grabberHeight: CGFloat { dialDiameter * 0.42 + inflate }
    var grabberWidth: CGFloat { dialDiameter * 0.42 + inflate }
}

/// A signed angle wedge that draws positive angles using the "tint" color, and negative angles using the complement of the tint color.
private struct AngleWedge<MoA: AnyAngle>: View {
    var angle: MoA
    var size: NDSize
    let zeroZone: MoA.Scalar = 2.0
    let zeroMarkOpacity = 0.5
    let wedgeOpacity = 0.80
    var centerSize: NDSize { NDSize(width: size.width * 0.25, height: size.height * 0.25) }

    var body: some View {
        ZStack(alignment: .center) {
            // Full background circle (unfilled track)
            Circle()
                .fill(Color.secondary.opacity(0.17))

            if angle.degrees < 0 {
                wedgePath(size)
                    .fill(.tintComplement.opacity(wedgeOpacity))
            }
            else if angle.degrees > 0 {
                wedgePath(size)
                    .fill(.tint.opacity(wedgeOpacity))
            }

            // Draw the zero mark, cross-faded with the signed wedge shapes.
            if angle.degrees > -zeroZone && angle.degrees < zeroZone {
                let opacity = lerp(0.0, zeroMarkOpacity, 1.0 - abs(angle.degrees) / zeroZone)
                Rectangle()
                    .fill(.labelColor.opacity(Double(opacity)))
                    .frame(width: size.width * 0.5, height: 1.0)
                    .offset(CGSize(width: size.width * 0.25, height: 0.0))
            }

            if angle.degrees < 0 {
                Circle()
                    .fill(.tintComplement)
                    .frame(width: centerSize.width, height: centerSize.height)
            }
            else if angle.degrees > 0 {
                Circle()
                    .fill(.tint)
                    .frame(width: centerSize.width, height: centerSize.height)
            }
            else {
                Circle()
                    .fill(.gray.opacity(0.8))
                    .frame(width: centerSize.width, height: centerSize.height)
            }
       }
        .frame(width: size.smallestSide,
               height: size.smallestSide)
    }

    func wedgePath(_ size: NDSize) -> Path {
        let shortSide = size.smallestSide
        let center = CGPoint(x: shortSide / 2, y: shortSide / 2)
        let radius = shortSide / 2

        return Path { path in
            path.move(to: center)

            path.addArc(
                center: center,
                radius: radius,
                startAngle: .degrees(0),
                endAngle: Angle(degrees: Double(-angle.degrees)),
                clockwise: angle.degrees > 0.0
            )

            path.closeSubpath()
        }
    }
}

/// A transformed Capsule that bakes `offset` + `rotation` into the generated Path,
/// instead of using `.offset` / `.rotationEffect`.
///
/// This matches:
///     Capsule()
///         .offset(x: dx, y: dy)
///         .rotationEffect(rotation, anchor: .center)
private struct TransformedCapsule<MoA: AnyAngle>: Shape
{
    public var offset: CGSize
    public var rotation: MoA

    public init(offset: CGSize = .zero, rotation: MoA = MoA()) {
        self.offset = offset
        self.rotation = rotation
    }

    // Make it animatable (optional, but usually what you want for knobs/controls).
    public var animatableData: AnimatablePair<AnimatablePair<CGFloat, CGFloat>, CGFloat> {
        get {
            .init(.init(offset.width, offset.height), CGFloat(rotation.radians))
        }
        set {
            offset = .init(width: newValue.first.first, height: newValue.first.second)
            rotation.radians = MoA.Scalar(newValue.second)
        }
    }

    public func path(in rect: CGRect) -> Path {
        Capsule().path(in: rect).applying(Self.grabberTransform(
            zeroPoint: NDPoint(x: rect.midX, y: rect.midY),
            offset: NDSize(self.offset),
            rotation: self.rotation
        ))
    }

    public static func grabberTransform(
        zeroPoint: NDPoint,
        offset: NDSize,
        rotation: MoA
    ) -> CGAffineTransform {
        let cx = zeroPoint.x
        let cy = zeroPoint.y

        let θ = CGFloat(-rotation.radians)
        let cosθ = cos(θ)
        let sinθ = sin(θ)

        let ox = offset.width
        let oy = offset.height

        // Implements: p' = c + R(θ) * (p + o - c)
        //
        // x' =  cosθ*x - sinθ*y + tx
        // y' =  sinθ*x + cosθ*y + ty
        //
        // with:
        // tx = (cx - cx*cosθ + cy*sinθ) + (ox*cosθ - oy*sinθ)
        // ty = (cy - cy*cosθ - cx*sinθ) + (ox*sinθ + oy*cosθ)
        let tx = (cx - cx * cosθ + cy * sinθ) + (ox * cosθ - oy * sinθ)
        let ty = (cy - cy * cosθ - cx * sinθ) + (ox * sinθ + oy * cosθ)

        let t = CGAffineTransform(a: cosθ, b: sinθ,
                                  c: -sinθ, d: cosθ,
                                  tx: tx, ty: ty)
        return t
    }
}
