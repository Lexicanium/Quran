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

/// A `FontFile` object represents the file of a specific font format.
public class FontFile {
    private var defaultTypefaces: [Typeface]!

    /// Creates a font file instance representing the specified file path. The data of the font is
    /// directly read from the file when needed.
    ///
    /// - Parameter path: The path of the font file.
    public init?(path: String) {
        guard let fontStream = FontStream(path: path) else {
            return nil
        }

        loadTypefaces(from: fontStream)
    }

    /// Creates a font file instance representing the specified data.
    ///
    /// - Parameter data: The data of the font file.
    public init?(data: Data) {
        guard let fontStream = FontStream(data: data) else {
            return nil
        }

        loadTypefaces(from: fontStream)
    }

    /// Creates a font file instance from the specified input stream by copying its data into a
    /// memory buffer. It may take some time to create the instance if the stream holds larger data.
    ///
    /// - Parameter stream: The input stream that contains the data of the font.
    public init?(stream: InputStream) {
        guard let fontStream = FontStream(stream: stream) else {
            return nil
        }

        loadTypefaces(from: fontStream)
    }

    private func loadTypefaces(from fontStream: FontStream) {
        defaultTypefaces = []

        for i in 0 ..< fontStream.faceCount {
            guard let firstTypeface = Typeface(fontStream: fontStream, faceIndex: i, instanceIndex: i) else {
                continue
            }

            let instanceStart = defaultTypefaces.count;
            let instanceCount = max(1, firstTypeface.ftFace.pointee.style_flags >> 16)

            defaultTypefaces.append(firstTypeface)

            for j in 1 ..< instanceCount {
                guard let instanceTypeface = Typeface(fontStream: fontStream, faceIndex: i, instanceIndex: j) else {
                    continue
                }

                let instanceCoords = instanceTypeface.variationCoordinates
                if !instanceCoords.isEmpty {
                    // Remove existing duplicate instances.
                    for k in (instanceStart ..< defaultTypefaces.count).reversed() {
                        let referenceCoords = defaultTypefaces[k].variationCoordinates

                        if instanceCoords == referenceCoords {
                            defaultTypefaces.remove(at: k)
                        }
                    }
                }

                defaultTypefaces.append(instanceTypeface)
            }
        }
    }

    /// Named typefaces of this font file.
    public var typefaces: [Typeface] {
        return defaultTypefaces
    }
}
