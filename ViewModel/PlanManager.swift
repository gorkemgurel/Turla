//
//  PlanManager.swift
//  Seyahat
//
//  Created by Gorkem Gurel on 28.05.2025.
//

import Foundation
import SwiftUI

class PlanManager: ObservableObject {
    static let shared = PlanManager()
    
    @Published var savedPlans: [PlanConfiguration] = []
    
    private let userDefaults = UserDefaults.standard
    private let plansKey = "SavedTravelPlans"
    
    private init() {
        loadSavedPlans()
    }
    
    func savePlan(_ plan: PlanConfiguration) {
        DispatchQueue.main.async {
            if let index = self.savedPlans.firstIndex(where: { $0.id == plan.id }) {
                self.savedPlans[index] = plan
            } else {
                self.savedPlans.append(plan)
            }
            self.saveToUserDefaults()
            print("Plan saved: \(plan.name), total plans: \(self.savedPlans.count)")
        }
    }
    
    func deletePlan(_ plan: PlanConfiguration) {
        DispatchQueue.main.async {
            self.savedPlans.removeAll { $0.id == plan.id }
            self.saveToUserDefaults()
            print("Plan deleted: \(plan.name), remaining plans: \(self.savedPlans.count)")
        }
    }
    
    func loadSavedPlans() {
        guard let data = userDefaults.data(forKey: plansKey) else {
            print("No saved plans found")
            return
        }
        
        do {
            let plans = try JSONDecoder().decode([PlanConfiguration].self, from: data)
            DispatchQueue.main.async {
                self.savedPlans = plans
                print("Loaded \(plans.count) plans")
            }
        } catch {
            print("Failed to load plans: \(error)")
        }
    }
    
    private func saveToUserDefaults() {
        do {
            let encoded = try JSONEncoder().encode(savedPlans)
            userDefaults.set(encoded, forKey: plansKey)
            userDefaults.synchronize()
            print("Plans saved to UserDefaults successfully. Total plans: \(savedPlans.count)")
        } catch {
            print("Failed to save plans: \(error)")
        }
    }
}
