import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'MainPage.dart';
import 'package:boundpages_final/features/user_auth/presentation/pages/profile_page.dart';
import 'package:boundpages_final/features/user_auth/presentation/pages/notifications_page.dart';
import 'package:boundpages_final/features/user_auth/presentation/pages/settings_page.dart';

class CartPage extends StatefulWidget {
  final int? discount; // Optional discount parameter

  CartPage({this.discount});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  int _selectedIndex = 2; // Cart tab by default

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return; // Avoid duplicate navigation
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainPage()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Profilepage()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => CartPage()),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => NotificationsPage()),
        );
        break;
      case 4:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SettingsPage()),
        );
        break;
    }
  }

  Future<QuerySnapshot> _getCartItems() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userId = user.uid;
      return FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('cart')
          .get();
    } else {
      throw Exception('User not logged in');
    }
  }

  Future<void> _removeCartItem(String cartItemId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userId = user.uid;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('cart')
          .doc(cartItemId)
          .delete();
    } else {
      throw Exception('User not logged in');
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Your Cart',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: size.height * 0.060),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Order Details",
                  style: GoogleFonts.poppins(
                    fontSize: size.width * 0.040,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            SizedBox(height: size.height * 0.030),
            Expanded(
              child: SizedBox(
                child: SingleChildScrollView(
                  physics: const ScrollPhysics(),
                  child: FutureBuilder<QuerySnapshot>(
                    future: _getCartItems(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator(color: Colors.white));
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Iconsax.bag, size: size.width * 0.20, color: Colors.grey),
                              SizedBox(height: size.height * 0.020),
                              Text(
                                "Your cart is empty!",
                                style: GoogleFonts.poppins(color: Colors.grey),
                              ),
                            ],
                          ),
                        );
                      }

                      var cartItems = snapshot.data!.docs;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "My Cart",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: size.height * 0.020),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: cartItems.length,
                            itemBuilder: (context, index) {
                              var cartItem = cartItems[index];
                              return ListTile(
                                contentPadding: EdgeInsets.symmetric(vertical: 10.0),
                                leading: Icon(Icons.book, color: Colors.white),
                                title: Text(
                                  cartItem['title'],
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                                subtitle: Text(
                                  'Price: ₹${cartItem['price']}',
                                  style: GoogleFonts.poppins(color: Colors.white),
                                ),
                                trailing: IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () async {
                                    // Remove item from cart
                                    await _removeCartItem(cartItem.id);
                                    // Refresh UI
                                    setState(() {});
                                  },
                                ),
                              );
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
            SizedBox(height: size.height * 0.020),
            _buildOrderInfo(size),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        unselectedItemColor: Colors.white70,
        selectedItemColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildOrderInfo(Size size) {
    return FutureBuilder<QuerySnapshot>(
      future: _getCartItems(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: Colors.white));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Container();
        }

        var cartItems = snapshot.data!.docs;
        double subTotal = cartItems.fold(0, (sum, item) => sum + item['price']);
        double gst = subTotal * 0.18; // 18% GST
        double discount = widget.discount != null ? subTotal * widget.discount! / 100 : 0;
        double total = subTotal + gst - discount;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Order Info",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: size.width * 0.040,
                color: Colors.white,
              ),
            ),
            SizedBox(height: size.height * 0.010),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Sub Total", style: GoogleFonts.poppins(color: Colors.white)),
                Text("₹$subTotal", style: GoogleFonts.poppins(color: Colors.white)),
              ],
            ),
            SizedBox(height: size.height * 0.008),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("GST (18%)", style: GoogleFonts.poppins(color: Colors.white)),
                Text("₹${gst.toStringAsFixed(2)}", style: GoogleFonts.poppins(color: Colors.white)),
              ],
            ),
            if (widget.discount != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Discount (${widget.discount}%)", style: GoogleFonts.poppins(color: Colors.green)),
                  Text("-₹${discount.toStringAsFixed(2)}", style: GoogleFonts.poppins(color: Colors.green)),
                ],
              ),
            SizedBox(height: size.height * 0.015),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Total", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white)),
                Text("₹${total.toStringAsFixed(2)}", style: GoogleFonts.poppins(fontWeight: FontWeight.w500, color: Colors.white)),
              ],
            ),
            SizedBox(height: size.height * 0.030),
            SizedBox(
              width: size.width,
              height: size.height * 0.055,
              child: ElevatedButton(
                onPressed: () {
                  // Handle checkout functionality here
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white,),
                child: Text(
                  "Checkout",
                  style: GoogleFonts.poppins(fontSize: size.width * 0.040, fontWeight: FontWeight.w600, color: Colors.black),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}