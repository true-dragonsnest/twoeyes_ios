//
//  AssetRepository.swift
//  App
//
//  Created by Yongsik Kim on 12/22/24.
//

import Foundation
import Combine

private let T = #fileID

class AssetRepository {
    static let shared = AssetRepository()
    private init() {}

    // MARK: - intro
    var introEntity: EntityIntro?
    
    func loadIntro() async {
        "load intro...".ld(T)
        do {
            introEntity = try await UseCases.Fetch.intro()
            "intro : \(o: introEntity?.jsonPrettyPrinted)".li(T)
            
            loadAssets()
        } catch {
            "failed to fetch intro : \(error)".lf(T)
        }
    }
    
    func loadAssets() {
    }
}
