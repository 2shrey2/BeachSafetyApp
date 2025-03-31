import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../constants/app_theme.dart';
import '../../models/notification_model.dart';
import '../../providers/user_provider.dart';
import '../../widgets/loading_indicator.dart';
import '../../routes/app_routes.dart';
import '../../screens/beach/beach_details_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    await Provider.of<UserProvider>(context, listen: false).getUserNotifications();
  }

  Future<void> _refreshNotifications() async {
    await Provider.of<UserProvider>(context, listen: false).getUserNotifications();
  }

  Future<void> _markAsRead(String notificationId) async {
    await Provider.of<UserProvider>(context, listen: false)
        .markNotificationAsRead(notificationId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          if (userProvider.isLoading) {
            return const Center(
              child: LoadingIndicator(),
            );
          }

          if (userProvider.notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No notifications yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You will receive notifications about beach conditions and alerts here',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refreshNotifications,
            color: AppTheme.primaryColor,
            child: ListView.builder(
              itemCount: userProvider.notifications.length,
              itemBuilder: (context, index) {
                final notification = userProvider.notifications[index];
                return _buildNotificationItem(notification);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotificationItem(UserNotification notification) {
    final formatter = DateFormat('MMM d, h:mm a');
    final formattedDate = formatter.format(notification.timestamp);
    
    // Determine notification icon based on type
    IconData notificationIcon;
    Color iconColor;
    
    switch (notification.type) {
      case NotificationType.beachAlert:
        notificationIcon = Icons.warning_rounded;
        iconColor = Colors.orange;
        break;
      case NotificationType.weatherUpdate:
        notificationIcon = Icons.wb_sunny;
        iconColor = Colors.blue;
        break;
      case NotificationType.systemMessage:
        notificationIcon = Icons.info_outline;
        iconColor = Colors.green;
        break;
      default:
        notificationIcon = Icons.notifications;
        iconColor = Colors.grey;
    }

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      onDismissed: (direction) {
        // Implement delete functionality when backend is available
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notification dismissed')),
        );
      },
      child: InkWell(
        onTap: () {
          if (!notification.isRead) {
            _markAsRead(notification.id);
          }
          
          // Navigate or show details based on notification type
          if (notification.type == NotificationType.beachAlert && 
              notification.data != null &&
              notification.data!.containsKey('beachId')) {
            AppRoutes.navigateToBeachDetails(
              context,
              notification.data!['beachId'],
            );
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: notification.isRead ? null : AppTheme.primaryColor.withOpacity(0.1),
            border: Border(
              bottom: BorderSide(
                color: Colors.grey.withOpacity(0.2),
                width: 1,
              ),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  notificationIcon,
                  color: iconColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          formattedDate,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (!notification.isRead)
                      Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          margin: const EdgeInsets.only(top: 8),
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 