//
//  ProductCatalogView.swift
//  Ecommerce
//
//  Created by Диас Сайынов on 01.11.2024.
//

import SwiftUI

struct ProductCatalogView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var searchText = ""
    @State private var selectedCategory: String = "All"

    var body: some View {
        NavigationView {
            VStack {
                HStack{
                    Text("Product Catalog")
                        .font(.largeTitle)
                        .padding()
                    Button(action: {
                                    viewModel.logout()
                    }) {
                        Text("Logout")
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .padding()
                }

                // Search Bar
                TextField("Search by name", text: $searchText)
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal)

                // Category Buttons
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(["All", "Electronics", "Books", "Clothing", "Home Appliances", "Sports Equipment"], id: \.self) { category in
                            Button(action: {
                                selectedCategory = category
                                viewModel.searchCategory = selectedCategory == "All" ? "" : selectedCategory
                            }) {
                                Text(category)
                                    .font(.subheadline)
                                    .padding(8)
                                    .background(selectedCategory == category ? Color.blue : Color.gray)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 10)

                // Product List
                List(filteredProducts) { product in
                    NavigationLink(destination: ProductDetailView(product: product).environmentObject(viewModel)) {
                        VStack(alignment: .leading) {
                            Text(product.name)
                                .font(.headline)
                            Text("Price: $\(product.price, specifier: "%.2f")")
                                .font(.subheadline)
                            Text("Category: \(product.category)")
                                .font(.footnote)
                        }
                        .padding(.vertical, 5)
                    }
                }
            }
            .onAppear {
                viewModel.searchName = searchText
                if viewModel.products.isEmpty {
                    viewModel.fetchProducts()
                }
            }
        }
    }

    // Filtered products based on search text and selected category
    var filteredProducts: [Product] {
        viewModel.products.filter { product in
            (searchText.isEmpty || product.name.localizedCaseInsensitiveContains(searchText)) &&
            (selectedCategory == "All" || product.category == selectedCategory)
        }
    }
}
