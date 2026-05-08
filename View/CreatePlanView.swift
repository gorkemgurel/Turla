//
//  CreatePlanView.swift
//  Seyahat
//
//  Created by Gorkem Gurel on 28.05.2025.
//

import SwiftUI

struct CreatePlanView: View {
    let district: District
    @ObservedObject var planManager = PlanManager.shared
    @Environment(\.presentationMode) var presentationMode
    
    @State private var planName: String = ""
    @State private var planItems: [PlanItem] = []
    @State private var showingCategoryPicker = false
    @State private var editingItem: PlanItem?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Plan Adı")
                        .font(.headline)
                    
                    TextField("Örn: \(district.name) Gezisi", text: $planName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding()
                .background(Color(.systemGray6))
                
                List {
                    Section(header: Text("Plan İçeriği")) {
                        ForEach(planItems) { item in
                            PlanItemRow(
                                item: item,
                                onEdit: { editingItem = item },
                                onDelete: { deletePlanItem(item) }
                            )
                        }
                        .onMove(perform: movePlanItems)
                        
                        Button(action: { showingCategoryPicker = true }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.blue)
                                Text("Kategori Ekle")
                                Spacer()
                            }
                        }
                    }
                    
                    /*if !planItems.isEmpty {
                        Section(header: Text("Önizleme")) {
                            ForEach(planItems) { item in
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.title)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    Text("\(item.maxCount) öneri")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.vertical, 2)
                            }
                        }
                    }*/
                }
                .listStyle(InsetGroupedListStyle())
            }
            .navigationTitle("Yeni Plan Oluştur")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("İptal") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Kaydet") {
                    savePlan()
                }
                .disabled(planName.isEmpty || planItems.isEmpty)
            )
        }
        .sheet(isPresented: $showingCategoryPicker) {
            CategoryPickerView { category in
                addPlanItem(category: category)
                showingCategoryPicker = false
            }
        }
        .sheet(item: $editingItem) { item in
            EditPlanItemView(item: item) { updatedItem in
                updatePlanItem(updatedItem)
                editingItem = nil
            }
        }
        .onAppear {
            if planName.isEmpty {
                planName = "\(district.name) Gezisi"
            }
        }
    }
    
    private func addPlanItem(category: PlanCategory) {
        let newItem = PlanItem(category: category)
        planItems.append(newItem)
    }
    
    private func deletePlanItem(_ item: PlanItem) {
        planItems.removeAll { $0.id == item.id }
    }
    
    private func updatePlanItem(_ updatedItem: PlanItem) {
        if let index = planItems.firstIndex(where: { $0.id == updatedItem.id }) {
            planItems[index] = updatedItem
        }
    }
    
    private func movePlanItems(from source: IndexSet, to destination: Int) {
        planItems.move(fromOffsets: source, toOffset: destination)
    }
    
    private func savePlan() {
        let newPlan = PlanConfiguration(items: planItems, name: planName, district: self.district)
        planManager.savePlan(newPlan)
        
        // Notification gönder - tüm sheet'leri kapat
        NotificationCenter.default.post(name: .dismissAllViews, object: nil)
        
        // Mevcut view'ı da kapat
        presentationMode.wrappedValue.dismiss()
    }
}

// Plan item satırı
struct PlanItemRow: View {
    let item: PlanItem
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                HStack {
                    Text(item.category.rawValue)
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(categoryColor(for: item.category).opacity(0.2))
                        .foregroundColor(categoryColor(for: item.category))
                        .cornerRadius(4)
                    
                    /*Text("• \(item.maxCount) öneri")
                        .font(.caption)
                        .foregroundColor(.secondary)*/
                }
            }
            
            Spacer()
            
            /*Button(action: onEdit) {
                Image(systemName: "pencil")
                    .foregroundColor(.blue)
            }
            .buttonStyle(BorderlessButtonStyle())*/
        }
        .swipeActions(edge: .trailing) {
            Button(role: .destructive, action: onDelete) {
                Label("Sil", systemImage: "trash")
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

// Kategori seçici
struct CategoryPickerView: View {
    let onCategorySelected: (PlanCategory) -> Void
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            List {
                ForEach(PlanCategory.allCases) { category in
                    Button(action: {
                        onCategorySelected(category)
                    }) {
                        HStack {
                            Text(category.rawValue)
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "plus.circle")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            .navigationTitle("Kategori Seç")
            .navigationBarItems(
                trailing: Button("İptal") { presentationMode.wrappedValue.dismiss() }
            )
        }
    }
}

// Plan item düzenleme
struct EditPlanItemView: View {
    let item: PlanItem
    let onSave: (PlanItem) -> Void
    
    @State private var title: String
    @State private var maxCount: Int
    @Environment(\.presentationMode) var presentationMode
    
    init(item: PlanItem, onSave: @escaping (PlanItem) -> Void) {
        self.item = item
        self.onSave = onSave
        self._title = State(initialValue: item.title)
        self._maxCount = State(initialValue: item.maxCount)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Başlık")) {
                    TextField("Başlık", text: $title)
                }
                
                Section(header: Text("Öneri Sayısı")) {
                    Stepper(value: $maxCount, in: 1...5) {
                        Text("\(maxCount) öneri")
                    }
                }
                
                Section(header: Text("Kategori")) {
                    Text(item.category.rawValue)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Düzenle")
            .navigationBarItems(
                leading: Button("İptal") { presentationMode.wrappedValue.dismiss() },
                trailing: Button("Kaydet") { saveItem() }
            )
        }
    }
    
    private func saveItem() {
        let updatedItem = PlanItem(
            category: item.category,
            maxCount: maxCount,
            title: title,
            id: item.id
        )
        onSave(updatedItem)
        presentationMode.wrappedValue.dismiss()
    }
}
