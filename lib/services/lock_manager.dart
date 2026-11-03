import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/lock.dart';
import 'protection_service.dart';

class LockManager {
  List<Lock> _locks = [];
  String? lastProtectionError;

  List<Lock> get locks => List.unmodifiable(_locks);

  List<Lock> get activeLocks {
    return _locks.where((lock) => !lock.isExpired).toList();
  }

  Lock? getLockById(String id) {
    try {
      return _locks.firstWhere(
        (lock) => lock.id == id,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> startLock({
    required String serviceName,
    required String password,
    required int days,
  }) async {
    final now = DateTime.now();

    final lock = Lock(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      serviceName: serviceName,
      password: password,
      startedAt: now,
      expiresAt: now.add(
        Duration(days: days),
      ),
    );

    _locks.add(lock);

    await _saveLocks();
    // Keep native Android enforcement aligned with the persisted commitment.
    lastProtectionError = null;
    try {
      await protectionService.start(_latestExpiry);
    } catch (error) {
      // Keep the timer/commitment usable, but surface that enforcement did not start.
      lastProtectionError = error.toString();
    }
  }

  Future<void> loadLocks() async {
    final prefs = await SharedPreferences.getInstance();

    final savedLocks = prefs.getString('locks');

    if (savedLocks == null) {
      await protectionService.stop();
      return;
    }

    try {
      final List<dynamic> decoded = jsonDecode(savedLocks);

      _locks = decoded
          .map(
            (item) => Lock.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();
      if (activeLocks.isNotEmpty) {
        await protectionService.start(_latestExpiry);
      } else {
        await protectionService.stop();
      }
    } catch (e) {
      _locks = [];
    }
  }

  Future<void> removeLock(String id) async {
    _locks.removeWhere(
      (lock) => lock.id == id,
    );

    await _saveLocks();
    if (activeLocks.isEmpty) {
      await protectionService.stop();
    } else {
      await protectionService.start(_latestExpiry);
    }
  }

  DateTime get _latestExpiry => activeLocks
      .map((lock) => lock.expiresAt)
      .reduce((a, b) => a.isAfter(b) ? a : b);

  Future<void> _saveLocks() async {
    final prefs = await SharedPreferences.getInstance();

    final encoded = jsonEncode(
      _locks.map((lock) => lock.toJson()).toList(),
    );

    await prefs.setString(
      'locks',
      encoded,
    );
  }
}

final lockManager = LockManager();