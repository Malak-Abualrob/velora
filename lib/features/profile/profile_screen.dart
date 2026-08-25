import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/profile_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/beauty_button.dart';
import '../../widgets/custom_text_field.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final nameController = TextEditingController();

  final ageController = TextEditingController();

  final phoneController = TextEditingController();

  final bioController = TextEditingController();

  bool initialized = false;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      if (mounted) {
        context.read<ProfileController>().loadProfile();
      }
    });
  }

  void fillFields(ProfileController controller) {
    if (initialized || controller.profile == null) {
      return;
    }

    final profile = controller.profile!;

    nameController.text = profile.name;
    ageController.text = profile.age;
    phoneController.text = profile.phone;
    bioController.text = profile.bio;

    initialized = true;
  }

  Future<void> save() async {
    final controller = context.read<ProfileController>();

    await controller.saveProfile(
      name: nameController.text.trim(),
      age: ageController.text.trim(),
      phone: phoneController.text.trim(),
      bio: bioController.text.trim(),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile saved successfully ♡')),
    );
  }

  Future<void> logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      if (!mounted) return;
      await context.read<AuthController>().logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileController>(
      builder: (context, controller, _) {
        fillFields(controller);

        if (controller.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final image = controller.selectedImage;

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'My Profile',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            actions: [
              IconButton(onPressed: logout, icon: const Icon(Icons.logout)),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                GestureDetector(
                  onTap: controller.pickImage,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 65,
                        backgroundColor: AppColors.lightPink,
                        backgroundImage: image != null
                            ? FileImage(image)
                            : controller.profile?.imageUrl.isNotEmpty == true
                            ? NetworkImage(controller.profile!.imageUrl)
                            : null,
                        child:
                            image == null &&
                                (controller.profile?.imageUrl.isEmpty ?? true)
                            ? const Icon(
                                Icons.person,
                                size: 55,
                                color: AppColors.primary,
                              )
                            : null,
                      ),

                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  'Tap to change photo',
                  style: TextStyle(color: AppColors.grey),
                ),

                const SizedBox(height: 30),

                CustomTextField(
                  controller: nameController,
                  hint: 'Name',
                  icon: Icons.person_outline,
                ),

                const SizedBox(height: 15),

                CustomTextField(
                  controller: ageController,
                  hint: 'Age',
                  icon: Icons.cake_outlined,
                  keyboardType: TextInputType.number,
                ),

                const SizedBox(height: 15),

                CustomTextField(
                  controller: phoneController,
                  hint: 'Phone',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),

                const SizedBox(height: 15),

                CustomTextField(
                  controller: bioController,
                  hint: 'Bio',
                  icon: Icons.favorite_outline,
                  maxLines: 4,
                ),

                const SizedBox(height: 25),

                BeautyButton(
                  text: 'Save Changes',
                  loading: controller.isSaving,
                  onPressed: save,
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}
