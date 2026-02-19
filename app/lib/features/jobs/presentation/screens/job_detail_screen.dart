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
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    final jobId = widget.job['id'];

    // Check if job_applications table exists and if we already applied
    try {
      final response = await Supabase.instance.client
          .from('job_applications')
          .select()
          .eq('job_id', jobId)
          .eq('craftsman_id', userId)
          .maybeSingle();

      if (response != null && mounted) {
        setState(() => _hasApplied = true);
      }
    } catch (e) {
      // Table might not exist yet, ignore error for now
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
        Navigator.pop(context); 
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Angebot gesendet! 🚀')),
        );
      }
    } catch (e) {
      if (mounted) {
         // Show specific error or generic one
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
        backgroundColor: const Color(0xFF1E2430),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Angebot senden', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: messageController,
              decoration: InputDecoration(
                labelText: 'Nachricht (z.B. "Bin morgen frei")',
                labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                filled: true,
                fillColor: const Color(0xFF15181E),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              style: const TextStyle(color: Colors.white),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Preis (€) (Geschätzt)',
                labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                filled: true,
                fillColor: const Color(0xFF15181E),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () => _submitOffer(messageController.text, priceController.text),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentSecondary,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Senden'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Data Extraction
    final title = widget.job['title'] ?? 'Unbekannt';
    final description = widget.job['description'] ?? 'Keine Beschreibung';
    final category = widget.job['category'] ?? 'Sonstiges';
    final city = widget.job['city'] ?? 'Unbekannt';
    final zip = widget.job['zip_code'] ?? '';
    final urgency = widget.job['urgency'] ?? 'normal';
    final images = widget.job['images'] as List<dynamic>?;

    // Urgency Logic
    Color urgencyColor = Colors.orangeAccent;
    String urgencyText = 'Wichtig';
    IconData urgencyIcon = Icons.calendar_today;
    if (urgency == 'emergency') {
      urgencyColor = Colors.redAccent;
      urgencyText = 'Notfall';
      urgencyIcon = Icons.warning_amber_rounded;
    } else if (urgency == 'flexible') {
      urgencyColor = Colors.greenAccent;
      urgencyText = 'Flexibel';
      urgencyIcon = Icons.weekend_outlined;
    }

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: Stack(
        children: [
          // 1. Background Image (Hero) or Gradient
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 300,
            child: images != null && images.isNotEmpty
                ? Image.network(images[0] as String, fit: BoxFit.cover)
                : Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.accentSecondary.withValues(alpha: 0.2), AppColors.bgPrimary],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Center(child: Icon(Icons.handyman_outlined, size: 80, color: Colors.white.withValues(alpha: 0.1))),
                  ),
          ),
          // Gradient Overlay
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 300,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black.withValues(alpha: 0.6), Colors.transparent, AppColors.bgPrimary],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),

          // 2. Back Button
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
              ),
            ),
          ),

          // 3. Content Scrollable
          Positioned(
            top: 250,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              decoration: const BoxDecoration(
                color: AppColors.bgPrimary,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge & Category
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: urgencyColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: urgencyColor),
                          ),
                          child: Row(
                            children: [
                              Icon(urgencyIcon, size: 14, color: urgencyColor),
                              const SizedBox(width: 6),
                              Text(urgencyText.toUpperCase(), style: TextStyle(color: urgencyColor, fontWeight: FontWeight.bold, fontSize: 12)),
                            ],
                          ),
                        ),
                        Text(category, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Title
                    Text(
                      title,
                      style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold, height: 1.2),
                    ),
                    const SizedBox(height: 24),
                    
                    // Location
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: AppColors.bgElevated, borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.location_on_outlined, color: AppColors.accentSecondary),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Einsatzort', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
                            Text('$zip $city', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                            const Text('(Genaue Adresse nach Annahme)', style: TextStyle(color: Colors.white30, fontSize: 10)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Description
                    const Text('Beschreibung', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Text(
                      description,
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 16, height: 1.5),
                    ),
                    const SizedBox(height: 32),

                    // Image Gallery Section (if more than 1 image)
                    if (images != null && images.length > 1) ...[
                      const Text('Fotos', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 100,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: images.length,
                          separatorBuilder: (ctx, i) => const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                // Fullscreen view logic here
                              },
                              child: Container(
                                width: 100,
                                decoration: BoxDecoration(
   borderRadius: BorderRadius.circular(16),
                                  image: DecorationImage(image: NetworkImage(images[index] as String), fit: BoxFit.cover),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],

                    const SizedBox(height: 80), // Space for FAB
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: SizedBox(
          width: double.infinity,
          child: FloatingActionButton.extended(
            onPressed: () {
               if (_hasApplied) return;
               _showOfferDialog();
            },
            backgroundColor: _hasApplied ? Colors.grey : AppColors.accentSecondary,
            foregroundColor: _hasApplied ? Colors.white : Colors.black,
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            label: Text(_hasApplied ? 'Angebot gesendet ✅' : 'Angebot machen', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            icon: Icon(_hasApplied ? Icons.check : Icons.send_rounded),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
