import React, { useState, useEffect, useRef } from 'react';
import {
  StyleSheet,
  View,
  Image,
  Animated,
  Easing,
  StatusBar,
  SafeAreaView,
  Linking,
  TouchableOpacity,
  Text,
  ActivityIndicator,
  BackHandler,
} from 'react-native';
import { WebView } from 'react-native-webview';

const TARGET_URL = 'https://anusi.in';

export default function App() {
  const [showSplash, setShowSplash] = useState(true);
  const [loadProgress, setLoadProgress] = useState(0);
  const [hasError, setHasError] = useState(false);
  const [canGoBack, setCanGoBack] = useState(false);

  const webViewRef = useRef(null);

  // In-animation states
  const fadeAnim = useRef(new Animated.Value(0)).current;
  const scaleAnim = useRef(new Animated.Value(0.78)).current;
  const floatAnim = useRef(new Animated.Value(0)).current;

  // Out-animation states
  const splashOpacity = useRef(new Animated.Value(1)).current;
  const outScaleAnim = useRef(new Animated.Value(1)).current;

  useEffect(() => {
    // 1. IN-ANIMATION: Smooth luxury scale-in and fade-in
    Animated.parallel([
      Animated.timing(fadeAnim, {
        toValue: 1,
        duration: 1100,
        easing: Easing.out(Easing.cubic),
        useNativeDriver: true,
      }),
      Animated.timing(scaleAnim, {
        toValue: 1,
        duration: 1100,
        easing: Easing.out(Easing.cubic),
        useNativeDriver: true,
      }),
    ]).start();

    // 2. BUTTERFLY BREATH / FLOAT: Subtle hover loop
    const floatLoop = Animated.loop(
      Animated.sequence([
        Animated.timing(floatAnim, {
          toValue: -5,
          duration: 1300,
          easing: Easing.inOut(Easing.sin),
          useNativeDriver: true,
        }),
        Animated.timing(floatAnim, {
          toValue: 3,
          duration: 1300,
          easing: Easing.inOut(Easing.sin),
          useNativeDriver: true,
        }),
      ])
    );
    floatLoop.start();

    // 3. OUT-ANIMATION: Majestic expand & fade-out transition after 2.4s
    const timer = setTimeout(() => {
      dismissSplash();
    }, 2400);

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
    Animated.parallel([
      Animated.timing(outScaleAnim, {
        toValue: 1.10,
        duration: 700,
        easing: Easing.inOut(Easing.ease),
        useNativeDriver: true,
      }),
      Animated.timing(splashOpacity, {
        toValue: 0,
        duration: 700,
        easing: Easing.inOut(Easing.ease),
        useNativeDriver: true,
      }),
    ]).start(() => {
      setShowSplash(false);
    });
  };

  const handleShouldStartLoadWithRequest = (request) => {
    const { url } = request;
    const isHttp = url.startsWith('http://') || url.startsWith('https://');

    if (!isHttp) {
      Linking.canOpenURL(url)
        .then((supported) => {
          if (supported) Linking.openURL(url);
        })
        .catch(() => {});
      return false;
    }

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
          onError={() => setHasError(true)}
          onNavigationStateChange={(navState) => setCanGoBack(navState.canGoBack)}
          onShouldStartLoadWithRequest={handleShouldStartLoadWithRequest}
          renderLoading={() => (
            <View style={styles.loadingContainer}>
              <ActivityIndicator size="small" color="#C48B71" />
            </View>
          )}
        />

        {hasError && (
          <View style={styles.errorOverlay}>
            <Image
              source={require('./assets/logo.png')}
              style={styles.errorLogo}
              resizeMode="contain"
            />
            <Text style={styles.errorTitle}>Connection Error</Text>
            <Text style={styles.errorMessage}>
              Unable to reach ANUSI.in. Please check your internet connection and tap retry.
            </Text>
            <TouchableOpacity style={styles.retryButton} onPress={handleRetry} activeOpacity={0.8}>
              <Text style={styles.retryButtonText}>RETRY</Text>
            </TouchableOpacity>
          </View>
        )}
      </View>

      {/* Luxury Animated Splash Screen */}
      {showSplash && (
        <Animated.View
          style={[styles.splashContainer, { opacity: splashOpacity }]}
          pointerEvents={showSplash ? 'auto' : 'none'}
        >
          <View style={styles.splashCenter}>
            <Animated.View
              style={[
                styles.logoWrapper,
                {
                  opacity: fadeAnim,
                  transform: [
                    { scale: Animated.multiply(scaleAnim, outScaleAnim) },
                    { translateY: floatAnim },
                  ],
                },
              ]}
            >
              <Image
                source={require('./assets/logo.png')}
                style={styles.splashLogo}
                resizeMode="contain"
              />
            </Animated.View>
          </View>
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
    backgroundColor: '#FFFFFF',
    zIndex: 9999,
  },
  splashCenter: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  logoWrapper: {
    width: '80%',
    maxWidth: 320,
    aspectRatio: 1.8,
    justifyContent: 'center',
    alignItems: 'center',
    shadowColor: '#C48B71',
    shadowOffset: { width: 0, height: 12 },
    shadowOpacity: 0.3,
    shadowRadius: 24,
  },
  splashLogo: {
    width: '100%',
    height: '100%',
  },
});
