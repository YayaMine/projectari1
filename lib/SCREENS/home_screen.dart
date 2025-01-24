import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:barcode_scan2/barcode_scan2.dart'; // Import library untuk barcode
import 'add_item_screen.dart';
import 'transaction_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController searchController = TextEditingController();
  final TextEditingController paymentController = TextEditingController();
  List<Map<String, dynamic>> cartItems = [];
  int totalPrice = 0;
  int change = 0;
  String? searchedItemName;
  String? searchedItemPrice;

  void searchAndAddItem(String name) async {
    final QuerySnapshot result = await FirebaseFirestore.instance
        .collection('items')
        .where('name', isEqualTo: name)
        .get();

    if (result.docs.isNotEmpty) {
      final selectedItem = result.docs.first.data() as Map<String, dynamic>;
      selectedItem['id'] = result.docs.first.id;

      setState(() {
        searchedItemName = selectedItem['name'];
        searchedItemPrice = selectedItem['sellPrice'].toString();

        final existingItemIndex =
            cartItems.indexWhere((item) => item['id'] == selectedItem['id']);
        if (existingItemIndex >= 0) {
          cartItems[existingItemIndex]['quantity'] += 1;
        } else {
          cartItems.add({
            'id': selectedItem['id'],
            'name': selectedItem['name'],
            'sellPrice': selectedItem['sellPrice'],
            'stock': selectedItem['stock'],
            'quantity': 1,
          });
        }
        calculateTotalPrice();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Barang tidak ditemukan!')),
      );
    }
  }

  void searchByBarcode() async {
    try {
      var result = await BarcodeScanner.scan();
      if (result.rawContent.isNotEmpty) {
        final QuerySnapshot barcodeResult = await FirebaseFirestore.instance
            .collection('items')
            .where('barcode', isEqualTo: result.rawContent)
            .get();

        if (barcodeResult.docs.isNotEmpty) {
          final selectedItem =
              barcodeResult.docs.first.data() as Map<String, dynamic>;
          selectedItem['id'] = barcodeResult.docs.first.id;

          setState(() {
            searchedItemName = selectedItem['name'];
            searchedItemPrice = selectedItem['sellPrice'].toString();

            final existingItemIndex = cartItems
                .indexWhere((item) => item['id'] == selectedItem['id']);
            if (existingItemIndex >= 0) {
              cartItems[existingItemIndex]['quantity'] += 1;
            } else {
              cartItems.add({
                'id': selectedItem['id'],
                'name': selectedItem['name'],
                'sellPrice': selectedItem['sellPrice'],
                'stock': selectedItem['stock'],
                'quantity': 1,
              });
            }
            calculateTotalPrice();
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text('Barang dengan barcode tersebut tidak ditemukan!')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saat memindai barcode: $e')),
      );
    }
  }

  void calculateTotalPrice() {
    totalPrice = cartItems.fold(0, (sum, item) {
      return sum +
          ((item['quantity'] as int) * (item['sellPrice'] as num).toInt());
    });

    if (paymentController.text.isNotEmpty) {
      final payment = int.parse(paymentController.text);
      change = payment - totalPrice;
    } else {
      change = 0;
    }

    setState(() {});
  }

  void processTransaction() async {
    if (cartItems.isEmpty || paymentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lengkapi data terlebih dahulu!')),
      );
      return;
    }

    if (change < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Uang tidak cukup untuk membayar!')),
      );
      return;
    }

    try {
      for (var item in cartItems) {
        final int quantity = item['quantity'];
        final int currentStock = (item['stock'] as num).toInt();

        if (quantity > currentStock) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text('Stok barang tidak mencukupi untuk ${item['name']}!')),
          );
          return;
        }

        await FirebaseFirestore.instance.collection('transactions').add({
          'itemName': item['name'],
          'quantity': quantity,
          'totalPrice': quantity * (item['sellPrice'] as num).toInt(),
          'payment': int.parse(paymentController.text),
          'change': change,
          'timestamp': FieldValue.serverTimestamp(),
        });

        await FirebaseFirestore.instance
            .collection('items')
            .doc(item['id'])
            .update({'stock': currentStock - quantity});
      }

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 30),
                SizedBox(width: 8),
                Text('Transaksi Berhasil'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );

      setState(() {
        cartItems.clear();
        searchController.clear();
        paymentController.clear();
        totalPrice = 0;
        change = 0;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    }
  }

  void cancelTransaction() {
    setState(() {
      cartItems.clear();
      totalPrice = 0;
      change = 0;
      paymentController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'M-Kasir',
          style: TextStyle(color: Colors.white),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu),
            color: Colors.white, // Ikon garis tiga
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        backgroundColor: Colors.blue,
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 60, // Sesuaikan ukuran lebar lingkaran
                    height: 60, // Sesuaikan ukuran tinggi lingkaran
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white, // Membuat bentuk lingkaran
                      image: DecorationImage(
                        image: AssetImage(
                            'assets/images/remove.png'), // Path gambar
                        fit: BoxFit.contain, // Agar gambar tidak terpotong
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'M-Kasir',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Aplikasi Kasir Sederhana',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.shopping_cart),
              title: Text('Transaksi'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.inventory),
              title: Text('Stok Barang'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddItemScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.receipt),
              title: Text('Laporan'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TransactionScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Cari Barang',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    onSubmitted: searchAndAddItem,
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.qr_code_scanner, size: 28),
                  onPressed: searchByBarcode,
                ),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: Stack(
                children: [
                  // Background gambar
                  Container(
                    height: 700,
                    width: 700, // Membuat lebar gambar lebih besar
                    alignment:
                        Alignment.center, // Posisi tetap di tengah-tengah
                    margin:
                        EdgeInsets.only(top: 40), // Memberikan jarak ke bawah
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        'assets/images/backHome.png',
                        fit: BoxFit.contain, // Gambar tetap terlihat rapi
                      ),
                    ),
                  ),
                  // Overlay hasil pencarian
                  Align(
                    alignment: Alignment.topCenter,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (searchedItemName != null ||
                            searchedItemPrice != null)
                          Expanded(
                            child: ListView.builder(
                              itemCount: cartItems.length,
                              itemBuilder: (context, index) {
                                final item = cartItems[index];
                                return ListTile(
                                  title: Text(item['name']),
                                  subtitle: Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.remove),
                                        onPressed: () {
                                          setState(() {
                                            if (item['quantity'] > 1) {
                                              item['quantity'] -= 1;
                                            } else {
                                              cartItems.removeAt(index);
                                            }
                                            calculateTotalPrice();
                                          });
                                        },
                                      ),
                                      Text('${item['quantity']}'),
                                      IconButton(
                                        icon: Icon(Icons.add),
                                        onPressed: () {
                                          setState(() {
                                            if (item['quantity'] <
                                                item['stock']) {
                                              item['quantity'] += 1;
                                              calculateTotalPrice();
                                            } else {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                    content: Text(
                                                        'Stok tidak mencukupi!')),
                                              );
                                            }
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                  trailing: Text(
                                      'Rp. ${item['sellPrice'] * item['quantity']}'),
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Total Section
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.account_balance_wallet,
                        size: 20,
                        color: Colors.white,
                      ),
                      SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TOTAL:',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Rp. $totalPrice',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Change Section
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 35, vertical: 8),
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 250, 111, 111),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'KEMBALI:',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Rp. $change,00',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Text('Rp.', style: TextStyle(color: Colors.black)),
                  SizedBox(width: 4),
                  Expanded(
                    child: TextField(
                      controller: paymentController,
                      decoration: InputDecoration(
                        hintText: 'Jumlah Uang',
                        border: InputBorder.none,
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (_) => calculateTotalPrice(),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: cancelTransaction,
                  child: Icon(
                    Icons.cancel,
                    size: 30,
                    color: Colors.white,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    minimumSize: Size(120, 40),
                  ),
                ),
                ElevatedButton(
                  onPressed: processTransaction,
                  child: Icon(
                    Icons.check,
                    size: 30,
                    color: Colors.white,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    minimumSize: Size(120, 40),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
