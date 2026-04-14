import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:intl/intl.dart';
import 'services/database.dart';
import 'models/customer.dart';
import 'models/transaction.dart';
import 'models/cash_entry.dart';
import 'services/pdf_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'services/auth_service.dart';
import 'services/sync_service.dart';
import 'screens/login_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'services/security_service.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'services/ad_service.dart';



// --- GLOBAL NOTIFIERS ---
final ValueNotifier<int> databaseUpdateNotifier = ValueNotifier(0);
final ValueNotifier<String> appLanguage = ValueNotifier('English');
final ValueNotifier<bool> isAppUnlocked = ValueNotifier(false);

// --- LANGUAGE SERVICE ---

class LanguageService {
  static const Map<String, Map<String, String>> _localizedValues = {
    'English': {
      'app_title': 'Hisab Kitab', 'tab_hisab': 'Hisab Kitab', 'tab_cash': 'Cashbook',
      'you_gave': 'You Gave', 'you_got': 'You Got', 'total_get': "You'll Get", 'total_give': "You'll Give",
      'search_hint': 'Search Customer...', 'add_cust': 'ADD CUSTOMER', 'settings': 'Settings',
      'language': 'Language', 'version': 'Version', 'dev_name': 'Developer', 'total_cust': 'Total Customers',
      'contact_dev': 'Contact', 'save': 'SAVE', 'cancel': 'CANCEL', 'delete': 'DELETE',
      'edit_entry': 'Edit Entry', 'new_entry': 'New Entry', 'cust_details': 'Customer Details',
      'cash_in': 'Total In (+)', 'cash_out': 'Total Out (-)', 'balance': 'Cash Balance', 'add_cash': 'ADD CASH',
      'from': 'From', 'to': 'To', 'all': 'All', 'date_note': 'Date / Note',
      // New additions
      'pick_contacts': 'Pick from Contacts', 'edit_cust': 'Edit Customer Details', 'update': 'UPDATE',
      'name': 'Name', 'mobile': 'Mobile', 'select_date': 'Select',
      'app_lock': 'App Lock', 'lock_desc': 'Enable Fingerprint or PIN',
      'business_profile': 'Business Profile', 'business_desc': 'Shop details for PDF',
      'shop_name': 'Shop Name', 'address': 'Address',
      'logout': 'Logout', 'backup_clear': 'Backup & Clear App',
      'profile_saved': 'Profile Saved!', 'sync_logout': 'Syncing & Logging out...'
    },
    'Hindi': {
      'app_title': 'हिसाब किताब', 'tab_hisab': 'हिसाब किताब', 'tab_cash': 'कैशबुक',
      'you_gave': 'आपने दिया', 'you_got': 'आपको मिला', 'total_get': "लेंने हैं", 'total_give': "देने हैं",
      'search_hint': 'कस्टमर खोजें...', 'add_cust': 'कस्टमर जोड़ें', 'settings': 'सेटिंग्स',
      'language': 'भाषा', 'version': 'वर्जन', 'dev_name': 'डेवलपर', 'total_cust': 'कुल कस्टमर',
      'contact_dev': 'संपर्क', 'save': 'सेव करें', 'cancel': 'रद्द करें', 'delete': 'हटाएं',
      'edit_entry': 'बदलें', 'new_entry': 'नई एंट्री', 'cust_details': 'जानकारी',
      'cash_in': 'कुल आया (+)', 'cash_out': 'कुल गया (-)', 'balance': 'नगद बैलेंस', 'add_cash': 'कैश जोड़ें',
      'from': 'शुरुआत', 'to': 'अंत', 'all': 'सब', 'date_note': 'तारीख / नोट',
      // New additions
      'pick_contacts': 'संपर्क से चुनें', 'edit_cust': 'कस्टमर एडिट करें', 'update': 'अपडेट',
      'name': 'नाम', 'mobile': 'मोबाइल', 'select_date': 'चुनें',
      'app_lock': 'ऐप लॉक', 'lock_desc': 'फिंगरप्रिंट या पिन चालू करें',
      'business_profile': 'बिजनेस प्रोफाइल', 'business_desc': 'PDF के लिए दुकान की जानकारी',
      'shop_name': 'दुकान का नाम', 'address': 'पता',
      'logout': 'लॉग आउट', 'backup_clear': 'बैकअप और ऐप साफ़ करें',
      'profile_saved': 'प्रोफाइल सेव हो गई!', 'sync_logout': 'सिंक और लॉग आउट हो रहा है...'
    },
    'Punjabi': {
      'app_title': 'ਹਿਸਾਬ ਕਿਤਾਬ', 'tab_hisab': 'ਹਿਸਾਬ ਕਿਤਾਬ', 'tab_cash': 'ਕੈਸ਼ਬੁੱਕ',
      'you_gave': 'ਤੁਸੀਂ ਦਿੱਤੇ', 'you_got': 'ਤੁਹਾਨੂੰ ਮਿਲੇ', 'total_get': "ਲੈਣੇ ਹਨ", 'total_give': "ਦੇਣੇ ਹਨ",
      'search_hint': 'ਖੋਜੋ...', 'add_cust': 'ਕਸਟਮਰ ਜੋੜੋ', 'settings': 'ਸੈਟਿੰਗਜ਼',
      'language': 'ਭਾਸ਼ਾ', 'version': 'ਵਰਜ਼ਨ', 'dev_name': 'ਡਿਵੈਲਪਰ', 'total_cust': 'ਕੁੱਲ ਕਸਟਮਰ',
      'contact_dev': 'ਸੰਪਰਕ', 'save': 'ਸੇਵ', 'cancel': 'ਰੱਦ', 'delete': 'ਡਿਲੀਟ',
      'edit_entry': 'ਸੋਧੋ', 'new_entry': 'ਨਵੀਂ ਐਂਟਰੀ', 'cust_details': 'ਵੇਰਵਾ',
      'cash_in': 'ਆਇਆ (+)', 'cash_out': 'ਗਿਆ (-)', 'balance': 'ਨਕਦ ਬਕਾਇਆ', 'add_cash': 'ਨਕਦ ਜੋੜੋ',
      'from': 'ਤੋਂ', 'to': 'ਤੱਕ', 'all': 'ਸਭ', 'date_note': 'ਤਰੀਕ / ਨੋਟ',
      // New additions
      'pick_contacts': 'ਸੰਪਰਕਾਂ ਵਿੱਚੋਂ ਚੁਣੋ', 'edit_cust': 'ਕਸਟਮਰ ਸੋਧੋ', 'update': 'ਅਪਡੇਟ',
      'name': 'ਨਾਮ', 'mobile': 'ਮੋਬਾਈਲ', 'select_date': 'ਚੁਣੋ',
      'app_lock': 'ਐਪ ਲੌਕ', 'lock_desc': 'ਫਿੰਗਰਪ੍ਰਿੰਟ ਜਾਂ ਪਿੰਨ ਚਾਲੂ ਕਰੋ',
      'business_profile': 'ਬਿਜ਼ਨਸ ਪ੍ਰੋਫਾਈਲ', 'business_desc': 'PDF ਲਈ ਦੁਕਾਨ ਦਾ ਵੇਰਵਾ',
      'shop_name': 'ਦੁਕਾਨ ਦਾ ਨਾਮ', 'address': 'ਪਤਾ',
      'logout': 'ਲੌਗ ਆਉਟ', 'backup_clear': 'ਬੈਕਅੱਪ ਅਤੇ ਐਪ ਸਾਫ਼ ਕਰੋ',
      'profile_saved': 'ਪ੍ਰੋਫਾਈਲ ਸੇਵ ਹੋ ਗਈ!', 'sync_logout': 'ਸਿੰਕ ਅਤੇ ਲੌਗ ਆਉਟ ਹੋ ਰਿਹਾ ਹੈ...'
    },
    'Gujarati': {
      'app_title': 'હિસાબ કિતાબ', 'tab_hisab': 'હિસાબ કિતાબ', 'tab_cash': 'રોકડમેળ',
      'you_gave': 'તમે આપ્યા', 'you_got': 'તમને મળ્યા', 'total_get': "લેવાના બાકી", 'total_give': "ચૂકવવાના બાકી",
      'search_hint': 'ગ્રાહક શોધો...', 'add_cust': 'ગ્રાહક ઉમેરો', 'settings': 'સેટિંગ્સ',
      'language': 'ભાષા', 'version': 'આવૃત્તિ', 'dev_name': 'ડેવલપર', 'total_cust': 'કુલ ગ્રાહકો',
      'contact_dev': 'સંપર્ક', 'save': 'સાચવો', 'cancel': 'રદ કરો', 'delete': 'કાઢી નાખો',
      'edit_entry': 'ફેરફાર કરો', 'new_entry': 'નવી નોંધ', 'cust_details': 'ગ્રાહક વિગતો',
      'cash_in': 'આવક (+)', 'cash_out': 'જાવક (-)', 'balance': 'રોકડ સિલક', 'add_cash': 'રોકડ ઉમેરો',
      'from': 'તારીખથી', 'to': 'તારીખ સુધી', 'all': 'બધું', 'date_note': 'તારીખ / નોંધ',
      // New additions
      'pick_contacts': 'સંપર્કોમાંથી પસંદ કરો', 'edit_cust': 'ગ્રાહક વિગતો સુધારો', 'update': 'અપડેટ',
      'name': 'નામ', 'mobile': 'મોબાઈલ', 'select_date': 'પસંદ કરો',
      'app_lock': 'એપ લોક', 'lock_desc': 'ફિંગરપ્રિન્ટ અથવા પિન સક્ષમ કરો',
      'business_profile': 'બિઝનેસ પ્રોફાઇલ', 'business_desc': 'PDF માટે દુકાનની વિગતો',
      'shop_name': 'દુકાનનું નામ', 'address': 'સરનામું',
      'logout': 'લોગ આઉટ', 'backup_clear': 'બેકઅપ અને એપ સાફ કરો',
      'profile_saved': 'પ્રોફાઇલ સાચવી!', 'sync_logout': 'સિંક અને લોગ આઉટ થઈ રહ્યું છે...'
    },
    'Marathi': {
      'app_title': 'हिशेब किताब', 'tab_hisab': 'हिशेब किताब', 'tab_cash': 'कॅशबुक',
      'you_gave': 'तुम्ही दिले', 'you_got': 'तुम्हाला मिळाले', 'total_get': "येणे बाकी", 'total_give': "देणे बाकी",
      'search_hint': 'ग्राहक शोधा...', 'add_cust': 'ग्राहक जोडा', 'settings': 'सेटिंग्ज',
      'language': 'भाषा', 'version': 'आवृत्ती', 'dev_name': 'डेव्हलपर', 'total_cust': 'एकूण ग्राहक',
      'contact_dev': 'संपर्क', 'save': 'जतन करा', 'cancel': 'रद्द करा', 'delete': 'हटवा',
      'edit_entry': 'संपादित करा', 'new_entry': 'नवीन नोंद', 'cust_details': 'ग्राहक तपशील',
      'cash_in': 'एकूण जमा (+)', 'cash_out': 'एकूण खर्च (-)', 'balance': 'शिल्लक रोकड', 'add_cash': 'कॅश जोडा',
      'from': 'पासून', 'to': 'पर्यंत', 'all': 'सर्व', 'date_note': 'तारीख / टीप',
      // New additions
      'pick_contacts': 'संपर्कातून निवडा', 'edit_cust': 'ग्राहक माहिती बदला', 'update': 'अपडेट',
      'name': 'नाव', 'mobile': 'मोबाईल', 'select_date': 'निवडा',
      'app_lock': 'ॲप लॉक', 'lock_desc': 'फिंगरप्रिंट किंवा पिन सुरू करा',
      'business_profile': 'व्यवसाय प्रोफाइल', 'business_desc': 'PDF साठी दुकानाची माहिती',
      'shop_name': 'दुकानाचे नाव', 'address': 'पत्ता',
      'logout': 'लॉग आउट', 'backup_clear': 'बॅकअप आणि ॲप साफ करा',
      'profile_saved': 'प्रोफाइल जतन केली!', 'sync_logout': 'सिंक आणि लॉग आउट होत आहे...'
    },
    'Bengali': {
      'app_title': 'হিসাব কিতাব', 'tab_hisab': 'হিসাব কিতাব', 'tab_cash': 'ক্যাশুবক',
      'you_gave': 'আপনি দিয়েছেন', 'you_got': 'আপনি পেয়েছেন', 'total_get': "পাবেন", 'total_give': "দেবেন",
      'search_hint': 'কাস্টমার খুঁজুন...', 'add_cust': 'কাস্টমার যোগ করুন', 'settings': 'সেটিংস',
      'language': 'ভাষা', 'version': 'সংস্করণ', 'dev_name': 'ডেভেলপার', 'total_cust': 'মোট কাস্টমার',
      'contact_dev': 'যোগাযোগ', 'save': 'সেভ', 'cancel': 'বাতিল', 'delete': 'মুছুন',
      'edit_entry': 'এডিট', 'new_entry': 'নতুন এন্ট্রি', 'cust_details': 'বিস্তারিত',
      'cash_in': 'মোট জমা (+)', 'cash_out': 'মোট খরচ (-)', 'balance': 'বর্তমান ব্যালেন্স', 'add_cash': 'ক্যাশ যোগ',
      'from': 'শুরু', 'to': 'শেষ', 'all': 'সব', 'date_note': 'তারিখ / নোট',
      // New additions
      'pick_contacts': 'কন্টাক্ট থেকে নিন', 'edit_cust': 'কাস্টমার এডিট করুন', 'update': 'আপডেট',
      'name': 'নাম', 'mobile': 'মোবাইল', 'select_date': 'বাছুন',
      'app_lock': 'অ্যাপ লক', 'lock_desc': 'ফিঙ্গারপ্রিন্ট বা পিন চালু করুন',
      'business_profile': 'ব্যবসার প্রোফাইল', 'business_desc': 'PDF এর জন্য দোকানের তথ্য',
      'shop_name': 'দোকানের নাম', 'address': 'ঠিকানা',
      'logout': 'লগ আউট', 'backup_clear': 'ব্যাকআপ এবং অ্যাপ পরিষ্কার',
      'profile_saved': 'প্রোফাইল সেভ হয়েছে!', 'sync_logout': 'সিঙ্ক এবং লগ আউট হচ্ছে...'
    },
    'Tamil': {
      'app_title': 'கணக்கு புத்தகம்', 'tab_hisab': 'கணக்கு', 'tab_cash': 'கேஷ் புக்',
      'you_gave': 'கொடுத்தது', 'you_got': 'பெற்றது', 'total_get': "வர வேண்டியது", 'total_give': "தர வேண்டியது",
      'search_hint': 'தேடுங்கள்...', 'add_cust': 'சேர்க்க', 'settings': 'அமைப்புகள்',
      'language': 'மொழி', 'version': 'பதிப்பு', 'dev_name': 'டெவலப்பர்', 'total_cust': 'மொத்த வாடிக்கையாளர்கள்',
      'contact_dev': 'தொடர்புக்கு', 'save': 'சேமி', 'cancel': 'ரத்து', 'delete': 'அழி',
      'edit_entry': 'திருத்த', 'new_entry': 'புதிய வரவு', 'cust_details': 'விவரங்கள்',
      'cash_in': 'மொத்த வரவு (+)', 'cash_out': 'மொத்த செலவு (-)', 'balance': 'மீதமுள்ள பணம்', 'add_cash': 'பணம் சேர்க்க',
      'from': 'முதல்', 'to': 'வரை', 'all': 'அனைத்தும்', 'date_note': 'தேதி / குறிப்பு',
      // New additions
      'pick_contacts': 'தொடர்புகளிலிருந்து எடு', 'edit_cust': 'வாடிக்கையாளர் திருத்தம்', 'update': 'புதுப்பி',
      'name': 'பெயர்', 'mobile': 'மொபைல்', 'select_date': 'தேர்வு',
      'app_lock': 'ஆப் லாக்', 'lock_desc': 'கைரேகை அல்லது பின்',
      'business_profile': 'வணிக விவரம்', 'business_desc': 'கடை விவரங்கள்',
      'shop_name': 'கடை பெயர்', 'address': 'முகவரி',
      'logout': 'வெளியேறு', 'backup_clear': 'காப்புப் பிரதி & அழி',
      'profile_saved': 'சேமிக்கப்பட்டது!', 'sync_logout': 'வெளியேறுகிறது...'
    },
    'Malayalam': {
      'app_title': 'കണക്കുപുസ്തകം', 'tab_hisab': 'കണക്ക്', 'tab_cash': 'കാഷ് ബുക്ക്',
      'you_gave': 'നൽകിയത്', 'you_got': 'ലഭിച്ചത്', 'total_get': "ലഭിക്കാനുണ്ട്", 'total_give': "നൽകാനുണ്ട്",
      'search_hint': 'തിരയുക...', 'add_cust': 'ചേർക്കുക', 'settings': 'ക്രമീകരണങ്ങൾ',
      'language': 'ഭാഷ', 'version': 'പതിപ്പ്', 'dev_name': 'ഡെവലപ്പർ', 'total_cust': 'ആകെ കസ്റ്റമേഴ്സ്',
      'contact_dev': 'ബന്ധപ്പെടുക', 'save': 'സേവ്', 'cancel': 'റദ്ദാക്കുക', 'delete': 'ഡിലീറ്റ്',
      'edit_entry': 'എഡിറ്റ്', 'new_entry': 'പുതിയ എൻട്രി', 'cust_details': 'വിശദാംശങ്ങൾ',
      'cash_in': 'ആകെ വരവ് (+)', 'cash_out': 'ആകെ ചെലവ് (-)', 'balance': 'കയ്യിലുള്ള പണം', 'add_cash': 'കാഷ് ചേർക്കുക',
      'from': 'മുതൽ', 'to': 'വരെ', 'all': 'എല്ലാം', 'date_note': 'തീയതി / കുറിപ്പ്',
      // New additions
      'pick_contacts': 'കോൺടാക്റ്റുകൾ', 'edit_cust': 'എഡിറ്റ് കസ്റ്റമർ', 'update': 'അപ്ഡേറ്റ്',
      'name': 'പേര്', 'mobile': 'മൊബൈൽ', 'select_date': 'തി',
      'app_lock': 'ആപ്പ് ലോക്ക്', 'lock_desc': 'ഫിംഗർപ്രിന്റ് അല്ലെങ്കിൽ പിൻ',
      'business_profile': 'ബിസിനസ് പ്രൊഫൈൽ', 'business_desc': 'കടയുടെ വിവരങ്ങൾ',
      'shop_name': 'കടയുടെ പേര്', 'address': 'വിലാസം',
      'logout': 'ലോഗ് ഔട്ട്', 'backup_clear': 'ബാക്കപ്പ് & ക്ലിയർ',
      'profile_saved': 'സേവ് ചെയ്തു!', 'sync_logout': 'ലോഗ് ഔട്ട് ചെയ്യുന്നു...'
    }
  };
  static String t(String key) => _localizedValues[appLanguage.value]?[key] ?? key;
  static List<String> get supportedLanguages => _localizedValues.keys.toList();
}

