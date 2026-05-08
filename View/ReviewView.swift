//
//  ReviewView.swift
//  Seyahat
//
//  Created by Gorkem Gurel on 25.05.2025.
//

import SwiftUI

struct ReviewView: View {
    @ObservedObject var viewModel: ReviewViewModel

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(viewModel.reviewList, id: \.text) { review in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(review.author)
                            .font(.headline)
                        if let reviewText = review.text {
                            Text(reviewText)
                                .font(.body)
                                .lineLimit(3)
                                .multilineTextAlignment(.leading)
                                .frame(minHeight: 60, alignment: .topLeading)
                        } else {
                            Text("")
                        }
                        
                        Text(review.timeAgo)
                            .font(.caption)
                            .foregroundColor(.gray)
                        StarsView(rating: Double(review.rating), maxRating: 5)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .frame(width: 250)
                }
                if let moreReviewURL = viewModel.moreReviewURL {
                    Link(destination: URL(string: moreReviewURL)!) {
                        ZStack {
                            Color.gray.opacity(0.2) // Arka plan (görsel yerine)
                            HStack(spacing: 4) {
                                Text("Daha fazla inceleme")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                                Image(systemName: "arrow.up.right.square")
                            }
                            .padding()
                        }
                        .frame(width: 250)
                        .clipped()
                        .cornerRadius(10)
                    }
                }
            }
            //.padding(.horizontal)
        }
    }
}

