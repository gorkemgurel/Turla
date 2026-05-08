//
//  PlanItem.swift
//  Seyahat
//
//  Created by Gorkem Gurel on 28.05.2025.
//


import Foundation

struct PlanItem: Identifiable, Codable {
    let id: UUID
    let category: PlanCategory
    let maxCount: Int
    let title: String
    
    init(category: PlanCategory, maxCount: Int = 1, title: String? = nil, id: UUID = UUID()) {
        self.id = id
        self.category = category
        self.maxCount = maxCount
        self.title = title ?? category.rawValue
    }
}