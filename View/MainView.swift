//
//  MainView.swift
//  Seyahat
//
//  Created by Gorkem Gurel on 22.05.2025.
//

import SwiftUI

struct MainView: View {
    
    let totalImages = 12
    // 2 sütunlu grid
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    // Her kart 4 resim gösterecek
    var groupedImages: [[String]] {
        stride(from: 1, through: totalImages, by: 4).map { start in
            (start..<min(start + 4, totalImages + 1)).map { index in
                "image-\(index)"
            }
        }
    }

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(groupedImages, id: \.self) { imageSet in
                    PreviewCard(images: imageSet)
                }
            }
            .padding()
            Button("Login") {
                //getData()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
    }
}

struct PreviewCard: View {
    let images: [String]

    let innerColumns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        VStack {
            LazyVGrid(columns: innerColumns, spacing: 4) {
                ForEach(images, id: \.self) { imageName in
                    Image(imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 70, height: 70)
                        .clipped()
                        .cornerRadius(4)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 4)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
