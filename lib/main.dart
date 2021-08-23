import 'package:flutter/material.dart';
import 'call.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

// App state class
class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();
  }

  // Build UI
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Video Call App'),
        ),
        body: Center(
          child: ElevatedButton(
            child: Text('Call Now'),
            onPressed: () {
              var route = MaterialPageRoute(builder: (context) => Call());
              Navigator.push(context, route);
            },
          ),
        ),
        // body: Image.asset('assets/me.jpg'),
      ),
    );
  }
}
