// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:equatable/equatable.dart';

// class ReadingPlan extends Equatable {
//   final String id;
//   final String title;
//   final String description;
//   final String duration; // e.g., "30 Days"
//   final String headerImageAssetPath; // Can be local asset or network URL
//   final bool isPremium;
//   final int version;
//   final List<ReadingDay> days;
//   final String? category;
//   final int? orderIndex;

//   const ReadingPlan({
//     required this.id,
//     required this.title,
//     required this.description,
//     required this.duration,
//     required this.headerImageAssetPath,
//     this.isPremium = false,
//     required this.version,
//     required this.days,
//     this.category,
//     this.orderIndex,
//   });

//   @override
//   List<Object?> get props => [
//         id,
//         title,
//         description,
//         duration,
//         headerImageAssetPath,
//         isPremium,
//         version,
//         days,
//         category,
//         orderIndex,
//       ];

//   // Helper to check if the image path is a network URL
//   bool get isHeaderImageNetworkUrl =>
//       headerImageAssetPath.startsWith('http://') ||
//       headerImageAssetPath.startsWith('https://');

//   // Factory constructor to create a ReadingPlan from a Firestore document
//   factory ReadingPlan.fromFirestore(DocumentSnapshot doc) {
//     Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
//     return ReadingPlan(
//       id: doc.id,
//       title: data['title'] ?? 'Untitled Plan',
//       description: data['description'] ?? 'No description available.',
//       duration: data['duration'] ?? 'N/A',
//       headerImageAssetPath: data['headerImageAssetPath'] ?? 'assets/images/default_plan_header.png', // Default local asset
//       isPremium: data['isPremium'] ?? false,
//       version: data['version'] ?? 1,
//       days: (data['days'] as List<dynamic>? ?? [])
//           .map((dayData) =>
//               ReadingDay.fromMap(dayData as Map<String, dynamic>))
//           .toList(),
//       category: data['category'] as String?,
//       orderIndex: data['orderIndex'] as int?,
//     );
//   }

//   // Factory constructor to create a ReadingPlan from a local map (e.g., bundled JSON)
//   factory ReadingPlan.fromMap(Map<String, dynamic> map) {
//     return ReadingPlan(
//       id: map['id'] ?? 'local_${DateTime.now().millisecondsSinceEpoch}',
//       title: map['title'] ?? 'Untitled Plan',
//       description: map['description'] ?? 'No description available.',
//       duration: map['duration'] ?? 'N/A',
//       headerImageAssetPath: map['headerImageAssetPath'] ?? 'assets/images/default_plan_header.png', // Default local asset
//       isPremium: map['isPremium'] ?? false,
//       version: map['version'] ?? 1,
//       days: (map['days'] as List<dynamic>? ?? [])
//           .map((dayData) =>
//               ReadingDay.fromMap(dayData as Map<String, dynamic>))
//           .toList(),
//       category: map['category'] as String?,
//       orderIndex: map['orderIndex'] as int?,
//     );
//   }

//   Map<String, dynamic> toMap() {
//     return {
//       'title': title,
//       'description': description,
//       'duration': duration,
//       'headerImageAssetPath': headerImageAssetPath,
//       'isPremium': isPremium,
//       'version': version,
//       'days': days.map((day) => day.toMap()).toList(),
//       'category': category,
//       'orderIndex': orderIndex,
//     };
//   }

//   ReadingPlan copyWith({
//     String? id,
//     String? title,
//     String? description,
//     String? duration,
//     String? headerImageAssetPath,
//     bool? isPremium,
//     int? version,
//     List<ReadingDay>? days,
//     String? category,
//     int? orderIndex,
//     bool? forceNullCategory,
//     bool? forceNullOrderIndex,
//   }) {
//     return ReadingPlan(
//       id: id ?? this.id,
//       title: title ?? this.title,
//       description: description ?? this.description,
//       duration: duration ?? this.duration,
//       headerImageAssetPath: headerImageAssetPath ?? this.headerImageAssetPath,
//       isPremium: isPremium ?? this.isPremium,
//       version: version ?? this.version,
//       days: days ?? this.days,
//       category: forceNullCategory == true ? null : category ?? this.category,
//       orderIndex: forceNullOrderIndex == true ? null : orderIndex ?? this.orderIndex,
//     );
//   }
// }

// class ReadingDay extends Equatable {
//   final int dayNumber;
//   final String title;
//   final String contentPath;
//   final String? audioUrl;
//   final String? scriptureReference;

//   const ReadingDay({
//     required this.dayNumber,
//     required this.title,
//     required this.contentPath,
//     this.audioUrl,
//     this.scriptureReference,
//   });

//   @override
//   List<Object?> get props => [dayNumber, title, contentPath, audioUrl, scriptureReference];

//   factory ReadingDay.fromMap(Map<String, dynamic> map) {
//     return ReadingDay(
//       dayNumber: map['dayNumber'] ?? 0,
//       title: map['title'] ?? 'Untitled Day',
//       contentPath: map['contentPath'] ?? '',
//       audioUrl: map['audioUrl'] as String?,
//       scriptureReference: map['scriptureReference'] as String?,
//     );
//   }

//   Map<String, dynamic> toMap() {
//     return {
//       'dayNumber': dayNumber,
//       'title': title,
//       'contentPath': contentPath,
//       'audioUrl': audioUrl,
//       'scriptureReference': scriptureReference,
//     };
//   }
// }