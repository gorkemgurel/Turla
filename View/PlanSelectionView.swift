//
//  PlanSelectionView.swift
//  Seyahat
//
//  Created by Gorkem Gurel on 28.05.2025.
//

import SwiftUI

struct PlanSelectionView: View {
    let district: District
    @ObservedObject private var planManager = PlanManager.shared
    @State private var showingCreatePlan = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        List {
            Section(header: Text("Hazır Planlar")) {
                NavigationLink(destination: PlanView(
                    viewModel: PlanViewModel(district: district, planConfiguration: .defaultPlan),
                    onSavePlan: { planConfiguration in
                        planManager.savePlan(planConfiguration)
                    }
                )) {
                    PlanRowView(plan: .defaultPlan)
                }
            }
            
            Section {
                Button(action: { showingCreatePlan = true }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.blue)
                        Text("Yeni Plan Oluştur")
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .navigationTitle("Plan Seç - \(district.name)")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showingCreatePlan) {
            CreatePlanView(
                district: district,
                planManager: planManager
            )
        }
        .onReceive(NotificationCenter.default.publisher(for: .dismissAllViews)) { _ in
            showingCreatePlan = false
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    private func deletePlans(offsets: IndexSet) {
        let plansToDelete = offsets.map { planManager.savedPlans[$0] }
        for plan in plansToDelete {
            planManager.deletePlan(plan)
        }
    }
}

struct PlanRowView: View {
    let plan: PlanConfiguration
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(plan.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(plan.items.count) kategori")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color(.systemGray5))
                    .cornerRadius(4)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(plan.items.prefix(4)) { item in
                        Text(item.category.rawValue)
                            .font(.caption2)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(categoryColor(for: item.category).opacity(0.2))
                            .foregroundColor(categoryColor(for: item.category))
                            .cornerRadius(6)
                    }
                    if plan.items.count > 4 {
                        Text("+\(plan.items.count - 4)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding(.vertical, 4)
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
