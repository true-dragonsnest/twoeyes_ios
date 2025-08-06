//
//  InputBar+Attachments.swift
//  App
//
//  Created by Yongsik Kim on 8/5/25.
//

import SwiftUI
import PhotosUI
import Kingfisher

private let T = #fileID

extension InputBar {
    func loadImage(from items: [PhotosPickerItem]) async {
        await withTaskGroup(of: (Data, AppMediaType)?.self) { group in
            items.forEach { item in
                group.addTask {
                    guard let data = try? await item.loadTransferable(type: Data.self),
                          let mime = item.supportedContentTypes.first?.preferredMIMEType else {
                        return nil
                    }
                    guard let type = AppMediaType.allCases.first(where: { $0.mime == mime }) else {
                        "unsupported mime type : \(mime)".le(T)
                        return nil
                    }
                    return (data, type)
                }
            }
            
            for await r in group {
                guard let r else { return }
                if await appendImage(data: r.0, type: r.1) == false { break }
            }
        }
    }
    
    func loadImage(_ image: UIImage) async {
        await MainActor.run {
            withAnimation {
                attachments.append(.image(image: image, type: nil))
            }
        }
    }
    
    func appendImage(data: Data, type: AppMediaType) async -> Bool {
        guard let image = UIImage(data: data) else { return true }
        
        guard attachments.count < AppConst.maxImageAttachments else {
            ContentViewModel.shared.setToastMessage("You can attach up to %d images".localized(AppConst.maxImageAttachments))
            return false
        }
        
        await MainActor.run {
            withAnimation {
                attachments.append(.image(image: image, type: type))
            }
        }
        
        return true
    }
}
