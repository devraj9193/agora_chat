import 'dart:async';
import 'dart:collection';

import 'package:agora_chat_sdk/agora_chat_sdk.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../chat_screens/chat_screen.dart';
import '../models/agora_keys.dart';
import '../utils/widgets.dart';

class AgoraChatService extends ChangeNotifier {
  bool hasMore = false;
  static const int PAGE_SIZE = 20;

  List<ChatMessage> list = [];

  final Set<ChatMessage> _wrappedMessageSet = HashSet<ChatMessage>();

  final StreamController _stream = StreamController.broadcast();
  StreamController get stream => _stream;

  StreamController typingStream = StreamController.broadcast();

  Future<bool> signIn(String agoraUserId, String agoraUserToken) async {
    bool isLogin;
    print("LOGIN: $agoraUserId");
    print("LOGINToken: $agoraUserToken");
    try {
      await ChatClient.getInstance.loginWithAgoraToken(
        agoraUserId,
        agoraUserToken,
      );
      isLogin = true;
      print("login success..");
      print("LOGIN: ${AgoraChatConfig.agoraUserId}");
      Get.to(() => ChatScreen(userName: agoraUserId));
      buildSnackBar("login succeed", "userId: ${AgoraChatConfig.agoraUserId}");
    } on ChatError catch (e) {
      isLogin = false;
      print("login Failed..");
      print("code: ${e.code}, desc: ${e.description}");
      buildSnackBar("login failed", "code: ${e.code}, desc: ${e.description}");
    }
    return isLogin;
  }

  Future signOut() async {
    try {
      await ChatClient.getInstance.logout(true);
      buildSnackBar(
          "sign out succeed", "userId: ${AgoraChatConfig.agoraUserId}");
    } on ChatError catch (e) {
      buildSnackBar(
          "sign out failed,", "code: ${e.code}, desc: ${e.description}");
    }
  }

  sendMessage(String senderId, String messageContent) async {
    if (senderId == null || messageContent == null) {
      buildSnackBar("single chat id or message content is null", "");
      return;
    }

    var msg = ChatMessage.createTxtSendMessage(
      targetId: senderId,
      content: messageContent!,
    );
    print("SEND MESSAGE: $msg");
    msg.setMessageStatusCallBack(MessageStatusCallBack(
      onSuccess: () {
        buildSnackBar("send message", messageContent);
      },
      onError: (e) {
        buildSnackBar(
            "send message failed", "code: ${e.code}, desc: ${e.description}");
      },
    ));
    ChatClient.getInstance.chatManager.sendMessage(msg);
  }

  sendFileMessage(String senderId, String filePath) async {
    if (senderId == null || filePath == null) {
      buildSnackBar("single chat id or message content is null", "");
      return;
    }

    var msg = ChatMessage.createFileSendMessage(
      targetId: senderId,
      filePath: filePath,
    );
    print("SEND MESSAGE: $msg");
    msg.setMessageStatusCallBack(MessageStatusCallBack(
      onSuccess: () {
        buildSnackBar("send message", filePath);
      },
      onError: (e) {
        buildSnackBar(
            "send message failed", "code: ${e.code}, desc: ${e.description}");
      },
    ));
    ChatClient.getInstance.chatManager.sendMessage(msg);
  }

  Future<void> loadingMessage(String messageId) async {
    ChatConversation? conversation =
        await ChatClient.getInstance.chatManager.getConversation(messageId);
    List<ChatMessage>? res = await conversation?.loadMessages();
    res?.forEach((element) {
      print(element.body.toJson());
    });

    //List<ChatMessage> messages = conversation.loadMoreMsgFromDB(startMsgId, pagesize);

    // List<ChatConversation> res = await ChatClient.getInstance.chatManager
    //     .getConversationsFromServer();

    // res.forEach((element) async {
    //   final msgList = await element.loadMessages();
    //   msgList.forEach((msgs) {
    //     print(msgs);
    //   });
    // });

    if (res != null || AgoraChatConfig.agoraUserId != null) {
     // List<ChatMessage> wrappedMessages = await _wrapMessages(res!);
     //
     //  _wrappedMessageSet.addAll(wrappedMessages);
     //  hasMore = res.length == PAGE_SIZE;
     //  print("hasmore: $hasMore");

      list.clear();
      list = _wrappedMessageSet.toList();
      list.sort((first, second) {
        DateTime dt = DateTime.fromMillisecondsSinceEpoch(first.localTime);
        DateTime dt1 = DateTime.fromMillisecondsSinceEpoch(second.localTime);
        return dt.day.compareTo(dt1.day);
      });

      _stream.sink.add(res);
      print('sink added from loadmessage:$res');
      notifyListeners();
    }
  }


}
