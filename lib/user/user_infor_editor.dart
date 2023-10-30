import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:user_market/entity/user.dart';
import 'package:user_market/home/home.dart';
import 'package:user_market/service/entity/user_service.dart';
import 'package:user_market/util/cache.dart';
import 'package:user_market/util/const.dart';

class UserInforEditor extends StatefulWidget {
  const UserInforEditor({super.key, this.redirectToHome = false});
  final bool redirectToHome;

  @override
  State<UserInforEditor> createState() => _UserInforEditorState();
}

class _UserInforEditorState extends State<UserInforEditor> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameTEC = TextEditingController();
  final TextEditingController _addressTEC = TextEditingController();
  final TextEditingController _phoneNumberTEC = TextEditingController();

  final FocusNode _nodeAddress = FocusNode();
  final FocusNode _nodePhoneNumber = FocusNode();

  void _save() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (Cache.user == null) {
      Cache.user = User()
        ..userId = Cache.userId
        ..address = _addressTEC.text
        ..fullName = _fullNameTEC.text
        ..phoneNumber = _phoneNumberTEC.text;

      UserService.instance.add(Cache.user!).then((_) => _direct());
    } else {
      Cache.user!
        ..address = _addressTEC.text
        ..fullName = _fullNameTEC.text
        ..phoneNumber = _phoneNumberTEC.text;
      UserService.instance.update(Cache.user!).then((_) => _direct());
    }
  }

  void _direct() {
    if (widget.redirectToHome) {
      Navigator.pushReplacement(
          context,
          CupertinoPageRoute(
            builder: (context) => const Home(),
          ));
    } else {
      Navigator.pop(context);
    }
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
                    label: const Text("Full name*"),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(defRadius)),
                    prefixIcon: const Icon(CupertinoIcons.profile_circled),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: () => _fullNameTEC.text = "",
                    ),
                  ),
                  controller: _fullNameTEC,
                  autofocus: true,
                  keyboardType: TextInputType.visiblePassword,
                  validator: (value) =>
                      value == null ? "Please enter full name" : null,
                  onEditingComplete: () => _nodeAddress.requestFocus(),
                ),
                const SizedBox(height: defPading),
                TextFormField(
                  decoration: InputDecoration(
                    label: const Text("Adresss"),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(defRadius)),
                    prefixIcon: const Icon(CupertinoIcons.location_solid),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: () => _addressTEC.text = "",
                    ),
                  ),
                  controller: _addressTEC,
                  focusNode: _nodeAddress,
                  keyboardType: TextInputType.streetAddress,
                  validator: (value) => null,
                  onEditingComplete: () => _nodePhoneNumber.requestFocus(),
                ),
                const SizedBox(height: defPading),
                TextFormField(
                  decoration: InputDecoration(
                    label: const Text("Phone Number"),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(defRadius)),
                    prefixIcon: const Icon(CupertinoIcons.phone_fill),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: () => _phoneNumberTEC.text = "",
                    ),
                  ),
                  controller: _phoneNumberTEC,
                  focusNode: _nodePhoneNumber,
                  keyboardType: TextInputType.phone,
                  validator: (value) => null,
                  onEditingComplete: _save,
                ),
                const SizedBox(height: defPading),
                SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                        onPressed: _save, child: const Text("Save")))
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _addressTEC.dispose();
    _fullNameTEC.dispose();
    _nodeAddress.dispose();
    _nodePhoneNumber.dispose();
    _phoneNumberTEC.dispose();
    super.dispose();
  }
}
