import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';


class StorageProvider {
  Future<String> postDocument(File _document, String phoneNo) async {
    String url;

    StorageReference storageReference = FirebaseStorage.instance    
    .ref().child('users/'+ phoneNo);

   StorageUploadTask uploadTask = storageReference.putFile(_document);    
   await uploadTask.onComplete; 

   url = await storageReference.getDownloadURL();

   return url;
  }
}