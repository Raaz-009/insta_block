# Reboot — Flutter + native Android protection

Reboot combines a commitment timer with Android-native Instagram app and website restrictions.

## What is implemented

- Flutter UI and commitment timer remain the app's user experience.
- `LockManager` persists the commitment expiry and synchronizes the expiry timestamp with Android through `MethodChannel` (`com.reboot/blocking`).
- `InstagramAccessibilityService` watches foreground-window/content events and redirects Instagram app launches (and supported browser views that expose an Instagram URL in accessibility text) to a Reboot pause screen.
- `InstagramVpnService` creates a local Android VPN interface that routes the configured DNS endpoint through a small DNS proxy. It returns NXDOMAIN for Instagram domains and forwards other UDP DNS lookups to Cloudflare DNS. Its socket is protected from VPN routing to avoid a loop.
- The VPN service is scheduled to stop at the saved commitment expiry. The accessibility service independently checks the same expiry before acting.
- When the Flutter app starts, it reconciles native protection with the persisted active commitment.

## Setup on an Android phone

1. Install the release APK.
2. Open Reboot settings (the tune icon on Home) and tap **Enable app blocking**.
3. In Android Accessibility settings, open **Downloaded apps / Installed apps → Reboot** and enable the service. Android will show its accessibility disclosure; approve only if you understand the permission.
4. Return to Reboot and start a commitment. Android will ask to authorize Reboot's VPN connection. Approve it.
5. Confirm the Android VPN key/status indicator is present. Test `instagram.com` in a supported browser and launch the Instagram app.
6. Let a short test commitment expire and confirm the VPN indicator disappears and Instagram is accessible again.

## Build APK

The GitHub Actions workflow `.github/workflows/build-apk.yml` builds `app-release.apk` on pushes to `main` or via **Actions → Build Reboot APK → Run workflow**. Download the `reboot-android-apk` artifact after a successful run.

## Important limitations

- This is an Android-only personal-use implementation. The VPN permission is user-approved and Android may revoke/stop it; accessibility can be disabled by the user or restricted by OEM battery management.
- DNS filtering blocks common Instagram hostnames when requests use the VPN-provided DNS server. It does not inspect HTTPS content and cannot guarantee blocking against DNS-over-HTTPS/DoT, another VPN, hard-coded IPs, proxy apps, or every browser configuration. Browser URL detection through accessibility is best-effort and browser-specific.
- The current DNS proxy handles UDP DNS over IPv4. It is a deliberately narrow DNS filter, not a general-purpose VPN router. IPv6, TCP DNS, encrypted DNS, and unusual resolver behavior need device testing and further hardening.
- The Accessibility API is powerful. Reboot uses it only to detect target app/browser foreground content and open its own pause screen; it does not read credentials or transmit accessibility content.
- This build is not a tamper-proof parental-control / kiosk product. A user who controls the phone can disable permissions, uninstall Reboot, or use alternate network paths.
- Existing VPN apps generally conflict with Reboot's local VPN because Android permits only one active VPN per user/profile.

## Testing checklist

- Grant accessibility before starting a session; verify `InstagramAccessibilityService` is enabled in Android settings.
- Start a 1-day commitment and approve VPN; verify notification and VPN key.
- Verify Instagram app foreground triggers Reboot pause screen.
- Verify `instagram.com` and `www.instagram.com` fail to resolve in Chrome/Samsung Internet.
- Verify unrelated domains still resolve.
- Force-stop and reopen Reboot; confirm the same saved expiry remains enforced.
- Reboot the phone and reopen Reboot; confirm Flutter reconciles active commitment and re-establishes VPN consent if Android requires it.
- Wait for expiry; confirm service stops and Instagram works again.

## Security follow-up

The original app stores the reveal password in SharedPreferences. Before using real account passwords, migrate secrets to Android Keystore-backed encrypted storage (for example, `flutter_secure_storage`) and review backup/export behavior. Prefer a randomly generated password used only for the commitment, not a reused account password.