// --- main.dart ---
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  await Firebase.initializeApp();
  await DatabaseService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: appLanguage,
      builder: (context, lang, _) => MaterialApp(
        key: ValueKey(lang),
        // databaseUpdateNotifier wala builder yahan se HATA DIYA gaya hai
        home: StreamBuilder<User?>(
  stream: FirebaseAuth.instance.authStateChanges(),
  // main.dart ke build method mein jahan error aa raha hai:

builder: (context, snapshot) {
  if (snapshot.hasData) {
    // 🔥 Suraksha ke liye try-catch ya default value:
    bool isLockEnabled = false;
    try {
       isLockEnabled = DatabaseService.settingsBox.get('appLock', defaultValue: false);
    } catch (e) {
       print("Box not ready yet: $e");
    }
    
    if (isLockEnabled) {
      return ValueListenableBuilder<bool>(
        valueListenable: isAppUnlocked,
        builder: (context, unlocked, _) {
          if (unlocked) return const HomeScreen();
          return LockScreen();
        },
      );
    }
    return const HomeScreen();
  }
  return const LoginScreen();
},
),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

// --- HOME SCREEN ---
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _activeTab = 0;
  BannerAd? _bannerAd;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _cashAmountController = TextEditingController();
  final TextEditingController _cashNoteController = TextEditingController();
  String _searchQuery = ""; 
  final FocusNode _searchFocusNode = FocusNode(); 

  DateTime? _cashFromDate;
  DateTime? _cashToDate;

  @override
  void initState() {
    super.initState();
    // 1. Banner Ad Load karo
    _bannerAd = BannerAd(
      adUnitId: AdService.bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (_) => setState(() {}),
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          print("Ad Failed: $error");
        },
      ),
    )..load();
    
    // 2. Full screen ad ready rakho
    AdService.loadInterstitialAd();
  }

  @override
  void dispose() {
    _bannerAd?.dispose(); // Ad memory se hatao
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: appLanguage,
      builder: (context, lang, _) => Scaffold(
        backgroundColor: Colors.grey[50],
        body: SafeArea(
          child: Column(
            children: [
              _buildTopToggle(),
              // Main content (List)
              Expanded(
                child: _activeTab == 0 ? _buildHisabKitabView() : _buildCashbookView()
              ),
                                         
            ],
          ),
        ),
        floatingActionButton: _activeTab == 0 ? FloatingActionButton.extended(
          onPressed: () { _searchFocusNode.unfocus(); _showAddCustomerDialog(); },
          label: Text(LanguageService.t('add_cust'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          icon: const Icon(Icons.person_add, color: Colors.white),
          backgroundColor: Colors.green[800],
        ) : null,
        bottomNavigationBar: _bannerAd != null 
    ? Container(
        height: _bannerAd!.size.height.toDouble(),
        width: double.infinity,
        child: AdWidget(ad: _bannerAd!),
      ) 
    : null,
      ),
    );
  }

  Widget _buildTopToggle() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(50),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          _toggleBtn(LanguageService.t('tab_hisab'), 0, Colors.green),
          _toggleBtn(LanguageService.t('tab_cash'), 1, Colors.red),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.blueAccent, size: 28),
            onPressed: () {
              _searchFocusNode.unfocus();
              Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
            },
          ),
        ],
      ),
    );
  }

  

  Widget _toggleBtn(String label, int index, Color color) {
    final isActive = _activeTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _activeTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isActive ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(40),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildHisabKitabView() {
    return Column(
      children: [
        _buildGrandTotalHeader(),
        _buildSearchBar(),
        Expanded(
          child: ValueListenableBuilder(
            valueListenable: DatabaseService.customersBox.listenable(),
            builder: (context, Box<Customer> box, _) {
              final customers = box.values.where((c) => c.name.toLowerCase().contains(_searchQuery) || (c.phone ?? "").contains(_searchQuery)).toList();
              customers.sort((a, b) => (b.lastUpdated ?? DateTime(2000)).compareTo(a.lastUpdated ?? DateTime(2000)));
              return ListView.builder(
                key: ValueKey("${customers.length}_$_searchQuery"),
                padding: const EdgeInsets.only(bottom: 100),
                itemCount: customers.length,
                itemBuilder: (context, index) => _CustomerTile(customer: customers[index]),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCashbookView() {
    return ValueListenableBuilder(
      valueListenable: DatabaseService.cashbookBox.listenable(),
      builder: (context, Box<CashEntry> box, _) {
        var entries = box.values.toList();
        if (_cashFromDate != null && _cashToDate != null) {
          entries = entries.where((e) => e.date.isAfter(_cashFromDate!.subtract(const Duration(days: 1))) && e.date.isBefore(_cashToDate!.add(const Duration(days: 1)))).toList();
        }
        entries.sort((a, b) => b.date.compareTo(a.date));

        double tIn = 0; double tOut = 0;
        for (var e in entries) { if (e.type == 'in') tIn += e.amount; else tOut += e.amount; }

        return Column(
          children: [
            _buildDateFilterRow(
              onFrom: (d) => setState(() => _cashFromDate = d),
              onTo: (d) => setState(() => _cashToDate = d),
              onClear: () => setState(() { _cashFromDate = null; _cashToDate = null; }),
              from: _cashFromDate, to: _cashToDate
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]),
              child: Column(children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                  _totalItem(LanguageService.t('cash_in'), tIn, Colors.green[700]!),
                  _totalItem(LanguageService.t('cash_out'), tOut, Colors.red[700]!),
                ]),
                const Divider(height: 20),
                Text(LanguageService.t('balance'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                Text("₹ ${(tIn - tOut).toStringAsFixed(2)}", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.blue[900])),
              ]),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 80),
                itemCount: entries.length,
                itemBuilder: (context, index) {
                  final e = entries[index];
                  bool isIn = e.type == 'in';
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: ListTile(
                      onLongPress: () => _showCashEntryOptions(e),
                      leading: CircleAvatar(
                        backgroundColor: isIn ? Colors.green[50] : Colors.red[50],
                        child: Icon(isIn ? Icons.arrow_downward : Icons.arrow_upward, color: isIn ? Colors.green : Colors.red),
                      ),
                      title: Text(e.note?.isEmpty ?? true ? "Cash" : e.note!, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(DateFormat('dd MMM, hh:mm a').format(e.date)),
                      trailing: Text("₹ ${e.amount.toStringAsFixed(2)}", style: TextStyle(color: isIn ? Colors.green[700] : Colors.red[700], fontWeight: FontWeight.bold)),
                    ),
                  );
                },
              ),
            ),
            _buildCashbookBottomActions(),
          ],
        );
      },
    );
  }

  Widget _buildCashbookBottomActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.grey[200]!))),
      child: Row(children: [
        Expanded(child: ElevatedButton(onPressed: () => _showAddCashDialog('out'), style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text("OUT (-)", style: TextStyle(fontWeight: FontWeight.bold)))),
        const SizedBox(width: 12),
        Expanded(child: ElevatedButton(onPressed: () => _showAddCashDialog('in'), style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text("IN (+)", style: TextStyle(fontWeight: FontWeight.bold)))),
      ]),
    );
  }

  // --- LOGIC COMPONENTS ---
  Widget _buildGrandTotalHeader() {
    return ValueListenableBuilder(
      valueListenable: databaseUpdateNotifier,
      builder: (context, _, __) {
        return FutureBuilder<Map<String, double>>(
          future: _calculateGrandTotal(),
          builder: (context, snapshot) {
            final data = snapshot.data ?? {'gave': 0.0, 'got': 0.0};
            double balance = data['gave']! - data['got']!;
            return Container(
              width: double.infinity, padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: Colors.white, borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]),
              child: Column(children: [
                // _buildGrandTotalHeader ke andar Column mein sabse upar ek Row dalo:
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Text("DASHBOARD", style: TextStyle(color: Colors.white60, fontSize: 10, letterSpacing: 2)),
    // ☁️ CLOUD SYNC ICON
    StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return const Icon(Icons.cloud_done, color: Colors.white70, size: 16);
        }
        return const Icon(Icons.cloud_off, color: Colors.white24, size: 16);
      },
    ),
  ],
),
const SizedBox(height: 10),
                Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                  _totalItem(LanguageService.t('you_gave'), data['gave']!, Colors.red[700]!),
                  _totalItem(LanguageService.t('you_got'), data['got']!, Colors.green[700]!),
                ]),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  decoration: BoxDecoration(color: balance >= 0 ? Colors.red[50] : Colors.green[50], borderRadius: BorderRadius.circular(20)),
                  child: Column(children: [
                    Text(balance >= 0 ? LanguageService.t('total_get') : LanguageService.t('total_give'), style: TextStyle(color: balance >= 0 ? Colors.red[900] : Colors.green[900], fontWeight: FontWeight.bold)),
                    Text("₹ ${balance.abs().toStringAsFixed(2)}", style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: balance >= 0 ? Colors.red[800] : Colors.green[800])),
                  ]),
                ),
              ]),
            );
          },
        );
      }
    );
  }

  Future<Map<String, double>> _calculateGrandTotal() async {
    double gave = 0, got = 0;
    for (var c in DatabaseService.customersBox.values) {
      final box = await DatabaseService.getTransactionsBox(c.id);
      for (var t in box.values) { if (t.type == 'gave') gave += t.amount; else got += t.amount; }
    }
    return {'gave': gave, 'got': got};
  }

  Widget _buildDateFilterRow({required Function(DateTime) onFrom, required Function(DateTime) onTo, required VoidCallback onClear, DateTime? from, DateTime? to}) {
    // "Select" ki jagah ab LanguageService.t('select_date') ayega
    String selectTxt = LanguageService.t('select_date'); 
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        const Icon(Icons.date_range, size: 18, color: Colors.blue),
        const SizedBox(width: 8),
        Text("${LanguageService.t('from')}:", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        TextButton(onPressed: () async { var d = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime.now()); if (d != null) onFrom(d); }, child: Text(from == null ? selectTxt : DateFormat('dd/MM').format(from))),
        Text("${LanguageService.t('to')}:", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        TextButton(onPressed: () async { var d = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime.now()); if (d != null) onTo(d); }, child: Text(to == null ? selectTxt : DateFormat('dd/MM').format(to))),
        const Spacer(),
        if (from != null) IconButton(icon: const Icon(Icons.clear, size: 18, color: Colors.red), onPressed: onClear)
      ]),
    );
  }

  Widget _totalItem(String title, double amount, Color color) {
    return Column(children: [Text(title, style: const TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.bold)), const SizedBox(height: 4), Text("₹ ${amount.toStringAsFixed(2)}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color))]);
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
      child: TextField(
        controller: _searchController, focusNode: _searchFocusNode,
        onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
        decoration: InputDecoration(hintText: LanguageService.t('search_hint'), prefixIcon: const Icon(Icons.search), border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(vertical: 15)),
      ),
    );
  }


  // --- DIALOGS ---
  void _showAddCustomerDialog({bool shouldClear = true}) {
    if (shouldClear) { _nameController.clear(); _phoneController.clear(); }
    showDialog(context: context, builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(LanguageService.t('add_cust'), style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        // "Pick from Contacts" ab translate hoga:
        ElevatedButton.icon(onPressed: () async { Navigator.pop(ctx); await _pickContact(); _showAddCustomerDialog(shouldClear: false); }, icon: const Icon(Icons.contacts), label: Text(LanguageService.t('pick_contacts'))),
        const SizedBox(height: 15),
        // Label "Name" aur "Mobile" translate honge:
        TextField(controller: _nameController, decoration: InputDecoration(labelText: "${LanguageService.t('name')} *", border: const OutlineInputBorder())),
        const SizedBox(height: 12),
        TextField(controller: _phoneController, decoration: InputDecoration(labelText: LanguageService.t('mobile'), border: const OutlineInputBorder()), keyboardType: TextInputType.phone),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text(LanguageService.t('cancel'))),
        ElevatedButton(
          onPressed: () {
            String name = _nameController.text.trim();
            String phone = _phoneController.text.trim();
            if (name.isNotEmpty) {
              if (phone.isNotEmpty && _isPhoneNumberDuplicate(phone)) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("This number is already Exists!!!"), backgroundColor: Colors.red));
                return;
              }
              DatabaseService.addCustomer(Customer(name: name, phone: phone.isEmpty ? null : phone, id: DateTime.now().millisecondsSinceEpoch.toString()));
              SyncService.triggerAutoBackup(); databaseUpdateNotifier.value++; Navigator.pop(ctx);
            }
          },
          child: Text(LanguageService.t('save')),
        ),
      ],
    ));
  }

  bool _isPhoneNumberDuplicate(String phone, {String? currentCustomerId}) {
  if (phone.isEmpty) return false;
  String cleanNewPhone = phone.replaceAll(RegExp(r'\D'), ''); 
  
  for (var customer in DatabaseService.customersBox.values) {
    // Agar ye wahi customer hai jise hum edit kar rahe hain, toh skip karo
    if (currentCustomerId != null && customer.id == currentCustomerId) continue;

    if (customer.phone != null) {
      String cleanExistingPhone = customer.phone!.replaceAll(RegExp(r'\D'), '');
      if (cleanExistingPhone == cleanNewPhone) return true;
    }
  }
  return false;
}

  Future<void> _pickContact() async {
  if (await FlutterContacts.requestPermission()) {
    final contact = await FlutterContacts.openExternalPick();
    if (contact != null) {
      final full = await FlutterContacts.getContact(contact.id);
      if (full != null && full.phones.isNotEmpty) {
        String pickedPhone = full.phones.first.number;

        // 🔥 CONTACT PICKER MEIN BHI CHECK 🔥
        if (_isPhoneNumberDuplicate(pickedPhone)) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("This number is already Exit's!!!"),
                backgroundColor: Colors.orange,
              ),
            );
          }
          return; // Text fields fill mat karo
        }

          setState(() {
          _nameController.text = full.displayName;
          _phoneController.text = pickedPhone.replaceAll(RegExp(r'\D'), '');
          });
        }
      }
    }
  }

  void _showAddCashDialog(String type, {CashEntry? editE}) {
  DateTime selectedDate = editE?.date ?? DateTime.now(); // Date handle karne ke liye
  if (editE != null) {
    _cashAmountController.text = editE.amount.toString();
    _cashNoteController.text = editE.note ?? "";
  } else {
    _cashAmountController.clear();
    _cashNoteController.clear();
  }
  
  Color color = type == 'in' ? Colors.green : Colors.red;
  showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder( // StatefulBuilder zaroori hai date update dikhane ke liye
      builder: (ctx, setS) => AlertDialog(
        title: Text(type == 'in' ? LanguageService.t('cash_in') : LanguageService.t('cash_out'), style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Date Picker Button
            TextButton.icon(
              onPressed: () async {
                final d = await showDatePicker(context: context, initialDate: selectedDate, firstDate: DateTime(2000), lastDate: DateTime.now());
                if (d != null) setS(() => selectedDate = d);
              },
              icon: const Icon(Icons.calendar_month),
              label: Text(DateFormat('dd-MM-yyyy').format(selectedDate)),
            ),
            TextField(controller: _cashAmountController, decoration: const InputDecoration(labelText: "Amount", prefixText: "₹ "), keyboardType: const TextInputType.numberWithOptions(decimal: true)),
            TextField(controller: _cashNoteController, decoration: const InputDecoration(labelText: "Note (Optional)")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(LanguageService.t('cancel'))),
          ElevatedButton(
            onPressed: () { 
              if (_cashAmountController.text.isNotEmpty) {
                if (editE == null) {
                  DatabaseService.cashbookBox.add(CashEntry(amount: double.parse(_cashAmountController.text), type: type, date: selectedDate, note: _cashNoteController.text));
                } else {
                  editE.amount = double.parse(_cashAmountController.text);
                  editE.note = _cashNoteController.text;
                  editE.date = selectedDate;
                  editE.save();
                }
                SyncService.triggerAutoBackup(); 
                databaseUpdateNotifier.value++; Navigator.pop(ctx); 
              }
            }, 
            style: ElevatedButton.styleFrom(backgroundColor: color), 
            child: Text(LanguageService.t('save'), style: const TextStyle(color: Colors.white))
          ),
        ],
      ),
    ),
  );
}

  void _showCashEntryOptions(CashEntry e) {
    showModalBottomSheet(context: context, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))), builder: (ctx) => Wrap(children: [
      ListTile(leading: const Icon(Icons.edit, color: Colors.blue), title: Text(LanguageService.t('edit_entry')), onTap: () { Navigator.pop(ctx); _showAddCashDialog(e.type, editE: e); }),
      ListTile(leading: const Icon(Icons.delete, color: Colors.red), title: Text(LanguageService.t('delete')), onTap: () { e.delete(); databaseUpdateNotifier.value++; Navigator.pop(ctx); }),
    ]));
  }
}

class LockScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF022c22), // Wahi premium emerald color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 80, color: Color(0xFFfbbf24)),
            const SizedBox(height: 30),
            const Text("Hisab Kitab Locked", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 50),
            ElevatedButton.icon(
              onPressed: () async {
                bool success = await SecurityService.authenticate();
                if (success) isAppUnlocked.value = true;
              },
              icon: const Icon(Icons.fingerprint),
              label: const Text("Unlock App"),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFfbbf24), foregroundColor: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}

// --- CUSTOMER DETAIL ---
class CustomerDetailScreen extends StatefulWidget {
  
  final Customer customer;
  const CustomerDetailScreen({super.key, required this.customer});
  @override State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  BannerAd? _detailBanner;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  DateTime? _fromDate; DateTime? _toDate;
  DateTime _selectedDate = DateTime.now();
  bool _isDeleting = false;

  @override
void initState() {
  super.initState();
  _detailBanner = BannerAd(
    adUnitId: AdService.bannerAdUnitId,
    request: const AdRequest(),
    size: AdSize.banner,
    listener: BannerAdListener(
      onAdLoaded: (_) => setState(() {}),
      onAdFailedToLoad: (ad, error) => ad.dispose(),
    ),
  )..load();
}

  @override
  Widget build(BuildContext context) {
    if (_isDeleting) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
  title: Text(widget.customer.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
  backgroundColor: Colors.green[800], 
  iconTheme: const IconThemeData(color: Colors.white),
  actions: [
    // ✏️ EDIT ICON
    IconButton(
      icon: const Icon(Icons.edit), 
      onPressed: _editCustomer,
      tooltip: "Edit Name/Phone",
    ),
    IconButton(
      icon: const Icon(Icons.picture_as_pdf), 
      onPressed: () async {
        AdService.showInterstitialAd(); 
        var b = await DatabaseService.getTransactionsBox(widget.customer.id); 
        _showReportDialog(b.values.toList()); 
      }
    ),
    IconButton(icon: const Icon(Icons.delete_outline), onPressed: _deleteCustomer),
  ],
),
      body: FutureBuilder<Box<Transaction>>(
        future: DatabaseService.getTransactionsBox(widget.customer.id),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          return ValueListenableBuilder(
            valueListenable: snapshot.data!.listenable(),
            builder: (context, box, _) {
              var list = box.values.toList();
              if (_fromDate != null && _toDate != null) {
                list = list.where((t) => t.date.isAfter(_fromDate!.subtract(const Duration(days: 1))) && t.date.isBefore(_toDate!.add(const Duration(days: 1)))).toList();
              }
              list.sort((a, b) => b.date.compareTo(a.date));
              double gave = 0, got = 0;
              for (var t in box.values) { if (t.type == 'gave') gave += t.amount; else got += t.amount; }
              double bal = gave - got;

              return Column(children: [
                _buildSummary(gave, got, bal),
                _buildFilterBar(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  color: Colors.grey[200],
                  child: Row(children: [
                    Expanded(flex: 2, child: Text(LanguageService.t('date_note'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                    Expanded(child: Text(LanguageService.t('you_gave'), textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.red))),
                    Expanded(child: Text(LanguageService.t('you_got'), textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.green))),
                  ]),
                ),
                Expanded(child: list.isEmpty ? const Center(child: Text("No entries found")) : ListView.builder(padding: const EdgeInsets.only(bottom: 90), itemCount: list.length, itemBuilder: (ctx, i) => _TransactionRow(t: list[i]))),
                _buildActionButtons(),
              ]);
            },
          );
        },
      ),
      bottomNavigationBar: _detailBanner != null 
    ? Container(height: 50, child: AdWidget(ad: _detailBanner!)) 
    : null,
    );
  }

  Widget _buildSummary(double gave, double got, double bal) {
  Color c = bal >= 0 ? Colors.red : Colors.green;
  return Container(
    // 1. Padding 24 se kam karke 12 vertical kar di taki space bache
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), 
    color: Colors.white,
    child: Column(
      mainAxisSize: MainAxisSize.min, // 2. Jitni zarurat utni hi jagah lega
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround, 
          children: [
            _sumCol(LanguageService.t('you_gave'), gave, Colors.red),
            _sumCol(LanguageService.t('you_got'), got, Colors.green),
          ],
        ),
        const SizedBox(height: 8), // 3. Gap 15 se 8 kar diya
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(
            color: c.withOpacity(0.1), 
            borderRadius: BorderRadius.circular(12)
          ),
          child: Column(
            children: [
              Text(
                bal >= 0 ? LanguageService.t('total_get') : LanguageService.t('total_give'), 
                style: TextStyle(fontWeight: FontWeight.bold, color: c, fontSize: 11)
              ),
              // 4. Balance aur WhatsApp Button ko ROW mein kar diya (Side-by-Side)
              // Isse vertical space (lambai) bachegi aur overflow nahi hoga
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "₹ ${bal.abs().toStringAsFixed(2)}", 
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: c)
                  ),
                  const SizedBox(width: 12), // Dono ke beech ka gap
                  IconButton(
                    onPressed: () => _sendWhatsAppReminder(bal),
                    constraints: const BoxConstraints(), // Padding extra hatane ke liye
                    padding: EdgeInsets.zero,
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.send, 
                        color: Colors.white, 
                        size: 16, // Size thoda chota kiya taki fit aaye
                      ),
                    ),
                    tooltip: "WhatsApp Reminder",
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

  Widget _sumCol(String l, double v, Color c) => Column(children: [Text(l, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54)), Text("₹ ${v.toStringAsFixed(2)}", style: TextStyle(color: c, fontWeight: FontWeight.bold, fontSize: 18))]);

  Widget _buildFilterBar() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16), color: Colors.white,
    child: Row(children: [
      const Icon(Icons.filter_alt, size: 18, color: Colors.grey),
      TextButton(onPressed: () async { var d = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime.now()); if (d != null) setState(() => _fromDate = d); }, child: Text(_fromDate == null ? "From" : DateFormat('dd/MM').format(_fromDate!))),
      TextButton(onPressed: () async { var d = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime.now()); if (d != null) setState(() => _toDate = d); }, child: Text(_toDate == null ? "To" : DateFormat('dd/MM').format(_toDate!))),
      const Spacer(),
      if (_fromDate != null) IconButton(icon: const Icon(Icons.close, size: 18, color: Colors.red), onPressed: () => setState(() { _fromDate = null; _toDate = null; }))
    ]),
  );

  Widget _buildActionButtons() => Container(
    padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.grey[200]!))),
    child: Row(children: [
      Expanded(child: ElevatedButton(onPressed: () => _showEntryDialog('gave'), style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: Text("${LanguageService.t('you_gave')} ₹", style: const TextStyle(fontWeight: FontWeight.bold)))),
      const SizedBox(width: 12),
      Expanded(child: ElevatedButton(onPressed: () => _showEntryDialog('got'), style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: Text("${LanguageService.t('you_got')} ₹", style: const TextStyle(fontWeight: FontWeight.bold)))),
    ]),
  );

  void _showEntryDialog(String type, {Transaction? editT}) {
    if (editT != null) { _amountController.text = editT.amount.toString(); _noteController.text = editT.note ?? ""; _selectedDate = editT.date; }
    else { _amountController.clear(); _noteController.clear(); _selectedDate = DateTime.now(); }
    Color color = type == 'gave' ? Colors.red : Colors.green;
    showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, setS) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(type == 'gave' ? LanguageService.t('you_gave') : LanguageService.t('you_got'), style: TextStyle(color: color, fontWeight: FontWeight.bold)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextButton.icon(onPressed: () async { var d = await showDatePicker(context: context, initialDate: _selectedDate, firstDate: DateTime(2000), lastDate: DateTime.now()); if (d != null) setS(() => _selectedDate = d); }, icon: const Icon(Icons.calendar_today), label: Text(DateFormat('dd-MM-yyyy').format(_selectedDate))),
        TextField(controller: _amountController, decoration: const InputDecoration(labelText: "Amount", prefixText: "₹ ", border: OutlineInputBorder()), keyboardType: const TextInputType.numberWithOptions(decimal: true)),
        const SizedBox(height: 12),
        TextField(controller: _noteController, decoration: const InputDecoration(labelText: "Note", border: OutlineInputBorder())),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text(LanguageService.t('cancel'))),
        ElevatedButton(onPressed: () { if (_amountController.text.isNotEmpty) { if (editT == null) DatabaseService.addTransaction(Transaction(customerId: widget.customer.id, type: type, amount: double.parse(_amountController.text), note: _noteController.text, date: _selectedDate)); else { editT.amount = double.parse(_amountController.text); editT.note = _noteController.text; editT.date = _selectedDate; editT.save(); }
        SyncService.triggerAutoBackup();
        databaseUpdateNotifier.value++; Navigator.pop(ctx); } }, style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white), child: Text(LanguageService.t('save'))),
      ],
    )));
  }

  void _sendWhatsAppReminder(double balance) async {
  if (widget.customer.phone == null || widget.customer.phone!.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Is customer ka mobile number nahi hai!")),
    );
    return;
  }

  // 1. Phone number saaf karo (Sirf numbers rakho)
  String phone = widget.customer.phone!.replaceAll(RegExp(r'\D'), '');
  if (!phone.startsWith('91') && phone.length == 10) {
    phone = '91$phone'; // Agar 10 digit hai toh India ka code lagao
  }

  // 2. Message taiyaar karo
  String message = "";
  if (balance > 0) {
    message = "Namaste ${widget.customer.name}, aapka Hisab Kitab hamare paas ₹${balance.abs().toStringAsFixed(2)} baki (Dena) hai. Kripya jald bhugtan karein. Dhanyawad!";
  } else if (balance < 0) {
    message = "Namaste ${widget.customer.name}, aapka ₹${balance.abs().toStringAsFixed(2)} hamare paas jama (Advance) hai. Dhanyawad!";
  } else {
    message = "Namaste ${widget.customer.name}, aapka hamare sath hisab barabar hai. Dhanyawad!";
  }

  // 3. WhatsApp URL banao
  var whatsappUrl = Uri.parse("https://wa.me/$phone?text=${Uri.encodeComponent(message)}");

  // 4. Launch karo
  try {
    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
    } else {
      throw "WhatsApp install nahi hai";
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("WhatsApp nahi khul raha: $e")),
    );
  }
}

  void _showReportDialog(List<Transaction> all) {
    DateTime? f, t; showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, setS) => AlertDialog(
      title: const Text("Generate Report"), content: Row(children: [
        Expanded(child: OutlinedButton(onPressed: () async { var d = await showDatePicker(context: ctx, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime.now()); if (d != null) setS(() => f = d); }, child: Text(f == null ? "From" : DateFormat('dd/MM').format(f!)))),
        const SizedBox(width: 8),
        Expanded(child: OutlinedButton(onPressed: () async { var d = await showDatePicker(context: ctx, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime.now()); if (d != null) setS(() => t = d); }, child: Text(t == null ? "To" : DateFormat('dd/MM').format(t!)))),
      ]),
      actions: [
        TextButton(onPressed: () { Navigator.pop(ctx); PdfService.generateReport(customer: widget.customer, transactions: all); }, child: const Text("FULL")),
        ElevatedButton(onPressed: (f != null && t != null) ? () { var res = all.where((tr) => tr.date.isAfter(f!.subtract(const Duration(days: 1))) && tr.date.isBefore(t!.add(const Duration(days: 1)))).toList(); Navigator.pop(ctx); PdfService.generateReport(customer: widget.customer, transactions: res, fromDate: f, toDate: t); } : null, child: const Text("GENERATE")),
      ],
    )));
  }

  void _deleteCustomer() {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: Text(LanguageService.t('delete')), actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text(LanguageService.t('cancel'))),
        TextButton(onPressed: () async { setState(() => _isDeleting = true); Navigator.pop(ctx); Navigator.pop(context); await Future.delayed(const Duration(milliseconds: 300)); await DatabaseService.deleteCustomer(widget.customer.id);
        SyncService.triggerAutoBackup();
        databaseUpdateNotifier.value++; }, child: Text(LanguageService.t('delete'), style: const TextStyle(color: Colors.red))),
      ],
    ));
  }

  void _editCustomer() {
  final nameController = TextEditingController(text: widget.customer.name);
  final phoneController = TextEditingController(text: widget.customer.phone ?? "");

  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      // Title translate hoga:
      title: Text(LanguageService.t('edit_cust'), style: const TextStyle(color: Colors.green)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Labels translate honge:
          TextField(controller: nameController, decoration: InputDecoration(labelText: LanguageService.t('name'))),
          const SizedBox(height: 10),
          TextField(controller: phoneController, decoration: InputDecoration(labelText: LanguageService.t('mobile')), keyboardType: TextInputType.phone),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text(LanguageService.t('cancel'))),
        // Button translate hoga:
        ElevatedButton(
          onPressed: () {
            String newName = nameController.text.trim();
            String newPhone = phoneController.text.trim();
            if (newName.isNotEmpty) {
              widget.customer.name = newName;
              widget.customer.phone = newPhone.isEmpty ? null : newPhone;
              widget.customer.save();
              SyncService.triggerAutoBackup();
              databaseUpdateNotifier.value++; 
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(LanguageService.t('profile_saved'))));
            }
          },
          child: Text(LanguageService.t('update')),
        ),
      ],
    ),
  );
}

}

