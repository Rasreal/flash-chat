import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart' as fb_core;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as fb_storage;
import 'dart:io';
import 'package:cool_alert/cool_alert.dart';

var user_uid = '';
String name1 = '';
String surname1 = '';

class Firebase_all {
  final _auth = FirebaseAuth.instance;
  final FirebaseFirestore fb_store = FirebaseFirestore.instance;
  final fb_storage.FirebaseStorage img_storage =
      fb_storage.FirebaseStorage.instance;

  Future<String> downloadUrl(String image_name) async {
    final String downloadurl = await img_storage
        .ref('testtest/$user_uid/$image_name')
        .getDownloadURL();

    return downloadurl;
  }

  Future<void> uploadFile(String filePath, String fileName) async {
    File file = File(filePath);

    try {
      await img_storage.ref('test/$user_uid/$fileName').putFile(file);
    } on fb_core.FirebaseException catch (e) {
      print(e);
    }
  }

  Future<void> createUser(String user_name, String user_surname) async {
    //Creates the user doc named whatever the user uid is in te collection "users"
    //and adds the user data
    await fb_store.collection("users").doc(user_uid).set({
      'Name': user_name,
      'Surname': user_surname,
    });
    name1 = await FirebaseFirestore.instance
        .collection('users')
        .doc(user_uid)
        .get()
        .then((value) {
      return value.data()!['Name']; // Access your after your get the data
    });

    print(name1);
  }

//This function registers a new user with auth and then calls the function createUser
  Future<void> registerUser(String email, String password) async {
    //Create the user with auth
    final newUser = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);

    //Create the user in firestore with the user data
    user_uid = newUser.user!.uid;
  }

//Function for logging in a user
  Future<void> logIn(String email, String password) async {
    //sign in the user with auth and get the user auth info back
    final currentUser = (await _auth.signInWithEmailAndPassword(
        email: email, password: password));
    user_uid = currentUser.user!.uid;
    //Get the user doc with the uid of the user that just logged in
    DocumentReference ref = await fb_store.collection("users").doc(user_uid);

    DocumentSnapshot snapshot = await ref.get();

    //Print the user's name or do whatever you want to do with it
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }
}
