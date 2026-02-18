import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../onboarding/presentation/screens/role_selection_screen.dart';
import 'package:helpme/core/theme/app_spacing.dart';
import 'package:helpme/core/theme/app_typography.dart';
import 'package:helpme/features/jobs/presentation/screens/job_detail_screen.dart'; // Import Detail Screen

class CraftsmanHomeScreen extends StatelessWidget {
  const CraftsmanHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Realtime stream of OPEN jobs
    final stream = Supabase.instance.client
        .from('jobs')
        .stream(primaryKey: ['id'])
        .eq('status', 'open') // Only show open jobs
        .order('created_at', ascending: false);

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        title: const Text('Offene Aufträge ⚡'), // Updated Title
        backgroundColor: AppColors.bgPrimary,
        foregroundColor: AppColors.textPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: stream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Fehler: ${snapshot.error}', style: const TextStyle(color: AppColors.danger)));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: AppColors.accentPrimary));
          }

          final jobs = snapshot.data!;

          if (jobs.isEmpty) {
            return const Center(
              child: Text(
                'Aktuell keine offenen Aufträge.\nTrink einen Kaffee! ☕',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 18),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: jobs.length,
            separatorBuilder: (ctx, i) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, index) {
              final job = jobs[index];
              return _buildJobCard(context, job);
            },
          );
        },
      ),
    );
  }

  Widget _buildJobCard(BuildContext context, Map<String, dynamic> job) {
    final title = job['title'] ?? 'Unbekannt';
    final category = job['category'] ?? 'Sonstiges';
    final location = job['location'] ?? 'Kein Ort';
    final budget = job['budget'] ?? 'VB';
    // Simple date formatting could be added here

    IconData catIcon = Icons.work;
    if (category == 'Maler') catIcon = Icons.format_paint;
    if (category == 'Elektrik') catIcon = Icons.bolt;
    if (category == 'Garten') catIcon = Icons.yard;
    if (category == 'Sanitär') catIcon = Icons.water_drop;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => JobDetailScreen(job: job),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.bgElevated),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Chip(
                    label: Text(category),
                    avatar: Icon(catIcon, size: 16, color: AppColors.textInverse),
                    backgroundColor: AppColors.accentPrimary,
                    labelStyle: const TextStyle(color: AppColors.textInverse, fontWeight: FontWeight.bold),
                    padding: EdgeInsets.zero,
                  ),
                  Text(
                    budget,
                    style: const TextStyle(
                      color: AppColors.success,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                   const Icon(Icons.location_on, size: 16, color: AppColors.textSecondary),
                   const SizedBox(width: 4),
                   Text(
                     location,
                     style: const TextStyle(color: AppColors.textSecondary),
                   ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