class _TransactionRow extends StatelessWidget {
  final Transaction t; 
  const _TransactionRow({required this.t});
  @override Widget build(BuildContext context) {
    bool isG = t.type == 'gave';
    return InkWell(
      onLongPress: () => showModalBottomSheet(context: context, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))), builder: (ctx) => Wrap(children: [
        ListTile(leading: const Icon(Icons.edit, color: Colors.blue), title: Text(LanguageService.t('edit_entry')), onTap: () { Navigator.pop(ctx); context.findAncestorStateOfType<_CustomerDetailScreenState>()?._showEntryDialog(t.type, editT: t); }),
        ListTile(leading: const Icon(Icons.delete, color: Colors.red), title: Text(LanguageService.t('delete')), onTap: () { t.delete(); SyncService.triggerAutoBackup();databaseUpdateNotifier.value++; Navigator.pop(ctx); }),
      ])),
      child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey[100]!))), child: Row(children: [
        Expanded(flex: 2, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(DateFormat('dd MMM yy').format(t.date), style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)), Text(t.note?.isEmpty ?? true ? "Cash" : t.note!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))])),
        Expanded(child: Text(isG ? "₹ ${t.amount.toStringAsFixed(2)}" : "-", textAlign: TextAlign.center, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold))),
        Expanded(child: Text(!isG ? "₹ ${t.amount.toStringAsFixed(2)}" : "-", textAlign: TextAlign.center, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold))),
      ])),
    );
  }
}

