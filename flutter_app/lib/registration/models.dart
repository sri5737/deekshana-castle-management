// Hosteler model for registration
class Hosteler {
  String name;
  String roomNumber;
  String contactNumber;
  DateTime joiningDate;
  String status; // 'Active' or 'Inactive'
  String profilePhotoPath;
  String registrationDocPath;
  String aadharNumber;
  String aadharPhotoPath;
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
    required this.registrationDocPath,
    required this.aadharNumber,
    required this.aadharPhotoPath,
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
    'registrationDocPath': registrationDocPath,
    'aadharNumber': aadharNumber,
    'aadharPhotoPath': aadharPhotoPath,
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
    registrationDocPath: json['registrationDocPath'],
    aadharNumber: json['aadharNumber'],
    aadharPhotoPath: json['aadharPhotoPath'],
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
