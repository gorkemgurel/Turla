//
//  LocationInfoView.swift
//  Seyahat
//
//  Created by Gorkem Gurel on 28.05.2025.
//


import SwiftUI
import CoreLocation

struct LocationInfoView: View {
    let fromPlace: Place
    let toPlace: Place
    let viewModel: PlanViewModel
    
    private var distance: CLLocationDistance {
        viewModel.calculateDistance(from: fromPlace, to: toPlace)
    }
    
    private var formattedDistance: String {
        viewModel.formatDistance(distance)
    }
    
    private var walkingTime: String {
        viewModel.estimateWalkingTime(distance)
    }
    
    private var drivingTime: String {
        viewModel.estimateDrivingTime(distance)
    }
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Spacer()
                
                VStack(spacing: 4) {
                    HStack(spacing: 12) {
                        // Yürüme bilgisi
                        HStack(spacing: 4) {
                            Image(systemName: "figure.walk")
                                .font(.caption)
                                .foregroundColor(.blue)
                            Text(walkingTime)
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        
                        // Araç bilgisi
                        HStack(spacing: 4) {
                            Image(systemName: "car.fill")
                                .font(.caption)
                                .foregroundColor(.green)
                            Text(drivingTime)
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                    }
                    
                    // Mesafe
                    Text("Mesafe: \(formattedDistance)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemGray6))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(.systemGray4), lineWidth: 0.5)
                        )
                )
                
                Spacer()
            }
            
            // Ok işareti
            Image(systemName: "arrow.down")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}
