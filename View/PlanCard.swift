//
//  PlanCard.swift
//  Seyahat
//
//  Created by Gorkem Gurel on 28.05.2025.
//

import SwiftUI

struct PlanCard: View {
    let plan: PlanConfiguration
    @ObservedObject var planManager: PlanManager
    @State private var showingCitySelection = false
    
    var body: some View {
        Button(action: { showingCitySelection = true }) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(plan.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Spacer()
                }
                
                Text("\(plan.items.count) kategori")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 4) {
                    ForEach(plan.items.prefix(3)) { item in
                        Text(item.category.rawValue)
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(categoryColor(for: item.category).opacity(0.2))
                            .foregroundColor(categoryColor(for: item.category))
                            .cornerRadius(4)
                    }
                    if plan.items.count > 3 {
                        Text("+\(plan.items.count - 3)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
            .frame(width: 160)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        }
        .contextMenu {
            Button(role: .destructive) {
                planManager.deletePlan(plan)
            } label: {
                Label("Sil", systemImage: "trash")
            }
        }
        .sheet(isPresented: $showingCitySelection) {
            NavigationView {
                            PlanView(
                                viewModel: PlanViewModel(district: plan.district!, planConfiguration: plan),
                                onSavePlan: { updatedPlan in
                                    // Plan güncellendikten sonra kaydet
                                    var planToSave = updatedPlan
                                    planToSave.lastModified = Date() // Son değişiklik tarihini ekleyin
                                    planManager.savePlan(planToSave)
                                }
                            )
                        }
        }
    }
    
    private func categoryColor(for category: PlanCategory) -> Color {
        switch category {
        case .breakfast: return .orange
        case .attraction: return .blue
        case .cafe: return .green
        case .dinner: return .red
        case .dessert: return .purple
        }
    }
}
