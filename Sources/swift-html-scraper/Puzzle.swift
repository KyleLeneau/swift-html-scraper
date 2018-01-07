//
//  Puzzle.swift
//  swift-html-scraper
//
//  Created by Kyle LeNeau on 1/3/18.
//

import Foundation
import SwiftSoup

struct Puzzle: Codable {
    let collection: String
    let title: String

    let series: Int
    let number: Int

    let notes: String

    let thumbnail: String
    let largeImage: String
}

// HTML Element parsing
extension Puzzle {
    init(from element: Element) {
        if let img = try! element.select("img").first() {
            let images = Puzzle.parseImages(baseUrl: "http://www.charleswysockipuzzles.com/Wysocki/", element: img)
            self.thumbnail = images.thumbnail
            self.largeImage = images.largeImage

            let titleCollection = Puzzle.parseTitleCollection(element: img)
            self.title = titleCollection.title
            self.collection = titleCollection.collection
        } else {
            self.thumbnail = ""
            self.largeImage = ""
            self.title = ""
            self.collection = ""
        }

        if let font = try! element.select("div > font").first() {
            let seriesInfo = Puzzle.parseSeriesInfo(element: font)
            self.series = seriesInfo.series
            self.number = seriesInfo.number
        } else {
            self.series = -1
            self.number = -1
        }

        if let notes = try! element.select("td > font").first() {
            self.notes = try! notes.text().replacingOccurrences(of: "Notes:  ", with: "")
        } else {
            self.notes = ""
        }
    }

    static func parseImages(baseUrl: String, element: Element) -> (thumbnail: String, largeImage: String) {
        do {
            let src = try element.attr("src")
            if !src.isEmpty {
                let largeImage = src.replacingOccurrences(of: "-150.", with: "-300.")
                return (baseUrl + src, baseUrl + largeImage)
            }
        } catch _ {
        }
        return ("", "")
    }

    static func parseTitleCollection(element: Element) -> (title: String, collection: String) {
        do {
            let alt = try element.attr("alt")
            if !alt.isEmpty, let parts = alt.range(of: " - ") {
                let title = alt.prefix(upTo: parts.lowerBound)
                let collection = alt.suffix(from: parts.upperBound)
                return (String(title), String(collection))
            }
        } catch _ {
        }
        return ("", "")
    }

    static func parseSeriesInfo(element: Element) -> (series: Int, number: Int) {
        let pattern = "\\.*(\\d+)\\s*#(\\d+)"
        do {
            let text = try element.text()
            let groups = text.capturedGroups(withRegex: pattern)
            let series = Int(groups.first ?? "") ?? -1
            let number = Int(groups.last ?? "") ?? -1
            return (series, number)
        } catch _ {
        }
        return (-1, -1)
    }
}


extension String {
    func capturedGroups(withRegex pattern: String) -> [String] {
        var results = [String]()

        var regex: NSRegularExpression
        do {
            regex = try NSRegularExpression(pattern: pattern, options: [])
        } catch {
            return results
        }

        let matches = regex.matches(in: self, options: [], range: NSRange(location:0, length: self.count))

        guard let match = matches.first else { return results }
        let lastRangeIndex = match.numberOfRanges - 1
        guard lastRangeIndex >= 1 else { return results }

        for i in 1...lastRangeIndex {
            let matchGroup = match.range(at: i)
            let lowerBound = index(startIndex, offsetBy: matchGroup.lowerBound)
            let upperBound = index(startIndex, offsetBy: matchGroup.upperBound)
            let result = String(self[lowerBound..<upperBound])
            results.append(result)
        }

        return results
    }
}
