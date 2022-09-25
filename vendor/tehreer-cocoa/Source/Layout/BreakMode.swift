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

/// Specifies the text break mode.
public enum BreakMode: Int {
    /// Breaks the text at a suitable opportunity as determined by the Unicode Line Breaking
    /// Algorithm.
    case character = 0
    /// Breaks the text at a grapheme cluster boundary.
    case line = 1
}
