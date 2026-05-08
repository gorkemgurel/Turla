//
//  AIRecommendationEngine.swift
//  Seyahat
//
//  Created by Gorkem Gurel on 29.05.2025.
//

import Foundation

class AIRecommendationEngine: ObservableObject {
    
    struct UserPreferenceProfile: Codable {
        var preferredPriceRange: ClosedRange<Int> = 1...3
        var minRatingThreshold: Double = 3.5
        var reviewCountImportance: Double = 0.3
        var ratingImportance: Double = 0.4
        var priceImportance: Double = 0.3
        
        // Kullanıcının beğenmediği sebepler - String key kullanarak
        var dislikedReasons: [String: Int] = [:]
        var totalInteractions: Int = 0
        
        // Custom encoding/decoding for ClosedRange
        enum CodingKeys: String, CodingKey {
            case preferredPriceRangeLower, preferredPriceRangeUpper
            case minRatingThreshold, reviewCountImportance, ratingImportance, priceImportance
            case dislikedReasons, totalInteractions
        }
        
        init() {}
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            let lowerBound = try container.decode(Int.self, forKey: .preferredPriceRangeLower)
            let upperBound = try container.decode(Int.self, forKey: .preferredPriceRangeUpper)
            preferredPriceRange = lowerBound...upperBound
            
