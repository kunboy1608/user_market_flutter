import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:user_market/service/google/firebase_service.dart';
import 'package:user_market/util/cache.dart';
import 'package:user_market/util/const.dart';
import 'package:user_market/util/spm.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _oldTEC = TextEditingController();
  final TextEditingController _newTEC = TextEditingController();
  final TextEditingController _conTEC = TextEditingController();

  final FocusNode _nodeNew = FocusNode();
  final FocusNode _nodeCon = FocusNode();

  String _noti = "";

  String? _checkPassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter password";
    }

    if (value.length < 6) {
      return "Password leasts 6 chracters";
    }

    return null;
  }

  void _changePassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (await SPM.get(SPK.password) != _oldTEC.text) {
      setState(() {
        _noti = "Old password is wrong";
      });
      return;
    }

    FirebaseService.instance
        .changePassword(Cache.userCredential!, _newTEC.text)
        .then((value) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Success")),
      );
      Navigator.pop(context);
      SPM.set(SPK.password, _newTEC.text);
    }).onError((error, stackTrace) {
      setState(() {
        _noti = "Unexpected error";
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("User's information editor"),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: defPading),
            child: Column(
              children: [
                const SizedBox(height: defPading),
                TextFormField(
                  decoration: InputDecoration(
                    label: const Text("Old password"),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(defRadius)),
                    prefixIcon: const Icon(CupertinoIcons.profile_circled),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: () => _oldTEC.text = "",
                    ),
                  ),
                  controller: _oldTEC,
                  autofocus: true,
                  obscureText: true,
                  keyboardType: TextInputType.visiblePassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter old pass";
                    }
                    return null;
                  },
                  onEditingComplete: () => _nodeNew.requestFocus(),
                ),
                const SizedBox(height: defPading),
                TextFormField(
                  decoration: InputDecoration(
                    label: const Text("New password"),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(defRadius)),
                    prefixIcon: const Icon(CupertinoIcons.location_solid),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: () => _newTEC.text = "",
                    ),
                  ),
                  controller: _newTEC,
                  focusNode: _nodeNew,
                  obscureText: true,
                  keyboardType: TextInputType.visiblePassword,
                  validator: _checkPassword,
                  onEditingComplete: () => _nodeCon.requestFocus(),
                ),
                const SizedBox(height: defPading),
                TextFormField(
                  decoration: InputDecoration(
                    label: const Text("Confirm password"),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(defRadius)),
                    prefixIcon: const Icon(CupertinoIcons.phone_fill),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: () => _conTEC.text = "",
                    ),
                  ),
                  controller: _conTEC,
                  focusNode: _nodeCon,
                  obscureText: true,
                  keyboardType: TextInputType.visiblePassword,
                  validator: (value) {
                    if (_conTEC.text != _newTEC.text) {
                      return "Confirm password is not the same new password";
                    }
                    return null;
                  },
                  onEditingComplete: _changePassword,
                ),
                const SizedBox(height: defPading),
                if (_noti.isNotEmpty)
                  Text(
                    _noti,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.errorContainer),
                  ),
                SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                        onPressed: _changePassword,
                        child: const Text("Change")))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
