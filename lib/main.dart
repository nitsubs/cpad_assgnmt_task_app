import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

const Color tdRed = Color(0xFFDA4040);
const Color tdBlue = Color(0xFF5F52EE);

const Color tdBlack = Color(0xFF3A3A3A);
const Color tdGrey = Color(0xFF717171);

const Color tdBGColor = Color(0xFFEEEFF5);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const keyApplicationId = 'HxSzKB9yXCVcRuj59YB4p6B2QcXAt0b1mfhvyJd7';
  const keyClientKey = 'KfLwo5YtEKM2zheZ4oWgFHeRmGsznxyVE9UE7EeL';
  const keyParseServerUrl = 'https://parseapi.back4app.com';

  await Parse().initialize(keyApplicationId, keyParseServerUrl,
      clientKey: keyClientKey, debug: true);

  runApp(
    MaterialApp(
      home: Task(),
    ),
  );
}

class Task extends StatefulWidget {
  @override
  _TaskState createState() => _TaskState();
}

class _TaskState extends State<Task> {
  @override
  Widget build(BuildContext context) {
    final dateFormat = new DateFormat('MMM dd,\nyyyy\nhh:mm');
    final originalDateFormat = new DateFormat('MMM dd, yyyy hh:mm');

    return Scaffold(
      backgroundColor: tdBGColor,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: tdBGColor,
        title: Text('ToDo App'),
      ),
      body: Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(
              top: 50,
              bottom: 20,
            ),
            child: Text(
              'Task List',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<ParseObject>>(
                future: getTask(),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                    case ConnectionState.waiting:
                      return Center(
                        child: Container(
                            width: 100,
                            height: 100,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.blueGrey),
                            )),
                      );
                    default:
                      if (snapshot.hasError) {
                        return Center(
                          child: Text("Error..."),
                        );
                      }
                      if (!snapshot.hasData) {
                        return Center(
                          child: Text("No Data..."),
                        );
                      } else {
                        return ListView.builder(
                            padding: EdgeInsets.all(10.0),
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              //*************************************
                              //Get Parse Object Values
                              final varTask = snapshot.data![index];
                              final varTitle = varTask.get<String>('Title')!;
                              final varContent =
                              varTask.get<String>('Description')!;
                              final varStatus = varTask.get<bool>('status')!;
                              final varDate = dateFormat
                                  .format(varTask.get<DateTime>('updatedAt')!);
                              final varOriginalDate = originalDateFormat
                                  .format(varTask.get<DateTime>('updatedAt')!);
                              //*************************************

                              return ListTile(
                                  onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => TaskDetails(
                                              varTitle,
                                              varContent,
                                              varOriginalDate,
                                              varStatus))),
                                  visualDensity: VisualDensity(vertical: 4),
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                        color: Colors.black, width: 2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  tileColor: Colors.white,
                                  leading: Checkbox(
                                      value: varStatus,
                                      activeColor: Colors.blueGrey,
                                      onChanged: (value) async {
                                        await updateTask(
                                            varTask.objectId!, value!);
                                        setState(() {
                                          //Refresh UI
                                        });
                                      }),
                                  // Icon(Icons.check_box, color: tdBlue),
                                  title: Text(
                                    varTitle,
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: tdBlack,
                                    ),
                                  ),
                                  trailing: Container(
                                      height: 35,
                                      width: 35,
                                      decoration: BoxDecoration(
                                        color: tdRed,
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: IconButton(
                                        color: Colors.white,
                                        iconSize: 18,
                                        icon: Icon(Icons.delete),
                                        onPressed: () async {
                                          await deleteTask(varTask.objectId!);
                                          setState(() {
                                            final snackBar = SnackBar(
                                              content: Text(
                                                  "Task Deleted Successfully!"),
                                              duration: Duration(seconds: 2),
                                            );
                                            ScaffoldMessenger.of(context)
                                              ..removeCurrentSnackBar()
                                              ..showSnackBar(snackBar);
                                          });
                                        },
                                      )));
                            });
                      }
                  }
                }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NewTask()),
          );
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> saveTaskToParse(String title, String content) async {
    final task = ParseObject('Tasks')
      ..set('title', title)
      ..set('content', content)
      ..set('status', false);
    await task.save();
  }

  Future<List<ParseObject>> getTask() async {
    QueryBuilder<ParseObject> queryTask =
    QueryBuilder<ParseObject>(ParseObject('Tasks'));
    final ParseResponse apiResponse = await queryTask.query();

    if (apiResponse.success && apiResponse.results != null) {
      return apiResponse.results as List<ParseObject>;
    } else {
      return [];
    }
  }

  Future<void> updateTask(String id, bool status) async {
    var task = ParseObject('Tasks')
      ..objectId = id
      ..set('status', status);
    await task.save();
  }

  Future<void> deleteTask(String id) async {
    var task = ParseObject('Tasks')..objectId = id;
    await task.delete();
  }
}

class NewTask extends StatefulWidget {
  @override
  _NewTaskState createState() => _NewTaskState();
}

