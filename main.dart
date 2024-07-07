import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

const String baseUrl = 'http://192.168.187.78:5000/tasks';

class Task {
  final String name;
  final int dayOrder;
  final String ch1;
  final String ch2;
  final String ch3;
  final String ch4;
  final String ch5;
  final int id;

  Task({
    required this.name,
    required this.dayOrder,
    required this.ch1,
    required this.ch2,
    required this.ch3,
    required this.ch4,
    required this.ch5,
    required this.id,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'dayorder': dayOrder,
      'ch1': ch1,
      'ch2': ch2,
      'ch3': ch3,
      'ch4': ch4,
      'ch5': ch5,
      'id': id,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      name: json['name'],
      dayOrder: json['dayorder'],
      ch1: json['ch1'],
      ch2: json['ch2'],
      ch3: json['ch3'],
      ch4: json['ch4'],
      ch5: json['ch5'],
      id: json['id'],
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rups Time Table App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Task> allData = [];
  String selectedName = '';
  int selectedDayOrder = 1;
  String selectedClassHour = 'ch1';
  String responseMessage = '';
  String ch1 = '';
  String ch2 = '';
  String ch3 = '';
  String ch4 = '';
  String ch5 = '';

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final List<dynamic> tasksJson = json.decode(response.body)['tasks'];
      setState(() {
        allData = tasksJson.map((task) => Task.fromJson(task)).toList();
      });
    } else {
      throw Exception('Failed to load tasks');
    }
  }

