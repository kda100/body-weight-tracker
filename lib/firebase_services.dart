import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'constants/field_names.dart';
import 'models/update_status.dart';
import 'models/weight_record_with_id.dart';

///class that is responsible for communication of data between the firestore backend and the
///body weight tracker provider.

class FirebaseServices {
  CollectionReference? _weightRecordsColRef = FirebaseFirestore.instance
      .collection("Your Weight Records Collection"); //ColRef where weight records will be store.
  DocumentReference? _targetDocRef = FirebaseFirestore.instance
      .doc("Your Target Document"); //DocRef where target will be stored
  final Duration _timeOutDuration = Duration(seconds: 3);

  List<QueryDocumentSnapshot>? _overwriteDocs;

  removeOverwriteDocs() {
    _overwriteDocs = null;
  }

  ///This function fetches Weight Records from Firestore and returns List<WeightRecord> and returns to body weight tracker provider.
  Future<List<WeightRecordWithId>> fetchWeightRecords(
      {required DateTimeRange dateTimeRange}) async {
    final List<WeightRecordWithId> weightRecords = [];
    final List<QueryDocumentSnapshot>? queryDocSnapshot =
        (await _weightRecordsColRef
                ?.where(
                  FieldNames.dateField,
                  isGreaterThanOrEqualTo: dateTimeRange.start,
                  isLessThanOrEqualTo: dateTimeRange.end,
                )
                .get())
            ?.docs;
    queryDocSnapshot?.forEach((docSnapshot) {
      if (docSnapshot.exists) {
        final Map<String, dynamic>? docData = docSnapshot.data();
        if (docData != null) {
          weightRecords.add(
            WeightRecordWithId(
              id: docSnapshot.id,
              dateTime: docData[FieldNames.dateField].toDate(),
              weight: docData[FieldNames.weightField].toDouble(),
            ),
          );
        }
      }
    });
    return weightRecords;
  }

  ///responsible for fetching the target from firestore doc.
  Future<double?> fetchTarget() async {
    final DocumentSnapshot? docSnapshot = await _targetDocRef?.get();
    if (docSnapshot != null) {
      if (docSnapshot.exists) {
        if (docSnapshot.data()?.isNotEmpty ?? false) {
          final double target = docSnapshot[FieldNames.targetField].toDouble();
          return target;
        }
      }
    }
    return null;
  }

  ///checks if a weight record already exists for the date given.
  Future<UpdateStatus> queryFirestoreWithDate(
      {required DateTime dateTime}) async {
    List<QueryDocumentSnapshot>? queryDocSnapshot;
    try {
      queryDocSnapshot = (await _weightRecordsColRef
              ?.where(FieldNames.dateField, isEqualTo: dateTime)
              .get()
              .timeout(_timeOutDuration))
          ?.docs;
    } catch (e) {
      return UpdateStatus.ERROR;
    }
    if (queryDocSnapshot != null && queryDocSnapshot.length > 0) {
      _overwriteDocs =
          queryDocSnapshot; // saves a reference to docs to be overwritten.
      return UpdateStatus.OVERWRITE;
    }
    return UpdateStatus.SUCCESS;
  }

  ///adds a new weight record doc to firestore col and returns WeightRecordWithId to body weight tracker provider.
  Future<WeightRecordWithId?> addWeightRecordToFirestore(
      {required DateTime dateTime, required double weight}) async {
    final DocumentReference? docRef = _weightRecordsColRef?.doc();
    if (docRef != null) {
      try {
        await docRef.set(
          {
            FieldNames.dateField: Timestamp.fromDate(dateTime),
            FieldNames.weightField: weight,
          },
        ).timeout(_timeOutDuration);
      } catch (e) {
        return null;
      }
      return WeightRecordWithId(
          id: docRef.id, dateTime: dateTime, weight: weight);
    }
    return null;
  }

  ///deletes weight record from Firestore.
  Future<UpdateStatus> deleteWeightRecordFromFirestore(
      {required String id}) async {
    try {
      await _weightRecordsColRef?.doc(id).delete().timeout(_timeOutDuration);
    } catch (e) {
      return UpdateStatus.ERROR;
    }
    return UpdateStatus.SUCCESS;
  }

  ///overwrites firestore doc and replaces weight field with new weight field.
  ///Then return new WeightRecordWithId.
  Future<WeightRecordWithId?> overwriteFirestoreDoc(
      {required double weight, required DateTime dateTime}) async {
    DocumentReference? documentReference;
    try {
      final int overwriteDocsLen = _overwriteDocs?.length ?? 0;
      for (int i = 0; i < overwriteDocsLen; i++) {
        final QueryDocumentSnapshot? queryDocumentSnapshot = _overwriteDocs?[i];
        if (i == overwriteDocsLen - 1) {
          //overwrite last doc in overwrite docs query.
          documentReference =
              _weightRecordsColRef?.doc(queryDocumentSnapshot?.id);
          await documentReference?.update({
            FieldNames.weightField: weight,
          }).timeout(_timeOutDuration);
        } else //deletes any excess docs in the overwrite docs query.
          await _weightRecordsColRef
              ?.doc(queryDocumentSnapshot?.id)
              .delete()
              .timeout(_timeOutDuration);
      }
    } catch (e) {
      return null;
    }
    removeOverwriteDocs();
    if (documentReference != null) {
      return WeightRecordWithId(
        id: documentReference.id,
        dateTime: dateTime,
        weight: weight,
      );
    }
  }

  ///sets a new target field in the firestore doc where target field is held.
  Future<UpdateStatus> setNewTargetToFirestore({double? target}) async {
    try {
      await _targetDocRef
          ?.set(target != null
              ? {
                  FieldNames.targetField: target,
                }
              : {})
          .timeout(_timeOutDuration);
    } catch (e) {
      return UpdateStatus.ERROR;
    }
    return UpdateStatus.SUCCESS;
  }

  ///changes doc in firestore where target is held to a empty doc.
  Future<UpdateStatus> removeTargetFromFirestore() async {
    try {
      await _targetDocRef?.set({}).timeout(_timeOutDuration);
    } catch (e) {
      return UpdateStatus.ERROR;
    }
    return UpdateStatus.SUCCESS;
  }
}
