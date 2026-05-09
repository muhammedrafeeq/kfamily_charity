import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppLanguage { english, malayalam }

final languageProvider = StateProvider<AppLanguage>((ref) => AppLanguage.english);

class AppLocalizations {
  final AppLanguage language;
  AppLocalizations(this.language);

  static AppLocalizations of(AppLanguage lang) => AppLocalizations(lang);

  bool get isMalayalam => language == AppLanguage.malayalam;

  String get appName => isMalayalam ? 'കെ-ഫാമിലി ചാരിറ്റി' : 'KFamily Charity';
  String get dashboard => isMalayalam ? 'ഡാഷ്‌ബോർഡ്' : 'Dashboard';
  String get payments => isMalayalam ? 'പേയ്‌മെന്റുകൾ' : 'Payments';
  String get reports => isMalayalam ? 'റിപ്പോർട്ടുകൾ' : 'Reports';
  String get members => isMalayalam ? 'അംഗങ്ങൾ' : 'Members';
  String get settings => isMalayalam ? 'ക്രമീകരണങ്ങൾ' : 'Settings';
  
  String get fundOverview => isMalayalam ? 'ഫണ്ട് അവലോകനം' : 'Fund Overview';
  String get totalCollected => isMalayalam ? 'ആകെ ശേഖരിച്ചത്' : 'Total Collected';
  String get withdrawn => isMalayalam ? 'പിൻവലിച്ചത്' : 'Withdrawn';
  String get balance => isMalayalam ? 'ബാക്കി' : 'Balance';
  
  String get recordWithdrawal => isMalayalam ? 'പിൻവലിക്കൽ രേഖപ്പെടുത്തുക' : 'Record Withdrawal';
  String get withdrawalAmount => isMalayalam ? 'പിൻവലിക്കുന്ന തുക' : 'Withdrawal Amount';
  String get reason => isMalayalam ? 'കാരണം' : 'Reason';
  String get selectMember => isMalayalam ? 'അംഗത്തെ തിരഞ്ഞെടുക്കുക' : 'Select Member';
  String get withdrawalHistory => isMalayalam ? 'പിൻവലിക്കൽ ചരിത്രം' : 'Withdrawal History';
  
  String get signIn => isMalayalam ? 'ലോഗിൻ ചെയ്യുക' : 'Sign In';
  String get signOut => isMalayalam ? 'പുറത്തുകടക്കുക' : 'Sign Out';
  String get appearance => isMalayalam ? 'രൂപഭാവം' : 'Appearance';
  String get theme => isMalayalam ? 'തീം' : 'Theme';
  String get languageStr => isMalayalam ? 'ഭാഷ' : 'Language';
  String get account => isMalayalam ? 'അക്കൗണ്ട്' : 'Account';
  String get editProfile => isMalayalam ? 'പ്രൊഫൈൽ തിരുത്തുക' : 'Edit Profile';
  String get changePassword => isMalayalam ? 'പാസ്‌വേഡ് മാറ്റുക' : 'Change Password';
  String get about => isMalayalam ? 'അതിനെക്കുറിച്ച്' : 'About';
  
  String get submitPayment => isMalayalam ? 'പേയ്‌മെന്റ് സമർപ്പിക്കുക' : 'Submit Payment';
  String get paymentAmount => isMalayalam ? 'പേയ്‌മെന്റ് തുക' : 'Payment Amount';
  String get paymentScreenshot => isMalayalam ? 'പേയ്‌മെന്റ് സ്ക്രീൻഷോട്ട്' : 'Payment Screenshot';
  String get tapToAddScreenshot => isMalayalam ? 'സ്ക്രീൻഷോട്ട് ചേർക്കാൻ ടാപ്പ് ചെയ്യുക' : 'Tap to add screenshot';
  String get cameraOrGallery => isMalayalam ? 'ക്യാമറ അല്ലെങ്കിൽ ഗാലറി' : 'Camera or Gallery';
  String get submitting => isMalayalam ? 'സമർപ്പിക്കുന്നു...' : 'Submitting...';
  String get takePhoto => isMalayalam ? 'ഫോട്ടോ എടുക്കുക' : 'Take Photo';
  String get chooseFromGallery => isMalayalam ? 'ഗാലറിയിൽ നിന്ന് തിരഞ്ഞെടുക്കുക' : 'Choose from Gallery';
  String get paymentWindow => isMalayalam ? 'പേയ്‌മെന്റ് വിൻഡോ: എല്ലാ മാസവും 1 മുതൽ 10 വരെ' : 'Payment window: 1st – 10th of each month';
  String get changePhoto => isMalayalam ? 'ഫോട്ടോ മാറ്റുക' : 'Change Photo';
  
  String get addMember => isMalayalam ? 'അംഗത്തെ ചേർക്കുക' : 'Add Member';
  String get fullName => isMalayalam ? 'മുഴുവൻ പേര്' : 'Full Name';
  String get emailAddress => isMalayalam ? 'ഇമെയിൽ വിലാസം' : 'Email Address';
  String get phoneOptional => isMalayalam ? 'ഫോൺ (ഓപ്ഷണൽ)' : 'Phone (optional)';
  String get memberNumberStr => isMalayalam ? 'അംഗം നമ്പർ' : 'Member Number';
  String get sendInvitation => isMalayalam ? 'ക്ഷണക്കത്ത് അയക്കുക' : 'Send Invitation';
  String get sending => isMalayalam ? 'അയക്കുന്നു...' : 'Sending...';
  String get inviteNewMember => isMalayalam ? 'പുതിയ അംഗത്തെ ക്ഷണിക്കുക' : 'Invite New Member';
}

final l10nProvider = Provider<AppLocalizations>((ref) {
  final lang = ref.watch(languageProvider);
  return AppLocalizations(lang);
});
