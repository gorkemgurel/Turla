//
//  PlaceView.swift
//  Seyahat
//
//  Created by Gorkem Gurel on 25.05.2025.
//

import SwiftUI
import CachedAsyncImage

import SwiftUI
import CachedAsyncImage // Eğer kullanıyorsanız

struct PlaceView: View {
    @ObservedObject var viewModel: PlaceViewModel
    
    @State private var showFilterMenu = false
    @State private var showPlaceSelection = false
    var onFilterSelected: ((String) -> Void)?
    var onManualPlaceSelected: ((Place) -> Void)?
    
    // AI Engine referansı - PlanView'dan geçirilecek
    var aiEngine: AIRecommendationEngine?

    private func priceLevelString(for level: Int?) -> String? {
        guard let level = level, level > 0 else { return nil }
        let maxLevel = 4
        return String(repeating: "₺", count: min(level, maxLevel))
    }
    
    // AI Score hesaplama
    private var aiScore: Double {
        return aiEngine?.calculateAIScore(for: viewModel.place) ?? 50
    }

    var body: some View {
        LazyVStack(alignment: .leading, spacing: 8) {
            Text(viewModel.place.displayName)
                .font(.title3)
                .fontWeight(.bold)
                .fixedSize(horizontal: false, vertical: true)

            HStack {
                if let rating = viewModel.place.rating {
                    Text(String(format: "%.1f", rating))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    StarsView(rating: rating, maxRating: 5)
                        .font(.subheadline)
                } else {
                    Text("Puan Yok")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // AI Score Badge - sadece AI sıralaması aktifse göster
                if aiEngine != nil {
                    AIScoreBadge(score: aiScore)
                }
                
                if let priceStr = priceLevelString(for: viewModel.place.priceLevel) {
                    Text(priceStr)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(Color.green.opacity(0.9))
                }
            }

            if let ratingCount = viewModel.place.userRatingCount, ratingCount > 0 {
                Text("\(ratingCount) değerlendirme")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            if let photos = viewModel.place.photos, !photos.isEmpty {
                 PhotoGalleryView(viewModel: PhotoGalleryViewModel(imageURLs: photos, morePhotoURL: viewModel.place.googleMapsLinks.photosUri))
                    .padding(.vertical, 5)
            }
            
            if let reviews = viewModel.place.reviews, !reviews.isEmpty {
                if let moreReviewURL = viewModel.place.googleMapsLinks.reviewsUri {
                    ReviewView(viewModel: ReviewViewModel(reviewList: reviews, moreReviewURL: moreReviewURL))
                } else {
                    ReviewView(viewModel: ReviewViewModel(reviewList: reviews))
                }
            }

            VStack(spacing: 10) {
                HStack(spacing: 12) {
                    if let directionsUrlString = viewModel.place.googleMapsLinks.directionsUri,
                       let directionsUrl = URL(string: directionsUrlString) {
                        Link(destination: directionsUrl) {
                            Label("Yol Tarifi", systemImage: "arrow.triangle.turn.up.right.diamond.fill")
                                .font(.caption.weight(.medium))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8).padding(.horizontal, 5)
                                .background(Color.blue.opacity(0.8))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                                .shadow(radius: 2)
                        }
                    }
                    
                    Button(action: {
                        withAnimation(.spring()) {
                            showFilterMenu.toggle()
                        }
                    }) {
                        Label("Beğenmedim", systemImage: showFilterMenu ? "hand.thumbsdown.fill" : "hand.thumbsdown")
                            .font(.caption.weight(.medium))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8).padding(.horizontal, 5)
                            .background(Color.orange.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                            .shadow(radius: 2)
                    }
                }
                
                if showFilterMenu {
                    VStack(alignment: .leading, spacing: 8) {
                        FilterReasonButton(title: "Çok Uzak Geldi", reasonKey: "Uzak", action: {
                            onFilterSelected?("Uzak")
                            showFilterMenu = false
                        })
                        FilterReasonButton(title: "Bütçeme Uymadı (Pahalı)", reasonKey: "Pahalı", action: {
                            onFilterSelected?("Pahalı")
                            showFilterMenu = false
                        })
                        FilterReasonButton(title: "Başka Bir Öneri Göster", reasonKey: "Rastgele", action: {
                            onFilterSelected?("Rastgele")
                            showFilterMenu = false
                        })
                        FilterReasonButton(title: "Kendim Seçeyim", reasonKey: "Manual", action: {
                            showPlaceSelection = true
                            showFilterMenu = false
                        })
                    }
                    .padding(.top, 8)
                    .transition(.asymmetric(insertion: .scale(scale: 0.9, anchor: .top).combined(with: .opacity), removal: .opacity))
                }
            }
            .padding(.top, 10)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 3)
        .sheet(isPresented: $showPlaceSelection) {
            if let onManualPlaceSelected = onManualPlaceSelected {
                PlaceSelectionView(
                    viewModel: viewModel.createPlaceSelectionViewModel(),
                    onPlaceSelected: onManualPlaceSelected
                )
            }
        }
    }
}

// AI Score Badge Component
struct AIScoreBadge: View {
    let score: Double
    
    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: "brain.head.profile")
                .font(.caption2)
                .foregroundColor(.purple)
            Text("\(Int(score))%")
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(.purple)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [.purple.opacity(0.15), .blue.opacity(0.15)]),
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.purple.opacity(0.3), lineWidth: 0.5)
        )
    }
}

