import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartclinic/core/constants/app_color.dart';
import 'package:smartclinic/core/constants/assets.dart';
import 'package:smartclinic/features/nouga/data/local/nouga_conversation_store.dart';
import 'package:smartclinic/features/nouga/presentation/manager/nouga_ai_cubit.dart';
import 'package:smartclinic/features/nouga/presentation/manager/nouga_ai_state.dart';
import 'package:smartclinic/injection_dependency.dart';

class NougaAiChatPage extends StatelessWidget {
  const NougaAiChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<SendMessageCubit>(),
      child: const NougaAiChatScreen(),
    );
  }
}

class NougaAiChatScreen extends StatefulWidget {
  const NougaAiChatScreen({super.key});

  @override
  State<NougaAiChatScreen> createState() => _NougaAiChatScreenState();
}

class _NougaAiChatScreenState extends State<NougaAiChatScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final NougaConversationStore _conversationStore =
      getIt<NougaConversationStore>();

  final Random _random = Random();
  String _activeConversationId = '';
  final List<_ChatMessage> _messages = [];
  List<NougaConversation> _conversations = [];

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    context.read<SendMessageCubit>().reset();
    super.dispose();
  }

  Future<void> _loadConversations() async {
    final loaded = await _conversationStore.loadConversations();
    if (!mounted) {
      return;
    }

    loaded.sort((a, b) => b.updatedAtMillis.compareTo(a.updatedAtMillis));

    if (loaded.isEmpty) {
      _startNewConversation();
      return;
    }

    setState(() {
      _conversations = loaded;
      _activeConversationId = loaded.first.id;
      _messages
        ..clear()
        ..addAll(
          loaded.first.messages
              .map(
                (message) => _ChatMessage(
                  text: message.text,
                  isUser: message.isUser,
                  time: message.time,
                ),
              )
              .toList(),
        );
    });
    _scrollToBottom();
  }

  String _createConversationId() {
    final now = DateTime.now().microsecondsSinceEpoch;
    final suffix = _random.nextInt(900000) + 100000;
    return 'conv_${now}_$suffix';
  }

  Future<void> _persistConversations() async {
    await _conversationStore.saveConversations(_conversations);
  }

  Future<void> _startNewConversation() async {
    final conversationId = _createConversationId();
    final conversation = NougaConversation(
      id: conversationId,
      title: 'New Conversation',
      updatedAtMillis: DateTime.now().millisecondsSinceEpoch,
      messages: const [],
    );

    setState(() {
      _activeConversationId = conversationId;
      _messages.clear();
      _conversations = [conversation, ..._conversations];
    });

    await _persistConversations();
  }

  Future<void> _loadConversation(String conversationId) async {
    final conversation = _conversations
        .where((item) => item.id == conversationId)
        .firstOrNull;
    if (conversation == null) {
      return;
    }

    setState(() {
      _activeConversationId = conversation.id;
      _messages
        ..clear()
        ..addAll(
          conversation.messages
              .map(
                (message) => _ChatMessage(
                  text: message.text,
                  isUser: message.isUser,
                  time: message.time,
                ),
              )
              .toList(),
        );
    });

    Navigator.pop(context);
    _scrollToBottom();
  }

  Future<void> _clearHistory() async {
    setState(() {
      _conversations = [];
      _messages.clear();
      _activeConversationId = '';
    });
    await _persistConversations();
    await _startNewConversation();
  }

  Future<void> _syncActiveConversation({
    String? preferredConversationId,
  }) async {
    final targetId = preferredConversationId?.trim().isNotEmpty == true
        ? preferredConversationId!.trim()
        : _activeConversationId;

    if (targetId.isEmpty) {
      return;
    }

    final records = _messages
        .map(
          (message) => NougaChatRecord(
            text: message.text,
            isUser: message.isUser,
            time: message.time,
          ),
        )
        .toList();

    final firstUserMessage = _messages.firstWhere(
      (message) => message.isUser,
      orElse: () =>
          const _ChatMessage(text: 'New Conversation', isUser: true, time: ''),
    );
    final computedTitle = firstUserMessage.text.trim().isEmpty
        ? 'New Conversation'
        : firstUserMessage.text.trim();
    final preview = computedTitle.length > 30
        ? '${computedTitle.substring(0, 30)}...'
        : computedTitle;

    final updatedConversation = NougaConversation(
      id: targetId,
      title: preview,
      updatedAtMillis: DateTime.now().millisecondsSinceEpoch,
      messages: records,
    );

    final existingIndex = _conversations.indexWhere(
      (conversation) =>
          conversation.id == _activeConversationId ||
          conversation.id == targetId,
    );

    if (existingIndex == -1) {
      _conversations = [updatedConversation, ..._conversations];
    } else {
      final updated = List<NougaConversation>.from(_conversations);
      updated[existingIndex] = updatedConversation;
      updated.sort((a, b) => b.updatedAtMillis.compareTo(a.updatedAtMillis));
      _conversations = updated;
    }

    _activeConversationId = targetId;
    await _persistConversations();
    if (mounted) {
      setState(() {});
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _onSendTapped() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    if (_activeConversationId.isEmpty) {
      _activeConversationId = _createConversationId();
    }

    setState(() {
      _messages.add(
        _ChatMessage(text: text, isUser: true, time: _formattedNow()),
      );
      _messageController.clear();
    });
    _scrollToBottom();
    _syncActiveConversation();

    context.read<SendMessageCubit>().sendMessage(
      patientMessage: text,
      conversationId: _activeConversationId,
    );
  }

  void _onPauseTapped() {
    context.read<SendMessageCubit>().reset();
  }

  String _formattedNow() {
    final now = DateTime.now();
    final h = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final m = now.minute.toString().padLeft(2, '0');
    final period = now.hour < 12 ? 'AM' : 'PM';
    return '$h:$m $period';
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SendMessageCubit, SendMessageState>(
      listener: (context, state) {
        if (state is SendMessageSuccess) {
          final serverConversationId = state.response.conversationId?.trim();
          final replyText =
              state.response.reply ?? state.response.message ?? '...';
          setState(() {
            _messages.add(
              _ChatMessage(
                text: replyText,
                isUser: false,
                time: _formattedNow(),
              ),
            );
          });
          _syncActiveConversation(
            preferredConversationId: serverConversationId,
          );
          _scrollToBottom();
        }

        if (state is SendMessageFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is SendMessageLoading;

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: const Color(0xFFE8F4F8),
          endDrawer: _buildDrawer(context),
          appBar: _buildAppBar(context),
          body: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  itemCount: _messages.length + (isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (isLoading && index == _messages.length) {
                      return _buildTypingBubble();
                    }
                    return _buildMessageBubble(_messages[index]);
                  },
                ),
              ),

              _buildInputBar(context, isLoading: isLoading),
            ],
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFFE8F4F8),
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: AppColors.deepNavy),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Nouga Ai',
        style: TextStyle(
          color: AppColors.deepNavy,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.menu, color: AppColors.deepNavy),
          onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
        ),
      ],
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.skyBlue.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.smart_toy_outlined,
                      color: AppColors.skyBlue,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Chat History',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.deepNavy,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Divider(
                color: AppColors.textSecondary.withValues(alpha: 0.2),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextButton.icon(
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.skyBlue.withValues(alpha: 0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
                icon: Icon(Icons.add, color: AppColors.skyBlue, size: 20),
                label: Text(
                  'New Chat',
                  style: TextStyle(
                    color: AppColors.skyBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onPressed: _startNewConversation,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _conversations.length,
                itemBuilder: (context, index) {
                  final conversation = _conversations[index];
                  final isSelected = conversation.id == _activeConversationId;
                  return ListTile(
                    tileColor: isSelected
                        ? AppColors.skyBlue.withValues(alpha: 0.14)
                        : Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    leading: Icon(
                      Icons.chat_bubble_outline,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    title: Text(
                      conversation.title,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.deepNavy,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () => _loadConversation(conversation.id),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextButton.icon(
                icon: Icon(
                  Icons.delete_outline,
                  color: Colors.redAccent,
                  size: 18,
                ),
                label: const Text(
                  'Clear History',
                  style: TextStyle(color: Colors.redAccent),
                ),
                onPressed: _clearHistory,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(_ChatMessage message) {
    final isUser = message.isUser;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isUser) ...[_AiAvatar(), const SizedBox(width: 8)],
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: isUser
                        ? Colors.white
                        : AppColors.skyBlue.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: isUser
                          ? const Radius.circular(18)
                          : const Radius.circular(4),
                      bottomRight: isUser
                          ? const Radius.circular(4)
                          : const Radius.circular(18),
                    ),
                    border: isUser
                        ? Border.all(
                            color: AppColors.skyBlue.withValues(alpha: 0.3),
                            width: 1,
                          )
                        : null,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.deepNavy,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (message.time.isNotEmpty) ...[
            const SizedBox(height: 6),
            Padding(
              padding: EdgeInsets.only(left: isUser ? 0 : 44),
              child: Row(
                children: [
                  Text(
                    message.time,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (isUser) ...[const SizedBox(width: 8), _EditBadge()],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingBubble() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _AiAvatar(),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
                decoration: BoxDecoration(
                  color: AppColors.skyBlue.withValues(alpha: 0.55),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(18),
                    topRight: Radius.circular(18),
                    bottomLeft: Radius.circular(4),
                    bottomRight: Radius.circular(18),
                  ),
                ),
                child: _TypingIndicator(),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 44),
            child: _PauseGeneratingButton(onTap: _onPauseTapped),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar(BuildContext context, {required bool isLoading}) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      color: const Color(0xFFE8F4F8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.deepNavy.withValues(alpha: 0.15),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextFormField(
                controller: _messageController,
                enabled: !isLoading,
                style: TextStyle(color: AppColors.textPrimary, fontSize: 15),
                decoration: InputDecoration(
                  hintText: isLoading
                      ? 'Waiting for response...'
                      : 'Message Chat Bot',
                  hintStyle: TextStyle(
                    color: AppColors.textSecondary.withValues(alpha: 0.5),
                    fontSize: 15,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                ),
                onFieldSubmitted: isLoading ? null : (_) => _onSendTapped(),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: isLoading ? null : _onSendTapped,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isLoading
                    ? AppColors.skyBlue.withValues(alpha: 0.4)
                    : AppColors.skyBlue,
                borderRadius: BorderRadius.circular(14),
                boxShadow: isLoading
                    ? []
                    : [
                        BoxShadow(
                          color: AppColors.skyBlue.withValues(alpha: 0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
              ),
              child: isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(13),
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(
                      Icons.arrow_upward_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;
  final String time;

  const _ChatMessage({
    required this.text,
    required this.isUser,
    required this.time,
  });
}

class _AiAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: const BoxDecoration(
        color: Color(0xFF1E293B),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Image.asset(
          AppImages.imagesIconsAssistant,
          width: 30,
          height: 30,
        ),
      ),
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      3,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      ),
    );
    _animations = _controllers
        .map(
          (c) => Tween<double>(
            begin: 0,
            end: 1,
          ).animate(CurvedAnimation(parent: c, curve: Curves.easeInOut)),
        )
        .toList();
    for (var i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 160), () {
        if (mounted) _controllers[i].repeat(reverse: true);
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return AnimatedBuilder(
          animation: _animations[i],
          builder: (_, __) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.deepNavy.withValues(
                alpha: 0.3 + _animations[i].value * 0.7,
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _EditBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.skyBlue.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'Edit',
        style: TextStyle(
          fontSize: 12,
          color: AppColors.skyBlue,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _PauseGeneratingButton extends StatelessWidget {
  final VoidCallback onTap;
  const _PauseGeneratingButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: AppColors.skyBlue,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(Icons.pause, color: Colors.white, size: 12),
            ),
            const SizedBox(width: 6),
            Text(
              'Pause generating',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.deepNavy,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
