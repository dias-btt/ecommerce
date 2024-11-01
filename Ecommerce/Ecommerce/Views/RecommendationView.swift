//
//  RecommendationView.swift
//  Ecommerce
//
//  Created by Диас Сайынов on 01.11.2024.
//

import SwiftUI

struct RecommendationsView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        VStack {
            Text("Recommended Products")
                .font(.largeTitle)
                .padding()
            
            if viewModel.recommendedProducts.isEmpty {
                Text("No recommendations available.")
                    .padding()
            } else {
                List(viewModel.recommendedProducts) { product in
                    VStack(alignment: .leading) {
                        Text(product.name)
                            .font(.headline)
                        Text(product.description)
                            .font(.subheadline)
                        Text("Price: $\(product.price, specifier: "%.2f")")
                            .font(.footnote)
                        Text("Category: \(product.category)")
                            .font(.footnote)
                    }
                    .padding(.vertical, 5)
                }
            }
        }
        .onAppear {
            viewModel.fetchRecommendations()
        }
    }
}
