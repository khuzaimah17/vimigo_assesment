import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class Task {
  String title;
  String description;
  double progress;
  String assignee;
  String period;
  String urgency;

  Task(this.title, this.description, this.progress, this.assignee, this.period,
      this.urgency);
}

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [
    Task('Task 1', 'Description of task 1', 0.15, 'Alice',
        '01.07.2023 - 31.07.2023', 'High'),
    Task('Task 2', 'Description of task 2', 0.3, 'Bob',
        '02.07.2023 - 15.07.2023', 'Medium'),
    Task('Task 3', 'Description of task 3', 0.45, 'Charlie',
        '03.07.2023 - 20.07.2023', 'Low'),
    Task('Task 4', 'Description of task 4', 0.6, 'David',
        '04.07.2023 - 25.07.2023', 'High'),
    Task('Task 5', 'Description of task 5', 0.75, 'Eve',
        '05.07.2023 - 30.07.2023', 'Medium'),
    Task('Task 6', 'Description of task 6', 0.9, 'Frank',
        '06.07.2023 - 10.07.2023', 'Low'),
    Task('Task 7', 'Description of task 7', 0.1, 'Grace',
        '07.07.2023 - 12.07.2023', 'High'),
    Task('Task 8', 'Description of task 8', 0.25, 'Hank',
        '08.07.2023 - 18.07.2023', 'Medium'),
    Task('Task 9', 'Description of task 9', 0.35, 'Ivy',
        '09.07.2023 - 19.07.2023', 'Low'),
    Task('Task 10', 'Description of task 10', 0.5, 'Jack',
        '10.07.2023 - 20.07.2023', 'High'),
    Task('Task 11', 'Description of task 11', 0.65, 'Kate',
        '11.07.2023 - 21.07.2023', 'Medium'),
    Task('Task 12', 'Description of task 12', 0.8, 'Leo',
        '12.07.2023 - 22.07.2023', 'Low'),
    Task('Task 13', 'Description of task 13', 0.95, 'Mia',
        '13.07.2023 - 23.07.2023', 'High'),
    Task('Task 14', 'Description of task 14', 0.2, 'Nick',
        '14.07.2023 - 24.07.2023', 'Medium'),
    Task('Task 15', 'Description of task 15', 0.4, 'Olivia',
        '15.07.2023 - 25.07.2023', 'Low')
  ];

  List<Task> get tasks => _tasks;

  void updateTask(int index, Task task) {
    _tasks[index] = task;
    notifyListeners();
  }

  void addTask(Task task) {
    _tasks.add(task);
    notifyListeners();
  }

  void deleteTask(int index) {
    _tasks.removeAt(index);
    notifyListeners();
  }

  void duplicateTask(int index) {
    if (index >= 0 && index < _tasks.length) {
      final originalTask = _tasks[index];
      final duplicatedTask = Task(
        originalTask.title + ' (Copy)',
        originalTask.description,
        originalTask.progress,
        originalTask.assignee,
        originalTask.period,
        originalTask.urgency,
      );
      _tasks.insert(index + 1, duplicatedTask);
      notifyListeners();
    }
  }

  void sortTasksBy(String field, bool ascending) {
    switch (field) {
      case 'Title':
        _tasks.sort((a, b) => ascending
            ? a.title.compareTo(b.title)
            : b.title.compareTo(a.title));
        break;
      case 'Description':
        _tasks.sort((a, b) => ascending
            ? a.description.compareTo(b.description)
            : b.description.compareTo(a.description));
        break;
      case 'Progress':
        _tasks.sort((a, b) => ascending
            ? a.progress.compareTo(b.progress)
            : b.progress.compareTo(a.progress));
        break;
      case 'Assignee':
        _tasks.sort((a, b) => ascending
            ? a.assignee.compareTo(b.assignee)
            : b.assignee.compareTo(a.assignee));
        break;
      case 'Period':
        _tasks.sort((a, b) => ascending
            ? a.period.compareTo(b.period)
            : b.period.compareTo(a.period));
        break;
      case 'Urgency':
        _tasks.sort((a, b) => ascending
            ? a.urgency.compareTo(b.urgency)
            : b.urgency.compareTo(a.urgency));
        break;
    }
    notifyListeners();
  }

  void filterTasksBy(String field, String query) {
    _tasks = _tasks.where((task) {
      switch (field) {
        case 'Title':
          return task.title.toLowerCase().contains(query.toLowerCase());
        case 'Description':
          return task.description.toLowerCase().contains(query.toLowerCase());
        case 'Assignee':
          return task.assignee.toLowerCase().contains(query.toLowerCase());
        case 'Urgency':
          return task.urgency.toLowerCase().contains(query.toLowerCase());
        default:
          return true;
      }
    }).toList();
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TaskProvider(),
      child: MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: Text('Task List'),
          ),
          body: TaskTable(),
        ),
      ),
    );
  }
}

