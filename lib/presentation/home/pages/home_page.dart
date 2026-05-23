import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../auth/cubit/login_cubit.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Pull the already-cached user out of the repository on first render.
    context.read<HomeCubit>().loadUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            // Logout lives on LoginCubit because it owns auth state.
            // GoRouter redirects to /login once authStateStream emits null.
            onPressed: () => context.read<LoginCubit>().logout(),
          ),
        ],
      ),
      body: SafeArea(
        child: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            if (state is! HomeLoaded) {
              return const Center(child: CircularProgressIndicator());
            }

            final user = state.user;

            return ListView(
              padding: EdgeInsets.all(24.w),
              children: [
                Text(
                  'Hello, ${user.name}!',
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8.h),
                Text(
                  user.email,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(color: Colors.grey),
                ),
                SizedBox(height: 32.h),
                Card(
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16.w),
                    leading: CircleAvatar(
                      radius: 24.r,
                      child: Text(
                        user.name[0].toUpperCase(),
                        style: TextStyle(fontSize: 20.sp),
                      ),
                    ),
                    title: Text(user.name),
                    subtitle: Text(user.email),
                    trailing: const Icon(Icons.chevron_right),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
