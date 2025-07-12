// import 'dart:convert';
// import 'dart:io';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:trendera/cloudinary_service/cloudinary_service.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class ProductUploadForm extends StatefulWidget {
//   const ProductUploadForm({super.key});

//   @override
//   State<ProductUploadForm> createState() => _ProductUploadFormState();
// }

// class _ProductUploadFormState extends State<ProductUploadForm> {
//   bool isLoading = false;
//   final _formKey = GlobalKey<FormState>();

//   final idController = TextEditingController();
//   final titleController = TextEditingController();
//   final priceController = TextEditingController();
//   final companyController = TextEditingController();
//   final descriptionController = TextEditingController();
//   final ratingsController = TextEditingController();
//   final offerDescriptionController = TextEditingController();

//   File? _imageFile;
//   File? _offerImage;
//   String? selectedCarouselModel;
//   String? selectedType;
//   bool isOffer = false;

//   final List<String> selectedSizes = [];

//   final List<String> types = [
//     'Shirt',
//     'Tshirt',
//     'Hoody',
//     'Trouser',
//     'Track',
//     'Accesoriees',
//   ];

//   List<String> getSizeOptionsForType(String? type) {
//     switch (type) {
//       case 'Shirt':
//       case 'Tshirt':
//       case 'Hoody':
//       case 'Track':
//         return ['S', 'M', 'L', 'XL', '2XL', '3XL', '4XL', '5XL'];
//       case 'Trouser':
//         return List.generate(12, (i) => (28 + i * 2).toString()); // 28 to 50
//       case 'Inner':
//         return List.generate(12, (i) => (75 + i * 5).toString()); // 75 to 130
//       default:
//         return [];
//     }
//   }

//   Future<void> _pickImage() async {
//     final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
//     if (picked != null) setState(() => _imageFile = File(picked.path));
//   }

//   Future<void> _pickOfferImage() async {
//     final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
//     if (picked != null && picked.path.toLowerCase().endsWith('.png')) {
//       setState(() => _offerImage = File(picked.path));
//     } else {
//       Get.snackbar(
//         "❌ Invalid file",
//         "Only PNG images allowed",
//         backgroundColor: Colors.black,
//       );
//     }
//   }

//   Future<void> _uploadProduct() async {
//     setState(() => isLoading = true);
//     try {
//       if (!_formKey.currentState!.validate() ||
//           _imageFile == null ||
//           (getSizeOptionsForType(selectedType).isNotEmpty &&
//               selectedSizes.isEmpty) ||
//           selectedType == null ||
//           (isOffer &&
//               (_offerImage == null ||
//                   offerDescriptionController.text.isEmpty ||
//                   selectedCarouselModel == null))) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text("Fill all required fields."),
//             backgroundColor: Colors.red,
//           ),
//         );
//         setState(() => isLoading = false);
//         return;
//       }

//       final cloudinary = CloudinaryService();
//       final imageUrl = await cloudinary.uploadImage(_imageFile!);
//       if (imageUrl == null) {
//         Get.snackbar(
//           "❌ Image upload failed.",
//           "",
//           backgroundColor: Colors.black,
//         );
//         setState(() => isLoading = false);
//         return;
//       }

//       final imageBytes = await _imageFile!.readAsBytes();
//       final base64ImageString = base64Encode(imageBytes);

//       String? offerImageUrl;
//       if (isOffer && _offerImage != null) {
//         offerImageUrl = await cloudinary.uploadImage(_offerImage!);
//         if (offerImageUrl == null) {
//           Get.snackbar(
//             "❌ Offer image upload failed.",
//             "",
//             backgroundColor: Colors.black,
//           );
//           setState(() => isLoading = false);
//           return;
//         }
//       }

//       final productData = {
//         'id': idController.text.trim(),
//         'title': titleController.text.trim(),
//         'price': double.tryParse(priceController.text.trim()) ?? 0.0,
//         'company': companyController.text.trim(),
//         'imageurl': imageUrl,
//         'imageBytes': base64ImageString,
//         'productdescription': descriptionController.text.trim(),
//         'ratings': double.tryParse(ratingsController.text.trim()) ?? 0.0,
//         'type': selectedType,
//         'size': selectedSizes,
//         'createdAt': FieldValue.serverTimestamp(),
//         'isOffer': isOffer,
//       };

//       if (isOffer) {
//         productData.addAll({
//           'offerDescription': offerDescriptionController.text.trim(),
//           'offerImage': offerImageUrl,
//           'carouselModel': selectedCarouselModel,
//         });
//       }

