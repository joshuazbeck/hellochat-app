import 'package:flex_color_picker/flex_color_picker.dart';
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
  TextEditingController textEditingController = TextEditingController();

  @override
  void didChangeDependencies() {
    textEditingController.text = Provider.of<MainViewModel>(
      context,
      listen: true,
    ).userHex;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: _buildForm(),
        ));
  }

  //TODO: Add the color picker dialog
  // Future<bool> colorPickerDialog(MainViewModel model) async {
  //   return ColorPicker(
  //     color: model.userColor,
  //     onColorChanged: (Color color) {
  //       model.setUserColor(color);
  //     },
  //     width: 35,
  //     height: 35,
  //     borderRadius: 4,
  //     spacing: 10,
  //     runSpacing: 10,
  //     wheelDiameter: 300,
  //     subheading: Text(
  //       'Select color shade',
  //       style: Theme.of(context).textTheme.titleSmall,
  //     ),
  //     heading: Text(
  //       'Select a color',
  //       style: Theme.of(context).textTheme.titleSmall,
  //     ),
  //     showColorName: true,
  //     showColorCode: true,
  //     copyPasteBehavior: const ColorPickerCopyPasteBehavior(
  //       longPressMenu: true,
  //     ),
  //     pickersEnabled: const {
  //       ColorPickerType.primary: true,
  //       ColorPickerType.accent: false,
  //       ColorPickerType.wheel: true,
  //     },
  //   ).showPickerDialog(context);
  // }

  Widget _buildColorField() {
    var color = Provider.of<MainViewModel>(context).userColor;
    final model = Provider.of<MainViewModel>(context);
    return Row(children: [
      TextButton(
          onPressed: () {
            //TODO: Add the color picker dialog
            // colorPickerDialog(model);
          },
          child: Container(
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
          )),
      const SizedBox(
        width: 10,
      ),
      Expanded(
        child: TextFormField(
            controller: textEditingController,
            onChanged: (value) => model.setUserColorFromHex(value),
            validator: (value) => model.validateUserColor(value),
            decoration: const InputDecoration(
                border: OutlineInputBorder(),
                //TODO: Add the prefix icon
                isDense: true,
                prefixIcon:
                    Padding(padding: EdgeInsets.all(15), child: Text('#')),
                prefixIconConstraints:
                    BoxConstraints(minWidth: 0, minHeight: 0),
                hintText: "FFFFFF",
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
