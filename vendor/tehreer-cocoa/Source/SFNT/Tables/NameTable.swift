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

/// Represents an OpenType `name` table.
public struct NameTable {
    private let typeface: Typeface?
    private let ftFace: FT_Face

    /// Creates a `name` table representation from the specified typeface.
    ///
    /// - Parameter typeface: The typeface for accessing the data of the table.
    public init?(typeface: Typeface) {
        self.typeface = typeface
        self.ftFace = typeface.ftFace
    }

    init?(ftFace: FT_Face) {
        self.typeface = nil
        self.ftFace = ftFace
    }

    /// The number of name records in this table.
    public var recordCount: Int {
        return Int(FT_Get_Sfnt_Name_Count(ftFace))
    }

    /// Retrieves a name record at a specified index.
    ///
    /// - Parameter index: The index of the name record.
    /// - Returns: A record of OpenType `name` table at a specified index.
    /// - Precondition: `index` must be greater than or equal to zero and less than `recordCount`.
    public func record(at index: Int) -> Record {
        precondition(index >= 0 && index < recordCount, String.indexOutOfRange)

        var sfntName = FT_SfntName()
        FT_Get_Sfnt_Name(ftFace, FT_UInt(index), &sfntName)

        let buffer = UnsafeBufferPointer(start: sfntName.string, count: Int(sfntName.string_len))

        return Record(nameID: sfntName.name_id,
                      platformID: sfntName.platform_id,
                      languageID: sfntName.language_id,
                      encodingID: sfntName.encoding_id,
                      bytes: Array(buffer))
    }
}

extension NameTable {
    enum NameID {
        static let fontFamily: UInt16 = 1
        static let fontSubfamily: UInt16 = 2
        static let full: UInt16 = 3
        static let typographicFamily: UInt16 = 16
        static let typographicSubfamily: UInt16 = 17
        static let wwsFamily: UInt16 = 21
        static let wwsSubfamily: UInt16 = 22
    }

    enum PlatformID {
        static let macintosh: UInt16 = 1
        static let windows: UInt16 = 3
    }

    func indexOfEnglishName(for nameID: UInt16) -> Int? {
        var candidate: Int?

        for i in 0 ..< recordCount {
            let current = record(at: i)
            if current.nameID != nameID {
                continue
            }

            let locale = current.locale
            if locale?.languageCode == "en" {
                if current.platformID == PlatformID.windows && locale?.regionCode == "US" {
                    return i
                }

                if candidate == nil || current.platformID == PlatformID.macintosh {
                    candidate = i
                }
            }
        }

        return candidate
    }

    func indexOfFamilyName(considering os2Table: OS2Table?) -> Int? {
        var familyName: Int? = nil

        if let os2Table = os2Table {
            if (os2Table.fsSelection & OS2Table.FSSelection.wws) != 0 {
                familyName = indexOfEnglishName(for: NameID.wwsFamily)
            }
        }
        if familyName == nil {
            familyName = indexOfEnglishName(for: NameID.typographicFamily)
        }
        if familyName == nil {
            familyName = indexOfEnglishName(for: NameID.fontFamily)
        }

        return familyName
    }

    func indexOfStyleName(considering os2Table: OS2Table?) -> Int? {
        var styleName: Int? = nil

        if let os2Table = os2Table {
            if (os2Table.fsSelection & OS2Table.FSSelection.wws) != 0 {
                styleName = indexOfEnglishName(for: NameID.wwsSubfamily)
            }
        }
        if styleName == nil {
            styleName = indexOfEnglishName(for: NameID.typographicSubfamily)
        }
        if styleName == nil {
            styleName = indexOfEnglishName(for: NameID.fontSubfamily)
        }

        return styleName
    }
}
