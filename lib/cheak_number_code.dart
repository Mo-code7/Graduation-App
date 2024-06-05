import 'package:flutter/material.dart';
import 'login.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const Cheak_Number_code(email: '',));
}

// ignore: must_be_immutable
class Cheak_Number_code extends StatefulWidget {
  final String email; // Receive email from first page

  const Cheak_Number_code({Key? key, required this.email}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _Cheak_Number_codeState createState() => _Cheak_Number_codeState();
}

// ignore: camel_case_types
class _Cheak_Number_codeState extends State<Cheak_Number_code> {
  // ignore: non_constant_identifier_names
  var OTPController = TextEditingController();
  var newPasswordController = TextEditingController();
  var confirmPasswordController = TextEditingController();
  bool isOTPCorrect = false;

  String userEmail = '';

  Future<void> upload() async {
    const String uploadEndPointHostginer = 'https://lungcancerdetection2010.com/Dashboard/otpkill.php';

    try {
      var request = http.MultipartRequest('POST', Uri.parse(uploadEndPointHostginer));
      request.fields['otpvalue'] = OTPController.text;
      userEmail = widget.email;


      var response = await request.send();

      if (response.statusCode == 200) {
        String responseBody = await response.stream.bytesToString();
        print('Response body: $responseBody');
        if (responseBody.trim() == 'success') {
          setState(() {
            isOTPCorrect = true;
          });
        } else {
          print('OTP verification failed');
        }
      } else {
        print('Error uploading files. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error uploading files: $error');
    }
  }



  Future<void> uploadNewPassword(BuildContext context) async {

    const String uploadEndPointHostginer = 'https://lungcancerdetection2010.com/Dashboard/otpupdatepassword.php';

    try {
      var request = http.MultipartRequest(
          'POST', Uri.parse(uploadEndPointHostginer));

      userEmail = widget.email;
      String npassword = newPasswordController.text;
      String npasswordconfirm = confirmPasswordController.text;

      if (npassword == npasswordconfirm) {

        request.fields['usermail']=userEmail;
        request.fields['usernpassword']=npassword;
      var response = await request.send();

      if (response.statusCode == 200) {
        String responseBody = await response.stream.bytesToString();
        print('Response body: $responseBody');
        if (responseBody.trim() == 'success') {
          // ignore: use_build_context_synchronously
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const LoginState()),
          );
          // ignore: use_build_context_synchronously
          showErrorDialog(context, 'Your password updated successfully',Colors.green);

        } else {
          print('OTP verification failed');
        }
      } else {
        print('Error uploading . Status code: ${response.statusCode}');
      }
    }
      else{
        showErrorDialog(context, 'Two passwords are not matching',Colors.red);
        print('Two passwords are not matching');
      }
    } catch (error) {
      print('$error');
    }
  }




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
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
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
                  'Checking the validation',
                  style: TextStyle(
                    fontSize: 25,
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
                  height: 40.0,
                ),
                if (!isOTPCorrect) ...[
                  const Text(
                    'Enter OTP that sent to your email',
                  ),
                  const SizedBox(
                    height: 5.0,
                  ),
                  TextFormField(
                    controller: OTPController,
                    keyboardType: TextInputType.number,
                    onFieldSubmitted: (value) {
                      print(value);
                    },
                    onChanged: (value) {
                      print(value);
                    },
                    decoration: const InputDecoration(
                      labelText: 'OTP',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(
                    height: 25.0,
                  ),
                  Container(
                    width: double.infinity,
                    color: Colors.blue,
                    child: MaterialButton(
                      onPressed: upload,
                      child: const Text(
                        'Continue',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ]
                else if (isOTPCorrect) ...[
                  TextFormField(
                    controller: newPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'New Password',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(
                    height: 25.0,
                  ),
                  TextFormField(
                    controller: confirmPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Confirm New Password',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(
                    height: 25.0,
                  ),
                  Container(
                    width: double.infinity,
                    color: Colors.blue,
                    child: MaterialButton(
                      onPressed: () {
                        // Handle password reset logic here
                        uploadNewPassword(context);
                      },
                      child: const Text(
                        'Reset Password',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
