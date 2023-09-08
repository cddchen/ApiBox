import Foundation
import Combine

class ApiModel: ObservableObject {
    @Published var request = Request()

    func makeAPICall() {
        // Implement your API call logic here
        // You can use jsonData to pass the data in the API request
    }
}

struct LogData: Codable {
    let log: Log
}

struct Log: Codable {
    let entries: [Entry]
}

struct Entry: Codable {
    let request: Request
}

struct StoredRequest: Identifiable, Encodable, Decodable {
    let id = UUID()
    let name: String
    let request: Request
    
    init(request: Request, name: String) {
        self.name = name
        self.request = request
    }
}

struct Request: Codable {
    let method: String
    let bodySize: Int
    let headersSize: Int
    let postData: PostData?
    let cookies: [Cookie]
    let headers: [Header]
    let queryString: [QueryParameter]
    let httpVersion: String
    let url: String
    
    init() {
        method = ""
        bodySize = 0
        headersSize = 0
        postData = nil
        cookies = []
        headers = []
        queryString = []
        httpVersion = ""
        url = ""
    }
}

struct PostData: Codable {
    let params: [String]
    let text: String
    let mimeType: String
}

struct Cookie: Codable {
    let name: String
    let value: String
}

struct Header: Codable, Hashable {
    let name: String
    let value: String
}

struct QueryParameter: Codable {
    let name: String
    let value: String
}
