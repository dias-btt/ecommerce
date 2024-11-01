//
//  Productr.swift
//  Ecommerce
//
//  Created by Диас Сайынов on 01.11.2024.
//

import Foundation

struct Product: Codable, Identifiable {
    var id: String
    var name: String
    var description: String
    var category: String
    var price: Double
    var attributes: [String: String]?
    var createdAt: String?  // Optional, as they may not be used
    var updatedAt: String?
    
    // Map `_id` to `id` for decoding
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
        case description
        case category
        case price
        case attributes
        case createdAt
        case updatedAt
    }
}
