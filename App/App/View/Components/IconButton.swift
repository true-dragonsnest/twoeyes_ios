//
//  IconButton.swift
//  App
//
//  Created by Yongsik Kim on 12/26/24.
//

import SwiftUI

private extension View {
    @ViewBuilder
    func varForegroundStyle(_ style: [AnyShapeStyle]) -> some View {
        if style.count > 0 {
            if style.count > 1 {
                if style.count > 2 {
                    self.foregroundStyle(style[0], style[1], style[2])
                } else {
                    self.foregroundStyle(style[0], style[1])
                }
            } else {
                self.foregroundStyle(style[0])
            }
        } else {
            self
        }
    }
}

extension String {
    func iconButton(font: Font,
                    monochrome: Color,
                    onTap: (() -> Void)? = nil) -> some View
    {
        Image(systemName: self)
            .font(font)
            .symbolRenderingMode(.monochrome)
            .foregroundStyle(monochrome)
            .modify {
                if let onTap {
                    $0.contentShape(.rect).onTapGesture {
                        onTap()
                    }
                } else {
                    $0
                }
            }
    }
    
    func iconButton(font: Font,
                    palette: Color...,
                    onTap: (() -> Void)? = nil) -> some View
    {
        Image(systemName: self)
            .font(font)
            .symbolRenderingMode(.palette)
            .varForegroundStyle(palette.map { $0.any })
            .modify {
                if let onTap {
                    $0.contentShape(.rect).onTapGesture {
                        onTap()
                    }
                } else {
                    $0
                }
            }
    }
    
    func iconButton(font: Font,
                    renderMode: SymbolRenderingMode,
                    foregroundStyle: AnyShapeStyle...,
                    onTap: (() -> Void)? = nil) -> some View
    {
        Image(systemName: self)
            .font(font)
            .symbolRenderingMode(renderMode)
            .varForegroundStyle(foregroundStyle)
            .modify {
                if let onTap {
                    $0.contentShape(.rect).onTapGesture {
                        onTap()
                    }
                } else {
                    $0
                }
            }
    }
}
