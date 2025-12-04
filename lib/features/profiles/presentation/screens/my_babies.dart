import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/baby_cubit.dart';
import '../cubit/baby_state.dart';
import 'baby_card.dart';

class MyBabiesPage extends StatelessWidget {
  const MyBabiesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<BabyCubit, BabyState>(
        builder: (context, state) {
          if (state is BabyLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is BabyLoaded) {
            return Column(
              children: [
                const SizedBox(height: 40),
                Wrap(
                  spacing: 20,
                  runSpacing: 20,
                  children: state.babies
                      .map(
                        (baby) => BabyCard(
                          name: baby.firstName,
                          age: baby.birthDate,
                          imageUrl:
                              baby.profileImage ??
                              'https://via.placeholder.com/150',
                          borderColor: Colors.pinkAccent,
                        ),
                      )
                      .toList(),
                ),
              ],
            );
          }

          if (state is BabyError) {
            return Center(child: Text(state.message));
          }

          return const SizedBox();
        },
      ),
    );
  }
}
