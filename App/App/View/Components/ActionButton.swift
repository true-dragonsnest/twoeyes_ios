//
//  ActionButton.swift
//  App
//
//  Created by Yongsik Kim on 12/29/24.
//

import SwiftUI

struct ActionButton: View {
    let text: String
    let disabled: Bool
    let onTap: () -> Void
    
    var body: some View {
        Text(text)
            .font(.headline)
            .foregroundStyle(disabled ? .label3 : .white)
            .padding()
            .background(disabled ? .secondaryFill : .appPrimary)
            .clipShape(.capsule)
            .onTapGesture {
                onTap()
            }
    }
}
