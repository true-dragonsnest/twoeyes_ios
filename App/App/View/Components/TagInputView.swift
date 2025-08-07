//
//  TagInputView.swift
//  App
//
//  Created by Yongsik Kim on 12/29/24.
//

import SwiftUI

struct TagInputView: View {
    enum Const {
        static let minSize = CGSize(width: 1, height: 20)
        static let maxLength: Int = 100
    }
    
    @Binding var tags: [String]
    @Binding var focused: Bool?
    let appendWhenOutFocus: Bool
    let maxCount: Int?
    let onMaxCount: (() -> Void)?
    let onReturn: (() -> Void)?
    
    init(tags: Binding<[String]>,
         focused: Binding<Bool?>,
         appendWhenOutFocus: Bool = false,
         maxCount: Int? = nil,
         onMaxCount: (() -> Void)? = nil,
         onReturn: (() -> Void)? = nil)
    {
        self._tags = tags
        self._focused = focused
        self.appendWhenOutFocus = appendWhenOutFocus
        self.maxCount = maxCount
        self.onMaxCount = onMaxCount
        self.onReturn = onReturn
    }
    
    @State var input: String = ""
    @State var width: CGFloat?
    
    var body: some View {
        VStack {
            listView
            inputView
        }
        .readSize { size in
            if width == nil, size.width > Const.minSize.width {
                width = size.width - 50
            }
        }
        .onChange(of: focused) { _, val in
            if appendWhenOutFocus, val == false {
                append()
                input = ""
            }
        }
    }
    
    @ViewBuilder
    var listView: some View {
        if tags.isEmpty == false {
            ChipCloudView() {
                ForEach(tags, id: \.self) { tag in
                    HStack(spacing: Spacing.xs) {
                        Text(tag)
                            .font(.caption)
                            .foregroundStyle(.label1)
                        "xmark.circle.fill".iconButton(font: .caption, monochrome: .label1)
                            .padding(.trailing, Padding.s)
                            .contentShape(.rect)
                            .onTapGesture {
                                withAnimation {
                                    tags.removeAll(where: { $0 == tag })
                                }
                            }
                    }
                    .padding(.leading, Padding.s)
                    .frame(height: 28)
                    .background(.primaryFill)
                    .clipShape(.rect(cornerRadius: 16))
                    .transition(.scale)
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    var inputView: some View {
        HStack(spacing: Spacing.xs) {
            Text("#")
                .font(.headline)
                .foregroundStyle(.label1)
            
            HStack {
                ResizableTextField(text: $input,
                                   focused: $focused,
                                   font: .preferredFont(for: .headline, weight: .regular),
                                   minSize: Const.minSize,
                                   maxSize: .init(width: width ?? Const.minSize.width, height: Const.minSize.height),
                                   maxLength: Const.maxLength,
                                   extraOptions: .init(returnKeyType: .done, onReturn: send))
                "plus.circle.fill".iconButton(font: .headline, monochrome: .appPrimary) {
                    _ = send()
                }
                .opacity(input.isEmpty ? 0 : 1)
            }
            
            Spacer()
        }
    }
    
    func append() {
        if input.hasContent, tags.contains(input) == false {
            if let maxCount, tags.count >= maxCount {
                onMaxCount?()
            } else {
                withAnimation {
                    tags.append(input)
                }
            }
        }
    }
    
    func send() -> Bool {
        append()
        
        focused = true
        input = ""
        
        onReturn?()
        
        return false
    }
}
