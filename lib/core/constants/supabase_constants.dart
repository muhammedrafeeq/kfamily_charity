class SupabaseConstants {
  static const String supabaseUrl = 'https://pluridardldhljlbstxl.supabase.co';
  static const String supabaseAnonKey = 'sb_publishable_wPRDKhzlMlltgQ_-GEe0yA_pkW6dknF';

  // Tables
  static const String profilesTable = 'profiles';
  static const String cyclesTable = 'payment_cycles';
  static const String contributionsTable = 'payment_contributions';
  static const String notificationsTable = 'notifications';

  // Views
  static const String monthlySummaryView = 'v_monthly_summary';
  static const String memberYearlySummaryView = 'v_member_yearly_summary';

  // Storage
  static const String screenshotsBucket = 'payment-screenshots';

  // Realtime channels
  static const String contributionsChannel = 'contributions';
  static const String notificationsChannel = 'notifications';
}
