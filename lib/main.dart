import 'package:ciao/task_model.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To Do List',
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
        colorScheme: ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 46, 178, 150)),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

 
  List<TaskModel> taskList = [];
  List<TaskModel> searchQuery = [];
  final TextEditingController searchController = TextEditingController();
  final TextEditingController taskTextEditingController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    searchQuery = List.from(taskList);
    searchController.addListener(_updateSearch);
  }

  @override
  void dispose() {
    searchController.dispose();
    taskTextEditingController.dispose();
    super.dispose();
  }

  void createTask({required TaskModel task}) {
    setState(() {
      taskList.add(task);
      _updateSearch();
    });
  }

  void updateTask({required String taskId, required TaskModel updatedTask}) {
    final taskIndex = taskList.indexWhere((task) => task.id == taskId);
    setState(() {
      taskList[taskIndex] = updatedTask;
      _updateSearch();
    });
  }

  void deleteTask({required String taskId}) {
    setState(() {
      taskList.removeWhere((task) => task.id == taskId);
      _updateSearch();
    });
  }

  void _updateSearch() {
    final query = searchController.text;
    setState(() {
      if (query.isEmpty) {
        searchQuery = List.from(taskList);
      } else {
        searchQuery = taskList
            .where((task) => task.title.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.primary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text('My To Do List',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24.0,)
          ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search task...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            searchController.clear();
                            _updateSearch();
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onChanged: (value) {
                  _updateSearch();
                },
              ),
            ),
            Expanded(
              child: searchQuery.isNotEmpty
                  ? ListView.builder(
                      itemCount: searchQuery.length,
                      itemBuilder: (context, index) {
                        final TaskModel task = searchQuery[index];
                        return ListTile(
                          title: Text(
                            task.title,
                            style: TextStyle(
                              color: task.isCompleted ? Colors.grey : Colors.black,
                              decoration: task.isCompleted
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                              fontSize: 18,
                            ),
                          ),
                          trailing: IconButton(
                            onPressed: () {
                              deleteTask(taskId: task.id);
                            },
                            icon: const Icon(Icons.delete, color: Colors.red, size: 30.0),
                          ),
                          leading: Transform.scale(
                            scale: 1.5,
                            child: Checkbox(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                              value: task.isCompleted,
                              onChanged: (value) {
                                setState(() {
                                  task.isCompleted = value!;
                                  _updateSearch();
                                });
                              },
                            ),
                          ),
                        );
                      },
                    )
                  : const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15.0),
                        child: Text(
                          'Nessun task trovato, aggiungine uno!',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context, 
            builder: (context) {
              return AlertDialog(
                title: const Text('Add Task'),
                content: TextField(
                  controller: taskTextEditingController,
                  decoration: const InputDecoration(
                    hintText: 'Describe your task',
                  ),
                  maxLines: 3,
                ),
                actionsAlignment: MainAxisAlignment.spaceBetween,
                actions: [
                  TextButton(
                    onPressed:() {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      if (taskTextEditingController.text.isNotEmpty) {
                        final TaskModel newTask = TaskModel(
                            id: DateTime.now().toString(),
                            title: taskTextEditingController.text,
                          );
                        createTask(task: newTask);
                        taskTextEditingController.clear();
                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text('Save'),
                  ),
                ]
              );
            });
        },
        tooltip: 'Increment', 
      ),
    ); 
  }
}

