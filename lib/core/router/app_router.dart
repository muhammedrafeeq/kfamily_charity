import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/admin/cycle_management_screen.dart';
import '../../features/cashier/cashier_entry_screen.dart';
import '../../features/cashier/withdrawal_screen.dart';
import '../../features/auth/forgot_password_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/members/add_member_screen.dart';
import '../../features/members/bulk_member_update_screen.dart';
import '../../features/members/member_detail_screen.dart';
import '../../features/members/member_list_screen.dart';
import '../../features/notifications/notifications_screen.dart';
import '../../features/payments/payment_detail_screen.dart';
import '../../features/payments/payment_list_screen.dart';
import '../../features/payments/submit_payment_screen.dart';
import '../../features/reports/member_history_screen.dart';
import '../../features/reports/monthly_trends_screen.dart';
import '../../features/reports/pending_report_screen.dart';
import '../../features/reports/reports_dashboard_screen.dart';
import '../../features/reports/yearly_summary_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/shell/main_shell.dart';
import '../../providers/auth_provider.dart';
import 'app_routes.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: AppRoutes.dashboard,
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull?.session != null;
      final isAuthRoute = state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.forgotPassword;

      if (!isLoggedIn && !isAuthRoute) return AppRoutes.login;
      if (isLoggedIn && isAuthRoute) return AppRoutes.dashboard;
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (_, __) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        builder: (_, __) => const NotificationsScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (_, __) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminCycles,
        builder: (_, __) => const CycleManagementScreen(),
      ),
      GoRoute(
        path: AppRoutes.cashierEntry,
        builder: (_, __) => const CashierEntryScreen(),
      ),
      GoRoute(
        path: AppRoutes.withdrawals,
        builder: (_, __) => const WithdrawalScreen(),
      ),
      GoRoute(
        path: AppRoutes.submitPayment,
        builder: (_, __) => const SubmitPaymentScreen(),
      ),
      GoRoute(
        path: '/payments/:id',
        builder: (_, state) => PaymentDetailScreen(
          contributionId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.monthlyTrends,
        builder: (_, __) => const MonthlyTrendsScreen(),
      ),
      GoRoute(
        path: AppRoutes.memberHistory,
        builder: (_, __) => const MemberHistoryScreen(),
      ),
      GoRoute(
        path: AppRoutes.yearlySummary,
        builder: (_, __) => const YearlySummaryScreen(),
      ),
      GoRoute(
        path: AppRoutes.pendingReport,
        builder: (_, __) => const PendingReportScreen(),
      ),
      GoRoute(
        path: AppRoutes.addMember,
        builder: (_, __) => const AddMemberScreen(),
      ),
      GoRoute(
        path: AppRoutes.bulkUpdateMembers,
        builder: (_, __) => const BulkMemberUpdateScreen(),
      ),
      GoRoute(
        path: '/members/:id',
        builder: (_, state) => MemberDetailScreen(
          memberId: state.pathParameters['id']!,
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (_, __, shell) => MainShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.dashboard,
              builder: (_, __) => const DashboardScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.payments,
              builder: (_, __) => const PaymentListScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.reports,
              builder: (_, __) => const ReportsDashboardScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.members,
              builder: (_, __) => const MemberListScreen(),
            ),
          ]),
        ],
      ),
    ],
  );
});
