//
// Copyright (C) 2020 Muhammad Tayyab Akram
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

/// Specifies the text truncation place.
public enum TruncationPlace: Int {
    /// Text is truncated at the start of the line.
    case start = 0
    /// Text is truncated at the middle of the line.
    case middle = 1
    /// Text is truncated at the end of the line.
    case end = 2
}
