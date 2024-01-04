import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ReviewPage extends StatefulWidget {
  @override
  _ReviewPageState createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  TextEditingController locationC = TextEditingController();
  TextEditingController viewsC = TextEditingController();
  TextEditingController searchController = TextEditingController();
  bool isSaving = false;

  showAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text("Review your place"),
          content: Form(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Enter location',
                    ),
                    controller: locationC,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: viewsC,
                    decoration: InputDecoration(
                      hintText: 'Enter message',
                    ),
                    maxLines: 3,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                saveReview();
                Navigator.pop(context);
              },
              child: Text("SAVE"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  saveReview() async {
    setState(() {
      isSaving = true;
    });
    await FirebaseFirestore.instance
        .collection('reviews')
        .add({'location': locationC.text, 'views': viewsC.text})
        .then((value) {
      setState(() {
        isSaving = false;
        Fluttertoast.showToast(msg: 'Review uploaded successfully');
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isSaving
          ? Center(child: CircularProgressIndicator())
          : SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search by place...',
                  hintStyle: TextStyle(color: Colors.black),
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (value) {
                  setState(() {
                  });
                },
              ),
            ),
            Text(
              "Recent Review by others",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('reviews')
                    .where('location', isEqualTo: searchController.text)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (BuildContext context, int index) {
                      final data = snapshot.data!.docs[index];
                      return Padding(
                        padding: const EdgeInsets.all(3.0),
                        child: Card(
                          elevation: 10,
                          child: ListTile(
                            title: Text(
                              data['location'],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(data['views']),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.pink,
        onPressed: () {
          showAlert(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: ReviewPage(),
  ));
}
