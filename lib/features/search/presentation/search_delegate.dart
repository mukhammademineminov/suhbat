import 'package:flutter/material.dart';

class RoomSearchDelegate extends SearchDelegate<String> {

  final List<String> searchTerms;

  RoomSearchDelegate(this.searchTerms);

  @override
  List<Widget> buildActions(BuildContext context) {
   return [
    IconButton(
      icon: const Icon(Icons.clear),
      onPressed: () {
        query = '';
      },
    ),
   ];
  }
  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          close(context, '');
        },
      );
  }
  @override
Widget buildResults(BuildContext context) {
  final results = searchTerms.where((term) {
    return term.toLowerCase().contains(query.toLowerCase());
  }).toList();

  return ListView.builder(
    itemCount: results.length,
    itemBuilder: (context, index) {
      return ListTile(
        title: Text(results[index]),
      );
    },
  );
}
  

}