import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Contactuscomponent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 393,
          height: 852,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(color: Color(0xFF012435)),
          child: Stack(
            children: [
              Positioned(
                left: 0,
                top: 326,
                child: Container(
                  width: 393,
                  height: 588,
                  decoration: ShapeDecoration(
                    color: Color(0xFFEF9823),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(67),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 39,
                top: 227,
                child: Text(
                  'Need some helps?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 35,
                    fontFamily: 'Work Sans',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Positioned(
                left: 39,
                top: 185,
                child: Text(
                  'Had trouble,',
                  style: GoogleFonts.workSans(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Positioned(
                left: 88,
                top: 367,
                child: Text(
                  'Contact Us',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontFamily: 'Work Sans',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Positioned(
                left: 96,
                top: 461,
                child: Text(
                  '+62 85649671617',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontFamily: 'Work Sans',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Positioned(
                left: 43,
                top: 503,
                child: Text(
                  'angelgarang69@yahoo.die',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontFamily: 'Work Sans',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Positioned(
                left: 23,
                top: 545,
                child: Text(
                  'emdubois777@ambulemah.id',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontFamily: 'Work Sans',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Positioned(
                left: 52,
                top: 587,
                child: Text(
                  'yogilistianto@gmail.com',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontFamily: 'Work Sans',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Positioned(
                left: 42,
                top: 629,
                child: Text(
                  'bozzulltoptier@papiculo.il',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontFamily: 'Work Sans',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Positioned(
                left: 183,
                top: 689,
                child: Text(
                  'Or',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontFamily: 'Work Sans',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Positioned(
                left: 87,
                top: 749,
                child: Text(
                  '@Aynoor.riziq on X',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontFamily: 'Work Sans',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Positioned(
                left: 22,
                top: 75,
                child: Container(
                  width: 25,
                  height: 25,
                  // decoration: BoxDecoration(
                  //   image: DecorationImage(
                  //     image: NetworkImage("https://via.placeholder.com/25x25"),
                  //     fit: BoxFit.fill,
                  //   ),
                  // ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}