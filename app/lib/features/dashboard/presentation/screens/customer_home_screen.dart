import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart'; // Added this import
import '../../../onboarding/presentation/screens/role_selection_screen.dart';
import '../../../jobs/presentation/screens/create_job_screen.dart';
import '../../../jobs/presentation/screens/customer_job_detail_screen.dart'; 
import '../../../profile/presentation/screens/profile_setup_screen.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  final _userId = Supabase.instance.client.auth.currentUser?.id;
  String _userName = 'Kunde';
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    if (_userId == null) return;
    try {
      final data = await Supabase.instance.client
          .from('profiles')
          .select('full_name, avatar_url')
          .eq('id', _userId!)
          .maybeSingle();
      
      if (data != null && mounted) {
        setState(() {
          final fullName = data['full_name'] as String?;
          if (fullName != null && fullName.isNotEmpty) {
             _userName = fullName.split(' ').first; // First name only
          }
          _avatarUrl = data['avatar_url'] as String?;
        });
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary, // Dark Theme 0xFF0E121A
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header (Greeting + Avatar)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Willkommen zurück,',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 14,
                          fontFamily: 'Outfit',
                        ),
                      ),
                      Text(
                        '$_userName 👋',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Outfit',
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ProfileSetupScreen(role: 'customer')),
                    ),
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.bgSurface,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.accentPrimary.withValues(alpha: 0.3), width: 2),
                        image: _avatarUrl != null 
                            ? DecorationImage(image: NetworkImage(_avatarUrl!), fit: BoxFit.cover) 
                            : null,
                      ),
                      child: _avatarUrl == null 
                          ? const Icon(Icons.person, color: Colors.white) 
                          : null,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),

              // 2. Hero Card "Need Help?" (Compact)
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => CreateJobScreen()),
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.accentPrimary,
                        AppColors.accentPrimary.withValues(alpha: 0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accentPrimary.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Neue Anfrage',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Outfit',
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Finde jetzt den passenden Handwerker.',
                              style: TextStyle(
                                color: Colors.black.withValues(alpha: 0.7),
                                fontSize: 14,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.add, color: Colors.black, size: 28),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // 3. Categories Title
              const Text(
                'Bereiche',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Outfit',
                ),
              ),
              const SizedBox(height: 16),

              // 4. Categories Grid
              SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildCategoryItem(Icons.water_drop_outlined, 'Sanitär'),
                    const SizedBox(width: 16),
                    _buildCategoryItem(Icons.lightbulb_outline, 'Elektro'),
                    const SizedBox(width: 16),
                    _buildCategoryItem(Icons.chair_outlined, 'Möbel'),
                    const SizedBox(width: 16),
                    _buildCategoryItem(Icons.grass_outlined, 'Garten'),
                    const SizedBox(width: 16),
                    _buildCategoryItem(Icons.format_paint_outlined, 'Maler'),
                  ],
                ),
              ),

              const SizedBox(height: 32),
              
              // 5. Active Jobs Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Aktuelle Aufträge',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Outfit',
                    ),
                  ),
                  // Optional "See All" button
                ],
              ),
              const SizedBox(height: 16),

              // 6. Active Jobs List (StreamBuilder)
              _buildActiveJobsList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryItem(IconData icon, String label) {
    return GestureDetector(
      onTap: () {
        // TODO: Pass category to CreateJobScreen
        Navigator.push(context, MaterialPageRoute(builder: (_) => CreateJobScreen()));
      },
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.bgElevated,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveJobsList() {
    if (_userId == null) return const SizedBox.shrink();

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: Supabase.instance.client
          .from('jobs')
          .select('*') // Select all columns for now
          .eq('customer_id', _userId!)
          .order('created_at', ascending: false)
          .limit(5)
          .asStream(), // Ensure it's treated as a stream
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
           return const Center(child: CircularProgressIndicator(color: AppColors.accentPrimary));
        }
        if (snapshot.hasError) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Text('Fehler: ${snapshot.error}', style: const TextStyle(color: Colors.red)),
          );
        }

        final jobs = snapshot.data ?? [];

        if (jobs.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.separated(
          shrinkWrap: true, // Important inside SingleChildScrollView
          physics: const NeverScrollableScrollPhysics(), // Scroll handled by parent
          itemCount: jobs.length,
          separatorBuilder: (ctx, i) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final job = jobs[index];
            return _buildJobCard(context, job);
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.bgSurface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Icon(Icons.assignment_outlined, size: 48, color: Colors.white.withValues(alpha: 0.2)),
          const SizedBox(height: 16),
          Text(
            'Keine laufenden Aufträge',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildJobCard(BuildContext context, Map<String, dynamic> job) {
    final title = job['title'] ?? 'Unbenannter Auftrag';
    final status = job['status'] ?? 'offen'; // open, in_progress, completed
    final category = job['category'] ?? 'Allgemein';
    // Format date if needed, for now just simplistic
    
    Color statusColor = Colors.orange;
    String statusText = 'Offen';
    if (status == 'in_progress') {
      statusColor = Colors.blue;
      statusText = 'In Arbeit';
    } else if (status == 'completed') {
      statusColor = Colors.green;
      statusText = 'Erledigt';
    }

    return GestureDetector(
      onTap: () {
         Navigator.push(
           context, 
           MaterialPageRoute(builder: (_) => CustomerJobDetailScreen(job: job)),
         );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.bgElevated,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
             BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            // Icon / Category
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.bgSurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.build_circle_outlined, color: Colors.white70), 
            ),
            const SizedBox(width: 16),
            
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: statusColor.withValues(alpha: 0.5), width: 0.5),
                        ),
                        child: Text(
                          statusText,
                          style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        category,
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.white30),
          ],
        ),
      ),
    );
  }
}