            minRatingThreshold = try container.decode(Double.self, forKey: .minRatingThreshold)
            reviewCountImportance = try container.decode(Double.self, forKey: .reviewCountImportance)
            ratingImportance = try container.decode(Double.self, forKey: .ratingImportance)
            priceImportance = try container.decode(Double.self, forKey: .priceImportance)
            dislikedReasons = try container.decode([String: Int].self, forKey: .dislikedReasons)
            totalInteractions = try container.decode(Int.self, forKey: .totalInteractions)
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            
            try container.encode(preferredPriceRange.lowerBound, forKey: .preferredPriceRangeLower)
            try container.encode(preferredPriceRange.upperBound, forKey: .preferredPriceRangeUpper)
            try container.encode(minRatingThreshold, forKey: .minRatingThreshold)
            try container.encode(reviewCountImportance, forKey: .reviewCountImportance)
            try container.encode(ratingImportance, forKey: .ratingImportance)
            try container.encode(priceImportance, forKey: .priceImportance)
            try container.encode(dislikedReasons, forKey: .dislikedReasons)
            try container.encode(totalInteractions, forKey: .totalInteractions)
        }
    }
    
    @Published var userProfile = UserPreferenceProfile()
    private let userDefaults = UserDefaults.standard
    
    init() {
        loadUserProfile()
    }
    
    func calculateAIScore(for place: Place) -> Double {
        var score: Double = 0
        
        // 1. Rating Score (0-35 puan)
        let ratingScore = (place.rating ?? 3.0) / 5.0 * 35 * userProfile.ratingImportance
        score += ratingScore
        
        // 2. Popularity Score (0-25 puan) - Logaritmik ölçek
        let reviewCount = Double(place.userRatingCount ?? 1)
        let popularityScore = min(log10(reviewCount + 1) / log10(1001), 1.0) * 25 * userProfile.reviewCountImportance
        score += popularityScore
        
        // 3. Price Preference Score (0-25 puan)
        let priceScore = calculatePriceScore(place.priceLevel)
        score += priceScore * userProfile.priceImportance
        
        // 4. User Learning Bonus (0-15 puan)
        let learningBonus = calculateLearningBonus(for: place)
        score += learningBonus
        
        // 5. Quality Bonus - Yüksek puanlı az yorumlu yerler için
        if let rating = place.rating, rating >= 4.5 && (place.userRatingCount ?? 0) < 50 {
            score += 5 // Hidden gem bonus
        }
        
        return min(score, 100) // Max 100 puan
    }
    
    private func calculatePriceScore(_ priceLevel: Int?) -> Double {
        guard let price = priceLevel else { return 15 } // Neutral skor
        
        if userProfile.preferredPriceRange.contains(price) {
            return 25
        } else if price == userProfile.preferredPriceRange.lowerBound - 1 ||
                  price == userProfile.preferredPriceRange.upperBound + 1 {
            return 15
        } else {
            return 5
        }
    }
    
    private func calculateLearningBonus(for place: Place) -> Double {
        var bonus: Double = 10 // Base bonus
        
        // Pahalı diye beğenmemişse, ucuz yerleri tercih et
        if let expensiveCount = userProfile.dislikedReasons["tooExpensive"],
           expensiveCount > 2 {
            if (place.priceLevel ?? 3) <= 2 {
                bonus += 3
            }
        }
        
        // Düşük puanlı diye beğenmemişse, yüksek puanlı yerleri tercih et
        if let ratingCount = userProfile.dislikedReasons["badRating"],
           ratingCount > 1 {
            if (place.rating ?? 0) >= 4.2 {
                bonus += 2
            }
        }
        
        // Uzak diye beğenmemişse, popüler yerleri tercih et (merkezi yerler)
        if let farCount = userProfile.dislikedReasons["tooFar"],
           farCount > 2 {
            if (place.userRatingCount ?? 0) > 100 {
                bonus += 2
            }
        }
        
        return min(bonus, 15)
    }
    
    // Kullanıcı etkileşimini öğren
    func recordUserInteraction(place: Place, wasLiked: Bool, dislikeReason: DislikeReason? = nil) {
        userProfile.totalInteractions += 1
        
        if wasLiked {
            // Beğenilen yerden öğren
            adaptToLikedPlace(place)
        } else if let reason = dislikeReason {
            // Beğenilmeyenlerden öğren
            let reasonKey = reasonToString(reason)
            userProfile.dislikedReasons[reasonKey, default: 0] += 1
            adaptToDislikedPlace(place, reason: reason)
        }
        
        saveUserProfile()
    }
    
    // DislikeReason'ı String'e çevir
    private func reasonToString(_ reason: DislikeReason) -> String {
        switch reason {
        case .tooFar:
            return "tooFar"
        case .tooExpensive:
            return "tooExpensive"
        case .badRating:
            return "badRating"
        case .general:
            return "general"
        }
    }
    
    private func adaptToLikedPlace(_ place: Place) {
        // Fiyat tercihini ayarla
        if let priceLevel = place.priceLevel {
            let currentRange = userProfile.preferredPriceRange
            let newLower = min(currentRange.lowerBound, priceLevel)
            let newUpper = max(currentRange.upperBound, priceLevel)
            userProfile.preferredPriceRange = newLower...newUpper
        }
        
        // Rating threshold'u ayarla
        if let rating = place.rating {
            userProfile.minRatingThreshold = (userProfile.minRatingThreshold * 0.8) + (rating * 0.2)
        }
    }
    
    private func adaptToDislikedPlace(_ place: Place, reason: DislikeReason) {
        // Ağırlıkları dinamik olarak ayarla
        switch reason {
        case .tooExpensive:
            userProfile.priceImportance = min(0.5, userProfile.priceImportance + 0.03)
            if let priceLevel = place.priceLevel, priceLevel > 1 {
                userProfile.preferredPriceRange = 1...(priceLevel - 1)
            }
        case .badRating:
            userProfile.ratingImportance = min(0.6, userProfile.ratingImportance + 0.05)
            if let rating = place.rating {
                userProfile.minRatingThreshold = max(userProfile.minRatingThreshold, rating + 0.3)
            }
        case .tooFar:
            userProfile.reviewCountImportance = min(0.4, userProfile.reviewCountImportance + 0.03)
        case .general:
            // Genel beğenmeme - tüm faktörleri hafifçe ayarla
            break
        }
        
        // Toplamın 1.0 olmasını sağla
        normalizeImportanceWeights()
    }
    
    private func normalizeImportanceWeights() {
        let total = userProfile.ratingImportance + userProfile.reviewCountImportance + userProfile.priceImportance
        if total > 0 {
            userProfile.ratingImportance /= total
            userProfile.reviewCountImportance /= total
            userProfile.priceImportance /= total
        }
    }
    
    // Kullanıcı profilini kaydet/yükle
    private func saveUserProfile() {
        if let encoded = try? JSONEncoder().encode(userProfile) {
            userDefaults.set(encoded, forKey: "AIUserProfile")
        }
    }
    
    private func loadUserProfile() {
        if let data = userDefaults.data(forKey: "AIUserProfile"),
           let decoded = try? JSONDecoder().decode(UserPreferenceProfile.self, from: data) {
            userProfile = decoded
        }
    }
}
