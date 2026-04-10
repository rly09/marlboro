import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  String _locale = 'en'; // default to english

  String get locale => _locale;

  LocaleProvider() {
    _loadPreference();
  }

  Future<void> _loadPreference() async {
    final prefs = await SharedPreferences.getInstance();
    _locale = prefs.getString('languageCode') ?? 'en';
    notifyListeners();
  }

  Future<void> toggleLocale() async {
    _locale = _locale == 'en' ? 'hi' : 'en';
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', _locale);
  }

  String translate(String key) {
    if (_locale == 'en') return _en[key] ?? key;
    return _hi[key] ?? _en[key] ?? key;
  }

  // --- ENGLISH DICTIONARY ---
  final Map<String, String> _en = {
    'Dashboard': 'Dashboard',
    'Total Reports': 'Total Reports',
    'In Progress': 'In Progress',
    'Cleaned': 'Cleaned',
    'Local Leaderboard': 'Local Leaderboard',
    'pts': 'pts',
    'Day Streak': 'Day Streak',
    'AI Predictive Heatmap': 'AI Predictive Heatmap',
    'Map': 'Map',
    'Report Garbage': 'Report Garbage',
    'Submit Report': 'Submit Report',
    'Analyzing Image': 'Analyzing Image',
    'Pending': 'Pending',
    'Pending Proof': 'Pending Proof',
    'Mark as Cleaned': 'Mark as Cleaned',
    'Claim Task': 'Claim Task',
    'Provide After Photo': 'Provide After Photo',
    'Trust Score': 'Trust Score',
    'Total Cleanups': 'Total Cleanups',
    'Take Before Photo': 'Take Before Photo',
    'Take After Photo': 'Take After Photo',
    'Cancel': 'Cancel',
    'Submit': 'Submit',
    'Elite Warriors': 'Loading elite warriors...',
    'Hello': 'Hello',
    'AI Analyzed': 'Cerebras AI analyzed',
    'Before': 'Before',
    'After': 'After',
    'Tap to Capture / Upload': 'Tap to Capture / Upload',
    'Photo + GPS auto-detected': 'Photo + GPS auto-detected',
    'Points': 'Points',
    'Claimed by': 'Claimed by',
    'Global Impact': 'Global Impact',
    'Area Cleaned': 'Area Cleaned',
    'Top Volunteers': 'Top Volunteers',
    'Impact Score': 'Impact Score',
    'High': 'High',
    'Medium': 'Medium',
    'Low': 'Low',
    'CleanChain': 'CleanChain',
    'Med': 'Med',
    'Proof': 'Proof'
  };

  // --- HINDI DICTIONARY ---
  final Map<String, String> _hi = {
    'Dashboard': 'डैशबोर्ड',
    'Total Reports': 'कुल रिपोर्ट',
    'In Progress': 'प्रगति पर है',
    'Cleaned': 'साफ किया गया',
    'Local Leaderboard': 'स्थानीय लीडरबोर्ड',
    'pts': 'अंक',
    'Day Streak': 'दिन की स्ट्रीक',
    'AI Predictive Heatmap': 'AI प्रेडिक्टिव हीटमैप',
    'Map': 'नक्शा',
    'Report Garbage': 'कचरा रिपोर्ट करें',
    'Submit Report': 'रिपोर्ट दर्ज़ करें',
    'Analyzing Image': 'चित्र का विश्लेषण हो रहा है',
    'Pending': 'लंबित',
    'Pending Proof': 'प्रमाण लंबित',
    'Mark as Cleaned': 'साफ के रूप में मार्क करें',
    'Claim Task': 'कार्य स्वीकार करें',
    'Provide After Photo': 'बाद की फोटो प्रदान करें',
    'Trust Score': 'विश्वास स्कोर',
    'Total Cleanups': 'कुल सफाई',
    'Take Before Photo': 'पहले की फोटो लें',
    'Take After Photo': 'बाद की फोटो लें',
    'Cancel': 'रद्द करें',
    'Submit': 'जमा करें',
    'Elite Warriors': 'योद्धा लोड हो रहे हैं...',
    'Hello': 'नमस्ते',
    'AI Analyzed': 'सेरेब्रास AI ने विश्लेषण किया',
    'Before': 'पहले',
    'After': 'बाद में',
    'Tap to Capture / Upload': 'कैद करने / अपलोड करने के लिए टैप करें',
    'Photo + GPS auto-detected': 'फोटो + GPS ऑटो-डिटेक्ट',
    'Points': 'अंक',
    'Claimed by': 'द्वारा दावा किया गया',
    'Global Impact': 'वैश्विक प्रभाव',
    'Area Cleaned': 'क्षेत्र साफ किया गया',
    'Top Volunteers': 'शीर्ष स्वयंसेवक',
    'Impact Score': 'प्रभाव स्कोर',
    'High': 'उच्च',
    'Medium': 'मध्यम',
    'Low': 'कम',
    'CleanChain': 'क्लीनचेन',
    'Med': 'मध्यम',
    'Proof': 'प्रमाण'
  };
}
