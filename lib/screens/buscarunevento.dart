import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:applogin/config.dart';
import 'package:applogin/models/event.dart';
import 'package:applogin/screens/eventodetalles.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class BuscadorUnEventoScreen extends StatefulWidget {
  const BuscadorUnEventoScreen({Key? key});

  @override
  State<BuscadorUnEventoScreen> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<BuscadorUnEventoScreen> {
  TextEditingController searchController = TextEditingController();
  String searchText = "";
  Event? foundEvent;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.search),
        backgroundColor: Colors.orange,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: searchEvent,
              style: ElevatedButton.styleFrom(
                primary: Colors.orange,
              ),
              child: Text(
                'Search',
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              TypeAheadFormField(
                textFieldConfiguration: TextFieldConfiguration(
                  controller: searchController,
                  onChanged: (value) {
                    setState(() {
                      searchText = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.enterNameHint,
                  ),
                ),
                suggestionsCallback: (pattern) async {
                  final response = await http.get(Uri.parse('$uri/events'));
                  if (response.statusCode == 200) {
                    final List<dynamic> data = json.decode(response.body);
                    return data
                        .map((item) => Event.fromJson(item))
                        .where((event) =>
                            event.eventName
                                .toLowerCase()
                                .contains(pattern.toLowerCase()))
                        .toList();
                  } else {
                    throw Exception('Error al cargar eventos');
                  }
                },
                itemBuilder: (context, suggestion) {
                  return ListTile(
                    title: Text((suggestion as Event).eventName),
                  );
                },
                onSuggestionSelected: (suggestion) {
                  setState(() {
                    foundEvent = suggestion as Event?;
                    searchText = (suggestion as Event).eventName;
                  });

                  // Establece el texto seleccionado en el controlador del campo de búsqueda
                  searchController.text = (suggestion as Event).eventName;
                },
              ),
              SizedBox(height: 20),
              if (foundEvent != null)
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              EventoDetailScreen(event: foundEvent!)),
                    );
                  },
                  child: Card(
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    color: Colors.grey[200],
                    child: ListTile(
                      title: Text('${AppLocalizations.of(context)!.eventName}: ${foundEvent!.eventName}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${AppLocalizations.of(context)!.coordinates}: ${foundEvent!.coordinates}'),
                          Text('${AppLocalizations.of(context)!.date}: ${foundEvent!.date}'),
                          Text('${AppLocalizations.of(context)!.description}: ${foundEvent!.description}'),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> searchEvent() async {
    try {
      final response = await http.get(Uri.parse('$uri/events'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        final List<Event> matchingEvents = data
            .map((item) => Event.fromJson(item))
            .where((event) =>
                event.eventName.toLowerCase() == searchText.toLowerCase())
            .toList();

        if (matchingEvents.isNotEmpty) {
          setState(() {
            foundEvent = matchingEvents.first;
          });
        } else {
          setState(() {
            foundEvent = null;
          });
          print('No se encontraron eventos con el eventName especificado.');
        }
      } else {
        print(
            'Error al cargar eventos. Código de estado: ${response.statusCode}');
      }
    } catch (error) {
      print('Error de red al cargar eventos: $error');
    }
  }
}
