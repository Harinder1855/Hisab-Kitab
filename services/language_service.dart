import 'package:flutter/material.dart';

// Global Notifier taaki puri app mein language change ho sake
ValueNotifier<String> appLanguage = ValueNotifier('English');

class LanguageService {
  static const Map<String, Map<String, String>> _localizedValues = {
    'English': {
      'app_title': 'Hisab Kitab',
      'you_gave': 'You Gave',
      'you_got': 'You Got',
      'total_get': "Total You'll Get",
      'total_give': "Total You'll Give",
      'add_customer': 'ADD CUSTOMER',
      'search': 'Search Customer...',
      'settings': 'Settings',
      'language': 'Language',
      'version': 'App Version',
      'dev_name': 'Developer Name',
      'total_cust': 'Total Customers',
      'contact_dev': 'Contact Developer',
    },
    'Hindi': {
      'app_title': 'हिसाब किताब',
      'you_gave': 'आपने दिया',
      'you_got': 'आपको मिला',
      'total_get': 'कुल आपको मिलेंगे',
      'total_give': 'कुल आपको देने हैं',
      'add_customer': 'कस्टमर जोड़ें',
      'search': 'कस्टमर खोजें...',
      'settings': 'सेटिंग्स',
      'language': 'भाषा (Language)',
      'version': 'ऐप वर्जन',
      'dev_name': 'डेवलपर का नाम',
      'total_cust': 'कुल कस्टमर',
      'contact_dev': 'डेवलपर से संपर्क करें',
    },
    'Punjabi': {
      'app_title': 'ਹਿਸਾਬ ਕਿਤਾਬ',
      'you_gave': 'ਤੁਸੀਂ ਦਿੱਤੇ',
      'you_got': 'ਤੁਹਾਨੂੰ ਮਿਲੇ',
      'total_get': 'ਕੁੱਲ ਤੁਹਾਨੂੰ ਮਿਲਣਗੇ',
      'total_give': 'ਕੁੱਲ ਤੁਹਾਨੂੰ ਦੇਣੇ ਪੈਣਗੇ',
      'add_customer': 'ਕਸਟਮਰ ਜੋੜੋ',
      'search': 'ਕਸਟਮਰ ਲੱਭੋ...',
      'settings': 'ਸੈਟਿੰਗਜ਼',
      'language': 'ਭਾਸ਼ਾ (Language)',
      'version': 'ਐਪ ਵਰਜ਼ਨ',
      'dev_name': 'ਡਿਵੈਲਪਰ ਦਾ ਨਾਮ',
      'total_cust': 'ਕੁੱਲ ਕਸਟਮਰ',
      'contact_dev': 'ਡਿਵੈਲਪਰ ਨਾਲ ਸੰਪਰਕ ਕਰੋ',
    }
  };

  static String t(String key) {
    return _localizedValues[appLanguage.value]?[key] ?? key;
  }
}