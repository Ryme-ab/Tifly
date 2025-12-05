// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../../data/models/baby_model.dart';
// import '../../data/repositories/baby_repo.dart';
// import '../../data/data_sources/baby_remote_data_source.dart';
// import '../cubit/baby_cubit.dart';
// import 'add_baby_profile_picture_screen.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// class AddBabyScreen extends StatefulWidget {
//   const AddBabyScreen({super.key});

//   @override
//   State<AddBabyScreen> createState() => _AddBabyScreenState();
// }

// class _AddBabyScreenState extends State<AddBabyScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _nameController = TextEditingController();
//   final _birthController = TextEditingController();
//   DateTime? _selectedDate;
//   bool isBoy = true;

//   @override
//   Widget build(BuildContext context) {
//     final client = Supabase.instance.client;

//     return BlocProvider(
//       create: (_) => BabyCubit(BabyRepository(BabyRemoteDataSource(client))),
//       child: BlocListener<BabyCubit, BabyState>(
//         listener: (context, state) {
//           if (state is BabySuccess) {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (_) =>
//                     AddBabyProfilePictureScreen(baby: state.baby),
//               ),
//             );
//           } else if (state is BabyError) {
//             ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(content: Text(state.message)));
//           }
//         },
//         child: Scaffold(
//           appBar: AppBar(title: const Text("Add Baby")),
//           body: Padding(
//             padding: const EdgeInsets.all(16),
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 children: [
//                   TextFormField(
//                     controller: _nameController,
//                     validator: (v) =>
//                         v!.isEmpty ? "Please enter baby's name" : null,
//                     decoration: const InputDecoration(labelText: "Baby Name"),
//                   ),
//                   const SizedBox(height: 16),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: ElevatedButton(
//                           onPressed: () async {
//                             final date = await showDatePicker(
//                               context: context,
//                               initialDate: DateTime.now(),
//                               firstDate: DateTime(2000),
//                               lastDate: DateTime.now(),
//                             );
//                             if (date != null) {
//                               setState(() {
//                                 _selectedDate = date;
//                                 _birthController.text =
//                                     '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
//                               });
//                             }
//                           },
//                           child: Text(_selectedDate == null
//                               ? "Select Birth Date"
//                               : _birthController.text),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 16),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: ElevatedButton(
//                             onPressed: () => setState(() => isBoy = true),
//                             child: const Text("Boy")),
//                       ),
//                       const SizedBox(width: 16),
//                       Expanded(
//                         child: ElevatedButton(
//                             onPressed: () => setState(() => isBoy = false),
//                             child: const Text("Girl")),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 24),
//                   ElevatedButton(
//                     onPressed: () {
//                       if (_formKey.currentState!.validate() &&
//                           _selectedDate != null) {
//                         final baby = Baby(
//                           id: '',
//                           firstName: _nameController.text,
//                           birthDate: _birthController.text,
//                           gender: isBoy ? 'male' : 'female',
//                           parentId: 'YOUR_PARENT_ID',
//                         );
//                         context.read<BabyCubit>().addBaby(baby);
//                       }
//                     },
//                     child: const Text("Save Baby"),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
