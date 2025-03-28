import 'package:flutter/material.dart';

class EnqueteCard extends StatelessWidget {
  final String title;
  final String description;
  final String image;
  final String status;
  final VoidCallback onTap;

  const EnqueteCard({
    required this.title,
    required this.description,
    required this.image,
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    Color statusColor;
    switch (status.toLowerCase()) {
      case 'active':
        statusColor = Colors.green;
        break;
      case 'pending':
        statusColor = Colors.orange;
        break;
      default:
        statusColor = Colors.red;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: screenWidth * 0.3, 
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(image, height: screenHeight * 0.08, width: screenWidth * 0.15), 
                SizedBox(height: screenHeight * 0.01),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xff0A1B34),
                    fontSize: screenWidth * 0.03, 
                  ),
                ),
                SizedBox(height: screenHeight * 0.01),
                ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xff0A1B34),
                    padding: EdgeInsets.symmetric(vertical: screenHeight * 0.005, horizontal: screenWidth * 0.04), 
                  ),
                  child: Text(
                    'S\'inscrire',
                    style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.03), 
                  ),
                ),
              ],
            ),
            Positioned(
              top: screenHeight * 0.01,
              right: screenWidth * 0.01,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02, vertical: screenHeight * 0.005),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: screenWidth * 0.025, 
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}