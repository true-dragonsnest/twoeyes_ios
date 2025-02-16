//
//  ReeedService.swift
//  TwoEyes
//
//  Created by Eunhye Kim on 9/9/24.
//

import Foundation
import Reeeed

private let T = #fileID

extension UseCases {
    enum ReaderMode {
        static let theme: ReaderTheme = .init()
        
        static func convert(from inputUrl: String) async throws -> (String, String) {
            guard let url = URL(string: inputUrl) else {
                throw AppError.invalidRequest("invalid url : \(inputUrl)".le(T))
            }
            var title = ""
            var article = ""
            
            // Load the extractor (if necessary) concurrently while we fetch the HTML:
            DispatchQueue.main.async { Reeeed.warmup() }
            
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let html = String(data: data, encoding: .utf8) else {
                "\(inputUrl): ExtractionError.DataIsNotString".le(T)
                throw ExtractionError.DataIsNotString
            }
            let baseURL = response.url ?? url
            // Extract the raw content:
            let content = try await Reeeed.extractArticleContent(url: baseURL, html: html)
            guard let extractedHTML = content.content else {
                "\(inputUrl): ExtractionError.MissingExtractionData".le(T)
                throw ExtractionError.MissingExtractionData
            }
            // Extract the "Site Metadata" — title, hero image, etc
            let extractedMetadata = try? await SiteMetadata.extractMetadata(fromHTML: html, baseURL: baseURL)
            // Generated "styled html" you can show in a webview:
            let styledHTML = Reeeed.wrapHTMLInReaderStyling(html: extractedHTML,
                                                            title: content.title ?? extractedMetadata?.title ?? "",
                                                            baseURL: baseURL,
                                                            author: content.author,
                                                            heroImage: extractedMetadata?.heroImage,
                                                            includeExitReaderButton: true, theme: theme)
            
            title = extractedMetadata?.title ?? ""
            
            guard let encodedData = styledHTML.data(using: String.Encoding.utf8) else {
                throw AppError.invalidResponse("failed to encode styled HTML : \(inputUrl)".le(T))
            }
            
            var attributedString: NSAttributedString
            "title: \(title)".ld(T)
            do {
                attributedString = try NSAttributedString(
                    data: encodedData,
                    options: [
                        NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html,
                        NSAttributedString.DocumentReadingOptionKey.characterEncoding: NSNumber(value: String.Encoding.utf8.rawValue)],
                    documentAttributes: nil)
                
                //attributedString.string.ld()
                article = attributedString.string
                "article: \(article)".ld(T)
            } catch {
                "failed to parse article : \(error)".le(T)
                throw error
            }
            
            return (title, article)
        }
    }
}
