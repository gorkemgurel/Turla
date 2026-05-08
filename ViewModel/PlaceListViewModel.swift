//
//  PlaceViewModel.swift
//  Seyahat
//
//  Created by Gorkem Gurel on 25.05.2025.
//

import Foundation

class PlaceListViewModel: ObservableObject {
    @Published var placeList: [Place] = []
    var category: Category
    
    init(category: Category) {
        self.category = category
        self.placeList = self.category.places
    }
}
