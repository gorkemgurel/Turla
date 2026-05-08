import SwiftUI
import CachedAsyncImage

struct PhotoGalleryView: View {
    @ObservedObject var viewModel: PhotoGalleryViewModel

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(viewModel.imageURLs, id: \.self) { url in
                    CachedAsyncImage(url: URL(string: url)) { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 150, height: 100)
                            .clipped()
                            .cornerRadius(10)
                            .onTapGesture {
                                viewModel.selectedImageURL = url
                                viewModel.isFullScreenPresented = true
                            }
                    } placeholder: {
                        ProgressView()
                            .frame(width: 150, height: 100)
                    }
                }
                Link(destination: URL(string: viewModel.morePhotoURL)!) {
                    ZStack {
                        Color.gray.opacity(0.2) // Arka plan (görsel yerine)
                        HStack(spacing: 4) {
                            Text("Daha fazla fotoğraf")
                                .font(.caption)
                                .foregroundColor(.blue)
                            Image(systemName: "arrow.up.right.square")
                        }
                        //.padding()
                    }
                    .frame(width: 150, height: 100)
                    .clipped()
                    .cornerRadius(10)
                }
            }
            .padding()
        }
        .fullScreenCover(isPresented: $viewModel.isFullScreenPresented) {
            if let imageURL = viewModel.selectedImageURL {
                FullScreenImageView(imageURL: imageURL)
            } else {
                Color.black
            }
        }
    }
}
