import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/app_snackbar.dart';
import '../../../models/user_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';

class UserProfileSheet extends StatefulWidget {
  final UserModel user;

  const UserProfileSheet({super.key, required this.user});

  @override
  State<UserProfileSheet> createState() => _UserProfileSheetState();
}

class _UserProfileSheetState extends State<UserProfileSheet> {
  final _formKey = GlobalKey<FormState>();
  final _oldPassCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  bool _isPickingPhoto = false;

  @override
  void dispose() {
    _oldPassCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto(ImageSource source) async {
    Navigator.pop(context); // fecha o menu de escolha
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _isPickingPhoto = true);
    try {
      final picked = await ImagePicker().pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      if (picked == null || !mounted) return;
      // readAsBytes() lida corretamente com content URIs no Android
      final bytes = await picked.readAsBytes();
      if (!mounted) return;
      await context.read<AuthProvider>().updateProfilePhoto(bytes);
    } catch (e) {
      AppSnackbar.errorWith(messenger, 'Não foi possível salvar a foto.');
    } finally {
      if (mounted) setState(() => _isPickingPhoto = false);
    }
  }

  void _showPhotoOptions() {
    final user = context.read<AuthProvider>().currentUser!;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            _PhotoOption(
              icon: Icons.camera_alt_outlined,
              label: 'Tirar foto',
              onTap: () => _pickPhoto(ImageSource.camera),
            ),
            const SizedBox(height: 8),
            _PhotoOption(
              icon: Icons.photo_library_outlined,
              label: 'Escolher da galeria',
              onTap: () => _pickPhoto(ImageSource.gallery),
            ),
            if (user.photoPath != null) ...[
              const SizedBox(height: 8),
              _PhotoOption(
                icon: Icons.delete_outline,
                label: 'Remover foto',
                color: AppColors.expense,
                onTap: () async {
                  Navigator.pop(context);
                  await context.read<AuthProvider>().updateProfilePhoto(null); // null = remover
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _isLoading = true);
    final auth = context.read<AuthProvider>();
    final ok = await auth.changePassword(
      oldPassword: _oldPassCtrl.text,
      newPassword: _newPassCtrl.text,
    );
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (ok) {
      AppSnackbar.successWith(messenger, 'Senha alterada com sucesso!');
      Navigator.pop(context);
    } else {
      AppSnackbar.errorWith(messenger, auth.error ?? 'Erro ao alterar senha.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser ?? widget.user;
    final initial = user.name.isNotEmpty ? user.name[0].toUpperCase() : '?';
    final hasPhoto = user.photoPath != null && File(user.photoPath!).existsSync();

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 28,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Avatar + nome + email
              Column(
                children: [
                  GestureDetector(
                    onTap: _showPhotoOptions,
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        // Foto ou letra inicial
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: hasPhoto
                                ? null
                                : const LinearGradient(
                                    colors: [AppColors.primaryDark, AppColors.primary],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                          ),
                          child: hasPhoto
                              ? ClipOval(
                                  child: _isPickingPhoto
                                      ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                                      : Image.file(
                                          File(user.photoPath!),
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.cover,
                                        ),
                                )
                              : Center(
                                  child: _isPickingPhoto
                                      ? const CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        )
                                      : Text(
                                          initial,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 32,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                        ),
                        // Botão de edição
                        Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              width: 2,
                            ),
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 14),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user.name,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Text(
                      user.email,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),
              const Divider(color: AppColors.divider, height: 1),
              const SizedBox(height: 24),

              // Título seção senha
              const Row(
                children: [
                  Icon(Icons.lock_outline, size: 18, color: AppColors.textSecondary),
                  SizedBox(width: 8),
                  Text(
                    'Alterar senha',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              CustomTextField(
                label: 'Senha atual',
                controller: _oldPassCtrl,
                obscureText: _obscureOld,
                prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textSecondary, size: 20),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureOld ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  onPressed: () => setState(() => _obscureOld = !_obscureOld),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Informe a senha atual';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              CustomTextField(
                label: 'Nova senha',
                controller: _newPassCtrl,
                obscureText: _obscureNew,
                prefixIcon: const Icon(Icons.lock_reset, color: AppColors.textSecondary, size: 20),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureNew ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  onPressed: () => setState(() => _obscureNew = !_obscureNew),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Informe a nova senha';
                  if (v.length < 6) return 'A senha deve ter ao menos 6 caracteres';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              CustomTextField(
                label: 'Confirmar nova senha',
                controller: _confirmPassCtrl,
                obscureText: _obscureConfirm,
                prefixIcon: const Icon(Icons.lock_reset, color: AppColors.textSecondary, size: 20),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Confirme a nova senha';
                  if (v != _newPassCtrl.text) return 'As senhas não coincidem';
                  return null;
                },
              ),
              const SizedBox(height: 24),

              CustomButton(
                label: 'Salvar senha',
                isLoading: _isLoading,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhotoOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _PhotoOption({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).textTheme.bodyLarge?.color ?? AppColors.textPrimary;
    return Material(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: c, size: 22),
              const SizedBox(width: 14),
              Text(label, style: TextStyle(color: c, fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }
}
