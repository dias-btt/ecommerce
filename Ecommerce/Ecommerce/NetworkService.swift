//
//  NetworkService.swift
//  Ecommerce
//
//  Created by Диас Сайынов on 01.11.2024.
//

import Foundation
import Combine

class NetworkService {
    static let shared = NetworkService()
    private let baseURL = "http://localhost:5001/api"

    private init() {}
    
    func register(user: User) -> AnyPublisher<String, Error> {
        guard let url = URL(string: "\(baseURL)/auth/register") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(user)
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { result in
                if let httpResponse = result.response as? HTTPURLResponse {
                    print("HTTP Status Code:", httpResponse.statusCode)
                }
                if let jsonString = String(data: result.data, encoding: .utf8) {
                    print("Raw JSON response:", jsonString)
                }
                
                let response = try JSONDecoder().decode([String: String].self, from: result.data)
                guard let userId = response["userId"] else {
                    throw URLError(.badServerResponse)
                }
                return userId
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    // Login function to capture userId
    func login(user: User) -> AnyPublisher<(String, String), Error> {
        guard let url = URL(string: "\(baseURL)/auth/login") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(user)
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { result in
                let response = try JSONDecoder().decode([String: String].self, from: result.data)
                guard let token = response["token"], let userId = response["userId"] else {
                    throw URLError(.badServerResponse)
                }
                return (userId, token) // Return userId and token
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func logout() -> AnyPublisher<Void, Error> {
        guard let url = URL(string: "\(baseURL)/auth/logout") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map { _ in () } // Ignore the response
            .mapError { $0 as Error } // Convert URLError to a more general Error type
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    // Fetch Products
    func fetchProducts(name: String? = nil, category: String? = nil) -> AnyPublisher<[Product], Error> {
        var components = URLComponents(string: "\(baseURL)/products")!
        
        // Add query items for name and category if provided
        var queryItems = [URLQueryItem]()
        if let name = name, !name.isEmpty {
            queryItems.append(URLQueryItem(name: "name", value: name))
        }
        if let category = category, !category.isEmpty {
            queryItems.append(URLQueryItem(name: "category", value: category))
        }
        components.queryItems = queryItems

        // Debugging print to verify the URL
        print("Fetching products with URL: \(components.url?.absoluteString ?? "Invalid URL")")
        
        return URLSession.shared.dataTaskPublisher(for: components.url!)
            .map { $0.data }
            .decode(type: [Product].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    // Log Interaction
    func logInteraction(userId: String, productId: String, interactionType: String) -> AnyPublisher<Void, Error> {
        guard let url = URL(string: "\(baseURL)/interactions") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "userId": userId,
            "productId": productId,
            "interactionType": interactionType
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map { _ in () } // Ignore the response
            .mapError { $0 as Error } // Convert URLError to generic Error
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    // Fetch recommended products for a user
    func fetchRecommendations(for userId: String) -> AnyPublisher<[Product], Error> {
        guard let url = URL(string: "\(baseURL)/products/recommendations/\(userId)") else {
            print("Invalid URL")
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        print("Fetching recommendations for userId: \(userId)")
        print("URL: \(url.absoluteString)")
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { result -> Data in
                if let httpResponse = result.response as? HTTPURLResponse {
                    print("Received HTTP status code: \(httpResponse.statusCode)")
                }
                print("Received data: \(String(data: result.data, encoding: .utf8) ?? "No data")")
                return result.data
            }
            .decode(type: [Product].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveOutput: { products in
                print("Fetched \(products.count) recommended products.")
            }, receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    print("Error decoding recommendations:", error.localizedDescription)
                case .finished:
                    print("Finished fetching recommendations successfully.")
                }
            })
            .eraseToAnyPublisher()
    }

}