// --- OTHER WIDGETS ---
class _CustomerTile extends StatelessWidget {
  final Customer customer;
  const _CustomerTile({required this.customer});
  @override Widget build(BuildContext context) {
    if (!DatabaseService.customersBox.containsKey(customer.id)) return const SizedBox.shrink();
    return FutureBuilder<Box<Transaction>>(
      future: DatabaseService.getTransactionsBox(customer.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();
        return ValueListenableBuilder(valueListenable: snapshot.data!.listenable(), builder: (context, box, _) {
          double bal = 0; for (var t in box.values) bal += (t.type == 'gave' ? t.amount : -t.amount);
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.grey[200]!)),
            child: ListTile(
              onTap: () async { FocusScope.of(context).unfocus(); await Navigator.push(context, MaterialPageRoute(builder: (context) => CustomerDetailScreen(customer: customer))); databaseUpdateNotifier.value++; },
              leading: CircleAvatar(
                backgroundColor: Colors.green[100],
                child: Text(customer.name[0].toUpperCase(), style: TextStyle(color: Colors.green[900], fontWeight: FontWeight.bold)),
              ),
              title: Text(customer.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(customer.phone ?? "No mobile", style: const TextStyle(fontSize: 12, color: Colors.black54)),
              trailing: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text("₹ ${bal.abs().toStringAsFixed(2)}", style: TextStyle(color: bal >= 0 ? Colors.red : Colors.green, fontWeight: FontWeight.w900, fontSize: 16)),
                Text(bal >= 0 ? LanguageService.t('total_get') : LanguageService.t('total_give'), style: TextStyle(color: bal >= 0 ? Colors.red : Colors.green, fontSize: 9, fontWeight: FontWeight.bold)),
              ]),
            ),
          );
        });
      },
    );
  }
}

