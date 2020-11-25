import 'package:flutter/material.dart';

class BuildTextField extends StatelessWidget {
  final String label;
  final TextInputType textType;
  final TextEditingController controller;
  final Function validatorFun;

  BuildTextField({
    @required this.label,
    @required this.textType,
    @required this.controller,
    @required this.validatorFun,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        keyboardType: textType,
        cursorColor: Colors.greenAccent.shade700,
        decoration: InputDecoration(
          labelText: label,
        ),
        textInputAction: TextInputAction.next,
        validator: validatorFun,
      ),
    );
  }
}
