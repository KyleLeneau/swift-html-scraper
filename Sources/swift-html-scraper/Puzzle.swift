//
//  Puzzle.swift
//  swift-html-scraper
//
//  Created by Kyle LeNeau on 1/3/18.
//

import Foundation
import SwiftSoup

struct Puzzle {
    var collection: String?
    var series: String?

    var title: String?
    var thumbnail: String?
    var notes: String?
}

extension Puzzle {
    init(from element: Element) {
        if let img = try! element.select("img").first() {
            self.thumbnail = try! img.attr("src")
            self.collection = try! img.attr("alt")
        }
    }
}
