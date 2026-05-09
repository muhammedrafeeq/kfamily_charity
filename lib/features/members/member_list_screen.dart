import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/router/app_routes.dart';
import '../../providers/profile_provider.dart';
import '../../shared/widgets/error_display.dart';

class MemberListScreen extends ConsumerWidget {
  const MemberListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(allMembersProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 120,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Container(
                decoration: const BoxDecoration(gradient: AppColors.heroGradient),
              ),
              title: const Text('Members',
                  style: TextStyle(color: Colors.white, fontSize: 17,
                      fontWeight: FontWeight.w600)),
              titlePadding: const EdgeInsetsDirectional.fromSTEB(72, 0, 16, 16),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          membersAsync.when(
            data: (members) {
              if (members.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(
                    child: Text('No members yet.',
                        style: TextStyle(color: AppColors.textSecondary)),
                  ),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) {
                      final m = members[i];
                      final initials = m.fullName.isNotEmpty
                          ? m.fullName[0].toUpperCase()
                          : '?';
                      return GestureDetector(
                        onTap: () => context.push('/members/${m.id}'),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: const BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.all(Radius.circular(16)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: const BoxDecoration(
                                  gradient: AppColors.heroGradient,
                                  borderRadius: BorderRadius.all(Radius.circular(14)),
                                ),
                                child: Center(
                                  child: Text('$initials',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 18)),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(m.fullName,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 15,
                                            color: AppColors.textPrimary)),
                                    const SizedBox(height: 3),
                                    Text(m.phone ?? m.role.toUpperCase(),
                                        style: const TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 12)),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.accent.withValues(alpha: 0.1),
                                      borderRadius:
                                          const BorderRadius.all(Radius.circular(8)),
                                    ),
                                    child: Text('#${m.memberNumber}',
                                        style: const TextStyle(
                                            color: AppColors.accent,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 12)),
                                  ),
                                  if (m.isAdmin) ...[
                                    const SizedBox(height: 5),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 7, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: AppColors.gold.withValues(alpha: 0.15),
                                        borderRadius:
                                            const BorderRadius.all(Radius.circular(8)),
                                      ),
                                      child: const Text('ADMIN',
                                          style: TextStyle(
                                              color: AppColors.gold,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: 0.5)),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.chevron_right_rounded,
                                  color: AppColors.textHint, size: 20),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: members.length,
                  ),
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator(color: AppColors.accent)),
            ),
            error: (e, _) =>
                SliverFillRemaining(child: ErrorDisplay(message: e.toString())),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.addMember),
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.primary,
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Add Member', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }
}
