import SwiftUI
import WebKit

struct WebViewContainer: View {
    let urlString: String
    
    @StateObject private var webViewModel = WebViewModel()
    @State private var showingError = false
    
    var body: some View {
        ZStack(alignment: .top) {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Progress Bar
                if webViewModel.isLoading && webViewModel.estimatedProgress < 1.0 {
                    ProgressView(value: webViewModel.estimatedProgress, total: 1.0)
                        .progressViewStyle(LinearProgressViewStyle(tint: Color(red: 0.78, green: 0.52, blue: 0.46)))
                        .frame(height: 2.5)
                }
                
                // WebView
                SwiftUIWebView(viewModel: webViewModel, urlString: urlString)
                    .edgesIgnoringSafeArea(.bottom)
            }
            
            // Offline / Error Overlay
            if webViewModel.hasError {
                VStack(spacing: 16) {
                    Image(systemName: "wifi.slash")
                        .font(.system(size: 48))
                        .foregroundColor(Color(red: 0.78, green: 0.52, blue: 0.46))
                    
                    Text("Connection Error")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("Unable to load ANUSI. Please check your internet connection and try again.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                    
                    Button(action: {
                        webViewModel.reload()
                    }) {
                        Text("Retry")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 28)
                            .padding(.vertical, 12)
                            .background(Color(red: 0.78, green: 0.52, blue: 0.46))
                            .cornerRadius(24)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.white)
            }
        }
    }
}

class WebViewModel: ObservableObject {
    @Published var isLoading: Bool = true
    @Published var estimatedProgress: Double = 0.0
    @Published var hasError: Bool = false
    @Published var canGoBack: Bool = false
    @Published var canGoForward: Bool = false
    
    var webView: WKWebView?
    
    func reload() {
        hasError = false
        webView?.reload()
    }
    
    func goBack() {
        webView?.goBack()
    }
    
    func goForward() {
        webView?.goForward()
    }
}

struct SwiftUIWebView: UIViewRepresentable {
    @ObservedObject var viewModel: WebViewModel
    let urlString: String
    
    func makeCoordinator() -> Coordinator {
        Coordinator(viewModel: viewModel)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.bounces = true
        
        // Add pull-to-refresh
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor(red: 0.78, green: 0.52, blue: 0.46, alpha: 1.0)
        refreshControl.addTarget(context.coordinator, action: #selector(Coordinator.handleRefreshControl(_:)), for: .valueChanged)
        webView.scrollView.refreshControl = refreshControl
        
        // Observers for progress and loading
        context.coordinator.setupObservers(for: webView)
        
        viewModel.webView = webView
        
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 30)
            webView.load(request)
        }
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
    
    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        var viewModel: WebViewModel
        private var progressObservation: NSKeyValueObservation?
        private var loadingObservation: NSKeyValueObservation?
        
        init(viewModel: WebViewModel) {
            self.viewModel = viewModel
        }
        
        func setupObservers(for webView: WKWebView) {
            progressObservation = webView.observe(\.estimatedProgress, options: [.new]) { [weak self] view, _ in
                DispatchQueue.main.async {
                    self?.viewModel.estimatedProgress = view.estimatedProgress
                }
            }
            
            loadingObservation = webView.observe(\.isLoading, options: [.new]) { [weak self] view, _ in
                DispatchQueue.main.async {
                    self?.viewModel.isLoading = view.isLoading
                    self?.viewModel.canGoBack = view.canGoBack
                    self?.viewModel.canGoForward = view.canGoForward
                }
            }
        }
        
        @objc func handleRefreshControl(_ sender: UIRefreshControl) {
            viewModel.webView?.reload()
            sender.endRefreshing()
        }
        
        // Handle external links (WhatsApp, UPI, Phone, Mail, App Store, GPay, Tez, PhonePe, Paytm, BHIM, CRED)
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            guard let url = navigationAction.request.url else {
                decisionHandler(.allow)
                return
            }
            
            let scheme = url.scheme?.lowercased() ?? ""
            
            // Normal HTTP/HTTPS web navigation
            if scheme == "http" || scheme == "https" || scheme == "about" || scheme == "data" {
                decisionHandler(.allow)
                return
            }
            
            // All custom schemes (upi, gpay, tez, phonepe, paytmmp, paytm, bhim, credpay, whatsapp, tel, mailto, etc.)
            UIApplication.shared.open(url, options: [:]) { success in
                if !success {
                    print("Could not open custom scheme: \(url)")
                }
            }
            
            // Cancel inside WKWebView so it never attempts to render a custom scheme as an HTML page
            decisionHandler(.cancel)
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            DispatchQueue.main.async {
                self.viewModel.hasError = false
            }
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            let nsError = error as NSError
            if nsError.code != NSURLErrorCancelled {
                DispatchQueue.main.async {
                    self.viewModel.hasError = true
                }
            }
        }
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            let nsError = error as NSError
            if nsError.code != NSURLErrorCancelled {
                DispatchQueue.main.async {
                    self.viewModel.hasError = true
                }
            }
        }
        
        // Handle target="_blank" and window.open (new window / payment popups)
        func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
            if let url = navigationAction.request.url {
                let scheme = url.scheme?.lowercased() ?? ""
                if scheme != "http" && scheme != "https" && scheme != "about" && scheme != "data" {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    return nil
                }
            }
            if navigationAction.targetFrame == nil {
                webView.load(navigationAction.request)
            }
            return nil
        }
    }
}
