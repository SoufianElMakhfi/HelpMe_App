import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:helpme/core/theme/app_spacing.dart'; // Fixed import
import 'package:helpme/features/chat/presentation/screens/chat_screen.dart'; // Import Chat

class CustomerJobDetailScreen extends StatefulWidget {
  final Map<String, dynamic> job;

  const CustomerJobDetailScreen({super.key, required this.job});

  @override
  State<CustomerJobDetailScreen> createState() => _CustomerJobDetailScreenState();
}

class _CustomerJobDetailScreenState extends State<CustomerJobDetailScreen> {
  bool _isLoading = false;

  Future<void> _acceptOffer(String applicationId) async {
    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client
          .from('job_applications')
          .update({'status': 'accepted'})
          .eq('id', applicationId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kontakt hergestellt! 🎉')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _startChat(String craftsmanId, String applicationId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          otherUserId: craftsmanId, 
          otherUserName: 'Handwerker', 
          applicationId: applicationId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.job['title'] ?? 'Unbekannt';
    final description = widget.job['description'] ?? 'Keine Beschreibung';
    final budget = widget.job['budget'] ?? 'VB';
    final jobId = widget.job['id'];

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        title: const Text('Bewerbungen'),
        backgroundColor: AppColors.bgPrimary,
        foregroundColor: AppColors.textPrimary,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Job Header (Compact)
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            color: AppColors.bgSurface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    const Icon(Icons.euro, color: AppColors.success, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      'Budget: $budget €',
                      style: const TextStyle(
                        color: AppColors.success,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: AppSpacing.lg),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Text(
              'Eingehende Angebote',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Applications List
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: Supabase.instance.client
                  .from('job_applications')
                  .stream(primaryKey: ['id'])
                  .eq('job_id', jobId)
                  .order('created_at', ascending: false),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Fehler: ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final applications = snapshot.data!;

                if (applications.isEmpty) {
                  return const Center(
                    child: Text(
                      'Noch keine Bewerbungen.',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  itemCount: applications.length,
                  separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, index) {
                    final app = applications[index];
                    return _buildApplicationCard(app);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationCard(Map<String, dynamic> application) {
    final craftsmanId = application['craftsman_id'];
    final message = application['message'] ?? '';
    final priceOffer = application['price_offer'];
    final status = application['status'] ?? 'pending';

    return FutureBuilder<Map<String, dynamic>>(
      future: Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', craftsmanId)
          .single(),
      builder: (context, snapshot) {
        final profile = snapshot.data;
        final name = profile != null 
            ? '${profile['first_name'] ?? ''} ${profile['last_name'] ?? ''}'.trim()
            : 'Lädt...';
        final company = profile?['company_name'];

        return Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.bgSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: status == 'accepted' 
                  ? AppColors.accentPrimary 
                  : AppColors.bgElevated,
              width: status == 'accepted' ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Name & Price
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        company != null && company.isNotEmpty ? company : name,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (company != null && company.isNotEmpty)
                        Text(
                          name,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                  if (priceOffer != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.bgElevated,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$priceOffer €',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              
              // Message
              Text(
                '"$message"',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Actions
              if (status == 'accepted')
                Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.accentPrimary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text(
                          'Im Kontakt 💬',
                          style: TextStyle(
                            color: AppColors.accentPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        // ERROR: _startChat expects 2 args now. 'application' variable is available in scope?
                        // Yes, _buildApplicationCard(Map<String, dynamic> application)
                        onPressed: () => _startChat(craftsmanId, application['id']), 
                        icon: const Icon(Icons.chat_bubble_outline),
                        label: const Text('Zum Chat'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textPrimary,
                          side: const BorderSide(color: AppColors.textSecondary),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                )
              else
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : () => _acceptOffer(application['id']),
                    icon: const Icon(Icons.chat_bubble_outline),
                    label: const Text('Kontakt aufnehmen'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentPrimary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
