import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

final FirebaseFirestore firestore = FirebaseFirestore.instance;

class DataFirebase extends ChangeNotifier {
  void savePatientLocation(double lat, double lon) {
    var patient = {'latitude': lat, 'longitude': lon};

    firestore
        .collection('Location')
        .doc('patient')
        .set(patient)
        .catchError((error) {
      print('Error save home location: $error');
    });
  }

  void savePatirntSpeed(double speed) {
    var walkPatient = {'speed': speed};

    firestore
        .collection('Caculate')
        .doc('speed')
        .set(walkPatient)
        .catchError((error) {
      print('Error save home location: $error');
    });
  }
}
