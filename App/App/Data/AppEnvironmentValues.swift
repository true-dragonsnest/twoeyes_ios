//
//  AppEnvironmentValues.swift
//  App
//
//  Created by Yongsik Kim on 12/22/24.
//

import SwiftUI
import CoreLocation

// MARK: - EnvironmentValues

extension EnvironmentValues {
    var authState: IntroViewModel.AuthState {
        get { self[AuthStateKey.self] }
        set { self[AuthStateKey.self] = newValue }
    }
    
    var sceneSize: CGSize {
        get { self[SceneSizeKey.self] }
        set { self[SceneSizeKey.self] = newValue }
    }
    
    var lastLocation: CLLocationCoordinate2D? {
        get { self[LastLocationKey.self] }
        set { self[LastLocationKey.self] = newValue }
    }
}

// MARK: - EnvironmentKeys

private struct AuthStateKey: EnvironmentKey {
    static var defaultValue: IntroViewModel.AuthState = .unknown
}

private struct SceneSizeKey: EnvironmentKey {
    static var defaultValue: CGSize {
        UIApplication.shared.keyWindow?.bounds.size ?? .init(width: 1, height: 1)
    }
}

private struct LastLocationKey: EnvironmentKey {
    static var defaultValue: CLLocationCoordinate2D? = nil
}

