//
//  CitySelectionView.swift
//  Seyahat
//
//  Created by Gorkem Gurel on 28.05.2025.
//

import SwiftUI

struct CitySelectionView: View {
    let preselectedPlan: PlanConfiguration?
    @Environment(\.presentationMode) var presentationMode
    
    init(preselectedPlan: PlanConfiguration? = nil) {
        self.preselectedPlan = preselectedPlan
    }
    
    var body: some View {
        NavigationView {
            ProvinceListView(preselectedPlan: preselectedPlan)
                .navigationBarItems(
                    leading: Button("İptal") {
                        presentationMode.wrappedValue.dismiss()
                    }
                )
        }
    }
}
