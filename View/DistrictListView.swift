//
//  DistrictListView.swift
//  Seyahat
//
//  Created by Gorkem Gurel on 24.05.2025.
//

import Foundation
import SwiftUI

struct DistrictListView: View {
    @ObservedObject var viewModel: DistrictListViewModel
    let selectedPlan: PlanConfiguration?

    init(viewModel: DistrictListViewModel, selectedPlan: PlanConfiguration? = nil) {
        self.viewModel = viewModel
        self.selectedPlan = selectedPlan
    }
    
    var body: some View {
        List(viewModel.districtList, id: \.name) { district in
            NavigationLink(destination: destinationView(for: district)) {
                HStack {
                    Text(district.name)
                        .font(.body)
                    
                    Spacer()
                    
                    // Bu satırı kaldırın - NavigationLink zaten otomatik chevron ekliyor
                    // Image(systemName: "chevron.right")
                    //     .font(.caption)
                    //     .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
            }
        }
        .onAppear {
            viewModel.loadDistricts()
            print("onAppear")
        }
        .navigationTitle("İlçeler")
    }
    
    @ViewBuilder
    private func destinationView(for district: District) -> some View {
        if let selectedPlan = selectedPlan {
            // Eğer plan önceden seçilmişse direkt PlanView'a git
            PlanView(
                viewModel: PlanViewModel(district: district, planConfiguration: selectedPlan),
                onSavePlan: nil // Bu durumda kaydetme işlemi olmayacak çünkü plan zaten var
            )
        } else {
            // Plan seçilmemişse plan seçim ekranına git
            PlanSelectionView(district: district)
        }
    }
}
