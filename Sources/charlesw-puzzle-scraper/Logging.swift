//
//  Logging.swift
//  charlesw-puzzle-scraper
//
//  Created by Kyle LeNeau on 1/3/18.
//

import Foundation

enum LogLevel: Int {
    case none = 0, error = 1, warn = 2, info = 3, debug = 4, verbose = 5

    var prefix: String {
        return "[\(String(describing: self))]".uppercased()
    }
}

protocol Logger {
    var logLevel: LogLevel { get set }

    func v(_ message: String)
    func d(_ message: String)
    func i(_ message: String)
    func w(_ message: String)
    func e(_ message: String)

    func log(level: LogLevel, message: String)
}

extension Logger {
    func v(_ message: String) {
        log(level: .verbose, message: message)
    }

    func d(_ message: String) {
        log(level: .debug, message: message)
    }

    func i(_ message: String) {
        log(level: .info, message: message)
    }

    func w(_ message: String) {
        log(level: .warn, message: message)
    }

    func e(_ message: String) {
        log(level: .error, message: message)
    }
}

class ConsoleLogger: Logger {

    var logLevel: LogLevel
    init(level: LogLevel = .none) {
        self.logLevel = level
    }

    func log(level: LogLevel, message: String) {
        if level.rawValue <= logLevel.rawValue {
            print("\(level.prefix): \(message)")
        }
    }
}
