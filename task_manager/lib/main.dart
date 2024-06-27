import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TareasScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class TareasScreen extends StatefulWidget {
  @override
  _TareasScreenState createState() => _TareasScreenState();
}

class _TareasScreenState extends State<TareasScreen> {
  final String apiUrl = "http://localhost:3000/api/tareas";

  Future<List<dynamic>> fetchTareas() async {
    var result = await http.get(Uri.parse(apiUrl));
    return json.decode(result.body);
  }

  bool intToBool(int value) {
    return value == 1;
  }

  Future<void> addTarea(String titulo, String descripcion, String fecha) async {
    await http.post(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'titulo': titulo,
        'descripcion': descripcion,
        'fecha': fecha,
        'completado': false
      }),
    );
    setState(() {});
  }

  Future<void> editTarea(int id, String titulo, String descripcion, String fecha, bool completado) async {
    await http.patch(
      Uri.parse('$apiUrl/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'titulo': titulo,
        'descripcion': descripcion,
        'fecha': fecha,
        'completado': completado
      }),
    );
    setState(() {});
  }

  Future<void> deleteTarea(int id) async {
    await http.delete(
      Uri.parse('$apiUrl/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lista de Tareas"),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _displayAddDialog(context),
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: fetchTareas(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              padding: EdgeInsets.all(8),
              itemCount: snapshot.data.length,
              itemBuilder: (BuildContext context, int index) {
                return Card(
                  child: ListTile(
                    title: Text(snapshot.data[index]['titulo']),
                    subtitle: Text(snapshot.data[index]['descripcion']),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Checkbox(
                          value: intToBool(snapshot.data[index]['completado']),
                          onChanged: (bool? value) {
                            editTarea(
                              snapshot.data[index]['id'],
                              snapshot.data[index]['titulo'],
                              snapshot.data[index]['descripcion'],
                              snapshot.data[index]['fecha'],
                              value!,
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () => _displayEditDialog(
                            context,
                            snapshot.data[index]['id'],
                            snapshot.data[index]['titulo'],
                            snapshot.data[index]['descripcion'],
                            snapshot.data[index]['fecha'],
                            intToBool(snapshot.data[index]['completado']),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => deleteTarea(snapshot.data[index]['id']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Future<void> _displayAddDialog(BuildContext context) async {
    final _formKey = GlobalKey<FormState>();
    String? titulo, descripcion, fecha;

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Agregar Tarea'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(labelText: 'Título'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese un título';
                    }
                    titulo = value;
                    return null;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Descripción'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese una descripción';
                    }
                    descripcion = value;
                    return null;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Fecha (YYYY-MM-DD)'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese una fecha';
                    }
                    fecha = value;
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Guardar'),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  addTarea(titulo!, descripcion!, fecha!);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _displayEditDialog(BuildContext context, int id, String titulo, String descripcion, String fecha, bool completado) async {
    final _formKey = GlobalKey<FormState>();
    String? newTitulo = titulo, newDescripcion = descripcion, newFecha = fecha;

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Editar Tarea'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  initialValue: titulo,
                  decoration: InputDecoration(labelText: 'Título'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese un título';
                    }
                    newTitulo = value;
                    return null;
                  },
                ),
                TextFormField(
                  initialValue: descripcion,
                  decoration: InputDecoration(labelText: 'Descripción'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese una descripción';
                    }
                    newDescripcion = value;
                    return null;
                  },
                ),
                TextFormField(
                  initialValue: fecha,
                  decoration: InputDecoration(labelText: 'Fecha (YYYY-MM-DD)'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese una fecha';
                    }
                    newFecha = value;
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Guardar'),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  editTarea(id, newTitulo!, newDescripcion!, newFecha!, completado);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }
}
