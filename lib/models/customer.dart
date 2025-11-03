class Customer {
  int id;
  int userId;
  String name;
  String address;
  String source;
  String contactNo;
  String? contactNo1;
  String status;
  String grade;
  String requirement;
  String specificNote;
  String? estimateImage;
  String mistriName;
  String? latitude;
  String? longitude;
  String visitingDate;
  String lastFollowUpDate;
  String lastFeedback;
  List<String>? estimateImageUrls;
  User user;

  Customer({
    required this.id,
    required this.userId,
    required this.name,
    required this.address,
    required this.source,
    required this.contactNo,
    this.contactNo1,
    required this.status,
    required this.grade,
    required this.requirement,
    required this.specificNote,
    this.estimateImage,
    required this.mistriName,
    this.latitude,
    this.longitude,
    required this.visitingDate,
    required this.lastFollowUpDate,
    required this.lastFeedback,
    this.estimateImageUrls,
    required this.user,
  });

  // Factory method to create a Customer from a JSON object
  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      source: json['source'] ?? '',
      contactNo: json['contact_no'] ?? '',
      contactNo1: json['contact_no_1'] ?? '',
      status: json['status'] ?? '',
      grade: json['grade'] ?? '',
      requirement: json['requirement'] ?? '',
      specificNote: json['specific_note'] ?? '',
      estimateImage: json['estimate_image'] ?? '',
      mistriName: json['mistri_name'] ?? '',
      latitude: json['latitude'] != null
          ? double.tryParse(json['latitude'].toString())?.toString() ??
                "" // Parse to string, default to empty string
          : "",

      longitude: json['longitude'] != null
          ? double.tryParse(json['longitude'].toString())?.toString() ??
                "" // Parse to string, default to empty string
          : "",
      visitingDate: json['visiting_date'] ?? '',
      lastFollowUpDate: json['last_follow_up_date'] ?? '',
      lastFeedback: json['last_feedback'] ?? '',
      estimateImageUrls: json['estimate_image_urls'] != null
          ? List<String>.from(json['estimate_image_urls'])
          : null,
      user: User.fromJson(json['user']),
    );
  }

  // Method to convert a Customer object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'address': address,
      'source': source,
      'contact_no': contactNo,
      'contact_no_1': contactNo1,
      'status': status,
      'grade': grade,
      'requirement': requirement,
      'specific_note': specificNote,
      'estimate_image': estimateImage,
      'mistri_name': mistriName,
      'latitude': latitude,
      'longitude': longitude,
      'visiting_date': visitingDate,
      'last_follow_up_date': lastFollowUpDate,
      'last_feedback': lastFeedback,
      'estimate_image_urls': estimateImageUrls,
      'user': user.toJson(),
    };
  }
}

class User {
  int id;
  String name;

  User({required this.id, required this.name});

  // Factory method to create a User from a JSON object
  factory User.fromJson(Map<String, dynamic> json) {
    return User(id: json['id'], name: json['name'] ?? '');
  }

  // Method to convert a User object to JSON
  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}
