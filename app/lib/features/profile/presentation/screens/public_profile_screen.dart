import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';

class PublicProfileScreen extends StatefulWidget {
  final String userId; // The ID of the user to show (e.g., craftsman)

  const PublicProfileScreen({super.key, required this.userId});

  @override
  State<PublicProfileScreen> createState() => _PublicProfileScreenState();
}

class _PublicProfileScreenState extends State<PublicProfileScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _profile;
  List<Map<String, dynamic>> _reviews = [];
  double _averageRating = 0.0;
  int _reviewCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    try {
      // 1. Fetch Profile
      final profileResponse = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', widget.userId)
          .single();

      // 2. Fetch Reviews
      final reviewsResponse = await Supabase.instance.client
          .from('reviews')
          .select('*, profiles:reviewer_id(full_name, avatar_url)') // Join reviewer profile
          .eq('reviewee_id', widget.userId)
          .order('created_at', ascending: false);
      
      final reviewsList = List<Map<String, dynamic>>.from(reviewsResponse);

      // Calculate Average Rating
      double totalRating = 0;
      for (var review in reviewsList) {
        totalRating += (review['rating'] as num).toDouble();
      }
      final average = reviewsList.isNotEmpty ? totalRating / reviewsList.length : 0.0;

      setState(() {
        _profile = profileResponse;
        _reviews = reviewsList;
        _averageRating = average;
        _reviewCount = reviewsList.length;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Fehler beim Laden: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.bgPrimary,
        body: Center(child: CircularProgressIndicator(color: AppColors.accentPrimary)),
      );
    }

    if (_profile == null) {
      return const Scaffold(
        backgroundColor: AppColors.bgPrimary,
        body: Center(child: Text('Profil nicht gefunden', style: TextStyle(color: Colors.white))),
      );
    }

    final fullName = _profile!['full_name'] ?? 'Unbekannt';
    final companyName = _profile!['company_name'];
    final avatarUrl = _profile!['avatar_url'];
    final trades = _profile!['trades'] as List<dynamic>? ?? [];
    final bio = _profile!['bio'] ?? 'Keine Beschreibung verfügbar.';

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        title: Text(fullName),
        backgroundColor: AppColors.bgPrimary,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Header
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.bgElevated,
                    backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                    child: avatarUrl == null 
                        ? const Icon(Icons.person, size: 50, color: AppColors.textSecondary) 
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    fullName,
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  if (companyName != null && companyName.isNotEmpty)
                    Text(
                      companyName,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 16),
                    ),
                  const SizedBox(height: 8),
                  
                  // Rating Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.amber.withOpacity(0.5)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 20),
                        const SizedBox(width: 4),
                        Text(
                          _averageRating.toStringAsFixed(1),
                          style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '($_reviewCount Bewertungen)',
                          style: TextStyle(color: Colors.amber.withOpacity(0.8), fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Trades Chips
            if (trades.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: trades.map((trade) => Chip(
                  label: Text(trade.toString()),
                  backgroundColor: AppColors.bgElevated,
                  labelStyle: const TextStyle(color: AppColors.textPrimary),
                  side: BorderSide.none,
                )).toList(),
              ),

            const SizedBox(height: 32),
            
            // Description
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Über mich', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 8),
            GlassCard(
              child: Text(
                bio,
                style: const TextStyle(color: AppColors.textSecondary, height: 1.5),
              ),
            ),
            
            const SizedBox(height: 32),

            // Reviews List
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Bewertungen', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),
            
            if (_reviews.isEmpty)
              const Center(child: Text('Noch keine Bewertungen.', style: TextStyle(color: AppColors.textSecondary)))
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _reviews.length,
                itemBuilder: (context, index) {
                  final review = _reviews[index];
                  final reviewer = review['profiles'] ?? {}; // Joined profile
                  final reviewerName = reviewer['full_name'] ?? 'Kunde';
                  final rating = review['rating'] as int;
                  final comment = review['comment'] ?? '';
                  final date = DateTime.parse(review['created_at']);
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.bgElevated,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(reviewerName, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                            Text(
                              '${date.day}.${date.month}.${date.year}', 
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: List.generate(5, (starIndex) => Icon(
                            starIndex < rating ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 16,
                          )),
                        ),
                        if (comment.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(comment, style: const TextStyle(color: AppColors.textSecondary)),
                        ],
                      ],
                    ),
                  );
                },
              ),
              
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
