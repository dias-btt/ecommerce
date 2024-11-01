//
//  ContentView.swift
//  Ecommerce
//
//  Created by Диас Сайынов on 01.11.2024.

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = AuthViewModel()
    
    var body: some View {
        NavigationView { // Wrap the entire view in NavigationView
            VStack {
                if viewModel.userId == nil {
                    VStack(spacing: 20) {
                        Text("Welcome to the Ecommerce App")
                            .font(.title)
                            .padding()
                        
                        NavigationLink(destination: LoginView(viewModel: viewModel)) {
                            Text("Login")
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .padding(.horizontal)
                        
                        NavigationLink(destination: RegisterView(viewModel: viewModel)) {
                            Text("Register")
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .padding(.horizontal)
                    }
                } else {
                    TabView {
                        ProductCatalogView()
                            .tabItem {
                                Label("Catalog", systemImage: "list.dash")
                            }
                            .environmentObject(viewModel)
                        
                        RecommendationsView()
                            .tabItem {
                                Label("Recommendations", systemImage: "star.fill")
                            }
                            .environmentObject(viewModel)
                    }
                }
            }
            .environmentObject(viewModel)
        }
    }
}
