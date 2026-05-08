//
//  PlanListRow.swift
//  Seyahat
//
//  Created by Gorkem Gurel on 28.05.2025.
//


import SwiftUI

struct PlanListRow: View {
    let plan: PlanConfiguration
    @ObservedObject var planManager: PlanManager
    @State private var showingCitySelection = false
    
    var body: some View {
        Button(action: { showingCitySelection = true }) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(plan.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text("\(plan.items.count) kategori • Son kullanım: \(formattedDate)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
        }
        .sheet(isPresented: $showingCitySelection) {
            CitySelectionView(preselectedPlan: plan)
        }
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: plan.lastUsedDate ?? plan.createdDate ?? Date())
    }
}