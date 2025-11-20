import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  // Cek apakah HP punya sensor sidik jari/wajah
  Future<bool> isBiometricAvailable() async {
    try {
      final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final bool canAuthenticate = canAuthenticateWithBiometrics || await _auth.isDeviceSupported();
      return canAuthenticate;
    } catch (e) {
      return false;
    }
  }

  // Eksekusi Autentikasi (Munculin Pop-up Sidik Jari)
  Future<bool> authenticate() async {
    try {
      return await _auth.authenticate(
        localizedReason: 'Pindai sidik jari untuk masuk ke DIRI',
        options: const AuthenticationOptions(
          stickyAuth: true, // Biar pop-up gak gampang ilang
          biometricOnly: true,
        ),
      );
    } catch (e) {
      return false;
    }
  }

  // Simpan Settingan User (Mau dikunci atau nggak?)
  Future<void> setBiometricEnabled(bool isEnabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_biometric_enabled', isEnabled);
  }

  // Cek Settingan User
  Future<bool> isBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_biometric_enabled') ?? false;
  }
}