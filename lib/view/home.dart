import 'package:flutter/material.dart';
import 'package:palette_chat/viewmodel/main_view_model.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: _buildForm(),
        ));
  }

  Widget _buildColorField() {
    var color = Provider.of<MainViewModel>(context).userColor;
    final model = Provider.of<MainViewModel>(context);
    return Row(children: [
      Container(
        height: 50,
        width: 50,
        decoration: BoxDecoration(
          borderRadius:
              BorderRadius.circular(10), // Adjust the radius as needed
          border: Border.all(
            color: Theme.of(context).hintColor, // Border color
            width: 2, // Border width
          ),
          color: color,
        ),
      ),
      const SizedBox(
        width: 10,
      ),
      Expanded(
        child: TextFormField(
            initialValue: model.userHex,
            onChanged: (value) => model.setUserHex(value),
            validator: (value) => model.validateUserColor(value),
            decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "#ffffff",
                labelText: "HEX color")),
      )
    ]);
  }

  Widget _buildNameField() {
    return TextFormField(
        onChanged: (value) =>
            context.read<MainViewModel>().setUserFullname(value),
        validator: (value) =>
            context.read<MainViewModel>().validateFullname(value),
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          hintText: "Enter your name",
        ));
  }

  Widget _buildJoinButton() {
    return TextButton(
        child: const Text("Join Chat Room"),
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            context.read<MainViewModel>().openChat(context);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('There were validation issues'),
                showCloseIcon: true,
              ),
            );
          }
        });
  }

  Widget _buildForm() {
    return SafeArea(
        child: Form(
            key: _formKey,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Spacer(),
              _buildColorField(),
              const SizedBox(
                height: 10,
              ),
              _buildNameField(),
              const Spacer(),
              Row(children: [
                const Spacer(),
                _buildJoinButton(),
                const Spacer()
              ])
            ])));
  }
}
