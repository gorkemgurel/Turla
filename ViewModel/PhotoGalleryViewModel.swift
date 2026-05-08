//
//  PhotoGalleryViewModel.swift
//  Seyahat
//
//  Created by Gorkem Gurel on 25.05.2025.
//

import Foundation

class PhotoGalleryViewModel: ObservableObject {
    var imageURLs: [String]
    var morePhotoURL: String
    @Published var isFullScreenPresented = false
    @Published var selectedImageURL: String? = nil
    
    init(imageURLs: [String], morePhotoURL: String) {
        self.imageURLs = imageURLs
        self.morePhotoURL = morePhotoURL
    }
}
