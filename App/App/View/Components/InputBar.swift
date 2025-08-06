//
//  InputBar.swift
//  App
//
//  Created by Yongsik Kim on 8/5/25.
//

import SwiftUI
import PhotosUI
import Shimmer
@_spi(Advanced) import SwiftUIIntrospect

private let T = #fileID

// MARK: - consts
extension InputBar {
    enum Const {
        static let height: CGFloat = 50
        static let radius: CGFloat = 25
    }
}


// MARK: - view
struct InputBar: View {
    enum Attachment {
        case image(image: UIImage, type: AppMediaType?)
    }
    
    @Environment(\.sceneSize) var sceneSize
    
    var focused: FocusState<Bool>.Binding
    
    let text: String
    let sendEnabled: Bool
    
    let onTap: (() -> Void)?
    typealias OnSubmit = (_ input: String, _ attachments: [Attachment]) -> Void
    let onSubmit: OnSubmit?
        
    @State var input: String = ""
    @State var inputActivated = false
    @StateObject private var textFieldDelegate = TextFieldDelegate()
    
    // attachments
    @State var attachments: [Attachment] = []
    
    @State var showAttachmentMenu = false
    @State var showPhotoPicker = false
    @State var pickerItems: [PhotosPickerItem] = []
    @State var showCamera = false
    @State var cameraImage: UIImage?
    //$
    
    // buttons
    @State var buttonsExpanded = true
    //$
    
    // UI effects
    @State var textShimmering = false
    //$
    
    
    init(text: String = "",
         focused: FocusState<Bool>.Binding,
         sendEnabled: Bool,
         onTap: (() -> Void)? = nil,
         onSubmit: OnSubmit?)
    {
        self.text = text
        self.focused = focused
        self.sendEnabled = sendEnabled
        self.onTap = onTap
        self.onSubmit = onSubmit
    }
    
    var body: some View {
        HStack(alignment: .bottom) {
            inputBar
                .background(.regularMaterial)
                .clipShape(.rect(cornerRadius: Const.radius))
                .overlay {
                    RoundedRectangle(cornerRadius: Const.radius)
                        .stroke(Material.thin, lineWidth: 1)
                }
            
            buttons
        }
        .photosPicker(isPresented: $showPhotoPicker,
                      selection: $pickerItems,
                      maxSelectionCount: AppConst.maxImageAttachments,
                      matching: .images,
                      photoLibrary: .shared())
        .onChange(of: pickerItems) {
            Task {
                await loadImage(from: pickerItems)
            }
        }
        .fullScreenCover(isPresented: $showCamera) {
            ImagePickerCameraView(capturedImage: $cameraImage)
                .edgesIgnoringSafeArea(.all)
        }
        .onChange(of: cameraImage) {
            guard let cameraImage else { return }
            Task {
                await loadImage(cameraImage)
            }
        }
        .onAppear {
            setupTextFieldDelegate()
        }
    }
    
    func setupTextFieldDelegate() {
        textFieldDelegate.onShouldChangeCharactersIn = { _, _ in
            return true
        }
        
        textFieldDelegate.onTextChange = {
            input = $0
            withAnimation {
                if buttonsExpanded, inputActivated {
                    buttonsExpanded = false
                }
                inputActivated = input.isEmpty == false
            }
            
        }
        
        textFieldDelegate.onImagePaste = { image in
            Task {
                await loadImage(image)
            }
        }
        
        textFieldDelegate.onGifPaste = { gif in
            Task {
                await appendImage(data: gif, type: .gif)
            }
        }
    }
}

// MARK: - input bar
extension InputBar {
    var inputBar: some View {
        VStack(spacing: 0) {
            if attachments.isEmpty == false {
                // TODO: attacmhment view
            }
            
            HStack(alignment: .bottom, spacing: 0) {
                textField
                    .padding(.leading)
                    .padding(.vertical)
                    .contentShape(.rect)
                    .onTapGesture {
                        onTap?()
                        if focused.wrappedValue == false {
                            focused.wrappedValue = true
                        }
                    }
                
                if inputActivated || attachments.isEmpty == false {
                    clearButton
                        .transition(.asymmetric(insertion: .identity, removal: .opacity).combined(with: .scale))
                    sendButton
                        .transition(.asymmetric(insertion: .identity, removal: .opacity).combined(with: .scale))
                }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: Const.height)
        .onAppear {
            clearInput()
        }
    }
    
    func clearInput(animated: Bool = true) {
        if animated {
            withAnimation {
                input = ""
                attachments = []
            }
        } else {
            input = ""
            attachments = []
        }
    }
    
    var textField: some View {
        TextField("", text: $input, axis: .vertical)
            .font(.headline).fontWeight(.semibold)
            .foregroundStyle(.label1)
            .lineLimit(4)
            .multilineTextAlignment(.leading)
            .submitLabel(.return)
            .focused(focused)
            .overlay(alignment: .leading) {
                textFieldPlaceHolder
            }
            .introspect(.textField(axis: .vertical), on: .iOS(.v18...)) { textField in
                textField.delegate = textFieldDelegate
            }
    }
    
    var textFieldPlaceHolder: some View {
        Text(text)
            .font(.headline).fontWeight(.semibold)
            .foregroundStyle(.label3)
            .shimmering(active: textShimmering, animation: .spring(duration: 2))
            .allowsTightening(false)
            .opacity(inputActivated ? 0 : 1)
            .onChange(of: text) {
                textShimmering = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    textShimmering = false
                }
            }
    }
    
