//
//  PlaceListView.swift
//  Seyahat
//
//  Created by Gorkem Gurel on 25.05.2025.
//

import SwiftUI

struct PlaceListView: View {
    @ObservedObject var viewModel: PlaceListViewModel

    var body: some View {
        List(viewModel.placeList, id: \.name) { place in
            /*NavigationLink(destination: PlaceListView(viewModel: PlaceListViewModel(category: category))) {
                Text(category.name)
            }*/
            PlaceView(viewModel: PlaceViewModel(place: place))
                .listRowInsets(EdgeInsets())
                .padding(.vertical)
        }
        .navigationTitle("Mekanlar")
    }
}
