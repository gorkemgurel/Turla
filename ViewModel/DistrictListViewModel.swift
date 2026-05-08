//
//  DistrictListViewModel.swift
//  Seyahat
//
//  Created by Gorkem Gurel on 25.05.2025.
//

import Foundation

class DistrictListViewModel: ObservableObject {
    @Published var districtList: [District] = []
    var provinceName: String
    
    init(provinceName: String) {
        self.provinceName = provinceName
    }
    
    func loadDistricts() {
        guard let url = Bundle.main.url(forResource: self.provinceName, withExtension: "json") else {
            print("Dosya bulunamadı.")
            return
        }

        do {
            let data = try Data(contentsOf: url)
            self.districtList = try JSONDecoder().decode([District].self, from: data)
        } catch {
            print("Decode hatası: \(error)")
        }
    }
    
    func printAll() {
        print(districtList[0].name)
    }
}
