import 'package:flutter/material.dart';

class PasswordTextField extends StatelessWidget {
  final TextEditingController controller;
  final bool isObscure;
  final FocusNode node;
  final Function isObscureFun;
  final Function validatorFun;
  PasswordTextField({
    @required this.controller,
    @required this.isObscure,
    @required this.node,
    @required this.isObscureFun,
    @required this.validatorFun,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        obscureText: isObscure,
        controller: controller,
        keyboardType: TextInputType.text,
        cursorColor: Colors.greenAccent.shade700,
        decoration: InputDecoration(
          labelText: 'Password',
          suffixIcon: IconButton(
            icon: Icon(isObscure ? Icons.visibility : Icons.visibility_off),
            onPressed: isObscureFun,
          ),
        ),
        textInputAction: TextInputAction.next,
        onFieldSubmitted: (_) {
          FocusScope.of(context).requestFocus(node);
        },
        validator: validatorFun,
      ),
    );
  }
}
