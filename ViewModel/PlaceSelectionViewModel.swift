//
//  PlaceSelectionViewModel.swift
//  Seyahat
//
//  Created by Gorkem Gurel on 29.05.2025.
//

import Foundation

class PlaceSelectionViewModel: ObservableObject {
    @Published var selectedSortOption: PlaceSortOption = .reviewCountDescending {
        didSet {
            updateSortedPlaces()
        }
    }
    @Published var sortedPlaces: [Place] = []
    
    private let availablePlaces: [Place]
    private let excludedPlaceNames: Set<String>
    private let aiEngine: AIRecommendationEngine?
    
    init(availablePlaces: [Place], excludedPlaceNames: Set<String> = [], aiEngine: AIRecommendationEngine? = nil) {
        self.availablePlaces = availablePlaces
        self.excludedPlaceNames = excludedPlaceNames
        self.aiEngine = aiEngine
        updateSortedPlaces()
    }
    
    private func updateSortedPlaces() {
        let filteredPlaces = availablePlaces.filter { place in
            !excludedPlaceNames.contains(place.name)
        }
        
        sortedPlaces = sortPlaces(filteredPlaces, by: selectedSortOption)
    }
    
    private func sortPlaces(_ places: [Place], by option: PlaceSortOption) -> [Place] {
        switch option {
        case .reviewCountDescending:
            return places.sorted { ($0.userRatingCount ?? 0) > ($1.userRatingCount ?? 0) }
        case .ratingDescending:
            return places.sorted { ($0.rating ?? 0) > ($1.rating ?? 0) }
        case .nameAscending:
            return places.sorted { $0.displayName.localizedCaseInsensitiveCompare($1.displayName) == .orderedAscending }
        case .priceLevelAscending:
            return places.sorted {
                let price0 = $0.priceLevel ?? Int.max
                let price1 = $1.priceLevel ?? Int.max
                if price0 != price1 {
                    return price0 < price1
                }
                return ($0.rating ?? 0.0) > ($1.rating ?? 0.0)
            }
        case .aiRecommended:
            guard let aiEngine = aiEngine else {
                // AI Engine yoksa rating'e göre sırala
                return places.sorted { ($0.rating ?? 0) > ($1.rating ?? 0) }
            }
            return places.sorted { place1, place2 in
                let score1 = aiEngine.calculateAIScore(for: place1)
                let score2 = aiEngine.calculateAIScore(for: place2)
                return score1 > score2
            }
        }
    }
}