//       await FirebaseFirestore.instance.collection('products').add(productData);

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("✅ Product uploaded!"),
//           backgroundColor: Colors.green,
//         ),
//       );

//       _formKey.currentState?.reset();
//       setState(() {
//         _imageFile = null;
//         _offerImage = null;
//         selectedSizes.clear();
//         selectedType = null;
//         isOffer = false;
//       });
//     } catch (e) {
//       Get.snackbar(
//         "❌ Upload failed.",
//         e.toString(),
//         backgroundColor: Colors.black,
//       );
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }

//   Widget buildField({
//     required TextEditingController controller,
//     required String hintText,
//     required String validatorMsg,
//     TextInputType keyboardType = TextInputType.text,
//     int maxLines = 1,
//     String? Function(String?)? validator,
//   }) {
//     return TextFormField(
//       controller: controller,
//       keyboardType: keyboardType,
//       maxLines: maxLines,
//       cursorColor: Colors.black,
//       selectionControls: materialTextSelectionControls, // blue selection
//       style: const TextStyle(fontSize: 14),
//       validator: validator ?? (value) => value!.isEmpty ? validatorMsg : null,
//       decoration: InputDecoration(
//         contentPadding: const EdgeInsets.symmetric(
//           horizontal: 12,
//           vertical: 14,
//         ),
//         labelText: hintText,
//         labelStyle: const TextStyle(fontSize: 14, color: Colors.grey),
//         filled: true,
//         fillColor: const Color(0xFFF2F2F2),
//         border: OutlineInputBorder(
//           borderSide: const BorderSide(color: Colors.grey),
//           borderRadius: BorderRadius.circular(8),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderSide: const BorderSide(color: Colors.grey),
//           borderRadius: BorderRadius.circular(8),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderSide: const BorderSide(color: Colors.black54),
//           borderRadius: BorderRadius.circular(8),
//         ),
//         errorBorder: OutlineInputBorder(
//           borderSide: const BorderSide(color: Colors.red),
//           borderRadius: BorderRadius.circular(8),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Upload Product")),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               _imageFile != null
//                   ? Image.file(_imageFile!, height: 150)
//                   : ElevatedButton.icon(
//                     onPressed: _pickImage,
//                     icon: const Icon(Icons.image),
//                     label: const Text("Pick Product Image"),
//                   ),
//               const SizedBox(height: 20),

//               buildField(
//                 controller: idController,
//                 hintText: 'Product ID',
//                 validatorMsg: 'Required',
//               ),
//               const SizedBox(height: 10),
//               buildField(
//                 controller: titleController,
//                 hintText: 'Title',
//                 validatorMsg: 'Required',
//               ),
//               const SizedBox(height: 10),
//               buildField(
//                 controller: priceController,
//                 hintText: 'Price',
//                 validatorMsg: 'Required',
//                 keyboardType: TextInputType.number,
//               ),
//               const SizedBox(height: 10),
//               buildField(
//                 controller: companyController,
//                 hintText: 'Company',
//                 validatorMsg: 'Required',
//               ),
//               const SizedBox(height: 10),
//               buildField(
//                 controller: descriptionController,
//                 hintText: 'Description',
//                 validatorMsg: 'Required',
//                 maxLines: 3,
//               ),
//               const SizedBox(height: 10),

//               TextFormField(
//                 controller: ratingsController,
//                 keyboardType: TextInputType.number,
//                 cursorColor: Colors.black,
//                 style: const TextStyle(fontSize: 14),
//                 decoration: InputDecoration(
//                   labelText: "Ratings (Max 5)",
//                   labelStyle: const TextStyle(fontSize: 14, color: Colors.grey),
//                   contentPadding: const EdgeInsets.symmetric(
//                     horizontal: 12,
//                     vertical: 14,
//                   ),
//                   filled: true,
//                   fillColor: const Color(0xFFF2F2F2),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   enabledBorder: OutlineInputBorder(
//                     borderSide: const BorderSide(color: Colors.grey),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderSide: const BorderSide(color: Colors.black54),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//                 validator: (value) {
//                   final rating = double.tryParse(value ?? '');
//                   if (rating == null || rating > 5) return "Enter rating ≤ 5";
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 10),

