import 'package:flutter/material.dart';
import 'package:frontend/Constants/api.dart';
import 'package:frontend/Models/Todo.dart';
import 'package:frontend/widgets/Todo_container.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend/widgets/app_bar.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:frontend/Constants/colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int done = 0;

  List<Todo> myTodos = [];
  bool isLoading = true;
  void _showModel() {
    String title = "";
    String desc = "";
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: MediaQuery.of(context).size.height / 2,
            child: Column(children: [
              Text(
                "Add your Todo",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              TextField(
                decoration: InputDecoration(
                    border: OutlineInputBorder(), labelText: "title"),
                onSubmitted: (value) {
                  setState(() {
                    title = value;
                  });
                },
              ),
              SizedBox(
                height: 10,
              ),
              TextField(
                decoration: InputDecoration(
                    border: OutlineInputBorder(), labelText: "Description"),
                onSubmitted: (value) {
                  setState(() {
                    desc = value;
                  });
                },
              ),
              ElevatedButton(
                  onPressed: () => _postData(title: title, desc: desc),
                  child: Text("add"))
            ]),
          );
        });
  }

  void fetchData() async {
    try {
      http.Response response = await http.get(Uri.parse(api));
      var data = json.decode(response.body);
      data.forEach((todo) {
        Todo t = Todo(
            id: todo["id"],
            title: todo["title"],
            desc: todo["desc"],
            isDone: todo["isDone"],
            date: todo["date"]);
        if (todo['isDone']) {
          done = done + 1;
        }
        myTodos.add(t);
      });
      // var aa = response.body;
      // aa = json.decode(aa);
      // print(aa);
      // ignore: avoid_print
      print(myTodos.length);
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print("Error is $e");
    }
  }

  void _postData({String title = "", String desc = ""}) async {
    try {
      http.Response response = await http.post(
        Uri.parse(api),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'title': title,
          'desc': desc,
          'isDone': false,
        }),
      );
      if (response.statusCode == 201) {
        setState(() {
          myTodos = [];
        });
        fetchData();
      } else {
        print("Something went wrong.......error.....");
      }
    } catch (e) {
      print(e);
    }
  }

  void delete_todo(String id) async {
    try {
      http.Response response = await http.delete(Uri.parse(api + "/" + id));
      setState(() {
        myTodos = [];
      });
      fetchData();
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    fetchData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: bg,
        appBar: customAppBar(),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              PieChart(dataMap: {
                "Done": done.toDouble(),
                "incomplete": (myTodos.length - done).toDouble(),
              }),
              isLoading
                  ? const CircularProgressIndicator()
                  : Column(
                      children: myTodos.map((e) {
                        return TodoContainer(
                            id: e.id,
                            onPress: () => delete_todo(e.id.toString()),
                            title: e.title,
                            desc: e.desc,
                            isDone: e.isDone);
                      }).toList(),
                    )
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: () {
              _showModel();
            }));
  }
}
