//
//  AuthViewModel.swift
//  Ecommerce
//
//  Created by Диас Сайынов on 01.11.2024.
//

import Foundation
import Combine

class AuthViewModel: ObservableObject {
    @Published var username = ""
    @Published var password = ""
    @Published var email = ""
    @Published var token: String?
    @Published var errorMessage: String?
    @Published var isAuthenticated = false
    @Published var products: [Product] = []
    @Published var searchName = ""        // Search parameter for name
    @Published var searchCategory = ""
    @Published var userId: String?
    @Published var recommendedProducts: [Product] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    func register(user: User) {
        print("registering \(user)")
        NetworkService.shared.register(user: user)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    self.errorMessage = error.localizedDescription
                    print("Login error:", error.localizedDescription)
                }
            }, receiveValue: { userId in
                self.userId = userId
                self.isAuthenticated = true
                print("Registered with userId:", userId)
            })
            .store(in: &cancellables)
    }
        
    func login(user: User) {
        NetworkService.shared.login(user: user)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    self.errorMessage = error.localizedDescription
                    print("Login error:", error.localizedDescription)
                }
            }, receiveValue: { (userId, token) in
                self.userId = userId // Store the userId
                self.token = token
                self.isAuthenticated = true
                print("Logged in with userId:", userId)
            })
            .store(in: &cancellables)
    }
    
    func logout() {
        NetworkService.shared.logout()
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    self.errorMessage = error.localizedDescription
                    print("Logout error:", error.localizedDescription)
                }
            }, receiveValue: {
                self.userId = nil
                self.token = nil
                self.isAuthenticated = false
                self.products.removeAll()
                print("User logged out successfully")
            })
            .store(in: &cancellables)
    }
    
    func fetchProducts() {
        NetworkService.shared.fetchProducts(name: searchName, category: searchCategory)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    self.errorMessage = error.localizedDescription
                    print("Error fetching products: \(error.localizedDescription)")
                }
            }, receiveValue: { products in
                self.products = products
            })
            .store(in: &cancellables)
    }
    
    func logInteraction(productId: String, interactionType: String) {
        NetworkService.shared.logInteraction(userId: userId ?? "", productId: productId, interactionType: interactionType)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Failed to log interaction:", error.localizedDescription)
                }
            }, receiveValue: {
                print("Interaction logged:", interactionType)
            })
            .store(in: &cancellables)
    }
    
    // Fetch recommended products
    func fetchRecommendations() {
        guard let userId = userId else {
            print("User ID is nil, cannot fetch recommendations.")
            return
        }
        
        NetworkService.shared.fetchRecommendations(for: userId)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Error fetching recommendations:", error.localizedDescription)
                }
            }, receiveValue: { [weak self] products in
                self?.recommendedProducts = products
                print("Fetched \(products.count) recommended products.")
            })
            .store(in: &cancellables)
    }

}

