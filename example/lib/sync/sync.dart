import 'package:flutter/material.dart';
import 'package:flutter_realm/flutter_realm.dart';

import '../subscription_widget.dart';

class SyncWidget extends StatefulWidget {
  @override
  _SyncWidgetState createState() => _SyncWidgetState();
}

class _SyncWidgetState extends State<SyncWidget> {
  Realm _realm;

  @override
  Widget build(BuildContext context) {
    return _realm == null
        ? Scaffold(
            appBar: AppBar(
              title: Text('Realm Sync Platform'),
            ),
            body: _SignIn(onRealm: (realm) => setState(() => _realm = realm)))
        : SubscriptionWidget(realm: _realm);
  }

  @override
  void dispose() {
    _realm?.close();

    super.dispose();
  }
}

class _SignIn extends StatefulWidget {
  final Function(Realm realm) onRealm;

  const _SignIn({Key key, @required this.onRealm}) : super(key: key);

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<_SignIn> {
  final form = GlobalKey<FormState>();

  String serverUrl = "[YOUR REALM URL]";
  String username;
  String password;

  List<String> lol = [];

  @override
  Widget build(BuildContext context) {
    var loz = lol.isNotEmpty;
    return Form(
      key: form,
      child: ListView(
        padding: EdgeInsets.all(16),
        children: <Widget>[
          TextFormField(
            key: Key('username'),
            decoration: InputDecoration(labelText: 'Username'),
            onSaved: (text) => username = text,
          ),
          TextFormField(
            key: Key('password'),
            decoration: InputDecoration(labelText: 'Password'),
            onSaved: (text) => password = text,
          ),
          RaisedButton(
            key: Key('sign_up'),
            child: Text('Sign Up'),
            onPressed: () => _onSignIn(true),
          ),
          RaisedButton(
            key: Key('sign_in'),
            child: Text('Sign In'),
            onPressed: () => _onSignIn(false),
          ),
          RaisedButton(
            key: Key('anonymous'),
            child: Text('Sign In as Anonymous'),
            onPressed: () => _onSignIn(false, isAnonymous: true),
          ),
        ],
      ),
    );
  }

  Future<void> _onSignIn(bool shouldRegister, {bool isAnonymous = false}) async {
    if (!form.currentState.validate()) {
      return;
    }
    form.currentState.save();
    final authUrl = 'https://$serverUrl';
    final syncServerUrl = 'realms://$serverUrl/~/products';

    final creds = UsernamePasswordAuthProvider.getCredentials(
      username: username,
      password: password,
      shouldRegister: shouldRegister,
    );

    try {
      print("==> 1");
      await SyncUser.logInWithCredentials(
        credentials: creds,
        authServerURL: authUrl,
        isAnonymous: isAnonymous
      );

      print("==> 2");
      final realm = await Realm.asyncOpenWithConfiguration(
        syncServerURL: syncServerUrl,
        fullSynchronization: true,
      );

      print("==> 3");
      widget.onRealm(realm);
    } catch (ex) {
      final bar = SnackBar(content: Text(ex.toString()));
      print("_onSignIn: Exception ====> $ex");
      Scaffold.of(context).showSnackBar(bar);
    }
  }
}
