import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../onboarding/presentation/screens/role_selection_screen.dart';
import 'package:helpme/core/theme/app_spacing.dart';
import 'package:helpme/core/theme/app_typography.dart';
import 'package:helpme/features/jobs/presentation/screens/job_detail_screen.dart';
import 'package:helpme/features/chat/presentation/screens/chat_screen.dart'; 
import 'package:helpme/features/profile/presentation/screens/profile_setup_screen.dart'; // Import Profile

class CraftsmanHomeScreen extends StatefulWidget {
  const CraftsmanHomeScreen({super.key});

  @override
  State<CraftsmanHomeScreen> createState() => _CraftsmanHomeScreenState();
}

class _CraftsmanHomeScreenState extends State<CraftsmanHomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        title: Text(_currentIndex == 0 ? 'Jobs finden 🔍' : 'Meine Aufträge ✅'),
        backgroundColor: AppColors.bgPrimary,
        foregroundColor: AppColors.textPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
               Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileSetupScreen(role: 'craftsman')), // Pass role
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: _currentIndex == 0 ? _buildJobFeed() : _buildMyJobs(),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.bgSurface,
        selectedItemColor: AppColors.accentPrimary,
        unselectedItemColor: AppColors.textSecondary,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Jobs finden',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle_outline),
            label: 'Meine Aufträge',
          ),
        ],
      ),
    );
  }

  // --- TAB 1: FEED ---
  Widget _buildJobFeed() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: Supabase.instance.client
          .from('jobs')
          .stream(primaryKey: ['id']).order('created_at', ascending: false),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final jobs = snapshot.data!;
        
        if (jobs.isEmpty) {
          return const Center(
            child: Text(
              'Aktuell keine Jobs verfügbar.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.lg),
          itemCount: jobs.length,
          separatorBuilder: (ctx, i) => const SizedBox(height: AppSpacing.md),
          itemBuilder: (context, index) {
            final job = jobs[index];
            return _buildJobCard(context, job);
          },
        );
      },
    );
  }

  // --- TAB 2: MY JOBS ---
  Widget _buildMyJobs() {
    final userId = Supabase.instance.client.auth.currentUser!.id;
    
    // We fetch 'job_applications' joined with 'jobs'
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: Supabase.instance.client
          .from('job_applications')
          .select('*, jobs(*)')
          .eq('craftsman_id', userId)
          .order('created_at', ascending: false),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
           return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Fehler: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
        }
        
        final applications = snapshot.data ?? [];

        if (applications.isEmpty) {
          return const Center(
            child: Text(
              'Du hast noch keine Hilfe angeboten.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.lg),
          itemCount: applications.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
          itemBuilder: (context, index) {
            final app = applications[index];
            final job = app['jobs']; // Joined job data
            final status = app['status'];

            if (job == null) return const SizedBox.shrink();

            return Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.bgSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: status == 'accepted' ? AppColors.success : AppColors.bgElevated,
                  width: status == 'accepted' ? 2 : 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        status == 'accepted' ? 'Im Kontakt 💬' : 'Wartet auf Antwort ⏳',
                        style: TextStyle(
                          color: status == 'accepted' ? AppColors.accentPrimary : AppColors.textSecondary,

                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '${app['price_offer'] ?? job['budget']} €',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    job['title'] ?? 'Unbekannt',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Deine Nachricht: "${app['message']}"',
                    style: const TextStyle(color: AppColors.textSecondary, fontStyle: FontStyle.italic),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (status == 'accepted') ...[
                    const SizedBox(height: AppSpacing.md),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          if (job['customer_id'] != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatScreen(
                                  otherUserId: job['customer_id'],
                                  otherUserName: 'Kunde', // Could fetch name
                                  applicationId: app['id'],
                                ),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Fehler: Keine Kunden-ID gefunden! 🛑')),
                            );
                          }
                        },
                        icon: const Icon(Icons.chat_bubble_outline),
                        label: const Text('Kunden kontaktieren'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildJobCard(BuildContext context, Map<String, dynamic> job) {
    final title = job['title'] ?? 'Unbekannt';
    final category = job['category'] ?? 'Sonstiges';
    final location = job['location'] ?? 'Kein Ort';
    final budget = job['budget'] ?? 'VB';
    
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
