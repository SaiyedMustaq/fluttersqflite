import 'dart:math';

import 'package:flutter/material.dart';

import 'SQLHelper.dart';
import 'personModel.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _SqflitePageState createState() => _SqflitePageState();
}

class _SqflitePageState extends State<HomePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final dbHelper = DatabaseHelper.instance;
  List<SqFlitePersonMode> listPersonSqflite = [];

  final GlobalKey<AnimatedListState> listKey = GlobalKey<AnimatedListState>();
  bool isLoading = false;

  @override
  void initState() {
    //addSuplie();
    getAllData();
    super.initState();
  }

  Future addSuplie() async {
    Map<String, dynamic> row = {
      DatabaseHelper.columnName: 'Mustaq',
      DatabaseHelper.columnAge: '25'
    };
    final id = await dbHelper.insert(row);

    final allRow = await dbHelper.getAllSupplier();
    allRow.forEach(
      (element) {
        print('ALL ROW - - - > ${element['name']}');
      },
    );
  }

  Future getAllData() async {
    isLoading = true;
    final allRows = await dbHelper.getAll();

    allRows.forEach(
      (element) {
        print('${element}');
        listPersonSqflite.add(SqFlitePersonMode(
            age: int.parse('${element['age']}'),
            id: element['_id'],
            name: '${element['name']}'));
      },
    );
    setState(() {
      isLoading = false;
    });
  }

  void _showForm(int? id) async {
    if (id != null) {
      final objectSingle =
          listPersonSqflite.firstWhere((element) => element.id == id);
      _titleController.text = objectSingle.name.toString();
      _ageController.text = objectSingle.age.toString();
    }

    showModalBottomSheet(
        context: context,
        elevation: 5,
        isScrollControlled: true,
        builder: (_) => Container(
              padding: EdgeInsets.only(
                top: 15,
                left: 15,
                right: 15,
                // this will prevent the soft keyboard from covering the text fields
                bottom: MediaQuery.of(context).viewInsets.bottom + 120,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextField(
                    controller: _titleController,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .copyWith(color: Colors.black),
                    decoration: InputDecoration(
                        hintText: 'Title',
                        hintStyle: Theme.of(context)
                            .textTheme
                            .caption!
                            .copyWith(color: Colors.grey)),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: _ageController,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .copyWith(color: Colors.black),
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Age',
                      hintStyle: Theme.of(context)
                          .textTheme
                          .caption!
                          .copyWith(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (id == null) {
                        Map<String, dynamic> row = {
                          DatabaseHelper.columnName: _titleController.text,
                          DatabaseHelper.columnAge: _ageController.text
                        };
                        final id = await dbHelper.insert(row);
                        print('inserted row id: $id');
                      } else {
                        Map<String, dynamic> row = {
                          DatabaseHelper.columnId: id,
                          DatabaseHelper.columnName: _titleController.text,
                          DatabaseHelper.columnAge: _ageController.text
                        };
                        final rowsAffected = await dbHelper.update(row);

                        print('Update row: $rowsAffected');
                      }

                      Navigator.of(context).pop();

                      setState(() {
                        isLoading = true;
                        listPersonSqflite.clear();
                        _titleController.clear();
                        _ageController.clear();
                        getAllData();
                      });
                    },
                    child: Text(id == null ? 'Create New' : 'Update'),
                  )
                ],
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("SQ-flite"),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.save),
          ),
        ],
      ),
      body: isLoading
          ? ListView()
          : ListView.builder(
              shrinkWrap: true,
              key: listKey,
              itemCount: listPersonSqflite.length,
              itemBuilder: (context, index) {
                return Card(
                  color: Colors
                      .primaries[Random().nextInt(Colors.primaries.length)],
                  margin: const EdgeInsets.all(15),
                  child: ListTile(
                      title: Text("${listPersonSqflite[index].name}"),
                      subtitle: Text("${listPersonSqflite[index].age}"),
                      trailing: SizedBox(
                        width: 100,
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () =>
                                  _showForm(listPersonSqflite[index].id),
                            ),
                            IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  dbHelper.delete(listPersonSqflite[index].id!);
                                  setState(() {
                                    listPersonSqflite.clear();
                                    getAllData();
                                  });
                                }),
                          ],
                        ),
                      )),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showForm(null),
      ),
    );
  }
}
