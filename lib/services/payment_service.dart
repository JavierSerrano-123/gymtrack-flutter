import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/payment_model.dart';

class PaymentService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  
  String get uid => auth.currentUser!.uid;

  Future<void> addPayment(PaymentModel payment) async {
    await firestore
        .collection('users')
        .doc(uid)
        .collection('payments')
        .add(payment.toMap());
  }

  Future<List<PaymentModel>> getPayments() async {
    final snapshot = await firestore
        .collection('users')
        .doc(uid)
        .collection('payments')
        .get();

    return snapshot.docs.map((doc) {
      return PaymentModel.fromMap(doc.data(), doc.id);
    }).toList();
  }

  Future<void> deletePayment(String id) async {
    await firestore
        .collection('users')
        .doc(uid)
        .collection('payments')
        .doc(id)
        .delete();
  }

  Future<double> getTotalIncome() async {
    final payments = await getPayments();
    double total = 0;
    for (var payment in payments) {
      total += payment.monto;
    }
    return total;
  }
}