struct FilterReasonButton: View {
    let title: String
    let reasonKey: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.footnote)
                .foregroundColor(.primary)
                .padding(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.gray.opacity(0.15))
                .cornerRadius(6)
        }
    }
}

struct PlaceView_Previews: PreviewProvider {
    static var previews: some View {
        PlaceView(viewModel: PlaceViewModel(place: Place(name: "places/ChIJuxrrafpTvxQRuha07-ENuVs", formattedAddress: "places/ChIJuxrrafpTvxQRuha07-ENuVs", location: Location(latitude: 37.6042128, longitude: 28.488011099999998), rating: 4.1, googleMapsUri: "https://maps.google.com/?cid=6609329192183273146", userRatingCount: 57, displayName: "EGE DOĞA PARK", priceLevel: nil, photos: [
            "https://places.googleapis.com/v1/places/ChIJuxrrafpTvxQRuha07-ENuVs/photos/AXQCQNSMm9vRmHUJzFxHF-V8ZtsH4auMXp2IgrgPekU0wAZuSHqX5HIxDjbrgRG_-Y-UJBs1a_DluJRTuASn-fsQoDSIgF5PbS_rSfEN-hduHJCUEPkXnavSIq1zDAGwteogfO-_0w6zm14OKmB-Gojw3s75ka_Z0mdevwddZL_L_abD3C_EuMUjcZXB9NrtVeYXGNZOLyZO4LekasimJTjp8Tn7-1BHb-9fp004YTMfX3wHx0tPBt_pn-_ejPbmE6WigVPmSyGKILEF-1rCilz1wz3a9USQ9_Ul_4IMtv0-NOgBoA/media?key=AIzaSyClzVsZd_hH8mBGYe1zlTNnnxY_vfv5ZUI&maxWidthPx=800",
            "https://places.googleapis.com/v1/places/ChIJuxrrafpTvxQRuha07-ENuVs/photos/AXQCQNR6CN4hwSc55DfGpSjU_ApDjkPIJKPoNNBZac9ZFlusTBPJCsXauwJca346fOp898R_Q9CUgAb02zZ_Z9jHkvdcGrzYX2uymngH_IGtst3nVtd8VUyhXM4twdc0xUX-Sh07jg-vdjBwit1MJXEZNHukRcF1TJKlRFe_HGtlqvhTr_l__YjcPvfYPW_qLHAH_gx_0_KQHeY2pU7x3doX2KLjlAPKvhsnzE4hNGIxjCRybqakwtGSAksYkC-P0j9IJ7IlZF6wQuB0r4PwxvplpG4vkz5ZwX1cbwGw160FYLfrEQ/media?key=AIzaSyClzVsZd_hH8mBGYe1zlTNnnxY_vfv5ZUI&maxWidthPx=800",
            "https://places.googleapis.com/v1/places/ChIJuxrrafpTvxQRuha07-ENuVs/photos/AXQCQNRIZzNNzOZu3pAbHf7p-787PSe29dFj1rGvYUizuh47ghCJZyNUKNLFyxnWi1dP8wltCRtCKezxZ35gPKzJDLA2MnSApEVetRCMcvm7ZhnoykEABHEwus8nFfcGy6Xe3qP5oDFZTvI8cpJCZTpvr4c9-ckXT34g6a0EEAiMNpkZi3vpIuW3ilUXBbyqVwz-kPPt1jqYihVGAhh0os2qrSWYja9iUDtjgW-JkulB0cgxq8IugULMOFWsb87qnZE4BjlpCgFC4hRfQq7tIppYT7_nIcU2uYSY5M0SEfP4JX8S0w/media?key=AIzaSyClzVsZd_hH8mBGYe1zlTNnnxY_vfv5ZUI&maxWidthPx=800",
            "https://places.googleapis.com/v1/places/ChIJuxrrafpTvxQRuha07-ENuVs/photos/AXQCQNTYHZK6lSuoQwf6yL412gYFCg05H5_fVnW_MVcvAtePrVJuvmYu5b-tJL7fnC-lFcuvE4-jlOHkEvhZOHW-OoByG2mll230MYOc9NVyo_0_fQFobwd4ckVEwYDsF-78NWlnrUOtfOXmwpRMZ8akU1UkT7PL1g2_4JA3fhOE2CPJvZ-fgD9qvSO_FcpECaR-BTwtmHXZD0bcegvwFyFISD3PeAWu-VKs6fgwVzP_XUEdSqc8i-REHTX5FH0QjW5sBep96dQzQr1LAtLvuJA79wJLIYMp-hj9Y5fTkeg9gXu0r5J1E35biEstRn6afqoFCvyhOk9mXszLA519NIOR7yEj3VBqcEP2TCk3Ze0z5_CoPwgTOI82KBVkA1kQCXCYmeuanWha6sSuckbv4HKtY968mD1oj0AHq1ceJRPWYZG-ZZI/media?key=AIzaSyClzVsZd_hH8mBGYe1zlTNnnxY_vfv5ZUI&maxWidthPx=800"
        ], reviews: [Review(text: "Alabalık yedik ızgarada efsane güzel ve lezzetliydi. Ortamın bakıma ve toparlanmaya ihtiyacı var. Sezon daha açılmamış belli fakat yine de tuvalet vs çok bakımsız geldi. Yemek ve atmosferi güzel bi yer. Fiyatlar çok uygun. 2 alabalık salata çay 600 tl di. Uzak yerde olmasaydık sık sık gelirdik.", rating: 4, author: "Bushra Uslu", timeAgo: "2 ay önce"),
                     Review(text: "Öncelikle şunu ifade edeyim. 5 yıldız hak eden çok güzel bir doğa alanı. Akan suları, minik şelaleleri il insana huzur veren yeşil bir güzellik. Yiyecek çeşitleri fena değil. Et, tavuk, balık ve kahvaltı mevcut. Ekmek arası köfte veya balık menülerinde olmasına rağmen ekmeklerin tamamını dilimledikleri bahanesiyle ekmek arası veremeyeceklerini söylemeleri pek inandırıcı gelmedi. Mangalcı ve piknikçi ile restoran müşterilerini ayırmaları gerekir. Girişte ücret var ancak tabelaya restoran  müşterilerinden ücret alınmıyor diye yazmışlar. Pikniğe değil restorana geldik dememize rağmen 100 tl giriş ücreti aldılar üstelik fiş falan da vermeden. İçeride belki 100 tane araba vardı. Kim sayıyor bu araçları, toplanan paralar nereye gidiyor konusu rahatsız edici. Mangalcıların ortalığı dumana boğması da ayrı bir sorun. Cennet gibi ortam son derece mutsuz eden bir yer haline gelebiliyor. Bozdoğan Belediyesi işletiyormuş. Biraz daha özen göstermesini temenni ederim. Özensizlik ve denetimsizlik nedeniyle 3 yıldız verdim.", rating: 3, author: "Erdal K", timeAgo: "bir yıl önce"),
                    Review(text: "mesire yeri güzel, suya isterseniz girebilirsiniz. 3 kişi gittik 3 alabalık söyledik yarım saat sonra 2 tane getirdiler, siz 2 tane söylediniz değil mi diyor bir de. Ardından 3 tane söylediğimizi söyledik 20-25 dk sonra geldi diğer alabalık. İlk başta verdiğimiz içecek siparişlerini ard arda söylememize rağmen en son gelen balıkla getirdiler. Aynı yere 5 kişi bakıyor bir tanesi bile doğru dürüst iş yapamıyor. Belediyenin oradaki çalışanlara bir göz atması lazım. Bir daha asla gitmem.", rating: 1, author: "TAHA FURKAN TEKE", timeAgo: "10 ay önce"),
                     Review(text: "Bozdoğan ilçesinde bulunulan en gözde piknik alanı gittiğimde suyun debisi gayet iyiydi. Çok kalabalık erken saatte gidip yer kapmak gerek girişler 100 TL. Kafeterya kullanmak isteyenler için fiyatlar uygun. Mescid ve tuvaletler mevcut ancak tuvalet sayısını artırmak gerek kalabalıklarda sıra beklemek zorunda kalıyoruz.", rating: 4, author: "Ali AYKUT", timeAgo: "11 ay önce"),
                     Review(text: "Şansımıza gittiğimizde sakin bir gündü. Temizlik gayet iyiydi, yiyeceklerse lezzetliydi. Doğal güzelliği ise muhteşem. En kısa zamanda tekrar gideceğiz,", rating: 5, author: "UĞUR Peynircioğlu (DONUT)", timeAgo: "7 ay önce")], googleMapsLinks: GoogleMapsLinks(directionsUri: "https://www.google.com/maps/dir//''/data=!4m7!4m6!1m1!4e2!1m2!1m1!1s0x14bf526d466ce1c9:0x7d0f36015b49a691!3e0", placeUri: "https://maps.google.com/?cid=9011480758846072465", reviewsUri: "https://www.google.com/maps/place//data=!4m4!3m3!1s0x14bf526d466ce1c9:0x7d0f36015b49a691!9m1!1b1", photosUri: "https://www.google.com/maps/place//data=!4m3!3m2!1s0x14bf526d466ce1c9:0x7d0f36015b49a691!10e5"))))
    }
}
