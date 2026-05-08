//
//  ReviewViewModel.swift
//  Seyahat
//
//  Created by Gorkem Gurel on 25.05.2025.
//

import Foundation

class ReviewViewModel: ObservableObject {
    @Published var reviewList: [Review] = []
    var moreReviewURL: String?
    
    init(reviewList: [Review], moreReviewURL: String) {
        self.reviewList = reviewList
        self.moreReviewURL = moreReviewURL
    }
    
    init(reviewList: [Review]) {
        self.reviewList = reviewList
    }
}