  Future<String> createTask(Task task) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(task),
    );
    fetchData(); // Refresh tasks after creating
    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = json.decode(response.body);
      String message = responseData['message'];
      return message;
    } else {
      if (kDebugMode) {
        print('Failed to create data');
      }
      return 'Failed to create data';
    }
  }

  Future<String> deleteTask(int taskId) async {
    final response = await http.delete(Uri.parse('$baseUrl/$taskId'));
    if (response.statusCode == 200) {
      if (kDebugMode) {
        print('Data deleted successfully');
      }
      fetchData(); // Refresh tasks after deletion
      Map<String, dynamic> responseData = json.decode(response.body);
      return responseData['message'];
    } else if (response.statusCode == 404) {
      if (kDebugMode) {
        print('Failed to delete data: Data not found');
      }
      Map<String, dynamic> responseData = json.decode(response.body);
      return responseData['message'];
    } else {
      if (kDebugMode) {
        print('Failed to delete data');
      }
      return 'Failed to delete data';
    }
  }

  Future<String> updateTask(int taskId, Task task) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$taskId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(task),
    );
    fetchData(); // Refresh tasks after updating
    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = json.decode(response.body);
      String message = responseData['message'];
      return message;
    } else if (response.statusCode == 404) {
      try {
        Map<String, dynamic> responseData = json.decode(response.body);
        String message = responseData['message'];
        return message;
      } catch (e) {
        if (kDebugMode) {
          print('Data not found');
        }
        return 'Data not found';
      }
    } else {
      if (kDebugMode) {
        print('Failed to update Data');
      }
      return 'Failed to update Data';
    }
  }

  @override
  Widget build(BuildContext context) {
    Set<String> uniqueNames = allData.map((task) => task.name).toSet();
    List<String> uniqueNamesList = uniqueNames.toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rups Time Table App'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: uniqueNamesList.isNotEmpty
                  ? () async {
                fetchData();
                Set<String> uniqueNames =
                allData.map((task) => task.name).toSet();
                List<String> uniqueNamesList = uniqueNames.toList();
                String selectedName = uniqueNamesList.isNotEmpty
                    ? uniqueNamesList.first
                    : '';
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return StatefulBuilder(
                      builder:
                          (BuildContext context, StateSetter setState) {
                        return SingleChildScrollView(
                          child: Container(
                            padding: const EdgeInsets.all(16.0),
                            constraints: BoxConstraints(
                              maxHeight:
                              MediaQuery.of(context).size.height *
                                  0.8,
                            ),
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.stretch,
                              children: [
                                DropdownButtonFormField<String>(
                                  value: selectedName,
                                  items: uniqueNamesList.map((name) {
                                    return DropdownMenuItem<String>(
                                      value: name,
                                      child: Text(name),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      selectedName = value!;
                                    });
                                  },
                                  decoration: const InputDecoration(
                                    labelText: 'Select Teacher',
                                  ),
                                ),
                                DropdownButtonFormField<int>(
                                  value: selectedDayOrder,
                                  items:
                                  [1, 2, 3, 4, 5, 6].map((dayOrder) {
                                    return DropdownMenuItem<int>(
                                      value: dayOrder,
                                      child: Text(dayOrder.toString()),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      selectedDayOrder = value!;
                                    });
                                  },
                                  decoration: const InputDecoration(
                                    labelText: 'Select Day Order',
                                  ),
                                ),
                                DropdownButtonFormField<String>(
                                  value: selectedClassHour,
                                  items: [
                                    'ch1',
                                    'ch2',
                                    'ch3',
                                    'ch4',
                                    'ch5'
                                  ].map((classHour) {
                                    return DropdownMenuItem<String>(
                                      value: classHour,
                                      child: Text(classHour),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      selectedClassHour = value!;
                                    });
                                  },
                                  decoration: const InputDecoration(
                                    labelText: 'Select Class Hour',
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    // Filter the tasks based on user selection
                                    Task? selectedTask;
                                    try {
                                      selectedTask = allData.firstWhere(
                                            (task) =>
                                        task.name == selectedName &&
                                            task.dayOrder ==
                                                selectedDayOrder &&
                                            (selectedClassHour == 'ch1'
                                                ? task.ch1 != ''
                                                : selectedClassHour ==
                                                'ch2'
                                                ? task.ch2 != ''
                                                : selectedClassHour ==
                                                'ch3'
                                                ? task.ch3 != ''
                                                : selectedClassHour ==
                                                'ch4'
                                                ? task.ch4 !=
                                                ''
                                                : selectedClassHour ==
                                                'ch5'
                                                ? task.ch5 !=
                                                ''
                                                : false),
                                      );
                                    } catch (e) {
                                      selectedTask = null;
                                    }

                                    // Display the result
                                    if (selectedTask != null) {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text('Details'),
                                            content: Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment
                                                  .start,
                                              mainAxisSize:
                                              MainAxisSize.min,
                                              children: [
                                                if (selectedClassHour ==
                                                    'ch1')
                                                  Text(
                                                      'Class Hour 1: ${selectedTask?.ch1 ?? 'N/A'}'),
                                                if (selectedClassHour ==
                                                    'ch2')
                                                  Text(
                                                      'Class Hour 2: ${selectedTask?.ch2 ?? 'N/A'}'),
                                                if (selectedClassHour ==
                                                    'ch3')
                                                  Text(
                                                      'Class Hour 3: ${selectedTask?.ch3 ?? 'N/A'}'),
                                                if (selectedClassHour ==
                                                    'ch4')
                                                  Text(
                                                      'Class Hour 4: ${selectedTask?.ch4 ?? 'N/A'}'),
                                                if (selectedClassHour ==
                                                    'ch5')
                                                  Text(
                                                      'Class Hour 5: ${selectedTask?.ch5 ?? 'N/A'}'),
                                              ],
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .pop();
                                                },
                                                child:
                                                const Text('Close'),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    } else {
                                      // No task found
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text(
                                                'No Data Found'),
                                            content: const Text(
                                                'No Data found with the selected criteria.'),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .pop();
                                                },
                                                child:
                                                const Text('Close'),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    }
                                  },
                                  child: const Text('Submit'),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              }
                  : null,
              child: const Text('Screen 1 - Fetch and Display Data'),
            ),
            ElevatedButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState) {
                        return SingleChildScrollView(
                          child: Container(
                            padding: const EdgeInsets.all(16.0),
                            constraints: BoxConstraints(
                              maxHeight:
                              MediaQuery.of(context).size.height * 0.8,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                TextField(
                                  decoration:
                                  const InputDecoration(labelText: 'Name'),
                                  onChanged: (value) {
                                    selectedName = value;
                                  },
                                ),
                                DropdownButtonFormField<int>(
                                  value: selectedDayOrder,
                                  items: [1, 2, 3, 4, 5, 6].map((dayOrder) {
                                    return DropdownMenuItem<int>(
                                      value: dayOrder,
                                      child: Text(dayOrder.toString()),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      selectedDayOrder = value!;
                                    });
                                  },
                                  decoration: const InputDecoration(
                                    labelText: 'Select Day Order',
                                  ),
                                ),
                                TextField(
                                  decoration: const InputDecoration(
                                      labelText: 'Enter Class Hour 1'),
                                  onChanged: (value) {
                                    setState(() {
                                      ch1 = value;
                                    });
                                  },
                                ),
                                TextField(
                                  decoration: const InputDecoration(
                                      labelText: 'Enter Class Hour 2'),
                                  onChanged: (value) {
                                    setState(() {
                                      ch2 = value;
                                    });
                                  },
                                ),
                                TextField(
                                  decoration: const InputDecoration(
                                      labelText: 'Enter Class Hour 3'),
                                  onChanged: (value) {
                                    setState(() {
                                      ch3 = value;
                                    });
                                  },
                                ),
                                TextField(
                                  decoration: const InputDecoration(
                                      labelText: 'Enter Class Hour 4'),
                                  onChanged: (value) {
                                    setState(() {
                                      ch4 = value;
                                    });
                                  },
                                ),
                                TextField(
                                  decoration: const InputDecoration(
                                      labelText: 'Enter Class Hour 5'),
                                  onChanged: (value) {
                                    setState(() {
                                      ch5 = value;
                                    });
                                  },
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    Task newTask = Task(
                                      name: selectedName,
                                      deptId: 'CS',
                                      dayOrder: selectedDayOrder,
                                      ch1: ch1,
                                      ch2: ch2,
                                      ch3: ch3,
                                      ch4: ch4,
                                      ch5: ch5,
                                      id: 0,
                                    );
                                    // Call the createTask function and wait for the response
                                    String responseMessage =
                                    await createTask(newTask);

                                    // Show a popup with the response message
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Data Creation'),
                                          content: Text(responseMessage),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context)
                                                    .pop(); // Close the dialog
                                              },
                                              child: const Text('OK'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  child: const Text('Submit'),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
              child: const Text('Screen 2 - Create Data'),
            ),
            ElevatedButton(
              onPressed: () {
                fetchData();
                Set<String> uniqueNames =
                allData.map((task) => task.name).toSet();
                List<String> uniqueNamesList = uniqueNames.toList();
                String selectedName =
                uniqueNamesList.isNotEmpty ? uniqueNamesList.first : '';
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState) {
                        return SingleChildScrollView(
                          child: Container(
                            padding: const EdgeInsets.all(16.0),
                            constraints: BoxConstraints(
                              maxHeight:
                              MediaQuery.of(context).size.height * 0.8,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                DropdownButtonFormField<String>(
                                  value: selectedName,
                                  items: allData.map((task) {
                                    return DropdownMenuItem<String>(
                                      value: task.name,
                                      child: Text(task.name),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      selectedName = value!;
                                    });
                                  },
                                  decoration: const InputDecoration(
                                    labelText: 'Select Teacher',
                                  ),
                                ),
                                DropdownButtonFormField<int>(
                                  value: selectedDayOrder,
                                  items: [1, 2, 3, 4, 5, 6].map((dayOrder) {
                                    return DropdownMenuItem<int>(
                                      value: dayOrder,
                                      child: Text(dayOrder.toString()),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      selectedDayOrder = value!;
                                    });
                                  },
                                  decoration: const InputDecoration(
                                    labelText: 'Select Day Order',
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    Task? selectedTask;
                                    try {
                                      selectedTask = allData.firstWhere(
                                            (task) =>
                                        task.name == selectedName &&
                                            task.dayOrder == selectedDayOrder,
                                      );
                                    } catch (e) {
                                      selectedTask = null;
                                    }

                                    if (selectedTask != null) {
                                      String message =
                                      await deleteTask(selectedTask.id);

                                      // Close the modal bottom sheet
                                      Navigator.pop(context);

                                      // Show pop-up dialog with response message
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text("Delete Data"),
                                            content: Text(message),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(
                                                      context); // Close the dialog
                                                },
                                                child: const Text("OK"),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    } else {
                                      // Show pop-up dialog indicating data not found
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text("Data Not Found"),
                                            content: const Text(
                                                "Selected name and day order not found in data."),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(
                                                      context); // Close the dialog
                                                },
                                                child: const Text("OK"),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    }
                                  },
                                  child: const Text('Delete Data'),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
              child: const Text('Screen 3 - Delete Data'),
            ),
            ElevatedButton(
              onPressed: () async {
                fetchData();
                Set<String> uniqueNames =
                allData.map((task) => task.name).toSet();
                List<String> uniqueNamesList = uniqueNames.toList();
                String selectedName =
                uniqueNamesList.isNotEmpty ? uniqueNamesList.first : '';
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState) {
                        return SingleChildScrollView(
                          child: Container(
                            padding: const EdgeInsets.all(16.0),
                            constraints: BoxConstraints(
                              maxHeight:
                              MediaQuery.of(context).size.height * 0.8,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                DropdownButtonFormField<String>(
                                  value: selectedName,
                                  items: allData.map((task) {
                                    return DropdownMenuItem<String>(
                                      value: task.name,
                                      child: Text(task.name),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      selectedName = value!;
                                    });
                                  },
                                  decoration: const InputDecoration(
                                    labelText: 'Select Teacher',
                                  ),
                                ),
                                DropdownButtonFormField<int>(
                                  value: selectedDayOrder,
                                  items: [1, 2, 3, 4, 5, 6].map((dayOrder) {
                                    return DropdownMenuItem<int>(
                                      value: dayOrder,
                                      child: Text(dayOrder.toString()),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      selectedDayOrder = value!;
                                    });
                                  },
                                  decoration: const InputDecoration(
                                    labelText: 'Select Day Order',
                                  ),
                                ),
                                TextField(
                                  decoration: const InputDecoration(
                                      labelText: 'Enter Class Hour 1'),
                                  onChanged: (value) {
                                    setState(() {
                                      ch1 = value;
                                    });
                                  },
                                ),
                                TextField(
                                  decoration: const InputDecoration(
                                      labelText: 'Enter Class Hour 2'),
                                  onChanged: (value) {
                                    setState(() {
                                      ch2 = value;
                                    });
                                  },
                                ),
                                TextField(
                                  decoration: const InputDecoration(
                                      labelText: 'Enter Class Hour 3'),
                                  onChanged: (value) {
                                    setState(() {
                                      ch3 = value;
                                    });
                                  },
                                ),
                                TextField(
                                  decoration: const InputDecoration(
                                      labelText: 'Enter Class Hour 4'),
                                  onChanged: (value) {
                                    setState(() {
                                      ch4 = value;
                                    });
                                  },
                                ),
                                TextField(
                                  decoration: const InputDecoration(
                                      labelText: 'Enter Class Hour 5'),
                                  onChanged: (value) {
                                    setState(() {
                                      ch5 = value;
                                    });
                                  },
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    Task? selectedTask;
                                    try {
                                      selectedTask = allData.firstWhere(
                                            (task) =>
                                        task.name == selectedName &&
                                            task.dayOrder == selectedDayOrder,
                                      );
                                    } catch (e) {
                                      selectedTask = null;
                                    }

                                    if (selectedTask != null) {
                                      Task updatedTask = Task(
                                        name: selectedName,
                                        deptId:
                                        'CS', // Example value, replace with actual logic to get department ID
                                        dayOrder: selectedDayOrder,
                                        ch1: ch1,
                                        ch2: ch2,
                                        ch3: ch3,
                                        ch4: ch4,
                                        ch5: ch5,
                                        id: selectedTask.id,
                                      );

                                      // Perform update operation
                                      String message = await updateTask(
                                          selectedTask.id, updatedTask);

                                      // Close the modal bottom sheet
                                      Navigator.pop(context);

                                      // Show pop-up dialog with response message
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text("Update Task"),
                                            content: Text(message),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(
                                                      context); // Close the dialog
                                                },
                                                child: const Text("OK"),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    } else {
                                      // Show pop-up dialog indicating data not found
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text("Data Not Found"),
                                            content: const Text(
                                                "Selected name and day order not found in data, Please Add"),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(
                                                      context); // Close the dialog
                                                },
                                                child: const Text("OK"),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    }
                                  },
                                  child: const Text('Update Data'),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
              child: const Text('Screen 4 - Update Data'),
            ),
          ],
        ),
      ),
    );
  }
