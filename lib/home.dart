import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final TextEditingController _name = TextEditingController();
  final TextEditingController _quantity = TextEditingController();

  List<Map<String, dynamic>> _items = [];

  final _shoppingBox = Hive.box('shopping_box');

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _refreshItems();
  }

  void _refreshItems() {
    final data = _shoppingBox.keys.map((key) {
      final item = _shoppingBox.get(key);
      return {"key": key,"name": item["name"], "quantity": item['quantity']};
    }).toList();

    setState(() {
      _items = data.reversed.toList();
    });
  }

  Future<void> _createItem(Map<String, dynamic> newItem) async {
    await _shoppingBox.add(newItem);
    _refreshItems();
  }

  Future<void> _updateItem(int itemKey, Map<String, dynamic> item) async {
    await _shoppingBox.put(itemKey, item);
    _refreshItems();
  }

  Future<void> _deleteItem(int itemKey) async {
    await _shoppingBox.delete(itemKey);
    _refreshItems();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("An Item has been deleted"))
    );
  }

  void _showForm(BuildContext context, int? itemKey) async {

    if(itemKey != null){
      final existItem = _items.firstWhere((element) => element['key'] == itemKey);
      _name.text = existItem['name'];
      _quantity.text = existItem['quantity'];
    }

    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (_) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 15,
            left: 15,
            right: 15
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                TextField(
                  controller: _name,
                  decoration: const InputDecoration(hintText: 'Name'),
                ),
                const SizedBox(
                  height: 10,
                ),
                TextField(
                  controller: _quantity,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(hintText: 'Quantity'),
                ),
                const SizedBox(
                  height: 10,
                ),
                ElevatedButton(
                    onPressed: () async {
                      if(itemKey == null) {
                        _createItem({
                          "name": _name.text,
                          "quantity": _quantity.text
                        });
                      }

                      if(itemKey != null){
                        _updateItem(itemKey, {
                          "name": _name.text.trim(),
                          "quantity": _quantity.text.trim()
                        });
                      }

                      _name.text = '';
                      _quantity.text = '';

                      Navigator.of(context).pop();
                    },
                    child: Text(
                      itemKey == null ? 'Create New' : 'Update'
                    )
                ),
                const SizedBox(
                  height: 15,
                ),
              ],
            ),
          ),
        )
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          "List Data"
        ),
      ),
      body: SafeArea(
        child: ListView.builder(
          itemCount: _items.length,
          itemBuilder: (BuildContext context, int index) {
            final currentItem = _items[index];
            return Card(
              color: Colors.orange.shade100,
              margin: EdgeInsets.all(10),
              elevation: 0,
              child: ListTile(
                title: Text(currentItem["name"]),
                subtitle: Text(currentItem["quantity"].toString()),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                        onPressed: () => _showForm(context, currentItem['key']),
                        icon: Icon(Icons.edit)
                    ),
                    IconButton(
                        onPressed: () => _deleteItem(currentItem['key']),
                        icon: Icon(Icons.delete)
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(context, null),
        child: const Icon(
          Icons.add
        ),
      ),
    );
  }
}
