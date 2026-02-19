import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../onboarding/presentation/screens/role_selection_screen.dart';
import '../../../jobs/presentation/screens/job_detail_screen.dart'; // We need to build/refactor this too
import '../../../profile/presentation/screens/profile_setup_screen.dart'; 

class CraftsmanHomeScreen extends StatefulWidget {
  const CraftsmanHomeScreen({super.key});

  @override
  State<CraftsmanHomeScreen> createState() => _CraftsmanHomeScreenState();
}

class _CraftsmanHomeScreenState extends State<CraftsmanHomeScreen> {
  final _userId = Supabase.instance.client.auth.currentUser?.id;
  String _userName = 'Meister';
  String? _avatarUrl;
  int _selectedTab = 0; // 0 = Marketplace (Open Jobs), 1 = My Jobs

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
             _userName = fullName.split(' ').first; 
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
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Header with Greeting & Avatar
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Moin, $_userName 👋',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Outfit',
                        ),
                      ),
                      Text(
                        _selectedTab == 0 ? 'Finde neue Aufträge' : 'Deine Baustellen',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ProfileSetupScreen(role: 'craftsman')),
                    ),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.bgSurface,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.accentSecondary.withValues(alpha: 0.3), width: 2),
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
            ),

            // 2. Custom Tab Switcher
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.bgElevated,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildTabButton('Marktplatz', 0),
                  ),
                  Expanded(
                    child: _buildTabButton('Meine Jobs', 1),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),

            // 3. Job List (Feed)
            Expanded(
              child: _selectedTab == 0 ? _buildMarketplaceFeed() : _buildMyJobsFeed(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String label, int index) {
    bool isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accentSecondary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white.withValues(alpha: 0.5),
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildMarketplaceFeed() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: Supabase.instance.client
          .from('jobs')
          .select('*')
          .eq('status', 'open') // Only show OPEN jobs
          .order('created_at', ascending: false)
          .asStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
           return const Center(child: CircularProgressIndicator(color: AppColors.accentSecondary));
        }
        if (snapshot.hasError) {
           return Center(child: Text('Fehler: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
        }
        
        final jobs = snapshot.data ?? [];
        
        if (jobs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 64, color: Colors.white.withValues(alpha: 0.2)),
                const SizedBox(height: 16),
                Text(
                  'Keine offenen Aufträge gefunden.',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          itemCount: jobs.length,
          separatorBuilder: (ctx, i) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            return _buildJobCard(jobs[index]);
          },
        );
      },
    );
  }

  Widget _buildMyJobsFeed() {
    // Placeholder for "My Jobs" logic (requires assignment logic)
    // For now, let's show jobs where craftsman_id matches (if we had that column)
    return Center(
      child: Text(
        'Du hast noch keine Aufträge angenommen.',
        style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
      ),
    );
  }

  Widget _buildJobCard(Map<String, dynamic> job) {
    // Extract Data
    final title = job['title'] ?? 'Unbekannt';
    final category = job['category'] ?? 'Allgemein';
    final city = job['city'] ?? 'Unbekannt';
    // final status = job['status'];
    final urgency = job['urgency'] ?? 'normal';
    final images = job['images'] as List<dynamic>?;
    final hasImage = images != null && images.isNotEmpty;

    // Urgency Color/Icon
    Color urgencyColor = Colors.orangeAccent;
    String urgencyText = 'Wichtig';
    if (urgency == 'emergency') {
      urgencyColor = Colors.redAccent;
      urgencyText = 'Notfall';
    } else if (urgency == 'flexible') {
      urgencyColor = Colors.greenAccent;
      urgencyText = 'Flexibel';
    }

    return GestureDetector(
      onTap: () {
        // Navigate to Job Detail
        Navigator.push(context, MaterialPageRoute(builder: (_) => JobDetailScreen(job: job)));
      },
      child: Container(
        height: 140, // Fixed height for consistent look
        decoration: BoxDecoration(
          color: AppColors.bgElevated,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            // Left: Image or Icon
            Container(
              width: 120,
              decoration: BoxDecoration(
                color: AppColors.bgSurface,
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), bottomLeft: Radius.circular(20)),
                image: hasImage ? DecorationImage(
                  image: NetworkImage(images[0]),
                  fit: BoxFit.cover,
                ) : null,
              ),
              child: !hasImage 
                  ? Center(child: Icon(_getCategoryIcon(category), color: Colors.white24, size: 40)) 
                  : null,
            ),
            
            // Right: Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Badge (Urgency)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: urgencyColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: urgencyColor.withValues(alpha: 0.5), width: 0.5),
                      ),
                      child: Text(
                        urgencyText.toUpperCase(),
                        style: TextStyle(color: urgencyColor, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                    
                    // Title
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    // Location & Category
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, size: 14, color: Colors.white54),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            city,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white54, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    // Simple mapper
    switch (category) {
      case 'Sanitär': return Icons.water_drop_outlined;
      case 'Elektro': return Icons.lightbulb_outline;
      case 'Möbel': return Icons.chair_outlined;
      case 'Garten': return Icons.grass_outlined;
      case 'Maler': return Icons.format_paint_outlined;
      default: return Icons.build_circle_outlined;
    }
  }
}
