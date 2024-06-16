import 'package:flutter/material.dart';
import 'package:phoenix_nsmq/pages/mode_selection_screen.dart';
import 'package:phoenix_nsmq/pages/questions_screen.dart';
import 'package:phoenix_nsmq/pages/subject_selection_screen.dart';
import 'package:phoenix_nsmq/routes.dart';
import 'package:phoenix_nsmq/store.dart';
import 'package:vxstate/vxstate.dart';

void main() {
  runApp(
    VxState(
      store: AppStore(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Phoenix NSMQ',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // home: const MainScreen(), // const MyHomePage(title: 'Flutter Demo Home Page'),
      routes: {
        mainRoute: (context) => const ModeSelectionScreen(),
        subjectSelectionRoute: (context) => const SubjectSelectionScreen(),
        questionsRoute: (context) => const QuestionsScreen(),
      },
      initialRoute: mainRoute,
    );
  }
}