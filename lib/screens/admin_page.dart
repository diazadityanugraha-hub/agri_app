import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_page.dart';
import 'home_page.dart';
import '../main.dart'; // PENTING: Ambil variabel global

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F5),
      appBar: AppBar(
        title: const Text(
          "DASHBOARD MONITORING",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
        ),
        backgroundColor: Colors.green[900],
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              // RESET SEMUA DATA GLOBAL SAAT LOGOUT
              dataPantauanAdmin = null;
              userLogin = "";
              savedName = null;
              savedLahan = null;
              
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
              );
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Daftar Petani Terdaftar",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const Text(
              "Data real-time dari Google Cloud Firestore",
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 20),
            
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .where('role', isEqualTo: 'petani')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text("Terjadi Kesalahan Koneksi"));
                  }
                  
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final listPetani = snapshot.data!.docs;

                  if (listPetani.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.group_off, size: 80, color: Colors.grey[300]),
                          const SizedBox(height: 10),
                          const Text("Belum ada petani di Cloud", style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: listPetani.length,
                    itemBuilder: (context, index) {
                      var doc = listPetani[index];
                      var data = doc.data() as Map<String, dynamic>;
                      String userId = doc.id;

                      return Card(
                        elevation: 3,
                        margin: const EdgeInsets.only(bottom: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                          leading: CircleAvatar(
                            backgroundColor: Colors.green.withOpacity(0.1),
                            child: const Icon(Icons.person, color: Colors.green),
                          ),
                          title: Text(
                            data['nama'] ?? "Tanpa Nama",
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          subtitle: Text(
                            "ID: $userId | Lahan: ${data['lahan'] ?? '-'}",
                            style: const TextStyle(fontSize: 12),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
                            onPressed: () => _konfirmasiHapus(userId, data['nama'] ?? userId),
                          ),
                          onTap: () {
                            // SIMPAN DATA KE VARIABEL GLOBAL SEBELUM PINDAH
                            dataPantauanAdmin = {
                              'nama': data['nama'],
                              'lahan': data['lahan'],
                              'kondisi': data['kondisi'] ?? 'Belum Scan',
                            };

                            // Pindah ke HomePage (Tanpa parameter karena sudah pakai Global)
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HomePage(),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _konfirmasiHapus(String id, String nama) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Akun?"),
        content: Text("Hapus akun '$nama' dari Cloud? Petani ini tidak akan bisa login lagi."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () async {
              try {
                await FirebaseFirestore.instance.collection('users').doc(id).delete();
                if (!mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Data berhasil dihapus!")),
                );
              } catch (e) {
                if (Navigator.canPop(context)) Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Gagal menghapus: $e"), backgroundColor: Colors.red),
                );
              }
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}