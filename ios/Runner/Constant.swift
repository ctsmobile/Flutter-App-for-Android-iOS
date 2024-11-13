//
//  Constant.swift
//  Runner
//
//  Created by Mayank Tyagi on 25/01/24.
//

import Foundation

struct BaseUrl {
    static let getLocation = "http://54.82.200.45:8082/api/v1/employee/checkLocation"
}


enum AlbumsFetcherError: Error {
    case invalidURL
    case missingData
}


enum httpError : Error {
    case nonSuccessStatusCode
}

class Singleton {
    static let shared = Singleton()
    func performOperation<T:Decodable>(token: String,latitude: String,longitude: String,requestUrl: String, response: T.Type) async throws -> T{
        let latitudeData = 28.626640
        let longitudeData = 77.384804
        guard let url = URL(string:requestUrl) else {
            throw AlbumsFetcherError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        //  request.allHTTPHeaderFields = ["Content-Type":"application/json", "token": "eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiI1S3VqdTAwTlJnS1p6cUFXT1B6ZjBRQUFBQUFBQUFBQUFBQUFBQUFBQUFBMTcwNjE3MzgzNzY3MiIsImlhdCI6MTcwNjE3MzgzNywiZXhwIjoxNzA2MzQ2NjM3fQ.2_S0A1gd2oqkY9u1RtD6yTHK7Gf6WC53aZQJYCoiH5h3z1cFo3i-jXo1KRxMijll_186qVZpfDc2U9qIQ8489g","latitude":"28.613939","longitude":"77.209023"]
        // Set headers
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.addValue("eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiI1S3VqdTAwTlJnS1p6cUFXT1B6ZjBRQUFBQUFBQUFBQUFBQUFBQUFBQUFBMTcwNjE3MzgzNzY3MiIsImlhdCI6MTcwNjE3MzgzNywiZXhwIjoxNzA2MzQ2NjM3fQ.2_S0A1gd2oqkY9u1RtD6yTHK7Gf6WC53aZQJYCoiH5h3z1cFo3i-jXo1KRxMijll_186qVZpfDc2U9qIQ8489g", forHTTPHeaderField: "token") // Example for sending an authorization token
//        request.addValue("28.613939", forHTTPHeaderField: "latitude") // Example for sending an authorization token
//        request.addValue("77.209023", forHTTPHeaderField: "longitude")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(token, forHTTPHeaderField: "token") // Example for sending an authorization token
        request.addValue(latitude, forHTTPHeaderField: "latitude") // Example for sending an authorization token
        request.addValue(longitude, forHTTPHeaderField: "longitude") // Example for sending an authorization token
        
        do {
            let (serverData, serverUrlResponse) = try await URLSession.shared.data(for:request)
            guard let httpStausCode = (serverUrlResponse as? HTTPURLResponse)?.statusCode,
                  (200...599).contains(httpStausCode) else {
                throw httpError.nonSuccessStatusCode
            }
            
            return try JSONDecoder().decode(response.self, from: serverData)
        } catch  {
            throw error
        }
    }
    
    
}
struct LocationModel: Codable {
    let actionRequired: String?
    let message: String?
    let frontendMessage: String?
}
