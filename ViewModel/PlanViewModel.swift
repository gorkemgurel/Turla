//
//  PlanViewModel.swift
//  Seyahat
//
//  Created by Gorkem Gurel on 25.05.2025.
//

import Foundation
import CoreLocation

class PlanViewModel: ObservableObject {
    var district: District
    
    private var _filteredPlacesByCategory: [PlanCategory: [Place]] = [:]
    
    @Published var selectedSortOption: PlaceSortOption = .reviewCountDescending
    @Published var currentPlanConfiguration: PlanConfiguration = .defaultPlan
    @Published var planAdvices: [UUID: [Place]] = [:]
    @Published var aiEngine = AIRecommendationEngine()
    
    private var _sessionDislikedAndActivePlaceNames: Set<String> = []
    private let turkishLocale = Locale(identifier: "tr_TR")

    init(district: District, planConfiguration: PlanConfiguration = .defaultPlan) {
        self.district = district
        self.currentPlanConfiguration = planConfiguration
        setupFilteredPlaces()
        
        // Eğer kayıtlı seçilmiş yerler varsa onları yükle, yoksa yeni öneriler oluştur
        loadSelectedPlacesFromConfiguration()
        if planAdvices.isEmpty {
            generateInitialAdvices()
        }
    }
    
    // Seçilmiş yerleri senkronize etme metodları
    func syncPlanAdvicesToConfiguration() {
        for (planItemId, places) in planAdvices {
            currentPlanConfiguration.updateSelectedPlaces(for: planItemId, places: places)
        }
    }
    
    func loadSelectedPlacesFromConfiguration() {
        for item in currentPlanConfiguration.items {
            if let savedPlaces = currentPlanConfiguration.getSelectedPlaces(for: item.id) {
                planAdvices[item.id] = savedPlaces
                // Kayıtlı yerleri session disliked listesine ekle
                for place in savedPlaces {
                    _sessionDislikedAndActivePlaceNames.insert(place.name)
                }
            }
        }
    }
    
    // Mekan değiştirme metodu
    func replacePlace(originalPlace: Place, newPlace: Place, planItemId: UUID) {
        guard var currentAdvices = planAdvices[planItemId] else { return }
        
        // Eski mekanı listeden çıkar
        if let index = currentAdvices.firstIndex(where: { $0.name == originalPlace.name }) {
            currentAdvices[index] = newPlace
            planAdvices[planItemId] = currentAdvices
            
            // Session tracking'i güncelle
            _sessionDislikedAndActivePlaceNames.remove(originalPlace.name)
            _sessionDislikedAndActivePlaceNames.insert(newPlace.name)
            
            // Otomatik sync
            autoSyncConfiguration()
        }
    }
    
    // Mesafe hesaplama fonksiyonları
    func calculateDistance(from source: Place, to destination: Place) -> CLLocationDistance {
        let sourceLocation = CLLocation(
            latitude: source.location.latitude,
            longitude: source.location.longitude
        )
        let destinationLocation = CLLocation(
            latitude: destination.location.latitude,
            longitude: destination.location.longitude
        )
        
        return sourceLocation.distance(from: destinationLocation)
    }
    
    func formatDistance(_ distance: CLLocationDistance) -> String {
        if distance < 1000 {
            return String(format: "%.0f m", distance)
        } else {
            return String(format: "%.1f km", distance / 1000)
        }
    }
    
    func estimateWalkingTime(_ distance: CLLocationDistance) -> String {
        let walkingSpeedKmH = 5.0
        let walkingSpeedMs = walkingSpeedKmH * 1000 / 3600
        let timeInSeconds = distance / walkingSpeedMs
        
        if timeInSeconds < 60 {
            return "< 1 dk"
        } else if timeInSeconds < 3600 {
            let minutes = Int(timeInSeconds / 60)
            return "\(minutes) dk"
        } else {
            let hours = Int(timeInSeconds / 3600)
            let minutes = Int((timeInSeconds.truncatingRemainder(dividingBy: 3600)) / 60)
            return "\(hours)s \(minutes)dk"
        }
    }
    
    func estimateDrivingTime(_ distance: CLLocationDistance) -> String {
        let drivingSpeedKmH = 30.0
        let drivingSpeedMs = drivingSpeedKmH * 1000 / 3600
        let timeInSeconds = distance / drivingSpeedMs
        
        if timeInSeconds < 60 {
            return "< 1 dk"
        } else if timeInSeconds < 3600 {
            let minutes = Int(timeInSeconds / 60)
            return "\(minutes) dk"
        } else {
            let hours = Int(timeInSeconds / 3600)
            let minutes = Int((timeInSeconds.truncatingRemainder(dividingBy: 3600)) / 60)
            return "\(hours)s \(minutes)dk"
        }
    }
    
    private func setupFilteredPlaces() {
        _filteredPlacesByCategory.removeAll()
        
        let usedCategories = Set(currentPlanConfiguration.items.map { $0.category })
        
        for category in usedCategories {
            let places = district.categories[category.districtCategoryIndex].places
            _filteredPlacesByCategory[category] = filterPlaces(
                places,
                excludeNamesContaining: category.excludedWords,
                locale: turkishLocale
            )
        }
    }
    
