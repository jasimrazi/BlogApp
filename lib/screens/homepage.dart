import 'package:apiapp/services/api_services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final SignupService _signupService = SignupService();
  List<Map<String, dynamic>> blogs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBlogs();
  }

  Future<void> _fetchBlogs() async {
    try {
      List<dynamic> fetchedBlogs = await _signupService.getBlogs(context);
      List<Map<String, dynamic>> parsedBlogs =
          fetchedBlogs.map((blog) => blog as Map<String, dynamic>).toList();
      setState(() {
        blogs = parsedBlogs;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching blogs: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: isLoading
            ? Center(child: CupertinoActivityIndicator())
            : blogs.isEmpty
                ? Center(child: Text('No blogs found'))
                : ListView.builder(
                    physics: BouncingScrollPhysics(),
                    itemCount: blogs.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: EdgeInsets.symmetric(vertical: 8.0),
                        padding: EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            blogs[index]['image'] != null
                                ? Image.network(
                                    blogs[index]['image'],
                                    height: 150.0,
                                    width: double.infinity,
                                    fit: BoxFit.contain,
                                  )
                                : Container(),
                            SizedBox(height: 8.0),
                            Text(
                              blogs[index]['title'] ?? '',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 4.0),
                            Text(
                              blogs[index]['content'] ?? '',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                            SizedBox(height: 4.0),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                'by ${blogs[index]['author'] ?? ''}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
