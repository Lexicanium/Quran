//
// Copyright (C) 2019-2021 Muhammad Tayyab Akram
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation
import FreeType
import UIKit

/// The `Renderer` class represents a generic glyph renderer. It can be used to generate glyph
/// paths, measure their bounding boxes and draw them in a `CGContext` object.
public class Renderer {
    /// Specifies if the glyph being drawn is filled, stroked, or both.
    public enum RenderingStyle {
        /// Glyphs drawn with this style will be filled, ignoring all stroke-related settings in the
        /// renderer.
        case fill
        /// Glyphs drawn with this style will be both filled and stroked at the same time,
        /// respecting the stroke-related settings in the renderer.
        case fillStroke
        /// Glyphs drawn with this style will be stroked, respecting the stroke-related settings in
        /// the renderer.
        case stroke
    }

    /// Specifies the treatment for the beginning and ending of stroked lines and paths.
    public enum StrokeCap: Int {
        /// The stroke ends with the path, and does not project beyond it.
        case butt = 0
        /// The stroke projects out as a semicircle, with the center at the end of the path.
        case round = 1
        /// The stroke projects out as a square, with the center at the end of the path.
        case square = 2
    }

    /// Specifies the treatment where lines and curve segments join on a stroked path.
    public enum StrokeJoin: Int {
        /// The outer edges of a join meet with a straight line.
        case bevel = 1
        /// The outer edges of a join meet at a sharp angle.
        case miter = 2
        /// The outer edges of a join meet in a circular arc.
        case round = 0
    }

    private let glyphAttributes = GlyphAttributes()

    /// Creates a renderer.
    public init() {
        updatePixelSizes()
        updateTransform()
    }

    /// The fill color for glyphs. Its default value is `.black`.
    public var fillColor: UIColor = .black {
        didSet {
            glyphAttributes.setForegroundColor(fillColor.ftColor())
        }
    }

    /// The style, used for controlling how glyphs should appear while drawing. Its default value is
    /// `.fill`.
    public var renderingStyle: RenderingStyle = .fill

    /// The direction in which the pen will advance after drawing a glyph. Its default value is
    /// `.leftToRight`.
    public var writingDirection: WritingDirection = .leftToRight

    /// The typeface, used for drawing glyphs.
    public var typeface: Typeface! = nil {
        didSet {
            glyphAttributes.setTypeface(typeface)
        }
    }

    /// The type size applied on the glyphs while drawing.
    public var typeSize: CGFloat = 16.0 {
        didSet {
            updatePixelSizes()
        }
    }

    /// The slant angle for glyphs. Its default value is zero.
    public var slantAngle: CGFloat = 0.0 {
        didSet {
            updateTransform()
        }
    }

    /// The scale factor applied to the glyphs and their metrics such as offsets and advances.
    public var renderScale: CGFloat = 1.0 {
        didSet {
            updatePixelSizes()
        }
    }

    /// The horizontal scale factor applied on the glyphs while drawing. Its default value is 1.0.
    /// Values greater than 1.0 will stretch the glyphs wider. Values less than 1.0 will stretch the
    /// glyphs narrower.
    public var scaleX: CGFloat = 1.0 {
        didSet {
            updatePixelSizes()
        }
    }

    /// The vertical scale factor applied on the glyphs while drawing. Its default value is 1.0.
    /// Values greater than 1.0 will stretch the glyphs wider. Values less than 1.0 will stretch the
    /// glyphs narrower.
    public var scaleY: CGFloat = 1.0 {
        didSet {
            updatePixelSizes()
        }
    }

    /// The stroke color for glyphs. Its default value is `.black`.
    public var strokeColor: UIColor = .black

    /// The width, in pixels, for stroking glyphs.
    public var strokeWidth: CGFloat = 1.0 {
        didSet {
            glyphAttributes.setLineRadius(strokeWidth / 2.0)
        }
    }

    /// The stroke cap style which controls how the start and end of stroked lines and paths are
    /// treated. Its default value is `.butt`.
    public var strokeCap: StrokeCap = .butt {
        didSet {
            glyphAttributes.setLineCap(FT_Stroker_LineCap(UInt32(strokeCap.rawValue)))
        }
    }

    /// The stroke join type. Its default value is `.round`.
    public var strokeJoin: StrokeJoin = .round {
        didSet {
            glyphAttributes.setLineJoin(FT_Stroker_LineJoin(UInt32(strokeJoin.rawValue)))
        }
    }

