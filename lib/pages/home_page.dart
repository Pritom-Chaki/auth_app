import 'package:flutter/material.dart';
import '../services/authentication.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/todo.dart';
import 'dart:async';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.auth, this.userId, this.onSignedOut})
      : super(key: key);

  final BaseAuth auth;
  final VoidCallback onSignedOut;
  final String userId;

  @override
  State<StatefulWidget> createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Todo> _todoList;

  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController _emailFilter = new TextEditingController();
  final TextEditingController _passwordFilter = new TextEditingController();
  final TextEditingController _resetPasswordEmailFilter =
      new TextEditingController();

  String _email = "";
  String _password = "";
  String _resetPasswordEmail = "";

  String _errorMessage;
  bool _isIos;
  bool _isLoading;

  _HomePageState() {
    _emailFilter.addListener(_emailListen);
    _passwordFilter.addListener(_passwordListen);
    _resetPasswordEmailFilter.addListener(_resetPasswordEmailListen);
  }

  void _resetPasswordEmailListen() {
    if (_resetPasswordEmailFilter.text.isEmpty) {
      _resetPasswordEmail = "";
    } else {
      _resetPasswordEmail = _resetPasswordEmailFilter.text;
    }
  }

  void _emailListen() {
    if (_emailFilter.text.isEmpty) {
      _email = "";
    } else {
      _email = _emailFilter.text;
    }
  }

  void _passwordListen() {
    if (_passwordFilter.text.isEmpty) {
      _password = "";
    } else {
      _password = _passwordFilter.text;
    }
  }

  final _textEditingController = TextEditingController();

  StreamSubscription<Event> _onTodoAddedSubscription;
  StreamSubscription<Event> _onTodoChangedSubscription;

  Query _todoQuery;

  bool _isEmailVerified = false;

  @override
  void initState() {
    super.initState();

    _checkEmailVerification();

    // _todoList = new List();
    // _todoQuery = _database
    //     .reference()
    //     .child("todo")
    //     .orderByChild("userId")
    //     .equalTo(widget.userId);
    // _onTodoAddedSubscription = _todoQuery.onChildAdded.listen(_onEntryAdded);
    // _onTodoChangedSubscription = _todoQuery.onChildChanged.listen(_onEntryChanged);
  }

  void _checkEmailVerification() async {
    _isEmailVerified = await widget.auth.isEmailVerified();
    if (!_isEmailVerified) {
      _showVerifyEmailDialog();
    }
  }

  void _resentVerifyEmail() {
    widget.auth.sendEmailVerification();
    _showVerifyEmailSentDialog();
  }

  void _showVerifyEmailDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Verify your account"),
          content: new Text("Please verify account in the link sent to email"),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Resent link"),
              onPressed: () {
                Navigator.of(context).pop();
                _resentVerifyEmail();
              },
            ),
            new FlatButton(
              child: new Text("Dismiss"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showVerifyEmailSentDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Verify your account"),
          content:
              new Text("Link to verify account has been sent to your email"),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Dismiss"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _onTodoAddedSubscription.cancel();
    _onTodoChangedSubscription.cancel();
    super.dispose();
  }

  

  _signOut() async {
    try {
      await widget.auth.signOut();
      widget.onSignedOut();
    } catch (e) {
      print(e);
    }
  }

  // _addNewTodo(String todoItem) {
  //   if (todoItem.length > 0) {

  //     Todo todo = new Todo(todoItem.toString(), widget.userId, false);
  //     _database.reference().child("todo").push().set(todo.toJson());
  //   }
  // }

  // _updateTodo(Todo todo){
  //   //Toggle completed
  //   todo.completed = !todo.completed;
  //   if (todo != null) {
  //     _database.reference().child("todo").child(todo.key).set(todo.toJson());
  //   }
  // }

  // _deleteTodo(String todoId, int index) {
  //   _database.reference().child("todo").child(todoId).remove().then((_) {
  //     print("Delete $todoId successful");
  //     setState(() {
  //       _todoList.removeAt(index);
  //     });
  //   });
  // }

  // _showDialog(BuildContext context) async {
  //   _textEditingController.clear();
  //   await showDialog<String>(
  //       context: context,
  //     builder: (BuildContext context) {
  //         return AlertDialog(
  //           content: new Row(
  //             children: <Widget>[
  //               new Expanded(child: new TextField(
  //                 controller: _textEditingController,
  //                 autofocus: true,
  //                 decoration: new InputDecoration(
  //                   labelText: 'Add new todo',
  //                 ),
  //               ))
  //             ],
  //           ),
  //           actions: <Widget>[
  //             new FlatButton(
  //                 child: const Text('Cancel'),
  //                 onPressed: () {
  //                   Navigator.pop(context);
  //                 }),
  //             new FlatButton(
  //                 child: const Text('Save'),
  //                 onPressed: () {
  //                   _addNewTodo(_textEditingController.text.toString());
  //                   Navigator.pop(context);
  //                 })
  //           ],
  //         );
  //     }
  //   );
  // }

  // Widget _showTodoList() {
  //   if (_todoList.length > 0) {
  //     return ListView.builder(
  //         shrinkWrap: true,
  //         itemCount: _todoList.length,
  //         itemBuilder: (BuildContext context, int index) {
  //           String todoId = _todoList[index].key;
  //           String subject = _todoList[index].subject;
  //           bool completed = _todoList[index].completed;
  //           String userId = _todoList[index].userId;
  //           return Dismissible(
  //             key: Key(todoId),
  //             background: Container(color: Colors.red),
  //             onDismissed: (direction) async {
  //               _deleteTodo(todoId, index);
  //             },
  //             child: ListTile(
  //               title: Text(
  //                 subject,
  //                 style: TextStyle(fontSize: 20.0),
  //               ),
  //               trailing: IconButton(
  //                   icon: (completed)
  //                       ? Icon(
  //                     Icons.done_outline,
  //                     color: Colors.green,
  //                     size: 20.0,
  //                   )
  //                       : Icon(Icons.done, color: Colors.grey, size: 20.0),
  //                   onPressed: () {
  //                     _updateTodo(_todoList[index]);
  //                   }),
  //             ),
  //           );
  //         });
  //   } else {
  //     return Center(child: Text("Welcome. Your list is empty",
  //       textAlign: TextAlign.center,
  //       style: TextStyle(fontSize: 30.0),));
  //   }
  // }

  Widget _showButtonList() {
    return new Container(
      padding: EdgeInsets.all(26.0),
      child: new ListView(
        children: <Widget>[
          _showChangeEmailContainer(),
          new SizedBox(
            height: 40.0,
          ),
          _showChangePasswordContainer(),
          new SizedBox(
            height: 40.0,
          ),
          _showSentResetPasswordEmailContainer(),
          new SizedBox(
            height: 40.0,
          ),
          _removeUserContainer(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Flutter login demo'),
        actions: <Widget>[
          new FlatButton(
              child: new Text('Logout',
                  style: new TextStyle(fontSize: 17.0, color: Colors.white)),
              onPressed: _signOut)
        ],
      ),
      body: _showButtonList(),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     _showDialog(context);
      //   },
      //   tooltip: 'Increment',
      //   child: Icon(Icons.add),
      // )
    );
  }

  Widget _showEmailChangeErrorMessage() {
    if (_errorMessage != null) {
      return new Text(
        _errorMessage,
        style: TextStyle(
            fontSize: 13.0,
            color: Colors.red,
            height: 1.0,
            fontWeight: FontWeight.w300),
      );
    } else {
      return new Container(
        height: 0.0,
      );
    }
  }

  _showChangeEmailContainer() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: new BorderRadius.circular(30.0),
        color: Colors.amberAccent,
      ),
      padding: EdgeInsets.fromLTRB(10, 20, 10, 20),
      child: Column(
        children: <Widget>[
          new TextFormField(
            controller: _emailFilter,
            decoration: new InputDecoration(
              contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
              hintText: "Enter New Email",
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(22.0)),
            ),
          ),
          new MaterialButton(
            shape: RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(30.0)),
            onPressed: () {
              // widget.auth.changeEmail("abc@gmail.com");
              _changeEmail();
            },
            minWidth: MediaQuery.of(context).size.width,
            padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
            color: Colors.blueAccent,
            textColor: Colors.white,
            child: Text(
              "Change Email",
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  void _changeEmail() {
    if (_email != null && _email.isNotEmpty) {
      try {
        print("============>" + _email);
        widget.auth.changeEmail(_email);
      } catch (e) {
        print("============>" + e);
        setState(() {
          _isLoading = false;
          if (_isIos) {
            _errorMessage = e.details;
          } else
            _errorMessage = e.message;
        });
      }
    } else {
      print("email feild empty");
    }
  }

  void _changePassword() {
    if (_password != null && _password.isNotEmpty) {
      print("============>" + _password);
      widget.auth.changePassword(_password);
    } else {
      print("password feild empty");
    }
  }

  void _removeUser() {
    widget.auth.deleteUser();
  }

  void _sendResetPasswordMail() {
    if (_resetPasswordEmail != null && _resetPasswordEmail.isNotEmpty) {
      print("============>" + _resetPasswordEmail);
      widget.auth.sendPasswordResetMail(_resetPasswordEmail);
    } else {
      print("password feild empty");
    }
  }

  _showChangePasswordContainer() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30.0),
        color: Colors.brown
      ),
      padding: EdgeInsets.fromLTRB(10, 20, 10, 20),
      child: Column(
        children: <Widget>[
          new TextFormField(
            controller: _passwordFilter,
            decoration: new InputDecoration(
              contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
              hintText: "Enter New Password",
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(22.0)),
            ),
          ),
          new MaterialButton(
            shape: RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(30.0)),
            onPressed: () {
              _changePassword();
            },
            minWidth: MediaQuery.of(context).size.width,
            padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
            color: Colors.blueAccent,
            textColor: Colors.white,
            child: Text(
              "Change Password",
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  _showSentResetPasswordEmailContainer() {
    return Column(
      children: <Widget>[
        new Container(
          child: new TextFormField(
            controller: _resetPasswordEmailFilter,
            decoration: new InputDecoration(
              contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
              hintText: "Enter Email",
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(22.0)),
            ),
          ),
        ),
        new MaterialButton(
          shape: RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(30.0)),
          onPressed: () {
            _sendResetPasswordMail();
          },
          minWidth: MediaQuery.of(context).size.width,
          padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          color: Colors.blueAccent,
          textColor: Colors.white,
          child: Text(
            "Send Password Reset Mail",
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  _removeUserContainer() {
    return new MaterialButton(
      shape:
          RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
      onPressed: () {
        _removeUser();
      },
      minWidth: MediaQuery.of(context).size.width,
      padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
      color: Colors.red,
      textColor: Colors.white,
      child: Text(
        "Remove User",
        textAlign: TextAlign.center,
      ),
    );
  }
}
