//
//  HomeView.swift
//  App
//
//  Created by Yongsik Kim on 1/27/25.
//

import SwiftUI
import AVFoundation
import PhotosUI

struct HomeView: View {
    @StateObject var viewModel = HomeViewModel()
    
    var body: some View {
        NavigationStack(path: $viewModel.navPath) {
            contentView
                .navigationDestination(for: HomeViewModel.NavPath.self) { path in
                    switch path.viewType {
                    default: Color.red
                    }
                }
        }
    }
    
    var contentView: some View {
        ZStack {
            Color.background.ignoresSafeArea()
            VStack {
                Text("home")
            }
        }
    }
}

