import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:palette_chat/extensions/mini_progress_loader.dart';
import 'package:palette_chat/model/message.dart';
import 'package:palette_chat/viewmodel/chat_view_model.dart';
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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    context
        .read<ChatViewModel>()
        .initializeSocketMessages(
          widget.fullname,
          widget.colorHex,
        )
        .then((results) {
      context.read<ChatViewModel>().setSessionId(results);
    }).onError((error, stackTrace) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          showCloseIcon: true,
        ),
      );
    });

    // TODO: Set up PopScope to disconnect from sockets
    return PopScope(
        child: Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              title: const Text("Hello Chat"),
            ),
            body: SafeArea(
                child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Consumer<ChatViewModel>(
                        builder: (context, model, child) => Column(children: [
                              _buildFeed(model),
                              _buildSendBar(model)
                            ]))))),
        onPopInvoked: (pop) => context.read<ChatViewModel>().destroy());
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
              style: TextStyle(
                  //TODO: Add adjustable font color
                  color: currentUser
                      ? color.computeLuminance() > 0.7
                          ? Colors.black
                          : Colors.white
                      : Colors.black),
              text,
            )));
  }

  Widget _buildMessage(Message message, ChatViewModel viewModel) {
    if (message.session == null) return const SizedBox();
    final isCurrentUser = (message.sessionId == viewModel.sessionId);
    final color = message
        .session!.colorHex.toColor; // Defaults to black if unable to convert

    return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: isCurrentUser
            ? Row(children: [
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                      _messageBody(message.text, isCurrentUser, color)
                    ])),
              ])
            : Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                _messageAvatar(color), // Avatar
                const SizedBox(width: 10), // Spacer
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(message.session!.name), // Session owner name
                      _messageBody(message.text, isCurrentUser,
                          color), // Body of message
                    ])),
              ]));
  }

  Widget _buildFeed(ChatViewModel viewModel) {
    // A consumer is a widget that rebuilds when the model changes

    return Expanded(
        child: SingleChildScrollView(
            controller: viewModel.scrollController,
            //TODO: Make the scroll view always scrollable
            physics: const AlwaysScrollableScrollPhysics(),
            child: viewModel.isLoading
                ? const CircularProgressIndicator()
                : _buildMessageList(viewModel)));
  }

  Widget _buildMessageList(ChatViewModel model) {
    return model.messages.isEmpty
        ? const Text(
            "Be the first to send a message",
            style: TextStyle(color: Colors.grey),
          )
        : Column(
            children: model.messages.map((e) {
            return _buildMessage(e, model);
          }).toList());
  }

  Widget _buildSendBar(ChatViewModel viewModel) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(
            child: TextField(
                controller: _messageInputController,
                enabled: viewModel.sessionId != null,
                decoration: InputDecoration( //TODO: Add session ID indicator
                  isDense: true,
                  prefixIcon: Padding(
                      padding: const EdgeInsets.all(15),
                      child: viewModel.sessionId != null
                          ? Text('#${viewModel.sessionId}')
                          : const CircularProgressIndicator().mini()),
                  prefixIconConstraints:
                      const BoxConstraints(minWidth: 0, minHeight: 0),
                  border: const OutlineInputBorder(),
                ))),
        IconButton(
            onPressed: () => viewModel.sendMessage(
                _messageInputController, viewModel.sessionId),
            icon: const Icon(Icons.send)),
      ])
    ]);
  }
}
