//
//  GlobalDismissManager.swift
//  Seyahat
//
//  Created by Gorkem Gurel on 28.05.2025.
//


//
//  GlobalDismissManager.swift
//  Seyahat
//
//  Created by Gorkem Gurel on 28.05.2025.
//

import Foundation
import SwiftUI

class GlobalDismissManager {
    static let shared = GlobalDismissManager()
    
    private init() {}
    
    func dismissAll() {
        NotificationCenter.default.post(name: .dismissAllViews, object: nil)
    }
}

extension Notification.Name {
    static let dismissAllViews = Notification.Name("dismissAllViews")
}