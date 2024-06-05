import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'cheak_number_code.dart';

void main() {
  runApp(const SecurityVerificationApp());
}

class SecurityVerificationApp extends StatelessWidget {
  const SecurityVerificationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: SecurityVerification(),
    );
  }
}

class SecurityVerification extends StatefulWidget {
  const SecurityVerification({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SecurityVerificationState createState() => _SecurityVerificationState();
}

class _SecurityVerificationState extends State<SecurityVerification> {
  final emailController = TextEditingController();
  String emailofuser = TextEditingController().text;

  Future<void> upload() async {
    const String uploadEndPointHostginer = 'https://lungcancerdetection2010.com/Dashboard/authenicationotp.php';

    try {
      var request = http.MultipartRequest('POST', Uri.parse(uploadEndPointHostginer));
      request.fields['otpemail'] = emailController.text;

      var response = await request.send();

      if (response.statusCode == 200) {
        String responseBody = await response.stream.bytesToString();
        print('Response body: $responseBody');

        if(responseBody == 'otpsuccess'){
          late final String email;
          final route = MaterialPageRoute(builder: (context) => Cheak_Number_code(email: emailController.text));
          // ignore: use_build_context_synchronously
          Navigator.push(context, route);

        }
      } else {
        print('Error uploading files. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error uploading files: $error');
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Lung Cancer',
                style: TextStyle(
                  fontSize: 30.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 35.0,
              ),
              const Text(
                'Check your email to reset your password',
              ),
              const SizedBox(
                height: 10.0,
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(
                height: 20.0,
              ),
              Container(
                width: double.infinity,
                color: Colors.blue,
                child: MaterialButton(
                  onPressed: () {
                    upload();
                  },
                  child: const Text(
                    'Continue',
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
    );
  }
}

