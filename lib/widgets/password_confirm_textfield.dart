import 'package:flutter/material.dart';

class PasswordConfirmTextField extends StatelessWidget {
  final bool isObscure;
  final FocusNode node;
  final Function validatorFun;
  PasswordConfirmTextField({
    @required this.isObscure,
    @required this.node,
    @required this.validatorFun,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        obscureText: isObscure,
        focusNode: node,
        keyboardType: TextInputType.text,
        cursorColor: Colors.greenAccent.shade700,
        decoration: InputDecoration(
          labelText: 'Confirm Password',
        ),
        textInputAction: TextInputAction.next,
        validator: validatorFun,
      ),
    );
  }
}
