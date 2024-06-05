import 'package:flutter/material.dart';
import 'package:imagepickingonline/signup.dart';
import 'login.dart';

void main()=>runApp( const MyHome());

class MyHome extends StatelessWidget {
  const MyHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home:Home(),
      debugShowCheckedModeBanner: false,
    );
  }
}
class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // Color background=Color ()
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.blue, // Set background color to blue
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'images/LungCancer.png', // Replace with your image file
                width: 200, // Adjust width as needed
                height: 200, // Adjust height as needed
              ),
              const SizedBox(height: 5),
              const Text('Check your Healthy to have a good life',
              style: TextStyle(
                fontSize:25,
                fontFamily: "Ranga",
                color: Colors.white
              ),),
              // Add some space between Text and Button
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MaterialButton(
                    onPressed: () {
                      final route=MaterialPageRoute(builder: (context)=>const LoginState());
                      Navigator.of(context).push(route);
                    },
                    color: Colors.black,
                    textColor: Colors.white,
                    child: const Text('Login'),
                  ),
                  const SizedBox(width: 20.0), // Adjust spacing between buttons
                  MaterialButton(
                    onPressed: () {
                      final route=MaterialPageRoute(builder: (context)=>const Sign_Up());
                      Navigator.of(context).push(route);
                    },
                    color: Colors.white,
                    textColor: Colors.green,
                    child: const Text('SignUp'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
