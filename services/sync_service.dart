import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'database.dart';
import '../models/customer.dart';
import '../models/transaction.dart' as my_model;
import '../models/cash_entry.dart';

class SyncService {
  final _db = FirebaseFirestore.instance;

  // 1. BACKUP: Data Cloud par bhejna
  Future<void> backupData() async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final userDoc = _db.collection('users').doc(uid);

    // Pehle purana kachra saaf karo cloud se (1:1 sync ke liye)
    var customers = await userDoc.collection('customers').get();
    for (var doc in customers.docs) {
      var trans = await doc.reference.collection('transactions').get();
      for (var t in trans.docs) { await t.reference.delete(); }
      await doc.reference.delete();
    }
    var cash = await userDoc.collection('cashbook').get();
    for (var doc in cash.docs) { await doc.reference.delete(); }

    // Fresh Upload
    for (var cust in DatabaseService.customersBox.values) {
      await userDoc.collection('customers').doc(cust.id).set(cust.toMap());
      var tBox = await DatabaseService.getTransactionsBox(cust.id);
      
      for (var t in tBox.values) {
        // ZARURI: Transaction ki date ko ID banao
        String tId = t.date.millisecondsSinceEpoch.toString();
        await userDoc.collection('customers').doc(cust.id)
            .collection('transactions').doc(tId).set(t.toMap());
      }
    }

    for (var entry in DatabaseService.cashbookBox.values) {
      String cId = entry.date.millisecondsSinceEpoch.toString();
      await userDoc.collection('cashbook').doc(cId).set(entry.toMap());
    }
  }

  // 2. RESTORE: Cloud se data wapas lana
  Future<void> restoreData() async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final userDoc = _db.collection('users').doc(uid);

    // Customers Restore
    var custSnap = await userDoc.collection('customers').get();
    for (var doc in custSnap.docs) {
      Customer c = Customer.fromMap(doc.data());
      await DatabaseService.customersBox.put(c.id, c); // .put use kiya duplicate rokne ke liye

      // Transactions Restore
      var tBox = await DatabaseService.getTransactionsBox(c.id);
      await tBox.clear(); // Restore se pehle local clear
      
      var transSnap = await doc.reference.collection('transactions').get();
      for (var tDoc in transSnap.docs) {
        my_model.Transaction t = my_model.Transaction.fromMap(tDoc.data());
        
        // 🔥 MAGIC LINE: tDoc.id (Timestamp) ko hi Hive ki key banao 🔥
        // Isse duplicate entry kabhi nahi banegi
        await tBox.put(tDoc.id, t); 
      }
    }

    // Cashbook Restore
    var cashSnap = await userDoc.collection('cashbook').get();
    await DatabaseService.cashbookBox.clear();
    for (var doc in cashSnap.docs) {
      CashEntry e = CashEntry.fromMap(doc.data());
      await DatabaseService.cashbookBox.put(doc.id, e);
    }
  }

  // 3. WIPE: Storage saaf karna
  Future<void> clearLocalData() async {
    await DatabaseService.customersBox.clear();
    await DatabaseService.cashbookBox.clear();
  }

  // SyncService class ke andar:
static void triggerAutoBackup() {
  // Bina await kiye background mein chalega
  SyncService().backupData().then((_) {
    print("☁️ Auto-sync successful");
  }).catchError((e) {
    print("☁️ Auto-sync failed: $e");
  });
}

}