    /// The stroke miter limit in pixels. This is used to control the behavior of miter joins when
    /// the joins angle is sharp.
    public var strokeMiter: CGFloat = 1.0 {
        didSet {
            glyphAttributes.setMiterLimit(strokeMiter)
        }
    }

    /// The shadow radius, in pixels, used when drawing glyphs. Its default value is
    /// zero. The shadow would be disabled if the value is set to zero.
    public var shadowRadius: CGFloat = 0.0

    /// The horizontal shadow offset, in pixels.
    public var shadowDx: CGFloat = 0.0

    /// The vertical shadow offset in pixels.
    public var shadowDy: CGFloat = 0.0

    /// The shadow color.
    public var shadowColor: UIColor = .black

    private func updatePixelSizes() {
        glyphAttributes.setPixelWidth(typeSize * scaleX * renderScale)
        glyphAttributes.setPixelHeight(typeSize * scaleY * renderScale)
    }

    private func updateTransform() {
        glyphAttributes.setSkewX(slantAngle)
    }

    private func cachedPath(forGlyph glyphID: GlyphID) -> CGPath? {
        return GlyphCache.instance.path(forGlyph: glyphID, attributes: glyphAttributes)
    }

    /// Generates the path of specified glyph.
    ///
    /// - Parameter glyphID: The ID of glyph whose path is generated.
    /// - Returns: The path of the glyph specified by `glyphID`.
    public func makePath(glyphID: GlyphID) -> CGPath? {
        return cachedPath(forGlyph: glyphID)?.copy()
    }

    /// Generates a cumulative path of specified glyphs.
    ///
    /// - Parameters:
    ///   - glyphIds: A sequence of glyph IDs.
    ///   - offsets: A sequence of glyph offsets.
    ///   - advances: A sequence of glyph advances.
    /// - Returns: The cumulative path of specified glyphs.
    public func makePath<GS, OS, AS>(glyphIDs: GS, offsets: OS, advances: AS) -> CGPath?
        where GS : Sequence, GS.Element == GlyphID,
              OS : Sequence, OS.Element == CGPoint,
              AS : Sequence, AS.Element == CGFloat {
        let comulativePath = CGMutablePath()
        var penX: CGFloat = 0.0

        var offsetIter = offsets.makeIterator()
        var advanceIter = advances.makeIterator()

        for glyphID in glyphIDs {
            let offset = offsetIter.next()!
            let advance = advanceIter.next()!

            if let path = cachedPath(forGlyph: glyphID) {
                let position = CGAffineTransform(scaleX: penX + offset.x, y: offset.y)
                comulativePath.addPath(path, transform: position)
            }

            penX += advance
        }

        return comulativePath
    }

    private func cachedBoundingBox(forGlyph glyphID: GlyphID) -> CGRect {
        if let glyphImage = GlyphCache.instance.defaultImage(forGlyph: glyphID, attributes: glyphAttributes) {
            return CGRect(x: glyphImage.left,
                          y: glyphImage.top,
                          width: glyphImage.width,
                          height: glyphImage.height)
        }

        return .zero
    }

    /// Calculates the bounding box of specified glyph.
    ///
    /// - Parameter glyphID: The ID of glyph whose bounding box is calculated.
    /// - Returns: A rectangle that tightly encloses the path of the specified glyph.
    public func computeBoundingBox(forGlyph glyphID: GlyphID) -> CGRect {
        var glyphBox = cachedBoundingBox(forGlyph: glyphID)
        glyphBox.origin.x /= renderScale
        glyphBox.origin.y /= renderScale
        glyphBox.size.width /= renderScale
        glyphBox.size.height /= renderScale

        return glyphBox
    }

    /// Calculates the bounding box of specified glyphs.
    ///
    /// - Parameters:
    ///   - glyphIDs: A sequence of glyph IDs.
    ///   - offsets: A sequence of glyph offsets.
    ///   - advances: A sequence of glyph advances.
    /// - Returns: A rectangle that tightly encloses the paths of specified glyphs.
    public func computeBoundingBox<GS, OS, AS>(forGlyphs glyphIDs: GS, offsets: OS, advances: AS) -> CGRect
        where GS: Sequence, GS.Element == GlyphID,
              OS: Sequence, OS.Element == CGPoint,
              AS: Sequence, AS.Element == CGFloat {
        let reverseMode = (writingDirection == .rightToLeft)

        var comulativeBox = CGRect.null
        var totalAdvance: CGFloat = .zero
        var penX: CGFloat = .zero

        var offsetIter = offsets.makeIterator()
        var advanceIter = advances.makeIterator()

        for glyphID in glyphIDs {
            let unscaledOffset = offsetIter.next()!
            let unscaledAdvance = advanceIter.next()!

            let offset = CGPoint(x: unscaledOffset.x * renderScale,
                                 y: unscaledOffset.y * renderScale)
            let advance = unscaledAdvance * renderScale

            if reverseMode {
                penX -= advance
            }

            var glyphBox = cachedBoundingBox(forGlyph: glyphID)
            glyphBox.origin.x = round(penX + offset.x + glyphBox.origin.x)
            glyphBox.origin.y = round(-offset.y - glyphBox.origin.y)

            comulativeBox = comulativeBox.union(glyphBox)

            if !reverseMode {
                penX += advance
            }

            totalAdvance += advance
        }

        if reverseMode {
            comulativeBox.origin.x += ceil(totalAdvance)
        }

        comulativeBox.origin.x /= renderScale
        comulativeBox.origin.y /= renderScale
        comulativeBox.size.width /= renderScale
        comulativeBox.size.height /= renderScale

        return comulativeBox
    }

