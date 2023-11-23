import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../data/database.dart';
import '../util/dialog_box.dart';
import '../util/todo_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // reference the hive box
  final _myBox = Hive.box('mybox');
  ToDoDataBase db = ToDoDataBase();

  @override
  void initState() {
    // if this is the 1st time ever openin the app, then create default data
    if (_myBox.get("TODOLIST") == null) {
      db.createInitialData();
    } else {
      // there already exists data
      db.loadData();
    }

    super.initState();
  }

  // text controller
  final _controller = TextEditingController();

  // checkbox was tapped
  void checkBoxChanged(bool? value, int index) {
    setState(() {
      db.toDoList[index][1] = !db.toDoList[index][1];
    });
    db.updateDataBase();
  }

  // save new task
  void saveNewTask() {
    setState(() {
      db.toDoList.add([_controller.text, false]);
      _controller.clear();
    });
    Navigator.of(context).pop();
    db.updateDataBase();
  }

  // create a new task
  void createNewTask() {
    showDialog(
      context: context,
      builder: (context) {
        return DialogBox(
            controller: _controller,
            onSave: saveNewTask,
            onCancel: () {
              Navigator.of(context).pop();
              _controller.clear();
            });
      },
    );
  }

  // delete task
  void deleteTask(int index) {
    setState(() {
      db.toDoList.removeAt(index);
    });
    db.updateDataBase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow[200],
      appBar: AppBar(
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: createNewTask,
              tooltip: "Add New Task",
              icon: Icon(
                Icons.note_add,
                size: 30,
                color: Colors.black.withOpacity(0.8),
              ))
        ],
        leading: Padding(
          padding: const EdgeInsets.only(left: 5),
          child: Icon(
            Icons.task,
            size: 30,
            color: Colors.black.withOpacity(0.8),
          ),
        ),
        title: RichText(
          text: const TextSpan(
            style: TextStyle(
              fontSize: 22,
            ),
            children: <TextSpan>[
              TextSpan(
                text: 'CP ',
                style: TextStyle(
                  letterSpacing: 2,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: 'TO - DO',
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: "Add New Task",
        onPressed: createNewTask,
        child: const Icon(Icons.add),
      ),
      body: Stack(
        children: [
          if (db.toDoList.isEmpty) // Check if the to-do list is empty
            const Center(
              child: Text(
                'Your To-Do list is Empty!',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
          if (db.toDoList.isNotEmpty) // Show the list if it's not empty
            ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: db.toDoList.length,
              itemBuilder: (context, index) {
                return ToDoTile(
                  taskName: db.toDoList[index][0],
                  taskCompleted: db.toDoList[index][1],
                  onChanged: (value) => checkBoxChanged(value, index),
                  deleteFunction: (context) => deleteTask(index),
                );
              },
            ),
        ],
      ),
    );
  }
}
