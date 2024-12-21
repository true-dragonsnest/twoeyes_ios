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
    
    var lastLocation: CLLocationCoordinate2D? {
        get { self[LastLocationKey.self] }
        set { self[LastLocationKey.self] = newValue }
    }
}

// MARK: - EnvironmentKeys

private struct AuthStateKey: EnvironmentKey {
    static var defaultValue: IntroViewModel.AuthState = .unknown
}

private struct LastLocationKey: EnvironmentKey {
    static var defaultValue: CLLocationCoordinate2D? = nil
}