class _NewTaskState extends State<NewTask> {
  final titleController = TextEditingController();
  final contentController = TextEditingController();

  void saveTask() async {
    if (titleController.text.trim().isEmpty ||
        contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Task details cannot be empty!"),
        duration: Duration(seconds: 2),
      ));
      return;
    }
    await saveTaskToParse(titleController.text, contentController.text);
    setState(() {
      titleController.clear();
      contentController.clear();
    });
  }

  void clearContent() {
    setState(() {
      titleController.clear();
      contentController.clear();
    });
  }

  Future<void> saveTaskToParse(String title, String content) async {
    final task = ParseObject('Tasks')
      ..set('Title', title)
      ..set('Description', content)
      ..set('completed', false);
    await task.save();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Task Details"),
          backgroundColor: Colors.blueGrey,
          centerTitle: true,
        ),
        body: Column(
          children: <Widget>[
            Container(
                padding: EdgeInsets.fromLTRB(18.0, 18.0, 18.0, 0.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        focusNode: null,
                        keyboardType: TextInputType.multiline,
                        maxLines: 1,
                        cursorColor: Colors.blueGrey,
                        autocorrect: false,
                        textCapitalization: TextCapitalization.sentences,
                        controller: titleController,
                        decoration: InputDecoration(
                            border: new OutlineInputBorder(
                              borderSide:
                              new BorderSide(color: Colors.blueGrey),
                            ),
                            focusedBorder: new OutlineInputBorder(
                              borderSide:
                              new BorderSide(color: Colors.blueGrey),
                            ),
                            labelText: "Task Title",
                            labelStyle: TextStyle(color: Colors.blueGrey)),
                      ),
                    ),
                  ],
                )),
            Container(
                padding: EdgeInsets.fromLTRB(18.0, 18.0, 18.0, 0.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        focusNode: null,
                        keyboardType: TextInputType.multiline,
                        maxLines: 5,
                        cursorColor: Colors.blueGrey,
                        autocorrect: false,
                        textCapitalization: TextCapitalization.sentences,
                        controller: contentController,
                        decoration: InputDecoration(
                            border: new OutlineInputBorder(
                              borderSide:
                              new BorderSide(color: Colors.blueGrey),
                            ),
                            focusedBorder: new OutlineInputBorder(
                              borderSide:
                              new BorderSide(color: Colors.blueGrey),
                            ),
                            labelText: "Task Content",
                            labelStyle: TextStyle(color: Colors.blueGrey)),
                      ),
                    ),
                  ],
                )),
            Container(
                padding: EdgeInsets.fromLTRB(18.0, 8.0, 18.0, 0.0),
                child: Row(children: <Widget>[
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.grey,
                        minimumSize: Size(142, 40),
                      ),
                      onPressed: clearContent,
                      child: Text("Clear")),
                  SizedBox(width: 10),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blueGrey,
                        minimumSize: Size(242, 40),
                      ),
                      onPressed: saveTask,
                      child: Text("Save Task")),
                ]))
          ],
        ));
  }
}

class TaskDetails extends StatefulWidget {
  final String varTitle;
  final String varContent;
  final String varOriginalDate;
  final bool varStatus;

  TaskDetails(
      this.varTitle, this.varContent, this.varOriginalDate, this.varStatus);

  @override
  _TaskDetailsState createState() =>
      _TaskDetailsState(varTitle, varContent, varOriginalDate, varStatus);
}

class _TaskDetailsState extends State<TaskDetails> {
  final String varTitle;
  final String varContent;
  final String varOriginalDate;
  final bool varStatus;

  _TaskDetailsState(
      this.varTitle, this.varContent, this.varOriginalDate, this.varStatus);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Task Details"),
          backgroundColor: Colors.blueGrey,
          centerTitle: true,
        ),
        body: Container(
            padding: EdgeInsets.fromLTRB(18.0, 8.0, 18.0, 18.0),
            child: Column(children: <Widget>[
              Column(
                children: [
                  Container(
                      padding: EdgeInsets.fromLTRB(18.0, 8.0, 18.0, 18.0),
                      child: Text(
                        varTitle,
                        style: DefaultTextStyle.of(context)
                            .style
                            .apply(fontSizeFactor: 0.5),
                      )),
                  Container(
                      padding: EdgeInsets.fromLTRB(18.0, 8.0, 18.0, 18.0),
                      width: 500,
                      child: Text(varContent)),
                  Container(
                      padding: EdgeInsets.fromLTRB(18.0, 8.0, 18.0, 18.0),
                      width: 500,
                      child: Text(
                        varOriginalDate,
                      )),
                  Container(
                      padding: EdgeInsets.fromLTRB(18.0, 8.0, 18.0, 18.0),
                      width: 500,
                      child: Text(
                        varStatus ? "Status: DONE" : "Status: Pending",
                        style: TextStyle(
                          color: Colors.black,
                          decoration: TextDecoration.underline,
                        ),
                      ))
                ],
              ),
            ])));
  }
}
