// To parse this JSON data, do
//
//     final getAllServiceModel = getAllServiceModelFromJson(jsonString);

import 'dart:convert';

List<GetAllServiceModel> getAllServiceModelFromJson(String str) =>
    List<GetAllServiceModel>.from(
        json.decode(str).map((x) => GetAllServiceModel.fromJson(x)));

String getAllServiceModelToJson(List<GetAllServiceModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetAllServiceModel {
  GetAllServiceModel({
    this.id,
    this.kendala,
    this.jenis,
    this.tipe,
    this.idKaryawan,
    this.namaPelanggan,
    this.status,
    this.finishedAt,
    this.tglMasuk,
  });

  final String id;
  final String kendala;
  final String jenis;
  final String tipe;
  final String idKaryawan;
  final String namaPelanggan;
  final String status;
  final DateTime finishedAt;
  final DateTime tglMasuk;

  factory GetAllServiceModel.fromJson(Map<String, dynamic> json) =>
      GetAllServiceModel(
        id: json["id"],
        kendala: json["kendala"],
        jenis: json["jenis"],
        tipe: json["tipe"],
        idKaryawan: json["id_karyawan"] == null ? null : json["id_karyawan"],
        namaPelanggan: json["nama_pelanggan"],
        status: json["status"],
        finishedAt: json["finishedAt"] == null
            ? null
            : DateTime.parse(json["finishedAt"]),
        tglMasuk: DateTime.parse(json["tgl_masuk"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "kendala": kendala,
        "jenis": jenis,
        "tipe": tipe,
        "id_karyawan": idKaryawan == null ? null : idKaryawan,
        "nama_pelanggan": namaPelanggan,
        "status": status,
        "finishedAt": finishedAt == null ? null : finishedAt.toIso8601String(),
        "tgl_masuk": tglMasuk.toIso8601String(),
      };
}
