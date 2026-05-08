//
//  PlanCategory.swift
//  Seyahat
//
//  Created by Gorkem Gurel on 28.05.2025.
//

import Foundation

enum PlanCategory: String, CaseIterable, Identifiable, Codable {
    case breakfast = "Kahvaltı"
    case attraction = "Gezilecek Yer"
    case cafe = "Kafe"
    case dinner = "Akşam Yemeği"
    case dessert = "Tatlıcı"
    
    var id: String { self.rawValue }
    
    var districtCategoryIndex: Int {
        switch self {
        case .breakfast: return 0
        case .dessert: return 1
        case .dinner: return 2
        case .cafe: return 3
        case .attraction: return 4
        }
    }
    
    var excludedWords: [String] {
        switch self {
        case .breakfast:
            return ["pide", "kebap", "piknik", "restaurant", "otel", "köfte", "çöp", "yoğurt", "kömür"]
        case .dessert:
            return ["pide", "park", "yeri", "kebap", "çorba", "lokanta", "outlet", "yoğurt", "restaurant"]
        case .dinner:
            return []
        case .cafe:
            return ["piknik", "pide", "dondurma", "apart", "evi", "park", "fast food", "yeri", "köfte", "müze"]
        case .attraction:
            return ["köfte", "otogar", "pide", "cafe"]
        }
    }
}
