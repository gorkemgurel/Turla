//
//  PlanConfiguration.swift
//  Seyahat
//
//  Created by Gorkem Gurel on 28.05.2025.
//

import Foundation

struct PlanConfiguration: Codable {
    var items: [PlanItem]
    var name: String
    var id: UUID
    var createdDate: Date?
    var lastUsedDate: Date?
    var lastModified: Date = Date() // Yeni eklenen property
    var district: District?
    var selectedPlaces: [String: [Place]] = [:] // planItemId.uuidString -> seçilmiş yerler
    
    init(items: [PlanItem], name: String = "Özel Plan", district: District) {
        self.items = items
        self.name = name
        self.id = UUID()
        self.createdDate = Date()
        self.lastUsedDate = Date()
        self.lastModified = Date()
        self.district = district
        self.selectedPlaces = [:]
    }
    
    private init(items: [PlanItem], name: String, isDefault: Bool) {
        self.items = items
        self.name = name
        self.id = UUID()
        self.lastModified = Date()
        self.selectedPlaces = [:]
        if isDefault {
            self.createdDate = nil
            self.lastUsedDate = nil
        } else {
            self.createdDate = Date()
            self.lastUsedDate = Date()
        }
    }
    
    static let defaultPlan = PlanConfiguration(items: [
        PlanItem(category: .breakfast),
        PlanItem(category: .attraction, title: "Gezilecek Yer 1"),
        PlanItem(category: .cafe),
        PlanItem(category: .attraction, title: "Gezilecek Yer 2"),
        PlanItem(category: .dinner),
        PlanItem(category: .dessert)
    ], name: "Varsayılan Plan", isDefault: true)
    
    mutating func updateSelectedPlaces(for planItemId: UUID, places: [Place]) {
        selectedPlaces[planItemId.uuidString] = places
        lastModified = Date()
    }
    
    func getSelectedPlaces(for planItemId: UUID) -> [Place]? {
        return selectedPlaces[planItemId.uuidString]
    }

    enum CodingKeys: String, CodingKey {
        case items
        case name
        case id
        case createdDate
        case lastUsedDate
        case lastModified
        case district
        case selectedPlaces
    }
}
