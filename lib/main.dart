import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: const BottomNavBar(),
    );
  }
}

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int indexBottomNav = 0;

  final List<MenuItem> favoriteItems = [];
  final List<CartItem> cartItems = [];

  void addToCart(MenuItem item) {
    setState(() {
      final existingItem = cartItems.firstWhere(
        (cartItem) => cartItem.menuItem.name == item.name,
        orElse: () => CartItem(menuItem: item, quantity: 0),
      );

      if (existingItem.quantity == 0) {
        cartItems.add(CartItem(menuItem: item, quantity: 1));
      } else {
        existingItem.quantity++;
      }
    });
  }

  void removeFromCart(int index) {
    setState(() {
      if (index >= 0 && index < cartItems.length) {
        cartItems.removeAt(index);
      }
    });
  }

  List<Widget> get widgetOption => [
        MenuScreen(
          onFavoriteToggled: (item, isFavorite) {
            setState(() {
              if (isFavorite) {
                favoriteItems.add(item);
              } else {
                favoriteItems.remove(item);
              }
            });
          },
          favoriteItems: favoriteItems,
          onAddToCart: addToCart,
          cartItems: cartItems,
          removeFromCart: removeFromCart,
        ),
        MyFavoriteScreen(favoriteItems: favoriteItems),
        Text("Settings is coming soon!",
            style:
                GoogleFonts.prompt(fontSize: 24, fontWeight: FontWeight.bold)),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: widgetOption[indexBottomNav],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "HOME"),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite), label: "MY FAVOURITE"),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: "SETTINGS"),
        ],
        currentIndex: indexBottomNav,
        onTap: (value) => setState(() => indexBottomNav = value),
      ),
    );
  }
}

class MyFavoriteScreen extends StatelessWidget {
  final List<MenuItem> favoriteItems;

  const MyFavoriteScreen({super.key, required this.favoriteItems});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "My Favorites",
          style: GoogleFonts.prompt(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: favoriteItems.isEmpty
          ? Center(
              child: Text(
                "No items in favorites!",
                style: GoogleFonts.prompt(fontSize: 18),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: favoriteItems.length,
              itemBuilder: (context, index) {
                final item = favoriteItems[index];
                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListTile(
                    leading: Image.asset(item.imagePath,
                        width: 50, fit: BoxFit.cover),
                    title: Text(item.name,
                        style: GoogleFonts.prompt(fontSize: 18)),
                    subtitle: Text(item.price,
                        style: GoogleFonts.prompt(fontSize: 16)),
                  ),
                );
              },
            ),
    );
  }
}

class MenuScreen extends StatelessWidget {
  final Function(MenuItem, bool) onFavoriteToggled;
  final List<MenuItem> favoriteItems;
  final Function(MenuItem) onAddToCart;
  final List<CartItem> cartItems;
  final Function(int) removeFromCart;

  const MenuScreen({
    super.key,
    required this.onFavoriteToggled,
    required this.favoriteItems,
    required this.onAddToCart,
    required this.cartItems,
    required this.removeFromCart,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {},
        ),
        title: Text(
          'Our Menu',
          style: GoogleFonts.prompt(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  showCartDialog(context);
                },
              ),
              if (cartItems.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      cartItems
                          .fold(0, (sum, item) => sum + item.quantity)
                          .toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: menuItems.length,
        itemBuilder: (context, index) {
          return MenuItemCard(
            menuItem: menuItems[index],
            isFavorite: favoriteItems.contains(menuItems[index]),
            onFavoriteToggled: onFavoriteToggled,
            onAddToCart: onAddToCart,
          );
        },
      ),
    );
  }

  void showCartDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Shopping Cart',
          style: GoogleFonts.prompt(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: cartItems.isEmpty
              ? Text(
                  'Your cart is empty',
                  style: GoogleFonts.prompt(fontSize: 16),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final item = cartItems[index];
                    return ListTile(
                      leading: Image.asset(
                        item.menuItem.imagePath,
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                      ),
                      title: Text(
                        item.menuItem.name,
                        style: GoogleFonts.prompt(fontSize: 16),
                      ),
                      subtitle: Text(
                        '${item.menuItem.price} x ${item.quantity}',
                        style: GoogleFonts.prompt(fontSize: 14),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          removeFromCart(index);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('ลบเมนูสินค้าเรียบร้อยแล้ว'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: GoogleFonts.prompt(),
            ),
          ),
        ],
      ),
    );
  }
}

