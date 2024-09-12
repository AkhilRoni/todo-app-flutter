import 'package:flutter/material.dart';
import 'package:tudo/api/firebase_api.dart';
import '../widgets/todo_item.dart';
import '../model/todo.dart';
import '../colors.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    final primarySwatch = MaterialColor(
      tdBGColor.value,
      <int, Color>{
        50: tdBGColor.withOpacity(0.1),
        100: tdBGColor.withOpacity(0.2),
        200: tdBGColor.withOpacity(0.3),
        300: tdBGColor.withOpacity(0.4),
        400: tdBGColor.withOpacity(0.5),
        500: tdBGColor.withOpacity(0.6),
        600: tdBGColor.withOpacity(0.7),
        700: tdBGColor.withOpacity(0.8),
        800: tdBGColor.withOpacity(0.9),
        900: tdBGColor.withOpacity(1.0),
      },
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: primarySwatch),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  List<ToDo> todosList = []; // Define the todosList here
  @override
  void initState() {
    super.initState();
    initializeApp();
  }

  Future<void> initializeApp() async {
    await fetchTasks();

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => RootPage(todosList: todosList),
      ),
    );
  }

  Future<void> fetchTasks() async {
    final tasks = await FirebaseService.fetchTasksFromFirebase();
    setState(() {
      todosList = tasks;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: tdBGColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'images/logo.png',
              width: 400,
              height: 270,
            ),
          ],
        ),
      ),
    );
  }
}

class RootPage extends StatefulWidget {
  final List<ToDo> todosList;

  const RootPage({Key? key, required this.todosList}) : super(key: key);

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  final _todoController = TextEditingController();

  // @override
  // void initState() {
  //   super.initState();
  //   fetchTasks();
  // }

  // Future<void> fetchTasks() async {
  //   final tasks = await FirebaseService.fetchTasksFromFirebase();
  //   setState(() {
  //     todosList = tasks;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: tdBGColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: const Icon(Icons.menu_rounded),
        foregroundColor: Colors.white,
        backgroundColor: tdBGColor,
        title: const Text(
          'TuDo',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        titleTextStyle: const TextStyle(
            backgroundColor: tdBGColor, color: Colors.black, fontSize: 30),
      ),
      body: Stack(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(
                            top: 20, bottom: 20, left: 15),
                        child: Text(
                          'We have ${widget.todosList.length} tasks remaining',
                          style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w500,
                              color: Colors.white),
                        ),
                      ),
                      for (ToDo todoo in widget.todosList)
                        ToDoItem(
                          todo: todoo,
                          onToDoChanged: _handleToDoChange,
                          onDeleteItem: _deleteToDoItem,
                        )
                    ],
                  ),
                ),
                const SizedBox(height: 69),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Row(
              children: [
                Expanded(
                    child: Container(
                  margin:
                      const EdgeInsets.only(bottom: 20, right: 20, left: 20),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: const [
                        BoxShadow(
                            color: tdGrey,
                            offset: Offset(0, 0),
                            spreadRadius: 0),
                      ],
                      borderRadius: BorderRadius.circular(20)),
                  child: TextField(
                    controller: _todoController,
                    decoration: const InputDecoration(
                        hintText: 'Add a new Task', border: InputBorder.none),
                  ),
                )),
                Container(
                    margin: const EdgeInsets.only(bottom: 20, right: 20),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: ElevatedButton(
                          onPressed: () {
                            _addToDoItem(_todoController.text);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: tdBlue,
                            minimumSize: const Size(60, 60),
                            elevation: 10,
                          ),
                          child:
                              const Text('+', style: TextStyle(fontSize: 40))),
                    ))
              ],
            ),
          )
        ],
      ),
    );
  }

  void _handleToDoChange(ToDo todo) {
    final newIsDone = !todo.isDone;
    setState(() {
      todo.isDone = newIsDone;
    });
    FirebaseService.updateisDone(todo.id, newIsDone);
  }

  void _deleteToDoItem(String id) {
    setState(() {
      widget.todosList.removeWhere((item) => item.id == id);
    });
    FirebaseService.deletefromFirebase(id);
  }

  void _addToDoItem(String toDo) {
    if (toDo.isNotEmpty) {
      setState(() {
        final newtask = ToDo(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            todoText: toDo);
        widget.todosList.add(newtask);
        FirebaseService.addtask(newtask);
      });
    }
    _todoController.clear();
  }
}
