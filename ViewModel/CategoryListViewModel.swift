//
//  CategoryListViewModel.swift
//  Seyahat
//
//  Created by Gorkem Gurel on 25.05.2025.
//

import Foundation

class CategoryListViewModel: ObservableObject {
    @Published var categoryList: [Category] = []
    var district: District
    
    init(district: District) {
        self.district = district
        self.categoryList = self.district.categories
    }
}
