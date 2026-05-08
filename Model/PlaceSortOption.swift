//
//  PlaceSortOption.swift
//  Seyahat
//
//  Created by Gorkem Gurel on 28.05.2025.
//

import Foundation

enum PlaceSortOption: String, CaseIterable, Identifiable {
    case aiRecommended = "AI Önerisi 🤖"
    case reviewCountDescending = "Yorum Sayısına Göre"
    case ratingDescending = "Puanına Göre"
    case nameAscending = "İsme Göre (A-Z)"
    case priceLevelAscending = "Fiyata Göre (Ucuzdan Pahalıya)"
    
    var id: String { self.rawValue }
}
