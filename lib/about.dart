import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<StatefulWidget> createState() => _aboutPage();
}

class _aboutPage extends State<AboutPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "About Page🧾",
          style: TextStyle(fontFamily: "heading"),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          Center(
              child: Column(
            children: [
              const Text(
                "Developed By:",
                style: TextStyle(fontFamily: "heading", color: Colors.white),
              ),
              const SizedBox(
                height: 15,
              ),
              const Text(
                "KAVIN M",
                style: TextStyle(
                    fontFamily: "heading", color: Colors.white, fontSize: 30),
              ),
              const SizedBox(
                height: 25,
              ),
              const Text(
                "Contact: \n\nPhone No: +91 9344042424 \n\nEmail : mkavin2005@gmail.com \n\nInstagram : i_kavinm\n\n",
                style: TextStyle(
                    fontFamily: "heading", color: Colors.white, fontSize: 16),
              ),
              InkWell(
                child: const Text("Linkedin : Kavin M",
                    style: TextStyle(
                        fontFamily: "heading",
                        color: Colors.white,
                        fontSize: 16)),
                onTap: () async {
                  final Uri url =
                      Uri.parse("https://www.linkedin.com/in/kavin-m--/");
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url);
                  } else {
                    // Handle the case where the URL can't be launched
                    print("Could not launch $url");
                  }
                },
              )
            ],
          ))
        ],
      ),
    );
  }
}
