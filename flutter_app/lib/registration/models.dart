// Hosteler model for registration
class Hosteler {
  String name;
  String roomNumber;
  String contactNumber;
  DateTime joiningDate;
  String status; // 'Active' or 'Inactive'
  String profilePhotoPath;
  List<int>? profilePhotoBytes;
  String registrationDocPath;
  List<int>? registrationDocBytes;
  String aadharNumber;
  String aadharPhotoPath;
  List<int>? aadharPhotoBytes;
  String emergencyContact;
  String contactAddress;
  String workAddress;
  double advanceAmount;
  String roomType; // 'AC Single', 'AC Double Sharing', 'Non-AC 4 Sharing'

  Hosteler({
  required this.name,
  required this.roomNumber,
  required this.contactNumber,
  required this.joiningDate,
  required this.status,
  required this.profilePhotoPath,
  this.profilePhotoBytes,
  required this.registrationDocPath,
  this.registrationDocBytes,
  required this.aadharNumber,
  required this.aadharPhotoPath,
  this.aadharPhotoBytes,
  required this.emergencyContact,
  required this.contactAddress,
  required this.workAddress,
  required this.advanceAmount,
  required this.roomType,
  });

  Map<String, dynamic> toJson() => {
  'name': name,
  'roomNumber': roomNumber,
  'contactNumber': contactNumber,
  'joiningDate': joiningDate.toIso8601String(),
  'status': status,
  'profilePhotoPath': profilePhotoPath,
  'profilePhotoBytes': profilePhotoBytes,
  'registrationDocPath': registrationDocPath,
  'registrationDocBytes': registrationDocBytes,
  'aadharNumber': aadharNumber,
  'aadharPhotoPath': aadharPhotoPath,
  'aadharPhotoBytes': aadharPhotoBytes,
  'emergencyContact': emergencyContact,
  'contactAddress': contactAddress,
  'workAddress': workAddress,
  'advanceAmount': advanceAmount,
  'roomType': roomType,
  };

  static Hosteler fromJson(Map<String, dynamic> json) => Hosteler(
  name: json['name'],
  roomNumber: json['roomNumber'],
  contactNumber: json['contactNumber'],
  joiningDate: DateTime.parse(json['joiningDate']),
  status: json['status'],
  profilePhotoPath: json['profilePhotoPath'],
  profilePhotoBytes: (json['profilePhotoBytes'] != null) ? List<int>.from(json['profilePhotoBytes']) : null,
  registrationDocPath: json['registrationDocPath'],
  registrationDocBytes: (json['registrationDocBytes'] != null) ? List<int>.from(json['registrationDocBytes']) : null,
  aadharNumber: json['aadharNumber'],
  aadharPhotoPath: json['aadharPhotoPath'],
  aadharPhotoBytes: (json['aadharPhotoBytes'] != null) ? List<int>.from(json['aadharPhotoBytes']) : null,
  emergencyContact: json['emergencyContact'],
  contactAddress: json['contactAddress'],
  workAddress: json['workAddress'],
  advanceAmount: (json['advanceAmount'] as num).toDouble(),
  roomType: json['roomType'],
  );
}

// Admin model for login
class Admin {
  String username;
  String password;
  Admin({required this.username, required this.password});
}
