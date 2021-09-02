import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/great_places.dart';

class PlacesListScreen extends StatefulWidget {
  @override
  _PlacesListScreenState createState() => _PlacesListScreenState();
}

class _PlacesListScreenState extends State<PlacesListScreen> {
  var _isTitle = true;
  var _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isLoading = true;
  }

  @override
  Widget build(BuildContext context) {
    final places=Provider.of<GreatPlaces>(context, listen: false);
        places.
        fetchAndSetData()
        .then((onValue) => setState(() {
              _isLoading = false;
            }));
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: GestureDetector(
          onTap: () {
            setState(() {
              _isTitle = !_isTitle;
            });
          },
          child: _isTitle
              ? const Text('Your places')
              : TextField(
                  decoration: InputDecoration(
                    labelText: 'Search...',
                    suffixIcon: IconButton(
                      icon: Icon(Icons.arrow_back),
                      color: Colors.white,
                      onPressed: () {
                        setState(() {
                          _isTitle = !_isTitle;
                        });
                      },
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      places.searchItems(value);
                    });
                  },
                ),
        ),
        actions: <Widget>[
          IconButton(
            tooltip: 'Change sorting order by date added',
              icon: Icon(Icons.filter_list),
              onPressed: () => setState(() {
                    Provider.of<GreatPlaces>(context).changeFilter();
                  })),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed('add_place_screen');
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Consumer<GreatPlaces>(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Center(
                      child: Text(
                    'No places added, go add some!',
                  )),
                  FlatButton.icon(
                    color: Colors.transparent,
                    onPressed: () {
                      Navigator.of(context).pushNamed('add_place_screen');
                    },
                    icon: Icon(Icons.add),
                    label: const Text('Add a place!!!'),
                  )
                ],
              ),
              builder: (ctx, greatPlaces, child) => greatPlaces.items.length <=
                      0
                  ? child
                  : ListView.builder(
                      itemCount: greatPlaces.items.length,
                      itemBuilder: (ctx, i) => Dismissible(
                        direction: DismissDirection.endToStart,
                        background: Container(
                          padding: EdgeInsets.only(right: 10),
                          alignment: Alignment.centerRight,
                          color: Colors.red,
                          child: Icon(Icons.delete, color: Colors.white),
                        ),
                        key: ValueKey(greatPlaces.items[i].id),
                        confirmDismiss: (endToStart) => showDialog(
                            context: context,
                            builder: ((ctx) => AlertDialog(
                                  title: Text('Are you sure?'),
                                  content: Text(
                                      '${greatPlaces.items[i].title} will be deleted. Are you sure to continue?'),
                                  actions: <Widget>[
                                    FlatButton(
                                      child: Text('Yes'),
                                      onPressed: () =>
                                          Navigator.of(context).pop(true),
                                    ),
                                    FlatButton(
                                      child: Text('No'),
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                    )
                                  ],
                                ))),
                        onDismissed: (endToStart) =>
                            greatPlaces.removeData(greatPlaces.items[i].id),
                        child: ListTile(
                          leading: Hero(
                            tag: greatPlaces.items[i].id,
                            child: CircleAvatar(
                              backgroundImage:
                                  FileImage(greatPlaces.items[i].image),
                            ),
                          ),
                          title: Text('${greatPlaces.items[i].title}'),
                          subtitle:
                              Text('${greatPlaces.items[i].location.address}'),
                          onTap: () {
                            Navigator.of(context).pushNamed(
                                'place_detail_screen',
                                arguments: greatPlaces.items[i].id);
                          },
                        ),
                      ),
                    ),
            ),
    );
  }
}
