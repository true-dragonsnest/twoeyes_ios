//
//  ResizableTextField.swift
//  App
//
//  Created by Yongsik Kim on 12/29/24.
//

import SwiftUI

private let T = #fileID

struct ResizableTextField: UIViewRepresentable {
    struct ExtraOptions {
        let returnKeyType: UIReturnKeyType
        
        /// should return `true` to allow Return key input
        let onReturn: (() -> Bool)?
        
        init(returnKeyType: UIReturnKeyType = .default, onReturn: (() -> Bool)? = nil) {
            self.returnKeyType = returnKeyType
            self.onReturn = onReturn
        }
    }
    
    @Binding var text: String
    @Binding var focused: Bool?
    @Binding var cursorPosition: Int?
    
    let font: UIFont
    let foregroundTint: UIColor
    let minSize: CGSize
    let maxSize: CGSize
    let maxLength: Int?
    let length: Binding<Int>?
    let extraOptions: ExtraOptions
    let onMaxLength: (() -> Void)?
    
    init(text: Binding<String>,
         focused: Binding<Bool?> = .constant(nil),
         cursorPosition: Binding<Int?> = .constant(nil),
         font: UIFont = .preferredFont(forTextStyle: .body),
         foregroundTint: UIColor = .label1,
         minSize: CGSize,
         maxSize: CGSize,
         maxLength: Int? = nil,
         length: Binding<Int>? = nil,
         extraOptions: ExtraOptions = .init(),
         onMaxLength: (() -> Void)? = nil)
    {
        self._text = text
        self._focused = focused
        self._cursorPosition = cursorPosition
        self.font = font
        self.foregroundTint = foregroundTint
        self.minSize = minSize
        self.maxSize = maxSize
        self.maxLength = maxLength
        self.length = length
        self.extraOptions = extraOptions
        self.onMaxLength = onMaxLength
    }
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        
        textView.delegate = context.coordinator
        textView.font = font
        textView.isScrollEnabled = false
        textView.textColor = foregroundTint
        textView.tintColor = foregroundTint
        textView.backgroundColor = .clear
        textView.showsVerticalScrollIndicator = false
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.returnKeyType = extraOptions.returnKeyType
        
        return textView
    }
    
    func updateUIView(_ textView: UITextView, context: Context) {
        DispatchQueue.main.async {
            if let maxLength, text.count > maxLength {
                text = String(text.prefix(maxLength))
                onMaxLength?()
            }
            length?.wrappedValue = text.count
        }
        
        if textView.text != text {
            textView.text = text
        }
        
        if let cursorPosition {
            if let newPosition = textView.position(from: textView.beginningOfDocument, offset: cursorPosition) {
                textView.selectedTextRange = textView.textRange(from: newPosition, to: newPosition)
            }
        }
        
        textView.textColor = foregroundTint
        textView.tintColor = foregroundTint
        textView.font = font
        
        if let focused {
            DispatchQueue.main.async {
                _ = focused ? textView.becomeFirstResponder() : textView.resignFirstResponder()
            }
        }
        
        updateHeight(textView: textView, boundSize: textView.bounds.size)
        scrollEnabled(minSize: minSize, maxSize: maxSize, textView: textView)
    }
    
    func sizeThatFits(_ proposal: ProposedViewSize, uiView: UITextView, context: Context) -> CGSize? {
        return updateHeight(textView: uiView, boundSize: .init(width: maxSize.width, height: .infinity))
    }
    
    @discardableResult
    func updateHeight(textView: UITextView, boundSize: CGSize) -> CGSize {
        let fitSize = textView.sizeThatFits(boundSize)
        
        return .init(
            width: max(min(fitSize.width, maxSize.width), minSize.width),
            height: max(min(fitSize.height, maxSize.height), minSize.height)
        )
    }
    
    func scrollEnabled(minSize: CGSize, maxSize: CGSize, textView: UITextView) {
        let size = textView.sizeThatFits(.init(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
        let minWidth = minSize.width
        let maxWidth = maxSize.width
        let maxHeight = maxSize.height
        let calculatedWidth = min(max(size.width, minWidth), maxWidth)
        let constrainedSize = textView.sizeThatFits(.init(width: calculatedWidth, height: CGFloat.greatestFiniteMagnitude))
        
        let calculatedHeight = constrainedSize.height
        
        if calculatedHeight > maxHeight {
            // ? : calculatedHeight = maxHeight
            textView.isScrollEnabled = true
        } else {
            textView.isScrollEnabled = false
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: ResizableTextField
        
        init(parent: ResizableTextField) {
            self.parent = parent
        }
        
        func textViewDidChange(_ textView: UITextView) {
            DispatchQueue.main.async {
                self.parent.text = textView.text
            }
            
            parent.updateHeight(textView: textView, boundSize: textView.bounds.size)
            parent.scrollEnabled(minSize: parent.minSize, maxSize: parent.maxSize, textView: textView)
        }
        
        func textViewDidChangeSelection(_ textView: UITextView) {
            if let selectedRange = textView.selectedTextRange, selectedRange.start == selectedRange.end {
                let position = textView.offset(from: textView.beginningOfDocument, to: selectedRange.start)
                
                DispatchQueue.main.async {
                    self.parent.cursorPosition = position
                }
            }
        }
        
        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            guard let onReturn = parent.extraOptions.onReturn else { return true }
            
            guard text.rangeOfCharacter(from: .newlines) == nil else {
                return onReturn()
            }
            return true
        }

//        @objc func textViewDidBecomeFirstResponder() {
//            parent.focused = true
//        }
    }
}
