import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/friend.dart';

class FriendsProvider extends ChangeNotifier {
  final List<Friend> _friends = [];

  List<Friend> get friends => _friends;

  Future<void> loadFriends() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('friends')
        .get();

    _friends.clear();
    for (var doc in snapshot.docs) {
      _friends.add(Friend.fromMap(doc.id, doc.data()));
    }
    notifyListeners();
  }

  Future<void> addFriend(Friend friend) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final docRef = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('friends')
        .add(friend.toMap());

    _friends.add(friend.copyWith(id: docRef.id));
    notifyListeners();
  }

  Future<void> removeFriend(String id) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('friends')
        .doc(id)
        .delete();

    _friends.removeWhere((f) => f.id == id);
    notifyListeners();
  }
}