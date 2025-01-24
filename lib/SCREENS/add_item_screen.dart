import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:barcode_scan2/barcode_scan2.dart'; // Import library untuk barcode

class AddItemScreen extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController costPriceController = TextEditingController();
  final TextEditingController sellPriceController = TextEditingController();
  final TextEditingController stockController = TextEditingController();
  final TextEditingController barcodeController = TextEditingController();
  String? selectedCategory;
  String? selectedItemId;

  Future<void> scanBarcode(BuildContext context) async {
    try {
      var result = await BarcodeScanner.scan();
      if (result.rawContent.isNotEmpty) {
        barcodeController.text = result.rawContent;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saat memindai barcode: $e')),
      );
    }
  }

  Future<void> addItem(BuildContext context) async {
    try {
      await FirebaseFirestore.instance.collection('items').add({
        'name': nameController.text,
        'costPrice': double.parse(costPriceController.text),
        'sellPrice': double.parse(sellPriceController.text),
        'stock': int.parse(stockController.text),
        'category': selectedCategory,
        'barcode': barcodeController.text,
        'timestamp': FieldValue.serverTimestamp(), // Waktu penambahan data
      });

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Berhasil'),
            content: Text('Barang berhasil ditambahkan!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      clearForm();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error menambahkan barang: $e')),
      );
    }
  }

  Future<void> updateItem(BuildContext context) async {
    if (selectedItemId != null) {
      try {
        await FirebaseFirestore.instance
            .collection('items')
            .doc(selectedItemId)
            .update({
          'name': nameController.text,
          'costPrice': double.parse(costPriceController.text),
          'sellPrice': double.parse(sellPriceController.text),
          'stock': int.parse(stockController.text),
          'category': selectedCategory,
          'barcode': barcodeController.text,
        });

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Berhasil'),
              content: Text('Barang berhasil diperbarui!'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
        clearForm();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error memperbarui barang: $e')),
        );
      }
    }
  }

  Future<void> deleteItem(BuildContext context) async {
    if (selectedItemId != null) {
      try {
        await FirebaseFirestore.instance
            .collection('items')
            .doc(selectedItemId)
            .delete();

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Berhasil'),
              content: Text('Barang berhasil dihapus!'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
        clearForm();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error menghapus barang: $e')),
        );
      }
    }
  }

  void clearForm() {
    nameController.clear();
    costPriceController.clear();
    sellPriceController.clear();
    stockController.clear();
    barcodeController.clear();
    selectedCategory = null;
    selectedItemId = null;
  }

  void loadItemData(QueryDocumentSnapshot item) {
    nameController.text = item['name'];
    costPriceController.text = item['costPrice'].toString();
    sellPriceController.text = item['sellPrice'].toString();
    stockController.text = item['stock'].toString();
    barcodeController.text = item['barcode'];
    selectedCategory = item['category'];
    selectedItemId = item.id;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'M-Kasir',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          'Form Tambah Barang',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(Icons.shopping_bag, size: 28),
                          Expanded(
                            child: TextField(
                              controller: nameController,
                              decoration: InputDecoration(
                                labelText: 'Nama Barang',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 2, horizontal: 8),
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 2, horizontal: 8),
                              ),
                              items: [
                                DropdownMenuItem(
                                  value: 'Electronic',
                                  child: Text('Electronic'),
                                ),
                                DropdownMenuItem(
                                  value: 'Furniture',
                                  child: Text('Furniture'),
                                ),
                              ],
                              onChanged: (value) {
                                selectedCategory = value;
                              },
                              value: selectedCategory,
                              hint: Text('Kategori'),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(Icons.attach_money, size: 28),
                          Expanded(
                            child: TextField(
                              controller: costPriceController,
                              decoration: InputDecoration(
                                labelText: 'Harga Dasar',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 2, horizontal: 8),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: sellPriceController,
                              decoration: InputDecoration(
                                labelText: 'Harga Jual',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 2, horizontal: 8),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(Icons.bookmark, size: 28),
                          Expanded(
                            child: TextField(
                              controller: stockController,
                              decoration: InputDecoration(
                                labelText: 'Stok',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 2, horizontal: 8),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: barcodeController,
                                    decoration: InputDecoration(
                                      labelText: 'Barcode/Kode',
                                      border: OutlineInputBorder(),
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: 2, horizontal: 8),
                                    ),
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.qr_code),
                                  onPressed: () => scanBarcode(context),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              if (nameController.text.isNotEmpty &&
                                  costPriceController.text.isNotEmpty &&
                                  sellPriceController.text.isNotEmpty &&
                                  stockController.text.isNotEmpty &&
                                  selectedCategory != null &&
                                  barcodeController.text.isNotEmpty) {
                                await addItem(context);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text('Semua field harus diisi!')),
                                );
                              }
                            },
                            child: Text(
                              'Simpan',
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey, // Warna abu-abu
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6), // Kotak
                              ),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 2),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              if (selectedItemId != null) {
                                await updateItem(context);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Pilih barang untuk diperbarui!')),
                                );
                              }
                            },
                            child: Text(
                              'Ubah',
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey, // Warna abu-abu
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6), // Kotak
                              ),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 2),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              if (selectedItemId != null) {
                                await deleteItem(context);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text('Pilih barang untuk dihapus!')),
                                );
                              }
                            },
                            child: Text(
                              'Hapus',
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey, // Warna abu-abu
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6), // Kotak
                              ),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 2),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text('Data Barang',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance.collection('items').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('Belum ada barang ditambahkan.'));
                  }

                  final items = snapshot.data!.docs;

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index].data() as Map<String, dynamic>;

                      // Ubah sellPrice ke bilangan bulat
                      final int sellPrice = (item['sellPrice'] as num).toInt();

                      return Card(
                        child: ListTile(
                          title: Text(item['name']),
                          subtitle: Text(
                            'Kategori: ${item['category']} | Harga Jual: Rp. $sellPrice,00 | Stok: ${item['stock']}',
                          ),
                          onTap: () {
                            loadItemData(items[index]);
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
