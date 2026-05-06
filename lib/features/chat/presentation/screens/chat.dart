import 'package:flutter/material.dart';
import 'package:smartclinic/core/constants/app_color.dart';
import 'package:smartclinic/core/constants/assets.dart';

class InboxChatRoomsScreen extends StatelessWidget {
  const InboxChatRoomsScreen({super.key, this.rooms = const []});

  final List<ChatRoomItem> rooms;

  @override
  Widget build(BuildContext context) {
    if (rooms.isEmpty) {
      return const _InboxEmptyState();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 110),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Messages',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              itemCount: rooms.length,
              separatorBuilder: (_, __) => const SizedBox(height: 25),
              itemBuilder: (context, index) {
                final room = rooms[index];
                return _ChatRoomTile(room: room);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatRoomTile extends StatelessWidget {
  const _ChatRoomTile({required this.room});

  final ChatRoomItem room;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {},
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.accentBlue,
                backgroundImage: AssetImage(room.avatarPath),
              ),
              if (room.isOnline)
                Positioned(
                  bottom: -1,
                  right: -1,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2ECC71),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  room.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 30 / 1.4,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  room.lastMessage,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                room.time,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              if (room.unreadCount > 0)
                Container(
                  width: 22,
                  height: 22,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE53E3E),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    room.unreadCount > 9 ? '9+' : '${room.unreadCount}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
              else
                const SizedBox(width: 22, height: 22),
            ],
          ),
        ],
      ),
    );
  }
}

class _InboxEmptyState extends StatelessWidget {
  const _InboxEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              AppImages.emptyInbox,
              width: MediaQuery.of(context).size.width * 0.58,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 18),
            const Text(
              'No messages yet\nBook an appointment to chat with your doctor',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatRoomItem {
  const ChatRoomItem({
    required this.name,
    required this.lastMessage,
    required this.time,
    required this.avatarPath,
    this.unreadCount = 0,
    this.isOnline = false,
  });

  final String name;
  final String lastMessage;
  final String time;
  final String avatarPath;
  final int unreadCount;
  final bool isOnline;
}

// const List<ChatRoomItem> _dummyRooms = <ChatRoomItem>[
//   ChatRoomItem(
//     name: 'Dr. Ahmed Khatab',
//     lastMessage: 'Hey! What about health?',
//     time: '02 min ago',
//     avatarPath: AppImages.imagesDoctorDRAhmedAlaa,
//     unreadCount: 3,
//     isOnline: true,
//   ),
//   ChatRoomItem(
//     name: 'Dr. Salwa Farouk',
//     lastMessage: 'Are you fine?',
//     time: '40 min ago',
//     avatarPath: AppImages.imagesDoctorDRSaraHassan,
//     unreadCount: 1,
//     isOnline: true,
//   ),
// ];
