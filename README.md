# Reboot — Flutter + Android Accessibility blocking

This project uses Flutter for the app UI and a native Kotlin Android Accessibility Service for best-effort app and browser URL blocking. It does not use Android VpnService, DNS filtering, or a local VPN.

## Features in this update
- Select installed launcher apps to include in a commitment.
- Persist a commitment expiry and selected package list on Android.
- Detect selected app foreground events and show a Reboot pause screen.
- Best-effort Instagram URL detection in Chrome, Samsung Internet, Firefox and Edge where URL text is exposed through Accessibility.
- One emergency bypass per commitment, lasting five minutes. The original expiry timestamp continues unchanged.
- Optional generated password protection. Passwords are encrypted with an Android Keystore AES-GCM key and are not written into the Flutter commitment JSON.

## Android setup
1. Install the APK.
2. Open Reboot settings and enable its Accessibility service in Android Settings.
3. Create a commitment and select installed apps. Only one active commitment is allowed so the single emergency bypass maps unambiguously to that session.
4. Test with a short commitment before relying on it.

## Limitations
Accessibility blocking is not tamper-proof. The user can disable the service, force-stop or uninstall Reboot, use another profile/device, or exploit OEM battery restrictions. Browser URL detection is best-effort: browsers may hide URL text, change their accessibility tree, or use in-app web views that are not supported. The service should be tested on the target Samsung model and Android version.

The five-minute bypass is stored in app-private preferences and is consumed once per active native session. The timer remains anchored to the persisted expiry timestamp.

## Build
Use Flutter 3.13+ compatible with the project's Dart SDK constraint and run `flutter pub get`, then `flutter build apk --release`. This source archive has not been compiled or tested on a physical device in this environment.
