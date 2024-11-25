import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class ReadingTimerManager {
  final String userId; // User ID to track specific sessions
  Timer? _timer;

  ReadingTimerManager({required this.userId});

  // Fetch the raw current_time value from Firestore
  Future<int> getCurrentTime() async {
    final readingSessionRef = FirebaseFirestore.instance.collection('reading_sessions').doc(userId);
    final docSnapshot = await readingSessionRef.get();

    if (docSnapshot.exists) {
      final data = docSnapshot.data()!;
      return data['current_time'] ?? 0; // Return the current_time value
    }

    return 0; // Default to 0 if the document does not exist
  }

  // Start tracking reading time (initialize or resume)
  Future<void> startTracking() async {
    final readingSessionRef = FirebaseFirestore.instance.collection('reading_sessions').doc(userId);

    // Check if the document exists
    final docSnapshot = await readingSessionRef.get();
    if (!docSnapshot.exists) {
      // Initialize a new reading session if it doesn't exist
      await readingSessionRef.set({
        'current_time': 0, // Total reading time in seconds
        'start_time': Timestamp.now(), // Initial start time
        'last_updated': Timestamp.now(), // Last update timestamp
      });
    } else {
      // Ensure the last_updated timestamp is current
      await readingSessionRef.update({
        'last_updated': Timestamp.now(),
      });
    }

    // Start the periodic timer to update the reading time
    _startPeriodicUpdates();
  }

  // Stop tracking reading time
  Future<void> stopTracking() async {
    final readingSessionRef = FirebaseFirestore.instance.collection('reading_sessions').doc(userId);

    // Cancel the periodic timer
    _timer?.cancel();

    // Update the final timestamp in Firestore
    final docSnapshot = await readingSessionRef.get();
    if (docSnapshot.exists) {
      final data = docSnapshot.data()!;
      final lastUpdated = (data['last_updated'] as Timestamp).toDate();
      final currentTime = data['current_time'] ?? 0;

      // Calculate additional seconds since the last update
      final elapsedSeconds = DateTime.now().difference(lastUpdated).inSeconds;

      // Update the total reading time and last_updated timestamp
      await readingSessionRef.update({
        'current_time': currentTime + elapsedSeconds,
        'last_updated': Timestamp.now(),
      });
    }
  }

  // Fetch the total reading time from Firestore
  Future<Duration> getTotalReadingTime() async {
    final readingSessionRef = FirebaseFirestore.instance.collection('reading_sessions').doc(userId);

    // Fetch the document that contains the reading session data
    final docSnapshot = await readingSessionRef.get();
    if (docSnapshot.exists) {
      final data = docSnapshot.data()!;
      final currentTime = data['current_time'] ?? 0;
      final lastUpdated = (data['last_updated'] as Timestamp).toDate();

      // Calculate the elapsed time since the last update
      final elapsedSeconds = DateTime.now().difference(lastUpdated).inSeconds;

      // Add elapsed time to the current total
      return Duration(seconds: currentTime + elapsedSeconds);
    } else {
      return Duration.zero; // Default to zero if no document is found
    }
  }

  // Periodically update reading time in Firestore
  void _startPeriodicUpdates() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) async {
      final readingSessionRef = FirebaseFirestore.instance.collection('reading_sessions').doc(userId);

      // Fetch the current session data
      final docSnapshot = await readingSessionRef.get();
      if (docSnapshot.exists) {
        final data = docSnapshot.data()!;
        final currentTime = data['current_time'] ?? 0;
        final lastUpdated = (data['last_updated'] as Timestamp).toDate();

        // Calculate elapsed seconds
        final elapsedSeconds = DateTime.now().difference(lastUpdated).inSeconds;

        // Update Firestore with the new total time
        await readingSessionRef.update({
          'current_time': currentTime + elapsedSeconds,
          'last_updated': Timestamp.now(),
        });
      }
    });
  }

  // Check if the user qualifies for a reward
  Future<bool> checkForReward() async {
    final totalTime = await getTotalReadingTime();
    if (totalTime.inMinutes >= 30) {
      // Example condition: Reward if the user has read for 30 minutes
      return true;
    }
    return false;
  }

  // Cleanup: Cancel the timer if the manager is disposed
  void dispose() {
    _timer?.cancel();
  }
}