// 🔥 Conversion: StatelessWidget ko StatefulWidget mein badla
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Services ko yahan shift kiya
  final AuthService _authService = AuthService();
  final SyncService _syncService = SyncService();
  
  // 🔥 Ad Variable
  BannerAd? _bannerAd;

  @override
  void initState() {
    super.initState();
    // 🔥 Ad Load logic
    _bannerAd = BannerAd(
      adUnitId: AdService.bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (_) => setState(() {}),
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose(); // 🔥 Memory saaf
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return ValueListenableBuilder(
      valueListenable: databaseUpdateNotifier,
      builder: (context, _, __) {
        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            title: Text(LanguageService.t('settings'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            backgroundColor: Colors.green[800],
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (currentUser != null)
                Card(
                  elevation: 0,
                  color: Colors.green[50],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: ListTile(
                    leading: CircleAvatar(backgroundColor: Colors.green, child: Text(currentUser.displayName?[0] ?? "U", style: const TextStyle(color: Colors.white))),
                    title: Text(currentUser.displayName ?? "User"),
                    subtitle: Text(currentUser.email ?? ""),
                  ),
                ),
              const SizedBox(height: 20),
              
              // LANGUAGE
              _settingTile(Icons.language, LanguageService.t('language'), null, DropdownButton<String>(
                value: appLanguage.value,
                underline: const SizedBox(),
                items: LanguageService.supportedLanguages.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                onChanged: (v) { if (v != null) { appLanguage.value = v; databaseUpdateNotifier.value++; } },
              )),

              // APP LOCK
              _settingTile(
                Icons.fingerprint,
                LanguageService.t('app_lock'),
                LanguageService.t('lock_desc'),
                Switch(
                  value: DatabaseService.settingsBox.get('appLock', defaultValue: false),
                  activeColor: Colors.green,
                  onChanged: (val) async {
                    bool canLock = await SecurityService.canCheckBiometrics();
                    if (canLock) { await DatabaseService.settingsBox.put('appLock', val); databaseUpdateNotifier.value++; }
                    else { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Device security not supported!"))); }
                  },
                ),
              ),

              // BUSINESS PROFILE
              _settingTile(
                Icons.business,
                LanguageService.t('business_profile'),
                LanguageService.t('business_desc'),
                IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _showBusinessProfileDialog(context)),
              ),

              const Divider(height: 30),
              _settingTile(Icons.people, LanguageService.t('total_cust'), DatabaseService.customersBox.length.toString(), null),
              _settingTile(Icons.info, LanguageService.t('version'), "1.1.8", null),
              _settingTile(Icons.code, LanguageService.t('dev_name'), "Harinder Singh", null),
              _settingTile(Icons.phone, LanguageService.t('contact_dev'), "+91 85285 82893", null),

              // LOGOUT
              _settingTile(
                Icons.logout,
                LanguageService.t('logout'),
                LanguageService.t('backup_clear'),
                IconButton(icon: const Icon(Icons.logout, color: Colors.red), onPressed: () => _handleLogout(context)),
              ),
            ],
          ),
          // 🔥 YE RAHI AD (Sabse niche fix aayegi)
          bottomNavigationBar: _bannerAd != null 
            ? SizedBox(
                height: _bannerAd!.size.height.toDouble(),
                width: double.infinity,
                child: AdWidget(ad: _bannerAd!),
              )
            : null,
        );
      },
    );
  }

  // --- HELPERS (Ye class ke andar hi rahenge) ---
  void _showBusinessProfileDialog(BuildContext context) {
    final nameController = TextEditingController(text: DatabaseService.settingsBox.get('shopName', defaultValue: "My Shop"));
    final addressController = TextEditingController(text: DatabaseService.settingsBox.get('shopAddress', defaultValue: ""));
    final phoneController = TextEditingController(text: DatabaseService.settingsBox.get('shopPhone', defaultValue: ""));

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(LanguageService.t('business_profile')),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: nameController, decoration: InputDecoration(labelText: LanguageService.t('shop_name'))),
            TextField(controller: addressController, decoration: InputDecoration(labelText: LanguageService.t('address'))),
            TextField(controller: phoneController, decoration: InputDecoration(labelText: LanguageService.t('mobile')), keyboardType: TextInputType.phone),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(LanguageService.t('cancel'))),
          ElevatedButton(
            onPressed: () async {
              await DatabaseService.settingsBox.put('shopName', nameController.text);
              await DatabaseService.settingsBox.put('shopAddress', addressController.text);
              await DatabaseService.settingsBox.put('shopPhone', phoneController.text);
              databaseUpdateNotifier.value++; Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(LanguageService.t('profile_saved'))));
            },
            child: Text(LanguageService.t('save')),
          ),
        ],
      ),
    );
  }

  void _handleLogout(BuildContext context) async {
    showDialog(
      context: context, barrierDismissible: false,
      builder: (ctx) => AlertDialog(content: Row(children: [const CircularProgressIndicator(), const SizedBox(width: 20), Text(LanguageService.t('sync_logout'))])),
    );
    try {
      await _syncService.backupData(); await _syncService.clearLocalData(); await _authService.signOut();
      if (context.mounted) { Navigator.of(context, rootNavigator: true).pop(); Navigator.of(context).pop(); }
    } catch (e) { if (context.mounted) Navigator.of(context, rootNavigator: true).pop(); }
  }

  Widget _settingTile(IconData i, String t, String? s, Widget? tr) => Card(
    margin: const EdgeInsets.only(bottom: 12), elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey[200]!)),
    child: ListTile(leading: Icon(i, color: Colors.green[700]), title: Text(t, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)), subtitle: s != null ? Text(s) : null, trailing: tr),
  );
}