class DetailMenu extends StatelessWidget {
  const DetailMenu({
    super.key,
    required this.name,
    required this.price,
    required this.imagePath,
    required this.description,
    required this.onAddToCart,
    required this.menuItem,
  });

  final String name;
  final String price;
  final String imagePath;
  final String description;
  final Function(MenuItem) onAddToCart;
  final MenuItem menuItem;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          name,
          style: GoogleFonts.prompt(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Image.asset(
            imagePath,
            height: 250,
            fit: BoxFit.cover,
          ),
          Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: GoogleFonts.prompt(
                          fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(
                    height: 8,
                  ),
                  Text(
                    description,
                    style: GoogleFonts.prompt(fontSize: 16),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Text(
                    "Price : $price",
                    style: GoogleFonts.prompt(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              )),
          const SizedBox(height: 250),
          SizedBox(
            height: 40,
            width: 200,
            child: FilledButton(
              onPressed: () {
                onAddToCart(menuItem);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${menuItem.name} x1 ถูกเพิ่มลงในตะกร้า'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: Text(
                "Add to Cart",
                style: GoogleFonts.prompt(
                    fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MenuItem {
  final String name;
  final String price;
  final String imagePath;
  final String description;

  MenuItem({
    required this.name,
    required this.price,
    required this.imagePath,
    required this.description,
  });
}

class MenuItemCard extends StatelessWidget {
  final MenuItem menuItem;
  final bool isFavorite;
  final Function(MenuItem, bool) onFavoriteToggled;
  final Function(MenuItem) onAddToCart;

  const MenuItemCard({
    super.key,
    required this.menuItem,
    required this.isFavorite,
    required this.onFavoriteToggled,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailMenu(
              name: menuItem.name,
              price: menuItem.price,
              imagePath: menuItem.imagePath,
              description: menuItem.description,
              onAddToCart: onAddToCart,
              menuItem: menuItem,
            ),
          ),
        );
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                  child: Image.asset(
                    menuItem.imagePath,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: GestureDetector(
                    onTap: () {
                      onFavoriteToggled(menuItem, !isFavorite);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.grey,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      menuItem.name,
                      style: GoogleFonts.prompt(
                          fontSize: 14, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      menuItem.description,
                      style: GoogleFonts.prompt(
                          fontSize: 12, color: Colors.grey[600]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Text(
                      menuItem.price,
                      style: GoogleFonts.prompt(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final List<MenuItem> menuItems = [
  MenuItem(
    name: 'ข้าวผัดกุ้ง',
    price: '120฿',
    imagePath: 'assets/images/kaowpad.png',
    description: 'ข้าวผัดกุ้งสดใหม่ ใส่ไข่ ผักสด รสชาติอร่อย',
  ),
  MenuItem(
    name: 'ข้าวมันไก่สิงคโปร์',
    price: '100฿',
    imagePath: 'assets/images/chicken-rice.png',
    description: 'ข้าวมันไก่สูตรสิงคโปร์ เสิร์ฟพร้อมน้ำจิ้มสูตรพิเศษ',
  ),
  MenuItem(
    name: 'กะเพราหมูสับไข่ดาว',
    price: '90฿',
    imagePath: 'assets/images/krapao.png',
    description: 'กะเพราหมูสับ ใส่ไข่ดาว รสชาติจัดจ้าน',
  ),
  MenuItem(
    name: 'สามชั้นคั่วพริกเกลือ',
    price: '95฿',
    imagePath: 'assets/images/mookorb.png',
    description: 'หมูสามชั้นทอดกรอบ คั่วพริกเกลือ รสชาติเข้มข้น',
  ),
  MenuItem(
    name: 'ผัดไทยกุ้งสด',
    price: '140฿',
    imagePath: 'assets/images/padthai.png',
    description: 'ผัดไทยกุ้งสด ใส่ไข่ ถั่วงอก กุ้งสดขนาดใหญ่',
  ),
  MenuItem(
    name: 'ผัดมาม่าไข่',
    price: '80฿',
    imagePath: 'assets/images/mama.png',
    description: 'ผัดมาม่าใส่ไข่ เพิ่มผักสด รสชาติกลมกล่อม',
  ),
];

class CartItem {
  final MenuItem menuItem;
  int quantity;

  CartItem({
    required this.menuItem,
    this.quantity = 1,
  });
}