class TaskTable extends StatefulWidget {
  @override
  _TaskTableState createState() => _TaskTableState();
}

class _TaskTableState extends State<TaskTable> {
  late PageController _pageController;
  int _currentPage = 0;
  String _searchQuery = '';
  bool _ascending = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final tasks = taskProvider.tasks;
    int pageCount = (tasks.length / 15).ceil();

    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemCount: pageCount,
            itemBuilder: (context, pageIndex) {
              final start = pageIndex * 15;
              final end = (pageIndex + 1) * 15;
              final pageTasks =
                  tasks.sublist(start, end > tasks.length ? tasks.length : end);

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: DataTable(
                    columnSpacing: 16,
                    columns: _buildColumns(taskProvider),
                    rows: List.generate(pageTasks.length, (index) {
                      final task = pageTasks[index];
                      final taskIndex = start + index;

                      return DataRow(
                        cells: [
                          DataCell(Text(task.title),
                              onTap: () => _editTask(
                                  context, taskProvider, taskIndex, 'Title')),
                          DataCell(Text(task.description),
                              onTap: () => _editTask(context, taskProvider,
                                  taskIndex, 'Description')),
                          DataCell(
                            Stack(
                              children: [
                                LinearProgressIndicator(
                                  value: task.progress,
                                  backgroundColor: Colors.grey,
                                  valueColor:
                                      AlwaysStoppedAnimation(Colors.blue),
                                ),
                                Center(
                                    child: Text(
                                        '${(task.progress * 100).toInt()}%')),
                              ],
                            ),
                            onTap: () => _editTask(
                                context, taskProvider, taskIndex, 'Progress'),
                          ),
                          DataCell(
                            GestureDetector(
                              onTap: () => _editAssignee(
                                  context, taskProvider, taskIndex),
                              child: Tooltip(
                                message: task.assignee,
                                child: CircleAvatar(
                                  child: Text(task.assignee.substring(0, 1)),
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            GestureDetector(
                              onTap: () =>
                                  _editPeriod(context, taskProvider, taskIndex),
                              child: Text(task.period),
                            ),
                          ),
                          DataCell(
                            GestureDetector(
                              onTap: () => _editUrgency(
                                  context, taskProvider, taskIndex),
                              child: Text(task.urgency),
                            ),
                          ),
                          DataCell(
                            PopupMenuButton(
                              onSelected: (value) {
                                if (value == 'duplicate') {
                                  taskProvider.duplicateTask(taskIndex);
                                } else if (value == 'delete') {
                                  taskProvider.deleteTask(taskIndex);
                                }
                              },
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 'duplicate',
                                  child: Text('Duplicate'),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Text('Delete'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              );
            },
          ),
        ),
        Container(
          padding: EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () {
                  _addTask(context, taskProvider);
                },
                child: Text('Add Task'),
              ),
              IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  if (_currentPage > 0) {
                    _pageController.previousPage(
                      duration: Duration(milliseconds: 500),
                      curve: Curves.ease,
                    );
                  }
                },
              ),
              Text(
                  'Page ${_currentPage + 1} of ${pageCount > 0 ? pageCount : 1}'),
              IconButton(
                icon: Icon(Icons.arrow_forward),
                onPressed: () {
                  if (_currentPage < pageCount - 1) {
                    _pageController.nextPage(
                      duration: Duration(milliseconds: 500),
                      curve: Curves.ease,
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<DataColumn> _buildColumns(TaskProvider taskProvider) {
    return [
      _buildColumn('Title', taskProvider),
      _buildColumn('Description', taskProvider),
      _buildColumn('Progress', taskProvider),
      _buildColumn('Assignee', taskProvider),
      _buildColumn('Period', taskProvider),
      _buildColumn('Urgency', taskProvider),
      DataColumn(label: Text('Actions')),
    ];
  }

  DataColumn _buildColumn(String columnName, TaskProvider taskProvider) {
    return DataColumn(
      label: Row(
        children: [
          Text(columnName),
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(columnName, taskProvider),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog(String field, TaskProvider taskProvider) {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController searchController = TextEditingController();

        return AlertDialog(
          title: Text('Filter $field'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: searchController,
                decoration: InputDecoration(labelText: 'Search $field'),
              ),
              ListTile(
                title: Text('Sort A-Z'),
                onTap: () {
                  taskProvider.sortTasksBy(field, true);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: Text('Sort Z-A'),
                onTap: () {
                  taskProvider.sortTasksBy(field, false);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                taskProvider.filterTasksBy(field, searchController.text);
                Navigator.of(context).pop();
              },
              child: Text('Search'),
            ),
          ],
        );
      },
    );
  }

  void _addTask(BuildContext context, TaskProvider taskProvider) {
    final task = Task('', '', 0, '', '', '');

    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController titleController = TextEditingController();
        final TextEditingController descriptionController =
            TextEditingController();
        final TextEditingController progressController =
            TextEditingController();
        final TextEditingController assigneeController =
            TextEditingController();
        DateTimeRange? period;
        String urgency = 'Low';

        return AlertDialog(
          title: Text('Add Task'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(labelText: 'Title'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(labelText: 'Description'),
                ),
                TextField(
                  controller: progressController,
                  decoration: InputDecoration(labelText: 'Progress (1-100)'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    TextInputFormatter.withFunction((oldValue, newValue) {
                      if (newValue.text.isNotEmpty) {
                        final progress = int.parse(newValue.text);
                        if (progress < 1 || progress > 100) {
                          return oldValue;
                        }
                      }
                      return newValue;
                    }),
                  ],
                ),
                TextField(
                  controller: assigneeController,
                  decoration: InputDecoration(labelText: 'Assignee'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    period = await showDateRangePicker(
                      context: context,
                      initialEntryMode: DatePickerEntryMode.input,
                      firstDate: DateTime(2022),
                      lastDate: DateTime(2024),
                    );
                  },
                  child: Text('Select Period'),
                ),
                period != null
                    ? Text(
                        '${DateFormat('dd.MM.yyyy').format(period!.start)} - ${DateFormat('dd.MM.yyyy').format(period!.end)}')
                    : Text('No period selected'),
                DropdownButton<String>(
                  value: urgency,
                  onChanged: (String? newValue) {
                    urgency = newValue!;
                  },
                  items: <String>['Low', 'Medium', 'High']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final progress =
                    double.tryParse(progressController.text) ?? 0 / 100;
                final newTask = Task(
                  titleController.text,
                  descriptionController.text,
                  progress,
                  assigneeController.text,
                  period != null
                      ? '${DateFormat('dd.MM.yyyy').format(period!.start)} - ${DateFormat('dd.MM.yyyy').format(period!.end)}'
                      : '',
                  urgency,
                );
                taskProvider.addTask(newTask);
                Navigator.of(context).pop();
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _editTask(BuildContext context, TaskProvider taskProvider, int index,
      String field) {
    final task = taskProvider.tasks[index];
    final TextEditingController controller = TextEditingController();

    switch (field) {
      case 'Title':
        controller.text = task.title;
        break;
      case 'Description':
        controller.text = task.description;
        break;
      case 'Progress':
        controller.text = (task.progress * 100).toInt().toString();
        break;
      default:
        return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit $field'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(labelText: field),
            keyboardType:
                field == 'Progress' ? TextInputType.number : TextInputType.text,
            inputFormatters: field == 'Progress'
                ? [
                    FilteringTextInputFormatter.digitsOnly,
                    TextInputFormatter.withFunction((oldValue, newValue) {
                      if (newValue.text.isNotEmpty) {
                        final progress = int.parse(newValue.text);
                        if (progress < 1 || progress > 100) {
                          return oldValue;
                        }
                      }
                      return newValue;
                    }),
                  ]
                : [],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                switch (field) {
                  case 'Title':
                    task.title = controller.text;
                    break;
                  case 'Description':
                    task.description = controller.text;
                    break;
                  case 'Progress':
                    task.progress = double.parse(controller.text) / 100;
                    break;
                }
                taskProvider.updateTask(index, task);
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _editAssignee(
      BuildContext context, TaskProvider taskProvider, int index) {
    final task = taskProvider.tasks[index];
    final TextEditingController controller = TextEditingController();
    controller.text = task.assignee;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Assignee'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(labelText: 'Assignee'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                task.assignee = controller.text;
                taskProvider.updateTask(index, task);
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _editPeriod(
      BuildContext context, TaskProvider taskProvider, int index) async {
    final task = taskProvider.tasks[index];
    DateTimeRange? period = await showDateRangePicker(
      context: context,
      initialEntryMode: DatePickerEntryMode.input,
      firstDate: DateTime(2022),
      lastDate: DateTime(2024),
    );

    if (period != null) {
      task.period =
          '${DateFormat('dd.MM.yyyy').format(period.start)} - ${DateFormat('dd.MM.yyyy').format(period.end)}';
      taskProvider.updateTask(index, task);
    }
  }

  void _editUrgency(
      BuildContext context, TaskProvider taskProvider, int index) {
    final task = taskProvider.tasks[index];
    String urgency = task.urgency;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Urgency'),
          content: DropdownButton<String>(
            value: urgency,
            onChanged: (String? newValue) {
              urgency = newValue!;
            },
            items: <String>['Low', 'Medium', 'High']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                task.urgency = urgency;
                taskProvider.updateTask(index, task);
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
