import 'package:flutter/material.dart';
import 'package:mobile_app/informacionPage.dart';
import 'package:mobile_app/main.dart';

import 'MapPage.dart';

class NavDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Text(
              'SOA Menú',
              style: TextStyle(color: Colors.white, fontSize: 25),
            ),
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
          ),
          ListTile(
            leading: Icon(Icons.account_box),
            title: Text('Pagina de inicio'),
            onTap: () => {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => informacionPage()))
            },
          ),
          ListTile(
            leading: Icon(Icons.verified_user),
            title: Text('Mapa'),
            onTap: () => {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => MapPage()))
            },
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Desloguearse'),
            onTap: () => {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MyApp(),
                ),
              )
            },
          ),
        ],
      ),
    );
  }
}
