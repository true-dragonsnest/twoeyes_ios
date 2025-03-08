//
//  ExploreView.swift
//  App
//
//  Created by Yongsik Kim on 3/8/25.
//

import SwiftUI
import Kingfisher

private let T = #fileID

@Observable
class ArticleRepo {
    var articles: [EntityArticle] = []
    
    init() {
        "init".li(T)
        fetch()
    }
    
    func fetch() {
        Task { @MainActor in
            do {
                articles = try await UseCases.Fetch.articles()
            } catch {
                ContentViewModel.shared.error = error
            }
        }
    }
}

struct ExploreView: View {
    @Environment(\.safeAreaInsets) var safeAreaInsets
    
    @State var repo: ArticleRepo = .init()
    
    var body: some View {
        contentView
    }
    
    var contentView: some View {
        ScrollView(.vertical, showsIndicators: false) {
            if repo.articles.isEmpty {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .label3))
            } else {
                LazyVStack(spacing: 16) {
                    ForEach(repo.articles) { article in
                        ArticleCardView(article: article)
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal)
                            .scrollTransition(topLeading: .interactive,
                                              bottomTrailing: .interactive,
                                              axis: .vertical) { view, phase in
                                view.opacity(1 - abs(phase.value * 0.7))
                            }
                    }
                }
                .scrollTargetLayout()
                .padding(.bottom, 36)
            }
        }
        .scrollTargetBehavior(.viewAligned(limitBehavior: .alwaysByOne))
        .scrollClipDisabled()
    }
}

struct ArticleCardView: View {
    let article: EntityArticle
    
    @State var width: CGFloat = 0
    @State var bgColor: Color = .clear
    
    var body: some View {
        contentView
            .background(
                LinearGradient(
                    gradient: .init(colors: [
                        bgColor.opacity(0.5),
                        bgColor.opacity(0.4),
                        bgColor.opacity(0.3),
                        bgColor.opacity(0.1),
                        bgColor.opacity(0.3),
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .animation(.smooth, value: bgColor)
            .background(article.image != nil ? AnyShapeStyle(.regularMaterial) : Color.clear.any)
            .clipShape(.rect(cornerRadius: 16))
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(.label2, lineWidth: 2)
            }
            .readSize {
                width = $0.width
            }
            .onAppear {
                loadColorIfNeeded()
            }
    }
    
    var contentView: some View {
        VStack {
            titleView
                .padding(.horizontal)
                .padding(.top)
            
            if let imageUrl = URL(fromString: article.image) {
                let width = max(0, self.width - 8 * 2)
                KFImage(imageUrl)
                    .backgroundDecode(true)
                    .resizable()
                    .placeholder {
                        Color.red
                    }
                    .aspectRatio(contentMode: .fill)
                    .frame(width: width, height: width)
                    .clipShape(.rect(cornerRadius: 8))
                    .padding(.horizontal, 8)
            }
            
            Spacer()
        }
    }
    
    var titleView: some View {
        HStack {
            Text(article.title ?? "")
                .font(.title2)
                .bold()
                .foregroundStyle(.label1)
            Spacer()
        }
    }
    
    func loadColorIfNeeded() {
        guard bgColor == .clear, let imageUrl = article.image else { return }
        Task {
            guard let image = try? await UseCases.Download.image(from: imageUrl),
                  let color = image.dominantColor else { return }
            bgColor = Color(uiColor: color)
        }
    }
}

// MARK: - get dominant color from image
import CoreImage
import CoreImage.CIFilterBuiltins

extension UIImage {
    var dominantColor: UIColor? {
        guard let ciImage = CIImage(image: self) else { return nil }
        
        let filter = CIFilter.areaAverage()
        filter.inputImage = ciImage
        filter.extent = ciImage.extent
        
        let context = CIContext()
        guard let filtered = filter.outputImage else { return nil }
        
        var bitmap = [UInt8](repeating: 0, count: 4)    // RGBA
        context.render(
            filtered,
            toBitmap: &bitmap,
            rowBytes: 4,
            bounds: .init(x: 0, y: 0, width: 1, height: 1),
            format: .RGBA8,
            colorSpace: CGColorSpaceCreateDeviceRGB()
        )
        
        return .init(red: CGFloat(bitmap[0]) / 255.0,
                     green: CGFloat(bitmap[1]) / 255.0,
                     blue: CGFloat(bitmap[2]) / 255.0,
                     alpha: CGFloat(bitmap[3]) / 255.0)
    }
}
