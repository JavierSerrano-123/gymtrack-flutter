import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/member_model.dart';

class MemberService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  String get uid => auth.currentUser!.uid;

  Future<String> addMember(MemberModel member) async {
    final doc = await firestore
        .collection('users')
        .doc(uid)
        .collection('members')
        .add(member.toMap());

    return doc.id;
  }

  Future<List<MemberModel>> getMembers() async {
    final snapshot = await firestore
        .collection('users')
        .doc(uid)
        .collection('members')
        .get();

    return snapshot.docs.map((doc) {
      return MemberModel.fromMap(doc.data(), doc.id);
    }).toList();
  }

  Future<void> deleteMember(String id) async {
    await firestore
        .collection('users')
        .doc(uid)
        .collection('members')
        .doc(id)
        .delete();
  }

  Future<void> updateMember(String id, MemberModel member) async {
    await firestore
        .collection('users')
        .doc(uid)
        .collection('members')
        .doc(id)
        .update(member.toMap());
  }

  Future<List<MemberModel>> getExpiredMembers() async {
    final snapshot = await firestore
        .collection('users')
        .doc(uid)
        .collection('members')
        .get();

    final now = DateTime.now();

    return snapshot.docs
        .map((doc) => MemberModel.fromMap(doc.data(), doc.id))
        .where((member) => member.fechaVencimiento.isBefore(now))
        .toList();
  }
}
