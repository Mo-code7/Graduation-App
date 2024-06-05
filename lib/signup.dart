import 'package:flutter/material.dart';
import 'package:imagepickingonline/question.dart';
import 'login.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

void main() => runApp(const Sign_Up());

// ignore: camel_case_types
class Sign_Up extends StatelessWidget {
  const Sign_Up({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SignUp(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// ignore: must_be_immutable
class SignUp extends StatelessWidget {
  static const String uploadEndPointauthsignup = 'https://lungcancerdetection2010.com/Dashboard/authenicationsignup.php';
  String status = '';

  static const String id = "sign-up";
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final conformPasswordController = TextEditingController();

  SignUp({super.key});

  Future<void> upload(BuildContext context) async {
    try {
      if (passwordController.text.isNotEmpty) {
        var url = Uri.parse(uploadEndPointauthsignup);
        var headers = {'Prefer': 'type=password'};
        var request = http.MultipartRequest('POST', url);
        request.headers.addAll(headers);

        request.fields['signupemail'] = emailController.text;
        request.fields['signuppassword'] = passwordController.text;

        if(passwordController.text == conformPasswordController.text){
        var response = await request.send();

        if (response.statusCode == 200) {
          String responseBody = await response.stream.bytesToString();
          print('Response body: $responseBody');
          // Clear the text fields after successful upload
          if (responseBody == 'success'){
            emailController.clear();
          passwordController.clear();
          conformPasswordController.clear();
            // ignore: use_build_context_synchronously
            showErrorDialog(context, 'Your new account created successfully',Colors.green);
          // ignore: use_build_context_synchronously
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const Questions()),
          );
        }
          else if(responseBody == 'notallowed'){
            // ignore: use_build_context_synchronously
            showErrorDialog(context, 'Already, This email is signed into app',Colors.red);
          }
        } else {
          print('Error uploading files. Status code: ${response.statusCode}');
        }
      }
        else{
          showErrorDialog(context, 'Two passwords are not matching',Colors.red);
        }
    }
    } catch (error) {
      print('Error uploading files: $error');
    }
  }

  setStatus(String message) {
    status = message;
  }

  final _formKey = GlobalKey<FormState>();
  void showErrorDialog(BuildContext context, String message ,Color tcolor) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Update password'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  message,
                  style: TextStyle(color: tcolor),
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
      appBar: AppBar(
        title: const Text('SignUp'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const Text(
                    'Lung Cancer',
                    style: TextStyle(
                      fontSize: 30.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Already have an account ?'),
                      TextButton(
                        onPressed: () {
                          final route = MaterialPageRoute(builder: (context) => const MylogIn(),);
                          Navigator.of(context).push(route);
                        },
                        child: const Text('Login'),
                      ),
                    ],
                  ),
                  const Text(
                    'Sign up',
                    style: TextStyle(
                      fontSize: 30.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  const Text('Use your OpenID to Sign up'),
                  const SizedBox(height: 15.0),
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email is required';
                      }

                      final emailRegExp = RegExp(r"[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[-a-zA-Z0-9]{0,253}\.)+[a-zA-Z]{2,}");

                      if (!emailRegExp.hasMatch(value!)) {
                        return 'Please enter a valid email address.';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      labelText: 'Email Address',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 15.0),
                  TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password is required';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock),
                      suffixIcon: Icon(Icons.remove_red_eye),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 15.0),
                  TextFormField(
                    controller: conformPasswordController,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Confirm Password is required';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      labelText: 'Confirm Password',
                      prefixIcon: Icon(Icons.lock),
                      suffixIcon: Icon(Icons.remove_red_eye),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 15.0),
                  Container(
                    width: double.infinity,
                    color: Colors.blue,
                    child: MaterialButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          upload(context);
                        }
                      },
                      child: const Text(
                        'Sign up',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
