import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:send_money_app/src/presentation/cubit/auth/auth_cubit.dart';
import 'package:send_money_app/src/presentation/cubit/auth/auth_state.dart';

class DashboardGreeting extends StatelessWidget {
  const DashboardGreeting({super.key});

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 17
            ? 'Good afternoon'
            : 'Good evening';

    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final username = (state is AuthLoaded) ? state.user.username : '';
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$greeting,',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              username.isNotEmpty ? '@$username' : '...',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.3,
              ),
            ),
          ],
        );
      },
    );
  }
}
