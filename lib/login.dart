import 'package:flutter/material.dart';
import 'package:imagepickingonline/question.dart';
import 'package:imagepickingonline/signup.dart';
import 'package:http/http.dart' as http;

import 'email_validation.dart';

void main() => runApp(const MylogIn());

class MylogIn extends StatelessWidget {
  const MylogIn({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: LoginState(),
      debugShowCheckedModeBanner: false,
    );
  }
}

final emailController = TextEditingController();
final passwordController = TextEditingController();
final formKey = GlobalKey<FormState>();

class LoginState extends StatefulWidget {
  const LoginState({super.key});

  @override
  State<LoginState> createState() => _LoginState();
}

class _LoginState extends State<LoginState> {
  static const String uploadEndPointauthsignup =
      'https://lungcancerdetection2010.com/Dashboard/authenicationlogin.php';
  bool isPasswordShow = true;
  String status = '';

  Future<void> upload(BuildContext context) async {
    try {
      if (passwordController.text.isNotEmpty) {
        var url = Uri.parse(uploadEndPointauthsignup);
        var headers = {'Prefer': 'type=password'};
        var request = http.MultipartRequest('POST', url);
        request.headers.addAll(headers);

        request.fields['loginemail'] = emailController.text;
        request.fields['loginpassword'] = passwordController.text;

        var response = await request.send();

        if (response.statusCode == 200) {
          String responseBody = await response.stream.bytesToString();
          print('Response body: $responseBody');
          if (responseBody.contains('success')) {
            // ignore: use_build_context_synchronously
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const Questions()),
            );
          } else {
            // ignore: use_build_context_synchronously
            showErrorDialog(context, 'Wrong email or password');
            print('Login failed');
          }
        } else {
          print('Status code: ${response.statusCode}');
        }
      }
    } catch (error) {
      print('Error uploading files: $error');
    }
  }


  void showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Login page'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  message,
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        children: [
          const SizedBox(
            height: 100,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      const Text(
                        'Cancer detection',
                        style: TextStyle(
                          fontSize: 30.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 15.0,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Don\'t have an account ??',
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>  const Sign_Up()),
                              );
                            },
                            child: const Text("Register"),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 50.0,
                      ),
                      const Text(
                        'Sign in to cancer detection App',
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(
                        color: Colors.black,
                        indent: 40,
                        endIndent: 40,
                        height: 80,
                        thickness: 1.5,
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      TextFormField(
                        controller: emailController,
                        decoration: const InputDecoration(
                            label: Text('Email Address'),
                            icon: Icon(Icons.email_outlined)),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Email must not be empty';
                          }

                          final emailRegExp = RegExp(r"[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[-a-zA-Z0-9]{0,253}\.)+[a-zA-Z]{2,}");

                          if (!emailRegExp.hasMatch(value!)) {
                            return 'Please enter a valid email address.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      TextFormField(
                        controller: passwordController,
                        decoration: InputDecoration(
                          label: const Text('Password'),
                          icon: const Icon(Icons.lock),
                          suffixIcon: GestureDetector(
                            onTap: () {
                              setState(() {
                                isPasswordShow = !isPasswordShow;
                              });
                            },
                            child: Icon(isPasswordShow
                                ? Icons.visibility
                                : Icons.visibility_off),
                          ),
                        ),
                        obscureText: isPasswordShow,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Password must not be empty';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Scan to login',
                          ),
                          TextButton(
                            onPressed: () {
                              final route = MaterialPageRoute(builder: (context) => const SecurityVerification());
                              Navigator.push(context, route);
                            },
                            child: const Text('Forgot password?'),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 15.0,
                      ),
                      Container(
                        width: double.infinity,
                        color: Colors.blue,
                        child: MaterialButton(
                          child: const Text(
                            'Login',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              upload(context);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
