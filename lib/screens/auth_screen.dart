import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:g_taxi/helpers/helper_methods.dart';
import 'package:g_taxi/screens/loading_screen.dart';
import 'package:g_taxi/style/my_colors.dart';
import 'package:g_taxi/style/text_style.dart';
import 'package:g_taxi/widgets/driver_button.dart';
import 'package:g_taxi/widgets/password_confirm_textfield.dart';
import 'package:g_taxi/widgets/password_textfield.dart';
import 'package:g_taxi/widgets/rider_button.dart';
import 'package:g_taxi/widgets/text_field.dart';
import 'package:g_taxi/widgets/sign_button.dart';

class AuthScreen extends StatefulWidget {
  static const String routeName = 'signin_screen';
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final carBrandController = TextEditingController();
  final carModelController = TextEditingController();
  final carNumberController = TextEditingController();
  final carColorController = TextEditingController();
  final passwordConfirmNode = FocusNode();

  String userType = 'rider';
  bool isRider = true;
  bool isDriver = false;
  bool isObscure = true;
  bool isLoading = false;
  bool isSignin = true;

  @override
  void dispose() {
    isLoading = false;
    super.dispose();
  }

  void riderFun() {
    setState(() {
      isRider = true;
      isDriver = false;
      userType = 'rider';
      print(userType);
    });
  }

  void driverFun() {
    setState(() {
      isDriver = true;
      isRider = false;
      userType = 'driver';
      print(userType);
    });
  }

  void isObscureFun() {
    setState(() {
      isObscure = !isObscure;
    });
    print(isObscure);
  }

  String nameValidatorFun(String value) {
    if (value.trim().isEmpty) {
      return 'Please enter your name';
    } else if (value.length < 3) {
      return 'Name is at lest 3 Char!';
    }
    return null;
  }

  String phoneValidatorFun(String value) {
    if (value.trim().isEmpty) {
      return 'Please enter your phone number';
    } else if (value.length < 8) {
      return 'Please enter a valid phone number!';
    }
    return null;
  }

  String emialValidatorFun(String value) {
    if (value.trim().isEmpty) {
      return 'Please enter your email';
    } else if (!value.contains('@')) {
      return 'Please enter a valid email!';
    }
    return null;
  }

  String passwordValidatorFun(String value) {
    if (value.trim().isEmpty) {
      return 'Please enter your password';
    } else if (value.length < 6) {
      return 'Password is at lest 6 Char!';
    }
    return null;
  }

  String passwordConfirmValidatorFun(String value) {
    if (value.trim().isEmpty) {
      return 'Please confirm your password';
    } else if (passwordController.text != value) {
      return 'Password not match!';
    }
    return null;
  }

  String carBrandValidatorFun(String value) {
    if (value.trim().isEmpty) {
      return 'Please enter your car brand';
    } else if (value.length < 3) {
      return 'Car brand is at lest 3 Char!';
    }
    return null;
  }

  String carModelValidatorFun(String value) {
    if (value.trim().isEmpty) {
      return 'Please enter your car model';
    } else if (value.length < 2) {
      return 'Car model is at lest 2 Char!';
    }
    return null;
  }

  String carNumberValidatorFun(String value) {
    if (value.trim().isEmpty) {
      return 'Please enter your car number';
    } else if (value.length < 4) {
      return 'Car number is at lest 4 Char!';
    }
    return null;
  }

  String carColorValidatorFun(String value) {
    if (value.trim().isEmpty) {
      return 'Please enter your car color';
    } else if (value.length < 3) {
      return 'Please enter valid color!';
    }
    return null;
  }

  Future<void> authFun() async {
    isLoading = true;
    setState(() {});
    try {
      FocusScope.of(context).unfocus();
      final _auth = FirebaseAuth.instance;
      if (isSignin) {
        await _auth.signInWithEmailAndPassword(
            email: emailController.text, password: passwordController.text);
        Navigator.of(context).pushReplacementNamed(LoadingScreen.routeName);
      } else {
        await _auth.createUserWithEmailAndPassword(
            email: emailController.text, password: passwordController.text);
        final user = _auth.currentUser;
        final userRef = FirebaseDatabase.instance.reference().child('users').child(user.uid);
        if (isRider) {
          await userRef.set({
            'id': user.uid,
            'name': nameController.text,
            'phoneNumber': phoneController.text,
            'email': emailController.text,
            'userType': userType,
          });
        } else {
          await userRef.set({
            'id': user.uid,
            'name': nameController.text,
            'phoneNumber': phoneController.text,
            'email': emailController.text,
            'userType': userType,
            'carBrand': carBrandController.text,
            'carModel': carModelController.text,
            'carNumber': carNumberController.text,
            'carColor': carColorController.text,
          });
        }
        Navigator.of(context).pushReplacementNamed(LoadingScreen.routeName);
      }
    } catch (error) {
      isLoading = false;
      setState(() {});
      FunctionsHelper.showMessageAlert(context, error.message);
    }
  }

