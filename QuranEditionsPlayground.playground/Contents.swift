import Cocoa
import Foundation

extension String {
    func matches(_ regex: String) -> Bool {
        return self.range(of: regex, options: .regularExpression, range: nil, locale: nil) != nil
    }
}



let editionsPath = "/Users/standard/Quran/data/editions"
let editionsListPath = "/Users/standard/Quran/data/editions.json"


let fileManager = FileManager.default
let enumerator:FileManager.DirectoryEnumerator = fileManager.enumerator(atPath: editionsPath)!


let langs = ["eng",
             "ukr", "rus", "zho"].joined(separator: "|")
let translationRegex = String(format: "^(%@)(?!.*?lad?\\.min\\.json)", langs)
let arabicRegex = "^ara.*\\.min\\.json"
let sura = 2
let ayat = 48

var editions: [String] = []

while let file = enumerator.nextObject() as? String {
    if file.matches(translationRegex) || file.matches(arabicRegex) {
//        print(file)
        editions += [URL(string: editionsPath)!.appendingPathComponent(file).absoluteString]
    }
}
editions.sort()

//print(editions)



struct Edition: Codable,  CustomStringConvertible {
    enum Direction: String, Codable {
        case ltr, rtl
    }
    let name: String
    let author: String
    let language: String
    let direction: Direction
    let comments: String
    let source: String
    let link: String
    let linkmin: String
    
    var description : String {
        return "[\(language)] \(author) <\(name)> \(comments)"
    }

}


struct Quran: Codable, CustomStringConvertible {
    var quran: [Ayat]
    var description : String {
        return "\(String(describing: quran.first)) .. \(String(describing: quran.last)) (\(quran.count) total)"
    }
}

struct Ayat: Codable, CustomStringConvertible {

    let chapter: Int
    let verse: Int
    let text: String
    
    var description : String {
        return "(\(chapter), \(verse)) \(text)"
    }

}


let data = try Data(contentsOf: URL(fileURLWithPath: editionsListPath))
let decoder = JSONDecoder()

let editionsRegistry = try! decoder.decode([String: Edition].self, from: data)

func editionsBy(name:String) -> Edition? {
    for (_, edition) in editionsRegistry {
        if edition.name == name {
            return edition
        }
    }
    return nil
}


for editionPath in editions {
    let data = try Data(contentsOf: URL(fileURLWithPath: editionPath))
    let decoder = JSONDecoder()

    if let q = try? decoder.decode(Quran.self, from: data) {
        let editionId = URL(fileURLWithPath: editionPath).deletingPathExtension().deletingPathExtension().lastPathComponent
        print("\(editionsBy(name:editionId)!)")
        print(q.quran[48])
    }

}
