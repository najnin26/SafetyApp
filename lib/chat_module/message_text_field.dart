import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MessageTextField extends StatefulWidget {
  final String currentId;
  final String friendId;
  const MessageTextField({super.key,
    required this.currentId,
    required this.friendId});

  @override
  State<MessageTextField> createState() => _MessageTextFieldState();
}

class _MessageTextFieldState extends State<MessageTextField> {
  TextEditingController _controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              cursorColor: Colors.pink,
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Type your message',
                fillColor: Colors.grey[100],
                filled: true,
                prefixIcon: IconButton(
                  onPressed:(){
                    showModalBottomSheet(
                      backgroundColor: Colors.transparent,
                      context: context,
                      builder: (context) => bottomsheet(),
                    );
                  },
                  icon: Icon(
                      Icons.add_box_rounded,
                      color: Colors.pink,
                  )),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              onTap: () async {
                _controller.clear();
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(widget.currentId)
                    .collection('messages')
                    .doc(widget.friendId)
                    .collection('chats')
                    .add({
                  'senderId': widget.currentId,
                  'receiverId': widget.friendId,
                  'message': _controller.text,
                  'type': 'text',
                  'date': DateTime.now(),
                });
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(widget.friendId)
                    .collection('messages')
                    .doc(widget.currentId)
                    .collection('chats')
                    .add({
                  'senderId': widget.currentId,
                  'receiverId': widget.friendId,
                  'message': _controller.text,
                  'type': 'text',
                  'date': DateTime.now(),
                });
              },
              child: Icon(
              Icons.send,
              color: Colors.pink,
                size: 30,
              ),
            ),
          ),
        ],
      ),
    );
  }

  bottomsheet() {
    return Container(
      height: MediaQuery.of(context).size.height*0.2,
      width: double.infinity,
      child: Card(
        margin: EdgeInsets.all(18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            chatIcon(Icons.location_pin,"Location",(){}),
            chatIcon(Icons.camera_alt,"Camera",(){}),
            chatIcon(Icons.insert_photo,"Photo",(){}),
          ],
        ),
      ),
    );
  }

  chatIcon(IconData icons,String title,VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.pink,
            child: Icon(icons),
          ),
          Text('$title')
        ],
      ),
    );
  }
}
