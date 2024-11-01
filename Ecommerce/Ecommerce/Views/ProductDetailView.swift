//
//  ProductDetailView.swift
//  Ecommerce
//
//  Created by Диас Сайынов on 01.11.2024.
//

import SwiftUI

struct ProductDetailView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    var product: Product
    
    var body: some View {
        VStack(spacing: 20) {
            Text(product.name)
                .font(.largeTitle)
                .padding()
            
            Text(product.description)
                .font(.body)
                .padding()
            
            Text("Price: $\(product.price, specifier: "%.2f")")
                .font(.headline)
            
            Button("Buy") {
                viewModel.logInteraction(productId: product.id, interactionType: "purchase")
                // Additional buy logic can be implemented here
            }
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(8)
            
            Button("Like") {
                viewModel.logInteraction(productId: product.id, interactionType: "like")
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .onAppear {
            viewModel.logInteraction(productId: product.id, interactionType: "view")
        }
    }
}
