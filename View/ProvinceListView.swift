//
//  ProvinceListView.swift
//  Seyahat
//
//  Created by Gorkem Gurel on 24.05.2025.
//

import SwiftUI

struct ProvinceListView: View {
    @StateObject var viewModel = ProvinceListViewModel()
    let preselectedPlan: PlanConfiguration?
    @Environment(\.presentationMode) var presentationMode
    
    init(preselectedPlan: PlanConfiguration? = nil) {
        self.preselectedPlan = preselectedPlan
    }
    
    var body: some View {
        NavigationView {
            List(viewModel.provinces, id: \.self) { province in
                NavigationLink(destination: DistrictListView(
                    viewModel: DistrictListViewModel(provinceName: province),
                    selectedPlan: preselectedPlan
                )) {
                    Text(province.description)
                }
            }
            .navigationTitle("Şehirler")
            .navigationBarItems(
                leading: Button("İptal") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
        .onReceive(NotificationCenter.default.publisher(for: .dismissAllViews)) { _ in
            presentationMode.wrappedValue.dismiss()
        }
    }
}

struct ProvinceListView_Previews: PreviewProvider {
    static var previews: some View {
        ProvinceListView()
    }
}
