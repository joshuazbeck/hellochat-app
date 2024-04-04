import 'package:flutter/material.dart';
import 'package:palette_chat/model/message.dart';
import 'package:palette_chat/viewmodel/chat_view_model.dart';
import 'package:palette_chat/extension/color.dart';
import 'package:provider/provider.dart';

class ChatPage extends StatefulWidget {
  final String colorHex;
  final String fullname;

  const ChatPage({super.key, required this.colorHex, required this.fullname});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _messageInputController = TextEditingController();
  int? _sessionId;

  @override
  Widget build(BuildContext context) {
    context
        .read<ChatViewModel>()
        .initializeSocketMessages(
          widget.fullname,
          widget.colorHex,
        )
        .then((results) {
      _sessionId = results;
    }).onError((error, stackTrace) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          showCloseIcon: true,
        ),
      );
    });

    return Scaffold(
        appBar: AppBar(
          title: const Text("Hello Chat"),
        ),
        body: SafeArea(
            child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(children: [_buildFeed(), _buildSendBar()]))));
  }

  Widget _messageAvatar(Color color) {
    return Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.grey,
            width: 1.0,
          ),
        ),
        child: CircleAvatar(
          backgroundColor: color,
        ));
  }

  Widget _messageBody(String text, bool currentUser, Color color) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(10),
          topRight: const Radius.circular(10),
          bottomRight: Radius.circular(currentUser ? 0 : 10),
          bottomLeft: Radius.circular(currentUser ? 10 : 0),
        ),
        border: Border.all(
          color: Colors.grey, // Border color
          width: 1.0, // Border width
        ),
        color: currentUser ? color : Colors.grey,
      ),
      child: Padding(
          padding: const EdgeInsets.all(10),
          child: Text(
            text,
          )),
    );
  }

  Widget _buildMessage({required Message message}) {
    if (message.session == null) return const SizedBox();
    final isCurrentUser = (message.sessionId == _sessionId);
    final color = HexColor.fromHex(message.session!.colorHex);

    return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: isCurrentUser
            ? Row(children: [
                const Spacer(), // Align left
                _messageBody(message.text, isCurrentUser, color)
              ])
            : Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                _messageAvatar(color), // Avatar
                const SizedBox(width: 10), // Spacer
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(message.session!.name), // Session owner name
                  _messageBody(
                      message.text, isCurrentUser, color) // Body of message
                ]),
                const Spacer(), // Align Right
              ]));
  }

  Widget _buildFeed() {
    // A consumer is a widget that rebuilds when the model changes
    return Consumer<ChatViewModel>(
      builder: (context, model, child) {
        return Expanded(
            child: SingleChildScrollView(
          controller: model.scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          child: model.messages.isEmpty
              ? const Text(
                  "Be the first to send a message",
                  style: TextStyle(color: Colors.grey),
                )
              : Column(
                  children: model.messages.map((e) {
                  return _buildMessage(message: e);
                }).toList()),
        ));
      },
    );
  }

  Widget _buildSendBar() {
    return Row(children: [
      Expanded(
          child: TextField(
              controller: _messageInputController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ))),
      IconButton(
          onPressed: () => context
              .read<ChatViewModel>()
              .sendMessage(_messageInputController.text, _sessionId),
          icon: const Icon(Icons.send)),
    ]);
  }
}