    var clearButton: some View {
        "xmark.circle.fill".iconButton(font: .headline, monochrome: .label3)
            .padding(.horizontal)
            .frame(height: Const.height)
            .contentShape(.rect)
            .onTapGesture {
                clearInput()
            }
    }
    
    var sendButton: some View {
        Circle().fill(sendEnabled ? AnyShapeStyle(Color.appPrimary) : AnyShapeStyle(Material.regular))
            .frame(width: Const.height - 4, height: Const.height - 4)
            .overlay {
                "arrow.up".iconButton(font: .title, monochrome: sendEnabled ? .white : .label1)
            }
            .contentShape(.rect)
            .onTapGesture {
                guard sendEnabled else { return }
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                onSubmit?(input, attachments)
                clearInput()
            }
            .padding(.trailing, 3)
            .padding(.bottom, 3)
    }
}

// MARK: - buttons
extension InputBar {
    @ViewBuilder
    var buttons: some View {
        if buttonsExpanded {
            attachmentButton
            aiButton
        } else {
            Circle().fill(.regularMaterial)
                .frame(width: Const.height, height: Const.height)
                .overlay {
                    "chevron.forward".iconButton(font: .title, monochrome: .label1)
                }
                .contentShape(.rect)
                .onTapGesture {
                    withAnimation {
                        buttonsExpanded = true
                    }
                }
        }
    }
    
    var attachmentButton: some View {
        Circle().fill(.regularMaterial)
            .frame(width: Const.height, height: Const.height)
            .overlay {
                "plus".iconButton(font: .title, monochrome: .label1)
            }
            .contentShape(.rect)
            .onTapGesture {
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                showAttachmentMenu = true
            }
            .confirmationDialog("", isPresented: $showAttachmentMenu) {
                Button("Attach Photos") {
                    showPhotoPicker = true
                }
                Button("Take Picture") {
                    showCamera = true
                }
            }
    }
    
    var aiButton: some View {
        Circle().fill(.regularMaterial)
            .frame(width: Const.height, height: Const.height)
            .overlay {
                "sparkles".iconButton(font: .title, monochrome: .appPrimary)
            }
            .contentShape(.rect)
            .onTapGesture {
            }
    }
}



// MARK: - TextFieldDelegate
private class TextFieldDelegate: NSObject, UITextViewDelegate, ObservableObject {
    var onShouldChangeCharactersIn: ((NSRange, String) -> Bool)? = nil
    var onTextChange: ((String) -> Void)? = nil
    var onImagePaste: ((UIImage) -> Void)? = nil
    var onGifPaste: ((Data) -> Void)? = nil
    
    override init() {
        super.init()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        onShouldChangeCharactersIn?(range, text) ??  true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        onTextChange?(textView.text)
    }
    
    func textView(_ textView: UITextView, editMenuForTextIn range: NSRange, suggestedActions: [UIMenuElement]) -> UIMenu? {
        var actions = suggestedActions
        if let uiImage = pasteImageFromClipboard()?.fixOrientation() {
            let menu = UIMenu(title: "", options: .displayInline, children: [
                UIAction(title: "Paste Image".localized) { [weak self] _ in
                    self?.onImagePaste?(uiImage)
                }
            ])
            actions.append(menu)
        }
        if let gifData = pasteGifFromClipboard() {
            let menu = UIMenu(title: "", options: .displayInline, children: [
                UIAction(title: "Paste GIF".localized) { [weak self] _ in
                    self?.onGifPaste?(gifData)
                }
            ])
            actions.append(menu)
        }
        return UIMenu(children: actions)
    }
    
    private func pasteImageFromClipboard() -> UIImage? {
        let pasteboard = UIPasteboard.general
        
        guard pasteboard.hasImages else { return nil }
        if let image = pasteboard.image {
            return image
        }

//        for t in ["public.png", "public.jpeg", "public.heif", "public.heic"] {
//            if pasteboard.types.contains(t),
//               let data = pasteboard.data(forPasteboardType: t),
//               let image = UIImage(data: data) {
//                return image
//            }
//        }
        
        return nil
    }
    
    private func pasteGifFromClipboard() -> Data? {
        let pasteboard = UIPasteboard.general

        let t = "com.compuserve.gif"
        if pasteboard.types.contains(t),
           let data = pasteboard.data(forPasteboardType: t) {
            return data
        }
        return nil
    }
}

// MARK: - preview
//#Preview {
//    @Previewable @FocusState var focus
//    
//    InputBar(text: "Input here",
//             focused: $focus,
//             sendEnabled: true) { _, _ in }
//        .padding(.horizontal)
//}
