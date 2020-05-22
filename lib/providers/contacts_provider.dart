import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:saleschat/providers/database_provider.dart';
import 'package:saleschat/providers/preferences_provider.dart';

class ContactsProvider {
  DatabaseProvider databaseProvider = DatabaseProvider.instance;

  Future<List<Map<String,String>>> getContactsPhones() async {
    final String myPhone = await sharedPreferencesProvider.getStringValue('phone');
    final PermissionStatus permissionStatus = await _getPermission();
    if (permissionStatus == PermissionStatus.granted) {
      List<Map<String, String>> result = new List<Map<String, String>>();
      List<String> phones = new List<String>();
      Iterable<Contact> contacts = await ContactsService.getContacts();
      contacts.forEach((contact){
        contact.phones.forEach((ph){
          String value = ph.value;
          value = value.trim().replaceAll(" ", "");
          if(value.length == 9 || value.length == 12){
            if(value.length == 9) value = '+34' + value;
            if(!phones.contains(value) && value != myPhone){
              phones.add(value);
              result.add({
                'phone': value,
                'name': contact.displayName
              });
            }
          }
        });
      });
      return result;
    }else{
      return [];
    }
  }

  Future<PermissionStatus> _getPermission() async {
    final PermissionStatus permission = await Permission.contacts.status;
    if (permission != PermissionStatus.granted && permission != PermissionStatus.denied) {
      final Map<Permission, PermissionStatus> permissionStatus =
          await [Permission.contacts].request();
      return permissionStatus[Permission.contacts] ??
          PermissionStatus.undetermined;
    } else {
      return permission;
    }
  }

  Future<void> crearContactes(List contactes) async {
    await databaseProvider.deleteMany('CONTACTS');
    contactes.forEach((contacte) async {
      await databaseProvider.insert(
        {
          'USERID': contacte['_id'],
          'PHOTO': contacte['photo'],
          'STATE': contacte['state'],
          'USERNAME': contacte['username'],
          'PHONE': contacte['phone'],
          'NAME': contacte['name'],
        },
        'CONTACTS'
      ).catchError((onError){});
    });
  }

}