//
//  Review.swift
//  Seyahat
//
//  Created by Gorkem Gurel on 25.05.2025.
//

struct Review: Codable, Equatable {
    let text: String?
    let rating: Int
    let author: String
    let timeAgo: String
}
