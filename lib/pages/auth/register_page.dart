import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/helper/helper_function.dart';
import 'package:flutter_chat_app/pages/auth/login_page.dart';
import 'package:flutter_chat_app/pages/home_page.dart';
import 'package:flutter_chat_app/service/auth_service.dart';

import '../../widgets/widgets.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final formKey = GlobalKey<FormState>();
  String email = "";
  String password = "";
  String fullName = "";
  bool _showPassword = false;
  bool _isLoading = false;
  AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                    color: Theme.of(context).primaryColor))
            : SingleChildScrollView(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'CHITHI',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 40,
                          ),
                        ),
                        Image.asset('assets/register.png'),
                        const Text(
                          'REGISTER ',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 30,
                            color: Color.fromARGB(255, 53, 115, 55),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          decoration: textInputDecoration.copyWith(
                            labelText: "E-mail",
                            prefixIcon: Icon(
                              Icons.email,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          onChanged: ((value) {
                            email = value;
                            // print(email);
                          }),
                          validator: (value) {
                            return RegExp(
                                        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                    .hasMatch(value!)
                                ? null
                                : "Please enter valid email";
                          },
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          decoration: textInputDecoration.copyWith(
                            labelText: "Full Name",
                            prefixIcon: Icon(
                              Icons.person,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          onChanged: ((value) {
                            fullName = value;
                            // print(email);
                          }),
                          validator: ((value) {
                            if (value!.isEmpty) {
                              return "Please enter your name";
                            }
                          }),
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          obscureText: !_showPassword,
                          decoration: textInputDecoration.copyWith(
                            labelText: "Password",
                            prefixIcon: Icon(
                              Icons.lock,
                              color: Theme.of(context).primaryColor,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(_showPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off),
                              onPressed: () {
                                setState(() {
                                  _showPassword = !_showPassword;
                                });
                              },
                            ),
                          ),
                          onChanged: ((value) {
                            password = value;
                          }),
                          validator: (value) {
                            if (value!.length < 6) {
                              return "Password must be atleast 6 characters";
                            } else {
                              return null;
                            }
                          },
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              register();
                            },
                            style: ElevatedButton.styleFrom(
                              elevation: 10,
                              shadowColor:
                                  const Color.fromARGB(255, 150, 193, 228),
                              backgroundColor: Theme.of(context).primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: const Text('SIGN UP'),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text.rich(
                          TextSpan(
                            text: "You already have an account. ",
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                text: "Signin here",
                                style: const TextStyle(
                                    color: Colors.black,
                                    decoration: TextDecoration.underline),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    nextScreenReplace(
                                        context, const LoginPage());
                                  },
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  register() async {
    if (formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      await authService
          .registerUserWithEmailPassword(fullName, email, password)
          .then((value) async {
        if (value == true) {
          await HelperFunctions.saveUserLoggedInStatus(true);
          await HelperFunctions.saveUserEmail(email);
          await HelperFunctions.saveUserName(fullName);
          nextScreenReplace(context, const HomePage());
        } else {
          showSnackBar(context, Colors.red, value);
          setState(() {
            _isLoading = false;
          });
        }
      });
    }
  }
}
