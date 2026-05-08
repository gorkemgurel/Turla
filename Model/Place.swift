//
//  Place.swift
//  Seyahat
//
//  Created by Gorkem Gurel on 25.05.2025.
//

struct Place: Codable, Equatable, Identifiable {
    var id: String { name }
    static func == (lhs: Place, rhs: Place) -> Bool {
        return lhs.id == rhs.id
    }
    
    let name: String
    let formattedAddress: String
    let location: Location
    let rating: Double?
    let googleMapsUri: String
    let userRatingCount: Int?
    let displayName: String
    let priceLevel: Int?
    let photos: [String]?
    let reviews: [Review]?
    let googleMapsLinks: GoogleMapsLinks
}
