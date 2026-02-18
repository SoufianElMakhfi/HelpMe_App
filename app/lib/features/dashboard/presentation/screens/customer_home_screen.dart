import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../onboarding/presentation/screens/role_selection_screen.dart';

import 'package:helpme/features/jobs/presentation/screens/create_job_screen.dart'; // Import CreateJob
import 'package:helpme/features/jobs/presentation/screens/customer_job_detail_screen.dart'; // Import Detail Screen
import 'package:helpme/core/theme/app_spacing.dart';

class CustomerHomeScreen extends StatelessWidget {
  const CustomerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = Supabase.instance.client.auth.currentUser?.id;

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        title: const Text('Mein Dashboard'),
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
      body: userId == null
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<List<Map<String, dynamic>>>(
              stream: Supabase.instance.client
                  .from('jobs')
                  .stream(primaryKey: ['id'])
                  .eq('customer_id', userId)
                  .order('created_at', ascending: false),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                   return Center(child: Text('Fehler: ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final jobs = snapshot.data!;
                if (jobs.isEmpty) {
                  return Center(
                    child: Text(
                      'Du hast noch keine Aufträge erstellt.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: EdgeInsets.all(AppSpacing.lg),
                  itemCount: jobs.length,
                  separatorBuilder: (ctx, i) => SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, index) {
                    final job = jobs[index];
                    return _buildMyJobCard(job);
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateJobScreen()),
          );
        },
        backgroundColor: AppColors.accentPrimary,
        foregroundColor: AppColors.textInverse,
        icon: const Icon(Icons.add),
        label: const Text('Neuer Auftrag'),
      ),
    );
  }

  Widget _buildMyJobCard(Map<String, dynamic> job) {
    // We need to fetch application count separately or joined.
    // For simplicity in StreamBuilder, we can do a FutureBuilder inside here or just show basic info first.
    // Ideally, we would use a view or Rpc, but let's do a simple count query via FutureBuilder for now.

    return FutureBuilder<int>(
      future: Supabase.instance.client
          .from('job_applications')
          .count(CountOption.exact)
          .eq('job_id', job['id']),
      builder: (context, snapshot) {
        final applicantCount = snapshot.data ?? 0;

        return GestureDetector(
          onTap: () {
             Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CustomerJobDetailScreen(job: job),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.bgSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.bgElevated), // Customer color border maybe?
            ),
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        job['title'] ?? 'Unbekannt',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (applicantCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.accentSecondary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$applicantCount Angebot${applicantCount == 1 ? '' : 'e'}',
                            style: const TextStyle(
                              color: AppColors.textInverse,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        )
                      else
                        const Text(
                          'Warten auf Angebote...',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.sm),
                  Text(
                    'Budget: ${job['budget']} €',
                    style: const TextStyle(color: AppColors.success),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    );
  }
}
