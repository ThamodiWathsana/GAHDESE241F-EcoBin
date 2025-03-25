import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BinStatusPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Bin Status'), centerTitle: true),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('bins').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var bins = snapshot.data!.docs;

          return GridView.builder(
            padding: EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1,
            ),
            itemCount: bins.length,
            itemBuilder: (context, index) {
              var bin = bins[index];
              return _BinStatusCard(
                name: bin['name'] ?? 'Bin ${index + 1}',
                isFull: bin['isFull'] ?? false,
              );
            },
          );
        },
      ),
    );
  }
}

class _BinStatusCard extends StatelessWidget {
  final String name;
  final bool isFull;

  const _BinStatusCard({required this.name, required this.isFull});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: isFull ? Colors.red[100] : Colors.green[100],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.delete,
            size: 50,
            color: isFull ? Colors.red : Colors.green,
          ),
          SizedBox(height: 10),
          Text(
            name,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isFull ? Colors.red : Colors.green,
            ),
          ),
          SizedBox(height: 10),
          Text(
            isFull ? 'Full' : 'Not Full',
            style: TextStyle(
              fontSize: 16,
              color: isFull ? Colors.red : Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}
