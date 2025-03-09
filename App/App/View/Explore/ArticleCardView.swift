//
//  ArticleCardView.swift
//  App
//
//  Created by Yongsik Kim on 3/9/25.
//

import SwiftUI
import Kingfisher

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
                    .stroke(bgColor, lineWidth: 1)
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
        .aspectRatio(9 / 16, contentMode: .fit)
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
