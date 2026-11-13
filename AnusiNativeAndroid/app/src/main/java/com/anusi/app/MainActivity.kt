package com.anusi.app

import android.annotation.SuppressLint
import android.content.Intent
import android.graphics.Bitmap
import android.net.Uri
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.os.Message
import android.view.View
import android.view.animation.AccelerateDecelerateInterpolator
import android.view.animation.AlphaAnimation
import android.view.animation.AnimationSet
import android.view.animation.OvershootInterpolator
import android.view.animation.ScaleAnimation
import android.webkit.CookieManager
import android.webkit.WebChromeClient
import android.webkit.WebResourceError
import android.webkit.WebResourceRequest
import android.webkit.WebSettings
import android.webkit.WebView
import android.webkit.WebViewClient
import android.widget.FrameLayout
import android.widget.ImageView
import android.widget.ProgressBar
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.swiperefreshlayout.widget.SwipeRefreshLayout

class MainActivity : AppCompatActivity() {

    private lateinit var webView: WebView
    private lateinit var swipeRefreshLayout: SwipeRefreshLayout
    private lateinit var progressBar: ProgressBar
    private lateinit var splashContainer: FrameLayout
    private lateinit var splashLogo: ImageView

    private val targetUrl = "https://anusi.in"

    @SuppressLint("SetJavaScriptEnabled")
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        webView = findViewById(R.id.webView)
        swipeRefreshLayout = findViewById(R.id.swipeRefreshLayout)
        progressBar = findViewById(R.id.progressBar)
        splashContainer = findViewById(R.id.splashContainer)
        splashLogo = findViewById(R.id.splashLogo)

        setupWebView()
        startFlipkartMyntraAnimation()

        swipeRefreshLayout.setColorSchemeResources(R.color.primary)
        swipeRefreshLayout.setOnRefreshListener {
            webView.reload()
        }

