import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../chat/presentation/screens/chat_screen.dart'; // Import Chat
import '../../../profile/presentation/screens/public_profile_screen.dart'; // Import Profile

class CustomerJobDetailScreen extends StatefulWidget {
  final Map<String, dynamic> job;

  const CustomerJobDetailScreen({super.key, required this.job});

  @override
  State<CustomerJobDetailScreen> createState() => _CustomerJobDetailScreenState();
}

class _CustomerJobDetailScreenState extends State<CustomerJobDetailScreen> {
  // State
  List<Map<String, dynamic>> _applications = [];
  bool _isLoadingApps = true;

  @override
  void initState() {
    super.initState();
    _loadApplications();
  }

  Future<void> _loadApplications() async {
    final jobId = widget.job['id'];
    try {
      // Fetch applications joined with profiles to get craftsman name/avatar
      final response = await Supabase.instance.client
          .from('job_applications')
          .select('*, profiles:craftsman_id(*)') 
          .eq('job_id', jobId)
          .order('created_at', ascending: false);
      
      if (mounted) {
        setState(() {
          _applications = List<Map<String, dynamic>>.from(response);
          _isLoadingApps = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading applications: $e');
      if (mounted) setState(() => _isLoadingApps = false);
    }
  }

  void _startChat(String craftsmanId, String craftsmanName, String applicationId) {
    // Navigate to Chat
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          otherUserId: craftsmanId,
          otherUserName: craftsmanName,
          applicationId: applicationId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.job['title'] ?? 'Unbekannt';
    final description = widget.job['description'] ?? 'Keine Beschreibung';
    final images = widget.job['images'] as List<dynamic>?;
    final status = widget.job['status'] ?? 'open';
    
    // Status Logic
    Color statusColor = Colors.orangeAccent;
    String statusText = 'Offen';
    if (status == 'in_progress') {
       statusColor = Colors.blueAccent;
       statusText = 'In Arbeit';
    } else if (status == 'completed') {
       statusColor = Colors.greenAccent;
       statusText = 'Erledigt';
    }

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: Stack(
        children: [
          // 1. Header Image
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 250,
            child: images != null && images.isNotEmpty
                ? Image.network(images[0] as String, fit: BoxFit.cover)
                : Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.accentPrimary.withOpacity(0.2), AppColors.bgPrimary],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Center(child: Icon(Icons.handyman_outlined, size: 80, color: Colors.white.withOpacity(0.1))),
                  ),
          ),
          
          // Overlay Gradient
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 250,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black54, Colors.transparent, AppColors.bgPrimary],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),

          // Back Button
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
              ),
            ),
          ),

          // Content
          Positioned(
            top: 200,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              decoration: const BoxDecoration(
                color: AppColors.bgPrimary,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: statusColor),
                    ),
                    child: Text(statusText.toUpperCase(), style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 12),
                  
                  // Title
                  Text(
                    title,
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Applications Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Bewerbungen', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      if (!_isLoadingApps)
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(color: AppColors.accentPrimary, shape: BoxShape.circle),
                          child: Text('${_applications.length}', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // List of Applicants
                  Expanded(
                    child: _isLoadingApps 
                        ? const Center(child: CircularProgressIndicator(color: AppColors.accentPrimary))
                        : _applications.isEmpty 
                            ? _buildEmptyState()
                            : ListView.separated(
                                itemCount: _applications.length,
                                separatorBuilder: (ctx, i) => const SizedBox(height: 16),
                                itemBuilder: (context, index) {
                                  return _buildApplicationCard(_applications[index]);
                                },
                              ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_search_outlined, size: 60, color: Colors.white.withOpacity(0.2)),
          const SizedBox(height: 16),
          Text(
            'Noch keine Bewerbungen.',
            style: TextStyle(color: Colors.white.withOpacity(0.5)),
          ),
          Text(
            'Wir benachrichtigen dich, sobald sich ein Handwerker meldet.',
            style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<bool> _hasUnreadMessages(String applicationId) async {
    final myId = Supabase.instance.client.auth.currentUser?.id;
    if (myId == null) return false;
    
    final response = await Supabase.instance.client
        .from('messages')
        .select('id')
        .eq('application_id', applicationId)
        .eq('receiver_id', myId)
        .eq('is_read', false)
        .limit(1)
        .maybeSingle();
        
    return response != null;
  }

  Widget _buildApplicationCard(Map<String, dynamic> app) {
    final craftsman = app['profiles'] ?? {}; // Joined data
    final name = craftsman['full_name'] ?? 'Handwerker';
    final avatarUrl = craftsman['avatar_url']; // Potential URL
    final message = app['message'] ?? 'Keine Nachricht';
    final price = app['price_offer'];
    final applicationId = app['id']; // Needed for unread check
    final craftsmanId = app['craftsman_id'];
    final status = app['status'] ?? 'pending'; // Default to pending

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Avatar + Name + Price
          GestureDetector(
            onTap: () {
              if (craftsmanId != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => PublicProfileScreen(userId: craftsmanId)),
                );
              }
            },
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                     color: AppColors.bgSurface,
                     shape: BoxShape.circle,
                     image: avatarUrl != null ? DecorationImage(image: NetworkImage(avatarUrl), fit: BoxFit.cover) : null,
                  ),
                  child: avatarUrl == null ? const Icon(Icons.person, color: Colors.white70) : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      Row(
                         children: const [
                           Icon(Icons.star, size: 12, color: AppColors.accentPrimary),
                           SizedBox(width: 4),
                           Text('Profil ansehen', style: TextStyle(color: AppColors.accentPrimary, fontSize: 12, decoration: TextDecoration.underline)),
                        ],
                      ),
                    ],
                  ),
                ),
              if (price != null)
                Text(
                  '$price €',
                  style: const TextStyle(color: AppColors.accentPrimary, fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
          ),

          
          // Unread Indicator (if any)
          FutureBuilder<bool>(
            future: _hasUnreadMessages(applicationId),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data == true) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 8),
                      const Text('Neue Nachricht 💬', style: TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),

          const SizedBox(height: 12),
          
          // Message
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.bgSurface.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '"$message"',
              style: TextStyle(color: Colors.white.withOpacity(0.8), fontStyle: FontStyle.italic),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Actions
          Row(
            children: [
              // Chat Button
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(
                          otherUserId: craftsmanId,
                          otherUserName: name,
                          applicationId: applicationId,
                        ),
                      ),
                    ).then((_) => setState(() {})); // Refresh on return
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: AppColors.textSecondary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Chat'),
                ),
              ),
              const SizedBox(width: 12),
              
              // Action Button (Accept or Complete)
              Expanded(
                child: status == 'accepted' 
                ? ElevatedButton(
                    onPressed: () => _showReviewDialog(craftsmanId, applicationId),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Abschließen'),
                  )
                : ElevatedButton(
                    onPressed: status == 'pending' ? () => _acceptOffer(applicationId) : null, // Assuming _acceptOffer exists or we need to add it
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentPrimary,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      disabledBackgroundColor: Colors.grey.withOpacity(0.3),
                    ),
                    child: Text(status == 'pending' ? 'Annehmen' : (status == 'declined' ? 'Abgelehnt' : 'Status: $status')),
                  ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _acceptOffer(String applicationId) async {
    try {
      // 1. Mark this application as ACCEPTED
      await Supabase.instance.client
          .from('job_applications')
          .update({'status': 'accepted'})
          .eq('id', applicationId);
          
      // 2. Mark database job as 'assigned' or similar? Optional.
      // For now, we keep job 'open' or mark it 'in_progress'
      // Maybe we want to decline all others? For MVP, we allow multiple accepts or just one.
      
      setState(() {
        // Optimistic update
        final index = _applications.indexWhere((app) => app['id'] == applicationId);
        if (index != -1) {
          _applications[index]['status'] = 'accepted';
        }
      });
      
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Fehler: $e')));
    }
  }

  Future<void> _showReviewDialog(String craftsmanId, String applicationId) async {
    final commentController = TextEditingController();
    int rating = 5;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: AppColors.bgElevated,
          title: const Text('Auftrag abschließen & Bewerten', style: TextStyle(color: AppColors.textPrimary)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Wie war die Arbeit?', style: TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    onPressed: () => setState(() => rating = index + 1),
                    icon: Icon(
                      index < rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 32,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: commentController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  hintText: 'Kommentar (optional)',
                  hintStyle: TextStyle(color: AppColors.textSecondary),
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Abbrechen', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context); // Close dialog
                await _completeJobAndReview(craftsmanId, applicationId, rating, commentController.text);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentPrimary, foregroundColor: Colors.black),
              child: const Text('Fertig'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _completeJobAndReview(String craftsmanId, String applicationId, int rating, String comment) async {
    try {
      final myId = Supabase.instance.client.auth.currentUser!.id;
      final jobId = widget.job['id'];

      // 1. Create Review
      await Supabase.instance.client.from('reviews').insert({
        'job_id': jobId,
        'reviewer_id': myId,
        'reviewee_id': craftsmanId,
        'rating': rating,
        'comment': comment,
      });

      // 2. Mark Job as Completed
      await Supabase.instance.client
          .from('jobs')
          .update({'status': 'completed'})
          .eq('id', jobId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vielen Dank! Auftrag abgeschlossen. 🎉')),
        );
        Navigator.pop(context); // Go back to Home
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Abschließen: $e')),
        );
      }
    }
  }
}
