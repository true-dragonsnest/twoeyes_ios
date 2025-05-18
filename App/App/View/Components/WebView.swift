//
//  WebView.swift
//  App
//
//  Created by Yongsik Kim on 5/18/25.
//

import SwiftUI
import WebKit
import Combine

private let T = #fileID

struct WebView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var webViewModel = UIWebViewModel()
    
    @Binding var url: String

    var body: some View {
        NavigationStack {
            content
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(.visible, for: .navigationBar)
                .toolbarBackground(Color.background, for: .navigationBar)
                .toolbarRole(.editor)
                .navigationBarBackButtonHidden(true)
                .toolbar(.hidden, for: .tabBar)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        barIcon("xmark", fontSize: 14) {
                            presentationMode.wrappedValue.dismiss()
                        }
                        .offset(x: -8)
                    }
                }
                .navigationTitle(webViewModel.title)
                .onAppear {
                    webViewModel.load(url)
                }
        }
    }
    
    var content: some View {
        VStack(spacing: 0) {
            UIWebView(viewModel: webViewModel)
            
            HStack {
                backButton
                Spacer()
                forwardButton
                Spacer()
                reloadButton
                Spacer()
                safariButton
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(Color.background)
        }
    }
    
    var backButton: some View {
        barIcon("chevron.left", disabled: webViewModel.canGoBack == false) {
            webViewModel.back()
        }
    }
    
    var forwardButton: some View {
        barIcon("chevron.right", disabled: webViewModel.canGoForward == false) {
            webViewModel.forward()
        }
    }
    
    var reloadButton: some View {
        barIcon("arrow.counterclockwise") {
            webViewModel.reload()
        }
    }
    
    var safariButton: some View {
        barIcon("safari") {
            webViewModel.openInSafari()
        }
    }
    
    func barIcon(_ name: String,
                 fontSize: CGFloat = 16,
                 disabled: Bool = false,
                 onTap: (() -> Void)? = nil) -> some View
    {
        name.iconButton(font: .system(size: fontSize), monochrome: disabled ? .label3 : .label1)
            .fontWeight(.semibold)
            .contentShape(.rect)
            .onTapGesture {
                if disabled == false {
                    onTap?()
                }
            }
    }
}

// MARK: - web view in UIViewRepresentable
public class UIWebViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var canGoBack: Bool = false
    @Published var canGoForward: Bool = false
    @Published var title: String = ""
    @Published fileprivate var url: String?
    
    enum Action {
        case load(_ url: String)
        case loadHTMLString(_ html: String, url: String)
        case back
        case forward
        case share
        case reload
        case openInSafari
        case none
    }
    
    @Published var action: Action = .none
    
    public func load(_ url: String) {
        action = .load(url)
    }
    
    public func loadHTMLString(_ html: String, url: String) {
        action = .loadHTMLString(html, url: url)
    }
    
    public func back() {
        action = .back
    }
    
    public func forward() {
        action = .forward
    }
    
    public func share() {
        action = .share
    }
    
    public func reload() {
        action = .reload
    }
    
    public func openInSafari() {
        action = .openInSafari
    }
}

public struct UIWebView: UIViewRepresentable {
    @ObservedObject var viewModel: UIWebViewModel
    let transparent: Bool
    let injectDarkModeCss: Bool
    let webView = WKWebView()
    
    init(viewModel: UIWebViewModel, transparent: Bool = false, injectDarkModeCss: Bool = false) {
        self.viewModel = viewModel
        self.transparent = transparent
        self.injectDarkModeCss = injectDarkModeCss
    }

    public func makeCoordinator() -> Coordinator {
        let c = Coordinator(self, viewModel)
        c.setupAction()
        return c
    }

    public func makeUIView(context: Context) -> WKWebView {
        webView.navigationDelegate = context.coordinator
        if transparent {
            webView.isOpaque = false
            webView.backgroundColor = .clear
            webView.scrollView.backgroundColor = .clear
        }
        if injectDarkModeCss {
            injectCSS(webView: webView)
        }
        return webView
    }

    public func updateUIView(_ uiView: WKWebView, context: Context) {
    }

    private func injectCSS(webView: WKWebView) {
        // Inject Light/Dark CSS
        let lightDarkCSS = ":root { color-scheme: light dark; }"
        let base64 = lightDarkCSS.data(using: .utf8)!.base64EncodedString()

        let script = """
            javascript:(function() {
                var parent = document.getElementsByTagName('head').item(0);
                var style = document.createElement('style');
                style.type = 'text/css';
                style.innerHTML = window.atob('\(base64)');
                parent.appendChild(style);
            })()
        """

        let cssScript = WKUserScript(source: script, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        webView.configuration.userContentController.addUserScript(cssScript)
    }
}

public extension UIWebView {
    class Coordinator: NSObject, WKNavigationDelegate {
        @ObservedObject private var viewModel: UIWebViewModel
        private let parent: UIWebView
        private var subscriptions: Set<AnyCancellable> = []
        
        init(_ parent: UIWebView, _ viewModel: UIWebViewModel) {
            self.parent = parent
            self.viewModel = viewModel
        }
        
        fileprivate func setupAction() {
            viewModel.$action.receive(on: RunLoop.main).sink { [weak self] action in
                guard let self else { return }
                switch action {
                case .load(let url):
                    guard let url = URL(fromString: url) else { return }
                    let request = URLRequest(url: url)
                    parent.webView.load(request)
                case .loadHTMLString(let html, let url):
                    guard let url = URL(fromString: url) else { return }
                    parent.webView.loadHTMLString(html, baseURL: url)
                case .back:
                    parent.webView.goBack()
                case .forward:
                    parent.webView.goForward()
                case .reload:
                    parent.webView.reload()
                case .openInSafari:
                    guard let url = parent.webView.url else { return }
                    UIApplication.shared.open(url)
                default: break
                }
                
            }
            .store(in: &subscriptions)
        }
        
        private func update() {
            viewModel.title = parent.webView.title ?? ""
            viewModel.canGoBack = parent.webView.canGoBack
            viewModel.canGoForward = parent.webView.canGoForward
        }
        
        public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            viewModel.isLoading = true
            update()
        }
        
        public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            viewModel.isLoading = false
            update()
        }
        
        public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            viewModel.isLoading = false
            update()
        }
    }
}
