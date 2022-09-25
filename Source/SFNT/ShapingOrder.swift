//
// Copyright (C) 2019 Muhammad Tayyab Akram
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

/// Specifies the order in which the text is shaped.
public enum ShapingOrder: Int {
    /// Text is shaped in forward order starting from first index (inclusive) to last index
    /// (exclusive).
    case forward = 0
    /// Text is shaped in backward order starting from last index (exclusive) to first index
    /// (inclusive).
    case backward = 1
}
