import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class ChatScreen extends StatefulWidget {
  final String otherUserId;
  final String? otherUserName;
  final String? applicationId; // Optional: Link to specific job application

  const ChatScreen({
    super.key,
    required this.otherUserId,
    this.otherUserName,
    this.applicationId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSending = false;
  Map<String, dynamic>? _otherUserProfile;

  @override
  void initState() {
    super.initState();
    _fetchOtherUserProfile();
  }

  Future<void> _fetchOtherUserProfile() async {
    try {
      final profile = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', widget.otherUserId)
          .single();
      
      if (mounted) {
        setState(() {
          _otherUserProfile = profile;
        });
      }
    } catch (e) {
      debugPrint('Error fetching profile: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    _controller.clear();
    setState(() => _isSending = true);

    try {
      final myId = Supabase.instance.client.auth.currentUser!.id;

      await Supabase.instance.client.from('messages').insert({
        'content': text,
        'sender_id': myId,
        'receiver_id': widget.otherUserId,
        'application_id': widget.applicationId,
      });

      // Scroll to bottom after sending
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0, // List is reversed, so 0 is bottom
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Senden: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final myId = Supabase.instance.client.auth.currentUser!.id;
    final otherName = _otherUserProfile?['full_name'] ?? _otherUserProfile?['company_name'] ?? widget.otherUserName ?? 'Chat';
    final otherAvatarUrl = _otherUserProfile?['avatar_url'];

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.bgElevated,
              backgroundImage: otherAvatarUrl != null ? NetworkImage(otherAvatarUrl) : null,
              child: otherAvatarUrl == null 
                  ? const Icon(Icons.person, color: AppColors.textSecondary) 
                  : null,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                otherName,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.bgPrimary,
        foregroundColor: AppColors.textPrimary,
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: widget.applicationId != null 
                    ? Supabase.instance.client
                        .from('messages')
                        .stream(primaryKey: ['id'])
                        .eq('application_id', widget.applicationId!) // Filter by application ID (Conversation)
                        .order('created_at', ascending: false) // Newest first (index 0) because list is reversed
                    : Supabase.instance.client
                        .from('messages')
                        .stream(primaryKey: ['id'])
                        .order('created_at', ascending: false)
                        .map((messages) => messages.where((msg) {
                              final sender = msg['sender_id'];
                              final receiver = msg['receiver_id'];
                              final myId = Supabase.instance.client.auth.currentUser?.id;
                              return (sender == myId && receiver == widget.otherUserId) ||
                                     (sender == widget.otherUserId && receiver == myId);
                            }).toList()),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Fehler: ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!;

                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.chat_bubble_outline, size: 48, color: AppColors.textSecondary),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'Sag Hallo! 👋',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  reverse: true, // Start from bottom
                  controller: _scrollController,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg['sender_id'] == myId;
                    return _buildMessageBubble(msg['content'], isMe, otherAvatarUrl);
                  },
                );
              },
            ),
          ),

          // Input Area
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            color: AppColors.bgSurface,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textCapitalization: TextCapitalization.sentences,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Nachricht schreiben...',
                      hintStyle: const TextStyle(color: AppColors.textSecondary),
                      filled: true,
                      fillColor: AppColors.bgElevated,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                IconButton(
                  onPressed: _sendMessage,
                  icon: const Icon(Icons.send_rounded),
                  color: AppColors.accentPrimary,
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.bgElevated,
                    padding: const EdgeInsets.all(12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(String text, bool isMe, String? otherAvatarUrl) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 14,
              backgroundColor: AppColors.bgElevated,
              backgroundImage: otherAvatarUrl != null ? NetworkImage(otherAvatarUrl) : null,
              child: otherAvatarUrl == null ? const Icon(Icons.person, size: 14, color: AppColors.textSecondary) : null,
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isMe ? AppColors.accentPrimary : AppColors.bgElevated,
                borderRadius: BorderRadius.circular(18).copyWith(
                  bottomRight: isMe ? Radius.zero : const Radius.circular(18),
                  bottomLeft: !isMe ? Radius.zero : const Radius.circular(18),
                ),
              ),
              child: Text(
                text,
                style: TextStyle(
                  color: isMe ? AppColors.textInverse : AppColors.textPrimary,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
