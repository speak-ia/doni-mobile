import 'package:donidata/authentification/login.dart';
import 'package:donidata/provider/userProvider.dart';
import 'package:donidata/screen/drawer/faq.dart';
import 'package:donidata/screen/drawer/motdepass.dart';
import 'package:donidata/screen/drawer/politique.dart';
import 'package:donidata/screen/drawer/profil_edit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue[100],
            ),
            child: userProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: (user?.photoUrl?.isNotEmpty ?? false) == true
                            ? NetworkImage(user!.photoUrl!)
                            : const AssetImage('assets/images/logo.png')
                                as ImageProvider,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        user?.fullname ?? 'Nom inconnu',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        user?.email ?? 'Email non disponible',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
          ),
          ListTile(
            leading: const Icon(Icons.brightness_6),
            title: const Text('Mode sombre & Lumière'),
            trailing: Switch(
              value: userProvider.isDarkMode,
              onChanged: (bool value) {
                userProvider.toggleDarkMode(); 
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Changer le mot de passe'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PasswordManagementPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Langue'),
            onTap: () {
              
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Modifier profil'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfilePage(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.article),
            title: const Text('Termes & Conditions'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PrivacyPolicyPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Politique de confidentialité'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PrivacyPolicyPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Aide'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FAQPage()),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Déconnexion"),
            onTap: () {
              FirebaseAuth.instance.signOut(); 
              Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
            },
          ),
        ],
      ),
    );
  }
}
