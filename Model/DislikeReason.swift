//
//  DislikeReason.swift
//  Seyahat
//
//  Created by Gorkem Gurel on 28.05.2025.
//


import Foundation

enum DislikeReason: String, CaseIterable {
    case tooFar = "Çok Uzak"
    case tooExpensive = "Çok Pahalı"
    case badRating = "Düşük Puanlı"
    case general = "Genel Beğenmedim"
}