    func filterPlaces(_ places: [Place], excludeNamesContaining forbiddenWords: [String], locale: Locale) -> [Place] {
        return places.filter { place in
            guard place.formattedAddress.lowercased(with: locale).contains(district.name.lowercased(with: locale)) else {
                return false
            }
            
            let displayNameLowercased = place.displayName.lowercased(with: locale)
            let hasForbiddenWord = forbiddenWords.contains { word in
                let wordLowercased = word.lowercased(with: locale)
                return displayNameLowercased.contains(wordLowercased)
            }
            return !hasForbiddenWord
        }
    }
    
    func generateInitialAdvices() {
        _sessionDislikedAndActivePlaceNames.removeAll()
        planAdvices.removeAll()
        
        for item in currentPlanConfiguration.items {
            generateAdviceForItem(item)
        }
    }
    
    private func generateAdviceForItem(_ item: PlanItem) {
        guard let filteredPlaces = _filteredPlacesByCategory[item.category] else { return }
        
        let sortedPlaces = sortPlaces(filteredPlaces, by: selectedSortOption)
        let selectedPlaces = selectNewUniquePlaces(
            from: sortedPlaces,
            count: item.maxCount,
            excludingSet: &_sessionDislikedAndActivePlaceNames
        )
        
        planAdvices[item.id] = selectedPlaces
    }
    
    func sortPlaces(_ places: [Place], by option: PlaceSortOption) -> [Place] {
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
                return places.sorted { place1, place2 in
                    let score1 = aiEngine.calculateAIScore(for: place1)
                    let score2 = aiEngine.calculateAIScore(for: place2)
                    return score1 > score2
                }
            }
        }
    
    func getPlacesForCategory(_ category: PlanCategory) -> [Place]? {
            return _filteredPlacesByCategory[category]
        }
        
        // Plan için kullanılan mekan isimlerini döndür
        func getExcludedPlaceNamesForPlan() -> Set<String> {
            return Set(currentPlanConfiguration.items.compactMap { item in
                planAdvices[item.id]?.compactMap { $0.name }
            }.flatMap { $0 })
        }
    
    private func selectNewUniquePlaces(from sortedList: [Place], count: Int, excludingSet: inout Set<String>) -> [Place] {
        var results: [Place] = []
        
        for place in sortedList {
            if !excludingSet.contains(place.name) {
                results.append(place)
                excludingSet.insert(place.name)
            }
            if results.count == count {
                break
            }
        }
        
        return results
    }

    private func sortPlacesByReason(places: [Place], reason: DislikeReason, defaultSortOption: PlaceSortOption) -> [Place] {
        var sortedPotentialPlaces = places
        
        switch reason {
        case .badRating:
            sortedPotentialPlaces.sort {
                if ($0.rating ?? 0.0) != ($1.rating ?? 0.0) {
                    return ($0.rating ?? 0.0) > ($1.rating ?? 0.0)
                }
                return ($0.userRatingCount ?? 0) > ($1.userRatingCount ?? 0)
            }
        case .tooExpensive:
            sortedPotentialPlaces.sort {
                let price0 = $0.priceLevel ?? Int.max
                let price1 = $1.priceLevel ?? Int.max
                if price0 != price1 {
                    return price0 < price1
                }
                return ($0.rating ?? 0.0) > ($1.rating ?? 0.0)
            }
        case .tooFar:
            sortedPotentialPlaces = sortPlaces(sortedPotentialPlaces, by: defaultSortOption)
        case .general:
            sortedPotentialPlaces = sortPlaces(places, by: defaultSortOption)
        }
        
        return sortedPotentialPlaces
    }

    func suggestAlternativeForPlanItem(_ planItem: PlanItem, dislikedPlace: Place, reason: DislikeReason) {
        guard let currentAdvices = planAdvices[planItem.id],
              let filteredPlaces = _filteredPlacesByCategory[planItem.category] else { return }
        
        _sessionDislikedAndActivePlaceNames.remove(dislikedPlace.name)
        _sessionDislikedAndActivePlaceNames.insert(dislikedPlace.name)
        
        var newAdvices: [Place] = []
        
        for advice in currentAdvices {
            if advice.name != dislikedPlace.name {
                newAdvices.append(advice)
                _sessionDislikedAndActivePlaceNames.insert(advice.name)
            }
        }
        
        let neededCount = planItem.maxCount - newAdvices.count
        
        if neededCount > 0 {
            let potentialCandidates = filteredPlaces.filter { place in
                return !_sessionDislikedAndActivePlaceNames.contains(place.name)
            }
            
            let sortedCandidates = sortPlacesByReason(
                places: potentialCandidates,
                reason: reason,
                defaultSortOption: selectedSortOption
            )
            
            let newlyFoundPlaces = selectNewUniquePlaces(
                from: sortedCandidates,
                count: neededCount,
                excludingSet: &_sessionDislikedAndActivePlaceNames
            )
            
            newAdvices.append(contentsOf: newlyFoundPlaces)
        }
        
        planAdvices[planItem.id] = Array(newAdvices.prefix(planItem.maxCount))
    }
    
    func autoSyncConfiguration() {
        syncPlanAdvicesToConfiguration()
    }

    func suggestAlternative(for planItemId: UUID, dislikedPlace: Place, reason: DislikeReason) {
        guard let planItem = currentPlanConfiguration.items.first(where: { $0.id == planItemId }) else { return }
        suggestAlternativeForPlanItem(planItem, dislikedPlace: dislikedPlace, reason: reason)
        
        // Değişiklik yapıldığında otomatik sync
        autoSyncConfiguration()
    }
}
