package in.anusi.app

import android.annotation.SuppressLint
import android.content.Intent
import android.graphics.Bitmap
import android.net.Uri
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.view.View
import android.view.animation.AccelerateDecelerateInterpolator
import android.view.animation.AlphaAnimation
import android.view.animation.AnimationSet
import android.view.animation.OvershootInterpolator
import android.view.animation.ScaleAnimation
import android.webkit.WebChromeClient
import android.webkit.WebResourceError
import android.webkit.WebResourceRequest
import android.webkit.WebSettings
import android.webkit.WebView
import android.webkit.WebViewClient
import android.widget.FrameLayout
import android.widget.ImageView
import android.widget.ProgressBar
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

        webView.webViewClient = object : WebViewClient() {
            override fun shouldOverrideUrlLoading(view: WebView?, request: WebResourceRequest?): Boolean {
                val url = request?.url?.toString() ?: return false
                val isHttp = url.startsWith("http://") || url.startsWith("https://")

                if (!isHttp) {
                    try {
                        val intent = Intent(Intent.ACTION_VIEW, Uri.parse(url))
                        startActivity(intent)
                        return true
                    } catch (e: Exception) {
                        return false
                    }
                }

                if (url.contains("wa.me") || url.contains("api.whatsapp.com")) {
                    try {
                        val intent = Intent(Intent.ACTION_VIEW, Uri.parse(url))
                        startActivity(intent)
                        return true
                    } catch (e: Exception) {
                        // ignore
                    }
                }

                return false
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
        }
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