//               DropdownButtonFormField<String>(
//                 value: selectedType,
//                 items:
//                     types.map((type) {
//                       return DropdownMenuItem(
//                         value: type,
//                         child: Text(type, style: const TextStyle(fontSize: 14)),
//                       );
//                     }).toList(),
//                 onChanged:
//                     (val) => setState(() {
//                       selectedType = val;
//                       selectedSizes.clear(); // Reset sizes
//                     }),
//                 decoration: InputDecoration(
//                   labelText: "Select Type",
//                   labelStyle: const TextStyle(fontSize: 14),
//                   filled: true,
//                   fillColor: const Color(0xFFF2F2F2),
//                   contentPadding: const EdgeInsets.symmetric(
//                     horizontal: 12,
//                     vertical: 14,
//                   ),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   enabledBorder: OutlineInputBorder(
//                     borderSide: const BorderSide(color: Colors.grey),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderSide: const BorderSide(color: Colors.black54),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//                 validator:
//                     (value) => value == null ? "Please select a type" : null,
//               ),

//               const SizedBox(height: 10),
//               if (getSizeOptionsForType(selectedType).isNotEmpty)
//                 Align(
//                   alignment: Alignment.centerLeft,
//                   child: Wrap(
//                     spacing: 10,
//                     runSpacing: 8,
//                     children:
//                         getSizeOptionsForType(selectedType).map((size) {
//                           final isSelected = selectedSizes.contains(size);
//                           return ChoiceChip(
//                             label: Text(size),
//                             selected: isSelected,
//                             onSelected:
//                                 (_) => setState(() {
//                                   isSelected
//                                       ? selectedSizes.remove(size)
//                                       : selectedSizes.add(size);
//                                 }),
//                           );
//                         }).toList(),
//                   ),
//                 ),

//               const SizedBox(height: 20),
//               const Text(
//                 "Is this product an offer?",
//                 style: TextStyle(fontSize: 16),
//               ),
//               Row(
//                 children: [
//                   Radio(
//                     activeColor: Colors.black,
//                     value: true,
//                     groupValue: isOffer,
//                     onChanged: (val) => setState(() => isOffer = val!),
//                   ),
//                   const Text("Yes"),
//                   Radio(
//                     activeColor: Colors.black,
//                     value: false,
//                     groupValue: isOffer,
//                     onChanged: (val) => setState(() => isOffer = val!),
//                   ),
//                   const Text("No"),
//                 ],
//               ),

//               if (isOffer) ...[
//                 buildField(
//                   controller: offerDescriptionController,
//                   hintText: 'Offer Description',
//                   validatorMsg: 'Required',
//                   maxLines: 2,
//                   validator: (value) {
//                     if (value == null || value.trim().isEmpty)
//                       return 'Required';
//                     if (value.trim().split(' ').length > 20)
//                       return 'Max 20 words';
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 10),
//                 _offerImage != null
//                     ? Image.file(_offerImage!, height: 100)
//                     : ElevatedButton.icon(
//                       onPressed: _pickOfferImage,
//                       icon: const Icon(Icons.image_outlined),
//                       label: const Text("Pick PNG Offer Image"),
//                     ),
//                 const SizedBox(height: 10),
//                 DropdownButtonFormField<String>(
//                   value: selectedCarouselModel,
//                   items:
//                       ["ModelA", "ModelB", "ModelC"].map((model) {
//                         return DropdownMenuItem(
//                           value: model,
//                           child: Text(model),
//                         );
//                       }).toList(),
//                   onChanged:
//                       (val) => setState(() => selectedCarouselModel = val),
//                   decoration: InputDecoration(
//                     labelText: "Select offer page Model",
//                     labelStyle: const TextStyle(
//                       fontSize: 14,
//                       color: Colors.black,
//                     ),
//                     filled: true,
//                     fillColor: const Color(0xFFF2F2F2),
//                     contentPadding: const EdgeInsets.symmetric(
//                       horizontal: 12,
//                       vertical: 14,
//                     ),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     enabledBorder: OutlineInputBorder(
//                       borderSide: const BorderSide(color: Colors.grey),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderSide: const BorderSide(color: Colors.black54),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                   ),
//                   validator: (value) => value == null ? "Select model" : null,
//                 ),
//               ],

//               const SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: isLoading ? () {} : _uploadProduct,
//                 child:
//                     isLoading
//                         ? const SizedBox(
//                           height: 20,
//                           width: 20,
//                           child: CircularProgressIndicator(
//                             color: Colors.white,
//                             backgroundColor: Colors.black,

//                             strokeWidth: 2,
//                           ),
//                         )
//                         : const Text(
//                           "Upload product",
//                           style: TextStyle(fontSize: 14),
//                         ),
//               ),
//               const SizedBox(height: 10),
//               ElevatedButton(
//                 onPressed: () async {
//                   await FirebaseAuth.instance.signOut();
//                   Navigator.of(context).popUntil((route) => route.isFirst);
//                 },
//                 child: const Text("Logout", style: TextStyle(fontSize: 14)),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
