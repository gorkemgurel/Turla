//
//  DashboardView.swift
//  Seyahat
//
//  Created by Gorkem Gurel on 28.05.2025.
//

import SwiftUI

struct DashboardView: View {
    @ObservedObject var planManager = PlanManager.shared
    @State private var showingCitySelection = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom header
            HStack {
                Text("Seyahat Planlayıcı")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button(action: { showingCitySelection = true }) {
                    Image(systemName: "plus")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Merhaba! 👋")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Bugün nereyi keşfetmek istiyorsun?")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(12)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Planlarım")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        if planManager.savedPlans.isEmpty {
                            emptyStateView
                        } else {
                            planGrid
                        }
                    }
                }
                .padding()
            }
        }
        .sheet(isPresented: $showingCitySelection) {
            ProvinceListView()
        }
        .onReceive(NotificationCenter.default.publisher(for: .dismissAllViews)) { _ in
            showingCitySelection = false
        }
        .onAppear {
            planManager.loadSavedPlans()
        }
    }
    
    private var planGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            ForEach(planManager.savedPlans, id: \.id) { plan in
                PlanCard(plan: plan, planManager: planManager)
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "map")
                .font(.system(size: 50))
                .foregroundColor(.gray.opacity(0.5))
            
            Text("Henüz plan yok")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Sağ üstteki + tuşuna basarak ilk planını oluştur!")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}
