import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../main.dart';
import 'history_model.dart'; // Import model yang tadi

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  Widget build(BuildContext context) {
    const Color agriGreen = Color(0xFF1E6F42);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("Riwayat Deteksi", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: agriGreen,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // TOMBOL HAPUS SEMUA
          IconButton(
            icon: const Icon(Icons.delete_sweep_rounded),
            onPressed: () => _konfirmasiHapusSemua(),
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('scan_history')
            .where('userId', isEqualTo: userLogin)
            .orderBy('tanggalInput', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: agriGreen));
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(child: Text("Riwayat kosong", style: TextStyle(color: Colors.grey)));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var data = docs[index].data() as Map<String, dynamic>;
              String docId = docs[index].id; // Ambil ID dokumen Firestore

              return Dismissible(
                key: Key(docId),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  color: Colors.red,
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (direction) {
                  // Panggil fungsi hapus dari model
                  HistoryModel.hapusRiwayat(docId);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Riwayat dihapus")),
                  );
                },
                child: Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: Icon(
                      data['status'] == "Normal" ? Icons.check_circle : Icons.warning,
                      color: Color(data['warna'] ?? 0xFF1E6F42),
                    ),
                    title: Text(data['penyakit'] ?? "Unknown", style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(data['waktu'] ?? ""),
                    trailing: Text(data['akurasi'] ?? "", style: const TextStyle(color: Colors.grey)),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // DIALOG KONFIRMASI HAPUS SEMUA
  void _konfirmasiHapusSemua() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Bersihkan Riwayat?"),
        content: const Text("Semua catatan scan kamu akan dihapus permanen dari Cloud."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("BATAL")),
          TextButton(
            onPressed: () {
              HistoryModel.bersihkanSemua();
              Navigator.pop(context);
            },
            child: const Text("HAPUS SEMUA", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}