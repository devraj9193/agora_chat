import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';

import 'chat_models.dart';

class AgoraChatConfig {
  static const String appKey = "61886615#1062415";
  static const String agoraUserId = "Naga93";
  static const String agoraUserToken = "007eJxTYFh1THLBy3/m62cmZd+4y98ZzvqC/9+89p9GO9PXLlsn4ntHgSHZPNnSIinNPNEo2djEONnc0jw1zTw1KSklKdEgySDNbOWWC8kNgYwMkcI+jIwMrAyMQAjiqzBYJiYnGySbGuhaWlgm6RoapqboWhqaJ+oam6ekmCanpZmlJicCAKz2KvM=";

  static const String getMessage = "getMessage";

  static List<UserProfile>? _users;
  static UserProfile? _currentUser;
  static UserProfile? get currentUser => _currentUser;
  static List<UserProfile>? get users => [..._users!];

  static const indicatorTimeout = 10;

  static init() async {

    const String DIRECTORY = 'assets/setup';
    final String usersJson =
    await rootBundle.loadString('$DIRECTORY/users.json');
    final profiles = await json.decode(usersJson) as List;

    _users = profiles.map((profile) => UserProfile.fromJson(profile)).toList();

    _currentUser = _users![Random().nextInt(_users!.length - 4)];

  }

  static UserProfile getUserById(String uuid) {
    if (uuid == 'current_user') {
      return currentUser!;
    }
    return users!.firstWhere((user) => (user.uuid == uuid));
  }


}