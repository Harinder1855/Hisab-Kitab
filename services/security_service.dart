import 'package:local_auth/local_auth.dart';

class SecurityService {
  static final LocalAuthentication _auth = LocalAuthentication(); // static dhyan se lagao

  static Future<bool> canCheckBiometrics() async { // static dhyan se lagao
    final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
    return canAuthenticateWithBiometrics || await _auth.isDeviceSupported();
  }

  static Future<bool> authenticate() async { // static dhyan se lagao
    try {
      return await _auth.authenticate(
        localizedReason: 'Unlock Hisab Kitab',
        options: const AuthenticationOptions(stickyAuth: true),
      );
    } catch (e) {
      return false;
    }
  }
}