  void submitFun() async {
    final isValid = _formKey.currentState.validate();
    if (isValid) {
      _formKey.currentState.save();
      await authFun();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 25),
          child: Form(
            key: _formKey,
            child: isSignin ? signinListView() : signupListView(),
          ),
        ),
      ),
    );
  }

  ListView signinListView() {
    return ListView(
      children: [
        SizedBox(height: 70),
        Image.asset('assets/images/logo.png', height: 110, width: 110),
        SizedBox(height: 20),
        Center(child: Text('Sign in', style: MyTextStyle.signStyle)),
        SizedBox(height: 20),
        BuildTextField(
          label: 'Email address',
          textType: TextInputType.emailAddress,
          controller: emailController,
          validatorFun: emialValidatorFun,
        ),
        PasswordTextField(
          controller: passwordController,
          isObscure: isObscure,
          node: passwordConfirmNode,
          isObscureFun: isObscureFun,
          validatorFun: passwordValidatorFun,
        ),
        SizedBox(height: 50),
        isLoading
            ? Align(child: Container(height: 50, width: 50, child: CircularProgressIndicator()))
            : SignButton(title: 'Sign in', function: submitFun),
        SizedBox(height: 30),
        if (!isLoading)
          FlatButton(
            child: Text('Don\'t have an account, singn up here'),
            onPressed: () {
              isSignin = false;
              setState(() {});
            },
          ),
      ],
    );
  }

  ListView signupListView() {
    return ListView(
      children: [
        SizedBox(height: 70),
        Image.asset('assets/images/logo.png', height: 110, width: 110),
        SizedBox(height: 20),
        Center(child: Text('Sign up', style: MyTextStyle.signStyle)),
        SizedBox(height: 20),
        Container(
          height: 50,
          decoration: BoxDecoration(
            border: Border.all(color: MyColors.green, width: 2),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              RiderButton(color: isRider ? MyColors.green : Colors.white, function: riderFun),
              DriverButton(color: isRider ? Colors.white : MyColors.green, function: driverFun),
            ],
          ),
        ),
        BuildTextField(
          label: 'name',
          textType: TextInputType.text,
          controller: nameController,
          validatorFun: nameValidatorFun,
        ),
        BuildTextField(
          label: 'Phone Number',
          textType: TextInputType.number,
          controller: phoneController,
          validatorFun: nameValidatorFun,
        ),
        BuildTextField(
          label: 'Email address',
          textType: TextInputType.emailAddress,
          controller: emailController,
          validatorFun: nameValidatorFun,
        ),
        PasswordTextField(
          controller: passwordController,
          isObscure: isObscure,
          node: passwordConfirmNode,
          isObscureFun: isObscureFun,
          validatorFun: nameValidatorFun,
        ),
        PasswordConfirmTextField(
          isObscure: isObscure,
          node: passwordConfirmNode,
          validatorFun: passwordConfirmValidatorFun,
        ),
        if (isDriver)
          Column(children: [
            SizedBox(height: 20),
            Center(
                child: Text(
              'Car Information',
              style: TextStyle(fontSize: 20),
            )),
            BuildTextField(
              label: 'Car Brand',
              textType: TextInputType.text,
              controller: carBrandController,
              validatorFun: nameValidatorFun,
            ),
            BuildTextField(
              label: 'Car Model',
              textType: TextInputType.text,
              controller: carModelController,
              validatorFun: nameValidatorFun,
            ),
            BuildTextField(
              label: 'Car Number',
              textType: TextInputType.text,
              controller: carNumberController,
              validatorFun: nameValidatorFun,
            ),
            BuildTextField(
              label: 'Car Color',
              textType: TextInputType.text,
              controller: carColorController,
              validatorFun: nameValidatorFun,
            ),
          ]),
        SizedBox(height: 50),
        isLoading
            ? Align(child: Container(height: 50, width: 50, child: CircularProgressIndicator()))
            : SignButton(title: 'Sign up', function: submitFun),
        SizedBox(height: 30),
        if (!isLoading)
          FlatButton(
            child: Text('Already have account? Log in'),
            onPressed: () {
              isSignin = true;
              setState(() {});
            },
          ),
      ],
    );
  }
}
