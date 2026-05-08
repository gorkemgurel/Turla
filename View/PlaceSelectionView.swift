//
//  PlaceSelectionView.swift
//  Seyahat
//
//  Created by Gorkem Gurel on 29.05.2025.
//

import SwiftUI

struct PlaceSelectionView: View {
    @ObservedObject var viewModel: PlaceSelectionViewModel
    @Environment(\.presentationMode) var presentationMode
    let onPlaceSelected: (Place) -> Void
    
    var body: some View {
        NavigationView {
            VStack {
                // Sıralama seçenekleri
                Picker("Sıralama", selection: $viewModel.selectedSortOption) {
                    ForEach(PlaceSortOption.allCases, id: \.self) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // Mekan listesi
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.sortedPlaces.indices, id: \.self) { index in
                            let place = viewModel.sortedPlaces[index]
                            PlaceSelectionCardView(place: place) {
                                onPlaceSelected(place)
                                presentationMode.wrappedValue.dismiss()
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Mekan Seçimi")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("İptal") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}

struct PlaceSelectionCardView: View {
    let place: Place
    let onSelect: () -> Void
    
    private func priceLevelString(for level: Int?) -> String? {
        guard let level = level, level > 0 else { return nil }
        let maxLevel = 4
        return String(repeating: "₺", count: min(level, maxLevel))
    }
    
    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 8) {
                Text(place.displayName)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                
                HStack {
                    if let rating = place.rating {
                        Text(String(format: "%.1f", rating))
                            .font(.subheadline)
                            .fontWeight(.medium)
                        StarsView(rating: rating, maxRating: 5)
                            .font(.caption)
                    } else {
                        Text("Puan Yok")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    if let priceStr = priceLevelString(for: place.priceLevel) {
                        Text(priceStr)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.green)
                    }
                }
                
                if let ratingCount = place.userRatingCount, ratingCount > 0 {
                    Text("\(ratingCount) değerlendirme")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if !place.formattedAddress.isEmpty {
                    Text(place.formattedAddress)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.blue.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
