import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:donidata/constante/category_item.dart';
import 'package:donidata/constante/enquete_card.dart';
import 'package:donidata/provider/enquete_provider.dart';
import 'package:donidata/provider/userProvider.dart';
import 'package:donidata/screen/drawer/notification_page.dart';
import 'package:donidata/screen/custom_drawer.dart';
import 'package:donidata/screen/detailsEnquete.dart';
import 'package:donidata/screen/profil_screen.dart';

class Accueil extends StatefulWidget {
  const Accueil({super.key});

  @override
  State<Accueil> createState() => _AccueilState();
}

class _AccueilState extends State<Accueil> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int selectedCategory = 0;
  final List<Map<String, dynamic>> categories = [
    {'name': 'Tout', 'icon': Icons.widgets},
    {'name': 'Ongs', 'icon': Icons.volunteer_activism},
    {'name': 'Entreprises', 'icon': Icons.business},
    {'name': 'Gouvernements', 'icon': Icons.account_balance},
  ];

  void _showInscriptionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Inscription impossible"),
          content: Text("Vous ne pouvez pas vous inscrire à une enquête en cours ou active."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchInitialData();
    });
  }

  void _fetchInitialData() {
    final enqueteProvider = Provider.of<EnqueteProvider>(context, listen: false);
    enqueteProvider.fetchEnquetes(context); // Appelle fetchEnquetes avec le BuildContext
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;
    final enqueteProvider = Provider.of<EnqueteProvider>(context);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.blue[100],
        elevation: 0,
        toolbarHeight: 80,
        leading: Padding(
          padding: EdgeInsets.all(screenWidth * 0.02),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileScreen()),
              );
            },
            child: userProvider.isLoading
                ? Center(child: CircularProgressIndicator())
                : userProvider.user == null
                    ? Center(child: Text("Aucun utilisateur connecté ou données non disponibles."))
                    : CircleAvatar(
                        backgroundImage: user?.photoUrl != null
                            ? NetworkImage(user!.photoUrl!)
                            : AssetImage('assets/images/logo.png') as ImageProvider,
                        radius: screenWidth * 0.05,
                      ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user?.fullname ?? 'Nom inconnu',
              style: TextStyle(
                fontSize: screenWidth * 0.05,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            Text(
              "Enqueteur",
              style: TextStyle(
                fontSize: screenWidth * 0.035,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.notifications_none,
              color: Colors.black,
              size: screenWidth * 0.07,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationSettingsPage()),
              );
            },
          ),
          IconButton(
            icon: Icon(
              Icons.menu,
              color: Colors.black,
              size: screenWidth * 0.07,
            ),
            onPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
        ],
      ),
      drawer: CustomDrawer(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: screenHeight * 0.02),
              child: Center(
                child: Text(
                  'BIENVENUE',
                  style: TextStyle(
                    fontSize: screenWidth * 0.05,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(categories.length, (index) {
                  return CategoryItem(
                    name: categories[index]['name'],
                    icon: categories[index]['icon'],
                    isSelected: selectedCategory == index,
                    onTap: () {
                      setState(() {
                        selectedCategory = index;
                      });
                    },
                  );
                }),
              ),
            ),
            SizedBox(height: screenHeight * 0.03),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
              child: Consumer<EnqueteProvider>(
                builder: (context, enqueteProvider, child) {
                  if (enqueteProvider.isLoading) {
                    return Center(child: CircularProgressIndicator());
                  }
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.6,
                    ),
                    itemCount: enqueteProvider.enquetes.length,
                    itemBuilder: (context, index) {
                      final enquete = enqueteProvider.enquetes[index];
                      return EnqueteCard(
                        onTap: () {
                          if (enquete.status == "pending" || enquete.status == "active") {
                            _showInscriptionDialog(context);
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EnqueteDetailPage(
                                  enquete: {
                                    'title': enquete.title,
                                    'description': enquete.description,
                                  },
                                ),
                              ),
                            );
                          }
                        },
                        title: enquete.title,
                        description: enquete.title, 
                        image: 'assets/images/logo.png',
                        status: enquete.status,
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
}