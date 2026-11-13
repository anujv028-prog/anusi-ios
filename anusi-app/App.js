import React, { useState, useEffect, useRef } from 'react';
import {
  StyleSheet,
  View,
  Text,
  Image,
  Animated,
  Easing,
  StatusBar,
  SafeAreaView,
  Platform,
  Linking,
  TouchableOpacity,
  ActivityIndicator,
  BackHandler,
} from 'react-native';
import { WebView } from 'react-native-webview';
import { LinearGradient } from 'expo-linear-gradient';

const TARGET_URL = 'https://anusi.in';

export default function App() {
  const [showSplash, setShowSplash] = useState(true);
  const [webViewLoaded, setWebViewLoaded] = useState(false);
  const [loadProgress, setLoadProgress] = useState(0);
  const [hasError, setHasError] = useState(false);
  const [canGoBack, setCanGoBack] = useState(false);

  const webViewRef = useRef(null);

  // Animation values
  const fadeAnim = useRef(new Animated.Value(0)).current;
  const scaleAnim = useRef(new Animated.Value(0.85)).current;
  const floatAnim = useRef(new Animated.Value(0)).current;
  const splashOpacity = useRef(new Animated.Value(1)).current;
  const textFadeAnim = useRef(new Animated.Value(0)).current;

  useEffect(() => {
    // 1. Entrance animation (fade and scale up)
    Animated.parallel([
      Animated.timing(fadeAnim, {
        toValue: 1,
        duration: 1200,
        easing: Easing.out(Easing.cubic),
        useNativeDriver: true,
      }),
      Animated.spring(scaleAnim, {
        toValue: 1,
        friction: 6,
        tension: 40,
        useNativeDriver: true,
      }),
      Animated.timing(textFadeAnim, {
        toValue: 1,
        duration: 1500,
        delay: 400,
        easing: Easing.out(Easing.ease),
        useNativeDriver: true,
      }),
    ]).start();

    // 2. Butterfly subtle breathing float loop
    const floatLoop = Animated.loop(
      Animated.sequence([
        Animated.timing(floatAnim, {
          toValue: -6,
          duration: 1400,
          easing: Easing.inOut(Easing.sin),
          useNativeDriver: true,
        }),
        Animated.timing(floatAnim, {
          toValue: 4,
          duration: 1400,
          easing: Easing.inOut(Easing.sin),
          useNativeDriver: true,
        }),
      ])
    );
    floatLoop.start();

    // 3. Keep splash screen for at least 2.5s for luxury branding feel, then fade out
    const timer = setTimeout(() => {
      dismissSplash();
    }, 2800);

    // Hardware back press handling for Android
    const onBackPress = () => {
      if (canGoBack && webViewRef.current) {
        webViewRef.current.goBack();
        return true;
      }
      return false;
    };
    const backSubscription = BackHandler.addEventListener('hardwareBackPress', onBackPress);

    return () => {
      clearTimeout(timer);
      floatLoop.stop();
      backSubscription.remove();
    };
  }, [canGoBack]);

  const dismissSplash = () => {
    Animated.timing(splashOpacity, {
      toValue: 0,
      duration: 600,
      easing: Easing.inOut(Easing.ease),
      useNativeDriver: true,
    }).start(() => {
      setShowSplash(false);
    });
  };

  // Intercept links like WhatsApp, UPI, phone calls, etc.
  const handleShouldStartLoadWithRequest = (request) => {
    const { url } = request;

    // Check if it's an external app scheme
    const isHttp = url.startsWith('http://') || url.startsWith('https://');
    const isAnusi = url.includes('anusi.in');

    if (!isHttp) {
      // e.g. whatsapp://, tel:, mailto:, upi:, paytmmp:, phonepe:
      Linking.canOpenURL(url)
        .then((supported) => {
          if (supported) {
            Linking.openURL(url);
          }
        })
        .catch((err) => console.log('Link open error:', err));
      return false;
    }

    // Handle WhatsApp web redirect
    if (url.includes('wa.me') || url.includes('api.whatsapp.com')) {
      Linking.openURL(url).catch(() => {});
      return false;
    }

    return true;
  };

  const handleRetry = () => {
    setHasError(false);
    if (webViewRef.current) {
      webViewRef.current.reload();
    }
  };

  return (
    <SafeAreaView style={styles.safeArea}>
      <StatusBar barStyle="dark-content" backgroundColor="#FFFFFF" />

      {/* Main WebView Screen */}
      <View style={styles.container}>
        {/* Loading Progress Bar */}
        {loadProgress < 1 && loadProgress > 0 && (
          <View style={styles.progressBarBackground}>
            <View style={[styles.progressBarFill, { width: `${loadProgress * 100}%` }]} />
          </View>
        )}

        <WebView
          ref={webViewRef}
          source={{ uri: TARGET_URL }}
          style={styles.webView}
          javaScriptEnabled={true}
          domStorageEnabled={true}
          startInLoadingState={true}
          allowsBackForwardNavigationGestures={true}
          pullToRefreshEnabled={true}
          sharedCookiesEnabled={true}
          thirdPartyCookiesEnabled={true}
          onLoadProgress={({ nativeEvent }) => setLoadProgress(nativeEvent.progress)}
          onLoadEnd={() => {
            setWebViewLoaded(true);
            setHasError(false);
          }}
          onError={() => setHasError(true)}
          onNavigationStateChange={(navState) => {
            setCanGoBack(navState.canGoBack);
          }}
          onShouldStartLoadWithRequest={handleShouldStartLoadWithRequest}
          renderLoading={() => (
            <View style={styles.loadingContainer}>
              <ActivityIndicator size="small" color="#C48B71" />
            </View>
          )}
        />

        {/* Offline / Error Screen */}
        {hasError && (
          <View style={styles.errorOverlay}>
            <Image
              source={require('./assets/logo.png')}
              style={styles.errorLogo}
              resizeMode="contain"
            />
            <Text style={styles.errorTitle}>Connection Error</Text>
            <Text style={styles.errorMessage}>
              Unable to reach ANUSI. Please check your internet connection and tap retry.
            </Text>
            <TouchableOpacity style={styles.retryButton} onPress={handleRetry} activeOpacity={0.8}>
              <Text style={styles.retryButtonText}>RETRY</Text>
            </TouchableOpacity>
          </View>
        )}
      </View>

      {/* Animated Splash Screen Overlay */}
      {showSplash && (
        <Animated.View style={[styles.splashContainer, { opacity: splashOpacity }]} pointerEvents={showSplash ? 'auto' : 'none'}>
          <LinearGradient
            colors={['#FFFFFF', '#FDF9F7', '#FAF3F0']}
            style={styles.splashGradient}
          >
            <View style={styles.splashCenter}>
              <Animated.View
                style={[
                  styles.logoWrapper,
                  {
                    opacity: fadeAnim,
                    transform: [{ scale: scaleAnim }, { translateY: floatAnim }],
                  },
                ]}
              >
                <Image
                  source={require('./assets/logo.png')}
                  style={styles.splashLogo}
                  resizeMode="contain"
                />
              </Animated.View>

              <Animated.View style={[styles.taglineWrapper, { opacity: textFadeAnim }]}>
                <View style={styles.goldLine} />
                <Text style={styles.tagline}>HANDCRAFTED LUXURY</Text>
                <View style={styles.goldLine} />
              </Animated.View>
            </View>

            <Animated.View style={[styles.splashFooter, { opacity: textFadeAnim }]}>
              <ActivityIndicator size="small" color="#C48B71" />
              <Text style={styles.footerText}>anusi.in</Text>
            </Animated.View>
          </LinearGradient>
        </Animated.View>
      )}
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safeArea: {
    flex: 1,
    backgroundColor: '#FFFFFF',
  },
  container: {
    flex: 1,
    position: 'relative',
    backgroundColor: '#FFFFFF',
  },
  webView: {
    flex: 1,
    backgroundColor: '#FFFFFF',
  },
  progressBarBackground: {
    height: 2.5,
    backgroundColor: '#F3E8E3',
    width: '100%',
    zIndex: 10,
  },
  progressBarFill: {
    height: '100%',
    backgroundColor: '#C48B71',
  },
  loadingContainer: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#FFFFFF',
  },
  errorOverlay: {
    ...StyleSheet.absoluteFillObject,
    backgroundColor: '#FFFFFF',
    justifyContent: 'center',
    alignItems: 'center',
    padding: 30,
    zIndex: 20,
  },
  errorLogo: {
    width: 140,
    height: 70,
    marginBottom: 20,
  },
  errorTitle: {
    fontSize: 20,
    fontWeight: '600',
    color: '#2A2A2A',
    marginBottom: 8,
  },
  errorMessage: {
    fontSize: 14,
    color: '#777777',
    textAlign: 'center',
    lineHeight: 20,
    marginBottom: 28,
  },
  retryButton: {
    backgroundColor: '#C48B71',
    paddingVertical: 12,
    paddingHorizontal: 36,
    borderRadius: 25,
    shadowColor: '#C48B71',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.3,
    shadowRadius: 8,
    elevation: 4,
  },
  retryButtonText: {
    color: '#FFFFFF',
    fontSize: 13,
    fontWeight: '700',
    letterSpacing: 2,
  },
  splashContainer: {
    ...StyleSheet.absoluteFillObject,
    zIndex: 9999,
  },
  splashGradient: {
    flex: 1,
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingVertical: 60,
  },
  splashCenter: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    width: '100%',
  },
  logoWrapper: {
    width: '82%',
    maxWidth: 320,
    aspectRatio: 1.8,
    justifyContent: 'center',
    alignItems: 'center',
    shadowColor: '#C48B71',
    shadowOffset: { width: 0, height: 10 },
    shadowOpacity: 0.25,
    shadowRadius: 20,
  },
  splashLogo: {
    width: '100%',
    height: '100%',
  },
  taglineWrapper: {
    flexDirection: 'row',
    alignItems: 'center',
    marginTop: 25,
    paddingHorizontal: 20,
  },
  goldLine: {
    width: 35,
    height: 1,
    backgroundColor: '#C48B71',
    opacity: 0.5,
  },
  tagline: {
    fontSize: 11,
    letterSpacing: 4,
    color: '#8A685B',
    fontWeight: '500',
    marginHorizontal: 12,
  },
  splashFooter: {
    alignItems: 'center',
    justifyContent: 'center',
    gap: 10,
  },
  footerText: {
    fontSize: 12,
    letterSpacing: 1.5,
    color: '#A08075',
    fontWeight: '400',
  },
});
