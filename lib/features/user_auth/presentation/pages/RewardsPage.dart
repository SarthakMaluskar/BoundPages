import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'cart_page.dart'; // Ensure this import is correct

class RewardsPage extends StatefulWidget {
  @override
  _RewardsPageState createState() => _RewardsPageState();
}

class _RewardsPageState extends State<RewardsPage> {
  late String userId;
  int _currentReadingTime = 0; // Holds the current reading time in seconds
  List<Map<String, dynamic>> _notifications = []; // Stores notifications with discount data

  @override
  void initState() {
    super.initState();
    _initializeUserId();
  }

  // Fetch the authenticated user's ID and initialize real-time updates
  Future<void> _initializeUserId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userId = user.uid; // Assign the user's UID
      });
      _fetchLiveCurrentReadingTime();
    } else {
      print('User not logged in');
    }
  }

  // Fetch the current reading time in real-time and trigger notifications
  void _fetchLiveCurrentReadingTime() {
    FirebaseFirestore.instance
        .collection('reading_sessions')
        .doc(userId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data()!;
        final liveCurrentTime = data['current_time'] ?? 0;

        setState(() {
          _currentReadingTime = liveCurrentTime;
        });

        _triggerCouponNotifications(liveCurrentTime);
      }
    });
  }

  // Trigger notifications for discount coupons based on milestones
  void _triggerCouponNotifications(int readingTime) {
    const milestones = [60, 1800, 3600]; // Milestones in seconds (10 mins, 30 mins, 1 hour)
    const couponData = {
      60: {"message": "You've earned a 10% discount!", "discount": 10},
      1800: {"message": "Congrats! You've unlocked a 20% discount!", "discount": 20},
      3600: {"message": "Amazing! Enjoy a 30% discount!", "discount": 30},
    };

    for (var milestone in milestones) {
      if (readingTime >= milestone &&
          !_notifications.any((notif) => notif['discount'] == couponData[milestone]!['discount'])) {
        setState(() {
          _notifications.add(couponData[milestone]!);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rewards',style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Text(
              'Notifications:',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _notifications.length,
                itemBuilder: (context, index) {
                  final notification = _notifications[index];
                  return GestureDetector(
                    onTap: () {
                      // Navigate to CartPage with discount details
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CartPage(discount: notification['discount']),
                        ),
                      );
                    },
                    child: Card(
                      color: Colors.grey[800],
                      margin: EdgeInsets.symmetric(vertical: 5),
                      child: ListTile(
                        title: Text(
                          notification['message'],
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Convert seconds to a readable format
  String _formatReadingTime(int seconds) {
    final minutes = (seconds / 60).floor();
    final hours = (minutes / 60).floor();
    return hours > 0
        ? '${hours}h ${minutes % 60}m'
        : '${minutes}m ${seconds % 60}s';
  }
}