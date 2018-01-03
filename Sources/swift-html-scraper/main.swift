import Foundation
import SwiftSoup

let pageToParse = "http://www.charleswysockipuzzles.com/Wysocki/Master-Checklist.aspx"
let log = ConsoleLogger(level: .verbose)

// keep track of response handler running async
let latch = DispatchSemaphore(value: 0)
func exit(_ success: Bool) {
    if success {
        log.i("Exiting with success")
    } else {
        log.w("Exiting with error")
    }
    latch.signal()
}

// Fetch the HTML data as a string
func getHtmlResponse(then: @escaping (String) -> Void) {
    guard let url = URL(string: pageToParse) else {
        latch.signal()
        return
    }

    let request = URLRequest(url: url)
    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
        guard let data = data,
            let httpResponse = response as? HTTPURLResponse,
            error == nil,
            httpResponse.statusCode == 200,
            let responseString = String(data: data, encoding: .utf8) else {
                log.d("Error fetching Http data as a String")
                log.e("\(String(describing: error))")
                exit(false)
                return
        }

        then(responseString)
    }
    task.resume()
}

// Parse the HTML for the elements we want
func findElements(html: String, then: @escaping (Elements) -> Void) {
    do{
        let doc: Document = try SwiftSoup.parse(html)
        let divs: Elements = try doc.select("#MainContent_lblPuzzles").select("div.4u")

        then(divs)
    } catch Exception.Error(_, let message){
        log.e(message)
        exit(false)
    } catch {
        log.e("error")
        exit(false)
    }
}

// Parse the elements to Model classes
func parse(elements: Elements, then: @escaping ([Puzzle]) -> Void) {
    let models = elements.array().map { Puzzle(from: $0) }
    then(models)
}

getHtmlResponse {
    findElements(html: $0) {
//        log.d(try! $0.toString())
//        exit(true)
        parse(elements: $0) {
            log.d("\($0)")
            exit(true)
        }
    }
}

// block main thread until all our tasks are complete
latch.wait()
