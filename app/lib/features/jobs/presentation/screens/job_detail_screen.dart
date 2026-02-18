import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class JobDetailScreen extends StatefulWidget {
  final Map<String, dynamic> job;

  const JobDetailScreen({super.key, required this.job});

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  bool _isLoading = false;
  bool _hasApplied = false;

  @override
  void initState() {
    super.initState();
    _checkIfApplied();
  }

  Future<void> _checkIfApplied() async {
    final userId = Supabase.instance.client.auth.currentUser!.id;
    final jobId = widget.job['id'];

    final response = await Supabase.instance.client
        .from('job_applications')
        .select()
        .eq('job_id', jobId)
        .eq('craftsman_id', userId)
        .maybeSingle();

    if (response != null) {
      if (mounted) setState(() => _hasApplied = true);
    }
  }

  Future<void> _submitOffer(String message, String price) async {
    setState(() => _isLoading = true);
    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;
      final jobId = widget.job['id'];

      await Supabase.instance.client.from('job_applications').insert({
        'job_id': jobId,
        'craftsman_id': userId,
        'message': message,
        'price_offer': double.tryParse(price.replaceAll(',', '.')),
        'status': 'pending', 
      });

      if (mounted) {
        setState(() => _hasApplied = true);
        Navigator.pop(context); // Close dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hilfe erfolgreich angeboten! 🚀')),
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

  void _showOfferDialog() {
    final messageController = TextEditingController();
    final priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.bgSurface,
        title: const Text('Hilfe anbieten', style: TextStyle(color: AppColors.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: messageController,
              decoration: const InputDecoration(
                labelText: 'Nachricht (z.B. "Kann ich machen!")',
                labelStyle: TextStyle(color: AppColors.textSecondary),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.textSecondary)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.accentSecondary)),
              ),
              style: const TextStyle(color: AppColors.textPrimary),
              maxLines: 3,
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Preisvorschlag (€) (Optional)',
                labelStyle: TextStyle(color: AppColors.textSecondary),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.textSecondary)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.accentSecondary)),
              ),
              style: const TextStyle(color: AppColors.textPrimary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => _submitOffer(messageController.text, priceController.text),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentSecondary,
              foregroundColor: AppColors.textInverse,
            ),
            child: const Text('Senden'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.job['title'] ?? 'Unbekannt';
    final description = widget.job['description'] ?? 'Keine Beschreibung';
    final location = widget.job['location'] ?? 'Kein Ort';
    final budget = widget.job['budget'] ?? 'VB';
    final category = widget.job['category'] ?? 'Sonstiges';
    final date = widget.job['scheduled_date'] != null 
        ? DateTime.parse(widget.job['scheduled_date']).toString().split(' ')[0] 
        : 'Baldmöglichst';

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: AppColors.bgPrimary,
        foregroundColor: AppColors.textPrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Chip(
                  label: Text(category, style: const TextStyle(color: AppColors.textInverse)),
                  backgroundColor: AppColors.accentPrimary,
                ),
                Text(
                  budget,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            // Details
            _buildDetailRow(Icons.location_on, 'Ort', location),
            const SizedBox(height: AppSpacing.md),
            _buildDetailRow(Icons.calendar_today, 'Wann?', date),
            
            const SizedBox(height: AppSpacing.xl),
            const Text(
              'Beschreibung',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              description,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
            ),

            const Spacer(),

            // CTA Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _hasApplied ? null : _isLoading ? null : _showOfferDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _hasApplied ? AppColors.bgSurface : AppColors.accentSecondary,
                  foregroundColor: _hasApplied ? AppColors.textSecondary : AppColors.textInverse,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading 
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: AppColors.textInverse))
                  : Text(_hasApplied ? 'Bereits angeboten ✅' : 'Hilfe anbieten 🤝'),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textSecondary, size: 20),
        const SizedBox(width: AppSpacing.md),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w500)),
          ],
        ),
      ],
    );
  }
}
