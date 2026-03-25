import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../services/auth_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> with SingleTickerProviderStateMixin {
  List notifications = [];
  bool loading = true;
  late TabController _tabController;

  final Color darkBg = const Color(0xFF0F172A);
  final Color cardBg = const Color(0xFF1E293B);
  final Color accentCyan = const Color(0xFF22D3EE);
  final Color primaryPurple = const Color(0xFF8B5CF6);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    try {
      final data = await AuthService.getNotifications();
      if (!mounted) return;
      setState(() {
        notifications = data;
        loading = false;
      });
    } catch (e) {
      debugPrint("ERROR = $e");
    }
  }

  Future<void> markRead(String id) async {
    await AuthService.markNotificationRead(id);
    loadNotifications();
  }

  String formatTime(String? isoTime) {
    if (isoTime == null) return "";
    final dateTime = DateTime.parse(isoTime).toLocal();
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inSeconds < 60) return "Just now";
    if (diff.inMinutes < 60) return "${diff.inMinutes}m ago";
    if (diff.inHours < 24) return "${diff.inHours}h ago";
    return "${dateTime.day}/${dateTime.month}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          "Notifications",
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: accentCyan,
          indicatorWeight: 3,
          labelColor: accentCyan,
          unselectedLabelColor: Colors.white38,
          tabs: const [
            Tab(text: "All"),
            Tab(text: "Unread"),
          ],
        ),
      ),
      body: loading
          ? Center(child: CircularProgressIndicator(color: accentCyan))
          : TabBarView(
        controller: _tabController,
        children: [
          _buildList(notifications),
          _buildList(notifications.where((n) => n["read"] == false).toList()),
        ],
      ),
    );
  }

  Widget _buildList(List items) {
    if (items.isEmpty) return _buildEmptyState();

    return RefreshIndicator(
      onRefresh: loadNotifications,
      color: accentCyan,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 16),
        physics: const BouncingScrollPhysics(),
        itemCount: items.length,
        itemBuilder: (context, index) => _notificationItem(items[index]),
      ),
    );
  }

  Widget _notificationItem(Map n) {
    final bool isRead = n["read"] == true;

    return Dismissible(
      key: Key(n["id"].toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.redAccent.withOpacity(0.1),
        child: const Icon(Icons.delete_outline, color: Colors.redAccent),
      ),
      onDismissed: (direction) {
        // Handle deletion logic here
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isRead ? cardBg.withOpacity(0.4) : cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isRead ? Colors.white.withOpacity(0.05) : accentCyan.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: isRead
              ? []
              : [BoxShadow(color: accentCyan.withOpacity(0.05), blurRadius: 10, spreadRadius: 2)],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: isRead ? null : () => markRead(n["id"]),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildIconBadge(n, isRead),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              n["title"] ?? "Alert",
                              style: TextStyle(
                                color: isRead ? Colors.white70 : Colors.white,
                                fontWeight: isRead ? FontWeight.w500 : FontWeight.w900,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          Text(
                            formatTime(n["createdAt"]),
                            style: const TextStyle(color: Colors.white24, fontSize: 11),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        n["body"] ?? "",
                        style: TextStyle(
                          color: isRead ? Colors.white38 : Colors.white70,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconBadge(Map n, bool isRead) {
    // Logic to change icon based on title/content
    IconData icon = Icons.notifications_none_rounded;
    Color color = accentCyan;

    if (n["title"].toString().toLowerCase().contains("match")) {
      icon = Icons.sports_cricket_rounded;
      color = Colors.orangeAccent;
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: isRead ? color.withOpacity(0.4) : color, size: 20),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined, size: 80, color: Colors.white.withOpacity(0.05)),
          const SizedBox(height: 16),
          Text(
            "All caught up!",
            style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "We'll notify you when something\nexciting happens.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withOpacity(0.15), fontSize: 13),
          ),
        ],
      ),
    );
  }
}