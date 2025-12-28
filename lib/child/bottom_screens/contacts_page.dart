import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

import 'package:womensafety/db/db_services.dart';
import 'package:womensafety/model/contactsm.dart';
import 'package:womensafety/utils/constants.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({Key? key}) : super(key: key);

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  List<Contact> contacts = [];
  List<Contact> contactsFiltered = [];

  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    askPermissions();
  }

  /// 🔹 Generate initials (replacement of contact.initials())
  String getInitials(String name) {
    if (name.isEmpty) return '';
    List<String> parts = name.trim().split(' ');
    if (parts.length == 1) {
      return parts[0][0].toUpperCase();
    }
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  /// 🔹 Clean phone number
  String flattenPhoneNumber(String phoneStr) {
    return phoneStr.replaceAllMapped(RegExp(r'^(\+)|\D'), (Match m) {
      return m[0] == "+" ? "+" : "";
    });
  }

  /// 🔹 Filter contacts
  void filterContact() {
    List<Contact> _contacts = [];
    _contacts.addAll(contacts);

    if (searchController.text.isNotEmpty) {
      _contacts.retainWhere((element) {
        String searchTerm = searchController.text.toLowerCase();
        String searchTermFlatten = flattenPhoneNumber(searchTerm);

        String contactName = element.displayName.toLowerCase();
        bool nameMatch = contactName.contains(searchTerm);
        if (nameMatch) return true;

        if (searchTermFlatten.isEmpty) return false;

        if (element.phones.isNotEmpty) {
          for (final phone in element.phones) {
            String flattenedPhone =
            flattenPhoneNumber(phone.number);
            if (flattenedPhone.contains(searchTermFlatten)) {
              return true;
            }
          }
        }
        return false;
      });
    }

    setState(() {
      contactsFiltered = _contacts;
    });
  }

  /// 🔹 Ask permission
  Future<void> askPermissions() async {
    PermissionStatus permissionStatus = await getContactsPermissions();
    if (permissionStatus == PermissionStatus.granted) {
      await getAllContacts();
      searchController.addListener(filterContact);
    } else {
      handleInvalidPermissions(permissionStatus);
    }
  }

  void handleInvalidPermissions(PermissionStatus permissionStatus) {
    if (permissionStatus == PermissionStatus.denied) {
      dialogueBox(context, "Access to contacts denied");
    } else if (permissionStatus == PermissionStatus.permanentlyDenied) {
      dialogueBox(context, "Enable contacts permission from settings");
    }
  }

  Future<PermissionStatus> getContactsPermissions() async {
    PermissionStatus permission = await Permission.contacts.status;
    if (!permission.isGranted && !permission.isPermanentlyDenied) {
      return await Permission.contacts.request();
    }
    return permission;
  }

  /// 🔹 Get all contacts
  Future<void> getAllContacts() async {
    if (await FlutterContacts.requestPermission()) {
      List<Contact> _contacts = await FlutterContacts.getContacts(
        withProperties: true,
        withPhoto: true,
      );
      setState(() {
        contacts = _contacts;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isSearching = searchController.text.isNotEmpty;
    bool listItemExist =
        contactsFiltered.isNotEmpty || contacts.isNotEmpty;

    return Scaffold(
      body: contacts.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: searchController,
                decoration: const InputDecoration(
                  labelText: "Search contact",
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
            listItemExist
                ? Expanded(
              child: ListView.builder(
                itemCount: isSearching
                    ? contactsFiltered.length
                    : contacts.length,
                itemBuilder: (context, index) {
                  Contact contact = isSearching
                      ? contactsFiltered[index]
                      : contacts[index];

                  return ListTile(
                    title: Text(contact.displayName),
                    leading: contact.photo != null
                        ? CircleAvatar(
                      backgroundColor: kColorRed,
                      backgroundImage:
                      MemoryImage(contact.photo!),
                    )
                        : CircleAvatar(
                      backgroundColor: kColorRed,
                      child: Text(
                        getInitials(
                            contact.displayName),
                        style: const TextStyle(
                            color: Colors.white),
                      ),
                    ),
                    onTap: () {
                      if (contact.phones.isNotEmpty) {
                        final String phoneNum =
                            contact.phones.first.number;
                        final String name =
                            contact.displayName;
                        _addContact(
                          TContact(phoneNum, name),
                        );
                      } else {
                        Fluttertoast.showToast(
                          msg:
                          "Oops! Phone number not available",
                        );
                      }
                    },
                  );
                },
              ),
            )
                : const Center(
              child: Text("No contacts found"),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔹 Save contact
  void _addContact(TContact newContact) async {
    int result = await _databaseHelper.insertContact(newContact);

    if (result != 0) {
      Fluttertoast.showToast(msg: "Contact added successfully");
    } else {
      Fluttertoast.showToast(msg: "Failed to add contact");
    }
    Navigator.of(context).pop(true);
  }
}