        webView.loadUrl(targetUrl)
    }

    @SuppressLint("SetJavaScriptEnabled")
    private fun setupWebView() {
        val settings = webView.settings
        settings.javaScriptEnabled = true
        settings.domStorageEnabled = true
        settings.databaseEnabled = true
        settings.allowFileAccess = true
        settings.cacheMode = WebSettings.LOAD_DEFAULT
        settings.useWideViewPort = true
        settings.loadWithOverviewMode = true
        settings.mixedContentMode = WebSettings.MIXED_CONTENT_ALWAYS_ALLOW
        settings.javaScriptCanOpenWindowsAutomatically = true
        settings.setSupportMultipleWindows(true)

        // Enable third-party cookies for Shiprocket Fastrr and payment gateways
        val cookieManager = CookieManager.getInstance()
        cookieManager.setAcceptCookie(true)
        cookieManager.setAcceptThirdPartyCookies(webView, true)

        webView.webViewClient = object : WebViewClient() {
            override fun shouldOverrideUrlLoading(view: WebView?, request: WebResourceRequest?): Boolean {
                val url = request?.url?.toString() ?: return false
                return handleCustomUrl(url)
            }

            @Deprecated("Deprecated in Java")
            override fun shouldOverrideUrlLoading(view: WebView?, url: String?): Boolean {
                if (url == null) return false
                return handleCustomUrl(url)
            }

            override fun onPageStarted(view: WebView?, url: String?, favicon: Bitmap?) {
                super.onPageStarted(view, url, favicon)
                progressBar.visibility = View.VISIBLE
            }

            override fun onPageFinished(view: WebView?, url: String?) {
                super.onPageFinished(view, url)
                progressBar.visibility = View.GONE
                swipeRefreshLayout.isRefreshing = false
            }

            override fun onReceivedError(view: WebView?, request: WebResourceRequest?, error: WebResourceError?) {
                super.onReceivedError(view, request, error)
                swipeRefreshLayout.isRefreshing = false
            }
        }

        webView.webChromeClient = object : WebChromeClient() {
            override fun onProgressChanged(view: WebView?, newProgress: Int) {
                progressBar.progress = newProgress
                if (newProgress >= 100) {
                    progressBar.visibility = View.GONE
                }
            }

            // Handle payment gateway popups & window.open
            override fun onCreateWindow(
                view: WebView?,
                isDialog: Boolean,
                isUserGesture: Boolean,
                resultMsg: Message?
            ): Boolean {
                val tempWebView = WebView(this@MainActivity)
                tempWebView.settings.javaScriptEnabled = true
                tempWebView.settings.domStorageEnabled = true
                tempWebView.webViewClient = object : WebViewClient() {
                    override fun shouldOverrideUrlLoading(view: WebView?, request: WebResourceRequest?): Boolean {
                        val popupUrl = request?.url?.toString() ?: return false
                        if (handleCustomUrl(popupUrl)) {
                            return true
                        }
                        webView.loadUrl(popupUrl)
                        return true
                    }

                    @Deprecated("Deprecated in Java")
                    override fun shouldOverrideUrlLoading(view: WebView?, url: String?): Boolean {
                        if (url == null) return false
                        if (handleCustomUrl(url)) {
                            return true
                        }
                        webView.loadUrl(url)
                        return true
                    }
                }
                val transport = resultMsg?.obj as? WebView.WebViewTransport
                transport?.webView = tempWebView
                resultMsg?.sendToTarget()
                return true
            }
        }
    }

    private fun handleCustomUrl(url: String): Boolean {
        // 1. UPI & PAYMENT APPS (GPay, PhonePe, Tez, Paytm, BHIM, CRED, MobiKwik)
        if (url.startsWith("upi://", ignoreCase = true) ||
            url.startsWith("gpay://", ignoreCase = true) ||
            url.startsWith("tez://", ignoreCase = true) ||
            url.startsWith("phonepe://", ignoreCase = true) ||
            url.startsWith("paytmmp://", ignoreCase = true) ||
            url.startsWith("paytm://", ignoreCase = true) ||
            url.startsWith("bhim://", ignoreCase = true) ||
            url.startsWith("credpay://", ignoreCase = true) ||
            url.startsWith("mobikwik://", ignoreCase = true)
        ) {
            try {
                val intent = Intent(Intent.ACTION_VIEW, Uri.parse(url))
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)

                // Launch via system chooser so GPay, PhonePe, Paytm all appear
                val chooser = Intent.createChooser(intent, "Pay with UPI")
                chooser.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                startActivity(chooser)
                return true
            } catch (e: Exception) {
                try {
                    val intent = Intent(Intent.ACTION_VIEW, Uri.parse(url))
                    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    startActivity(intent)
                    return true
                } catch (e2: Exception) {
                    Toast.makeText(this@MainActivity, "No UPI payment app found (GPay, PhonePe, Paytm)", Toast.LENGTH_SHORT).show()
                }
                return true
            }
        }

        // 2. ANDROID INTENT SCHEME (intent://...) - used by Truecaller, Fastrr, UPI gateways
        if (url.startsWith("intent://", ignoreCase = true)) {
            try {
                val intent = Intent.parseUri(url, Intent.URI_INTENT_SCHEME)
                intent.addCategory(Intent.CATEGORY_BROWSABLE)
                intent.component = null
                intent.selector = null
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)

                try {
                    startActivity(intent)
                    return true
                } catch (e: Exception) {
                    // Check if intent is for a UPI payment
                    val scheme = intent.scheme
                    val data = intent.dataString
                    if (scheme.equals("upi", ignoreCase = true) || data?.startsWith("upi://", ignoreCase = true) == true) {
                        try {
                            val upiIntent = Intent(Intent.ACTION_VIEW, Uri.parse(data ?: "upi://pay"))
                            upiIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                            val chooser = Intent.createChooser(upiIntent, "Pay with UPI")
                            chooser.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                            startActivity(chooser)
                            return true
                        } catch (eUpi: Exception) {
                            Toast.makeText(this@MainActivity, "Please install a UPI app (PhonePe/GPay/Paytm) to pay", Toast.LENGTH_SHORT).show()
                            return true
                        }
                    }

                    // Fallback to browser URL if provided
                    val fallbackUrl = intent.getStringExtra("browser_fallback_url")
                    if (!fallbackUrl.isNullOrEmpty()) {
                        webView.loadUrl(fallbackUrl)
                        return true
                    }

                    val pkg = intent.`package`
                    if (!pkg.isNullOrEmpty() && (pkg.contains("truecaller") || scheme?.contains("truecaller") == true)) {
                        Toast.makeText(this@MainActivity, "Truecaller app not installed on this device", Toast.LENGTH_SHORT).show()
                        return true
                    }

                    return true
                }
            } catch (e: Exception) {
                return true
            }
        }

        // 3. TRUECALLER DIRECT SCHEMES (truecallersdk://, truecaller://, tc://)
        if (url.startsWith("truecallersdk://", ignoreCase = true) ||
            url.startsWith("truecaller://", ignoreCase = true) ||
            url.startsWith("tc://", ignoreCase = true)
        ) {
            try {
                val intent = Intent(Intent.ACTION_VIEW, Uri.parse(url))
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                startActivity(intent)
            } catch (e: Exception) {
                Toast.makeText(this@MainActivity, "Truecaller app not installed on this device", Toast.LENGTH_SHORT).show()
            }
            return true
        }

        // 4. WHATSAPP SUPPORT
        if (url.startsWith("whatsapp://", ignoreCase = true) ||
            url.contains("wa.me", ignoreCase = true) ||
            url.contains("api.whatsapp.com", ignoreCase = true)
        ) {
            try {
                val intent = Intent(Intent.ACTION_VIEW, Uri.parse(url))
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                startActivity(intent)
            } catch (e: Exception) {
                Toast.makeText(this@MainActivity, "WhatsApp is not installed", Toast.LENGTH_SHORT).show()
            }
            return true
        }

        // 5. DIALER, SMS & EMAIL
        if (url.startsWith("tel:", ignoreCase = true) ||
            url.startsWith("mailto:", ignoreCase = true) ||
            url.startsWith("sms:", ignoreCase = true)
        ) {
            try {
                val intent = Intent(Intent.ACTION_VIEW, Uri.parse(url))
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                startActivity(intent)
            } catch (e: Exception) {
                // ignore
            }
            return true
        }

        // 6. ALL OTHER NON-HTTP SCHEMES
        val isHttp = url.startsWith("http://", ignoreCase = true) || url.startsWith("https://", ignoreCase = true)
        if (!isHttp) {
            try {
                val intent = Intent(Intent.ACTION_VIEW, Uri.parse(url))
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                startActivity(intent)
            } catch (e: Exception) {
                // ignore
            }
            return true // Always consume so WebView never shows net::ERR_UNKNOWN_URL_SCHEME
        }

        // Standard HTTP / HTTPS URL -> allow WebView to load normally
        return false
    }

    private fun startFlipkartMyntraAnimation() {
        // 1. IN-ANIMATION: Flipkart / Myntra Signature Elastic Pop
        val inAnim = AnimationSet(true).apply {
            interpolator = OvershootInterpolator(1.6f)
            duration = 550
            addAnimation(ScaleAnimation(0.55f, 1.0f, 0.55f, 1.0f,
                ScaleAnimation.RELATIVE_TO_SELF, 0.5f,
                ScaleAnimation.RELATIVE_TO_SELF, 0.5f))
            addAnimation(AlphaAnimation(0.3f, 1.0f))
        }
        splashLogo.startAnimation(inAnim)

        // 2. SUBTLE HEARTBEAT PULSE (after 600ms)
        Handler(Looper.getMainLooper()).postDelayed({
            val pulseAnim = AnimationSet(true).apply {
                duration = 350
                interpolator = AccelerateDecelerateInterpolator()
                addAnimation(ScaleAnimation(1.0f, 1.05f, 1.0f, 1.05f,
                    ScaleAnimation.RELATIVE_TO_SELF, 0.5f,
                    ScaleAnimation.RELATIVE_TO_SELF, 0.5f))
            }
            splashLogo.startAnimation(pulseAnim)
        }, 650)

        // 3. OUT-ANIMATION: Flipkart / Myntra Signature Zoom-Out & Reveal at 1.8s
        Handler(Looper.getMainLooper()).postDelayed({
            val outAnim = AnimationSet(true).apply {
                duration = 450
                interpolator = AccelerateDecelerateInterpolator()
                addAnimation(ScaleAnimation(1.0f, 1.30f, 1.0f, 1.30f,
                    ScaleAnimation.RELATIVE_TO_SELF, 0.5f,
                    ScaleAnimation.RELATIVE_TO_SELF, 0.5f))
                addAnimation(AlphaAnimation(1.0f, 0.0f))
            }

            val containerFade = AlphaAnimation(1.0f, 0.0f).apply {
                duration = 450
                interpolator = AccelerateDecelerateInterpolator()
            }

            splashLogo.startAnimation(outAnim)
            splashContainer.startAnimation(containerFade)

            Handler(Looper.getMainLooper()).postDelayed({
                splashContainer.visibility = View.GONE
            }, 440)
        }, 1800)
    }

    override fun onBackPressed() {
        if (webView.canGoBack()) {
            webView.goBack()
        } else {
            super.onBackPressed()
        }
    }
}