    private func drawGlyphs<GS, OS, AS>(in context: CGContext, glyphIDs: GS, offsets: OS, advances: AS, strokeMode: Bool)
        where GS: Sequence, GS.Element == GlyphID,
              OS: Sequence, OS.Element == CGPoint,
              AS: Sequence, AS.Element == CGFloat {
        let cache = GlyphCache.instance
        let reverseMode = (writingDirection == .rightToLeft)
        var penX: CGFloat = 0.0

        var offsetIter = offsets.makeIterator()
        var advanceIter = advances.makeIterator()

        for glyphID in glyphIDs {
            let unscaledOffset: CGPoint! = offsetIter.next()
            let unscaledAdvance: CGFloat! = advanceIter.next()

            let offset = CGPoint(x: unscaledOffset.x * renderScale, y: unscaledOffset.y * renderScale)
            let advance = unscaledAdvance * renderScale

            if reverseMode {
                penX -= advance
            }

            let glyphImage = (!strokeMode
                              ? cache.defaultImage(forGlyph: glyphID, attributes: glyphAttributes)
                              : cache.strokeImage(forGlyph: glyphID, attributes: glyphAttributes))

            if let glyphImage = glyphImage {
                let rect = CGRect(x: round(penX + offset.x + glyphImage.left),
                                  y: round(-offset.y - glyphImage.top),
                                  width: glyphImage.width,
                                  height: glyphImage.height)

                context.draw(glyphImage.layer, in: rect)
            }

            if !reverseMode {
                penX += advance
            }
        }
    }

    /// Draws the glyphs in the specified context.
    ///
    /// - Parameters:
    ///   - context: The context onto which to draw the glyphs.
    ///   - glyphIDs: A sequence of glyph IDs.
    ///   - offsets: A sequence of glyph offsets.
    ///   - advances: A sequence of glyph advances.
    public func drawGlyphs<GS, OS, AS>(in context: CGContext, glyphIDs: GS, offsets: OS, advances: AS)
        where GS: Sequence, GS.Element == GlyphID,
              OS: Sequence, OS.Element == CGPoint,
              AS: Sequence, AS.Element == CGFloat {
        if glyphAttributes.isRenderable {
            context.setShadow(offset: CGSize(width: shadowDx, height: shadowDy),
                              blur: shadowRadius,
                              color: shadowColor.cgColor)
        }

        // Extract the pixel level translation.
        let transform = context.userSpaceToDeviceSpaceTransform
        let pixelPosition = CGPoint(x: round(transform.tx), y: round(transform.ty))
        let difference = CGSize(width: pixelPosition.x - transform.tx, height: pixelPosition.y - transform.ty)
        let translation = context.convertToUserSpace(difference)

        // Work on pixel level.
        context.translateBy(x: translation.width, y: translation.height)
        context.scaleBy(x: 1.0 / renderScale, y: 1.0 / renderScale)

        if renderingStyle == .fill || renderingStyle == .fillStroke {
            context.setFillColor(fillColor.cgColor)
            drawGlyphs(in: context, glyphIDs: glyphIDs, offsets: offsets, advances: advances, strokeMode: false)
        }

        if renderingStyle == .stroke || renderingStyle == .fillStroke {
            context.setFillColor(strokeColor.cgColor)
            drawGlyphs(in: context, glyphIDs: glyphIDs, offsets: offsets, advances: advances, strokeMode: true)
        }

        // Reset the scale and the translation.
        context.scaleBy(x: renderScale, y: renderScale)
        context.translateBy(x: -translation.width, y: -translation.height)
    }
}
