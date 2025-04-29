import 'package:flutter/material.dart';

import '../model/todo.dart';
import '../constants/colors.dart';
import '../widgets/todo_item.dart';

class Home extends StatefulWidget {
  Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final todosList = ToDo.todoList();
  List<ToDo> _foundToDo = [];
  final _todoController = TextEditingController();
  double _completionPercentage = 0.0;

  final List<Color> _backgroundColors = [
    tdBGColor,
    Colors.blue[50]!,
    Colors.green[50]!,
    Colors.purple[50]!,
    Colors.amber[50]!,
    Colors.pink[50]!,
  ];

  int _currentBgColorIndex = 0;
  Color get _currentBgColor => _backgroundColors[_currentBgColorIndex];

  @override
  void initState() {
    _foundToDo = todosList;
    super.initState();
  }

  void _updateCompletionPercentage() {
    if (todosList.isEmpty) {
      _completionPercentage = 0.0;
    } else {
      final completedCount = todosList.where((todo) => todo.isDone).length;
      _completionPercentage = (completedCount / todosList.length) * 100;
    }
  }

  void _changeBackgroundColor() {
    setState(() {
      _currentBgColorIndex = (_currentBgColorIndex + 1) % _backgroundColors.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _currentBgColor,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                Center(
                  child: Text(
                    'Productivity App',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 20),

                searchBox(),
                Expanded(
                  child: ListView(
                    children: [
                      Container(
                        margin: EdgeInsets.only(
                          top: 40,
                          bottom: 20,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'All ToDos',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            // Add color selector next to "All ToDos"
                            _buildColorChangeButton(),
                          ],
                        ),
                      ),
                      ..._foundToDo.reversed.map((todoo) => ToDoItem(
                        todo: todoo,
                        onToDoChanged: _handleToDoChange,
                        onDeleteItem: _deleteToDoItem,
                      )).toList(),
                      SizedBox(height: 20),
                      Center(
                        child: Text(
                          'Completed: ${_completionPercentage.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: tdBlue,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Row(children: [
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(
                    bottom: 20,
                    right: 20,
                    left: 20,
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.grey,
                        offset: Offset(0.0, 0.0),
                        blurRadius: 10.0,
                        spreadRadius: 0.0,
                      ),
                    ],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    controller: _todoController,
                    decoration: InputDecoration(
                        hintText: 'Add a new todo item',
                        border: InputBorder.none),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(
                  bottom: 20,
                  right: 20,
                ),
                child: ElevatedButton(
                  child: Text(
                    '+',
                    style: TextStyle(
                      fontSize: 40,
                    ),
                  ),
                  onPressed: () {
                    _addToDoItem(_todoController.text);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: tdBlue,
                    minimumSize: Size(60, 60),
                    elevation: 10,
                  ),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildColorChangeButton() {
    return InkWell(
      onTap: _changeBackgroundColor,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Container(
              height: 16,
              width: 16,
              decoration: BoxDecoration(
                color: _currentBgColor,
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            SizedBox(width: 5),
            Text(
              'Theme',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(width: 5),
            Icon(Icons.color_lens, size: 16),
          ],
        ),
      ),
    );
  }

  void _handleToDoChange(ToDo todo) {
    if (!todo.isDone) {
      setState(() {
        todo.isDone = true;
        _updateCompletionPercentage();
      });
    }
  }

  void _deleteToDoItem(String id) {
    final todoItem = todosList.firstWhere((item) => item.id == id);

    if (todoItem.isDone) {
      setState(() {
        todosList.removeWhere((item) => item.id == id);
        _runFilter('');
        _updateCompletionPercentage();
      });
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Delete Task'),
          content: Text('This task is not completed. Are you sure you want to delete it?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  todosList.removeWhere((item) => item.id == id);
                  _runFilter(''); // refresh filter
                  _updateCompletionPercentage();
                });
                Navigator.of(context).pop();
              },
              child: Text('Delete', style: TextStyle(color: tdRed)),
            ),
          ],
        ),
      );
    }
  }

  void _addToDoItem(String toDo) {
    final trimmedTodo = toDo.trim();

    if (trimmedTodo.isEmpty) {
      return;
    }

    bool isDuplicate = todosList.any(
            (item) => item.todoText!.toLowerCase() == trimmedTodo.toLowerCase()
    );

    if (!isDuplicate) {
      setState(() {
        todosList.add(ToDo(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          todoText: trimmedTodo,
        ));
        _runFilter(''); // refresh filter
        _updateCompletionPercentage();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('This task already exists!'),
          duration: Duration(seconds: 2),
        ),
      );
    }

    _todoController.clear();
  }

  void _runFilter(String enteredKeyword) {
    List<ToDo> results = [];
    if (enteredKeyword.isEmpty) {
      results = todosList;
    } else {
      results = todosList
          .where((item) => item.todoText!
          .toLowerCase()
          .contains(enteredKeyword.toLowerCase()))
          .toList();
    }

    setState(() {
      _foundToDo = results;
    });
  }

  Widget searchBox() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        onChanged: (value) => _runFilter(value),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.all(0),
          prefixIcon: Icon(
            Icons.search,
            color: tdBlack,
            size: 20,
          ),
          prefixIconConstraints: BoxConstraints(
            maxHeight: 20,
            minWidth: 25,
          ),
          border: InputBorder.none,
          hintText: 'Search',
          hintStyle: TextStyle(color: tdGrey),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: _currentBgColor, // Use the selected background color for AppBar too
      elevation: 0,
      title: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Icon(
          Icons.menu,
          color: tdBlack,
          size: 30,
        ),
        Container(
          height: 40,
          width: 40,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset('assets/images/jia.jpg'),
          ),
        ),
      ]),
    );
  }
}