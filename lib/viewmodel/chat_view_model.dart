import 'package:flutter/material.dart';
import 'package:palette_chat/model/message.dart';
import 'package:palette_chat/service/messaging_service.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class ChatViewModel with ChangeNotifier {
  List<Message> _messages = [];
  List<Message> get messages => _messages;

  final ScrollController scrollController = ScrollController();

  void sendMessage(String text, int? sessionId) {
    if (sessionId != null) {
      MessagingService.standard.sendMessage(text, sessionId);
    } else {
      print("Issue sending the message for session id: $sessionId");
    }
  }

  void _scrollDown() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(seconds: 1),
        curve: Curves.fastOutSlowIn,
      );
    }
  }

  Future<int?> initializeSocketMessages(String name, String colorHex) async {
    var messages = await MessagingService.standard.listMessages();
    _messages = messages;
    notifyListeners();
    var socketId = await MessagingService.standard
        .listenToSocket(name, colorHex, (socket_value) {
      refreshMessages();
    });
    return socketId;
  }

  void refreshMessages() {
    MessagingService.standard.listMessages().then((messages) {
      _messages = messages;
      notifyListeners();
      Future.delayed(const Duration(milliseconds: 500))
          .then((value) => {_scrollDown()});
    });
  }
}
