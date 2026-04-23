import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import 'package:storysync/core/theme/app_colors.dart';
import 'package:storysync/core/theme/app_dimensions.dart';
import 'package:storysync/core/theme/app_text_styles.dart';
import 'package:storysync/core/utils/snackbar_util.dart';
import 'package:storysync/features/library/data/models/manga_item.dart';

/// Dialog for editing manga information.
///
/// Allows users to correct or modify manga data that may be incorrect
/// from the API source.
class EditMangaDialog extends StatefulWidget {
  final MangaItem manga;
  final void Function(MangaItem updatedManga) onSave;

  const EditMangaDialog({super.key, required this.manga, required this.onSave});

  @override
  State<EditMangaDialog> createState() => _EditMangaDialogState();
}

class _EditMangaDialogState extends State<EditMangaDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _authorController;
  late TextEditingController _synopsisController;
  late TextEditingController _coverUrlController;
  late TextEditingController _totalChaptersController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.manga.title);
    _authorController = TextEditingController(text: widget.manga.author ?? '');
    _synopsisController = TextEditingController(
      text: widget.manga.synopsis ?? '',
    );
    _coverUrlController = TextEditingController(
      text: widget.manga.coverUrl ?? '',
    );
    _totalChaptersController = TextEditingController(
      text: widget.manga.totalChapters?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _synopsisController.dispose();
    _coverUrlController.dispose();
    _totalChaptersController.dispose();
    super.dispose();
  }

  Future<bool> _validateImageUrl(String? url) async {
    if (url == null || url.trim().isEmpty) {
      return true;
    }

    setState(() {
      // _isValidatingImage = true;
    });

    try {
      final dio = Dio();
      final response = await dio.head(
        url.trim(),
        options: Options(
          validateStatus: (status) => status != null && status < 400,
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      final isValid =
          response.statusCode == 200 &&
          (response.headers.value('content-type')?.contains('image') ?? false);

      setState(() {
        // _isValidatingImage = false;
      });

      return isValid;
    } catch (e) {
      setState(() {
        // _isValidatingImage = false;
      });
      return false;
    }
  }

  void _handleSave() async {
    if (_formKey.currentState?.validate() ?? false) {
      final coverUrl = _coverUrlController.text.trim();

      if (coverUrl.isNotEmpty) {
        final isValid = await _validateImageUrl(coverUrl);

        if (!mounted) return;

        if (!isValid) {
          VoidInkSnackbar.showError(
            context,
            'Unable to fetch image from the provided link.',
          );
          return;
        }
      }

      if (!mounted) return;
      // Create updated manga item
      final updatedManga = MangaItem.create(
        mangaDexId: widget.manga.mangaDexId,
        title: _titleController.text.trim(),
        author: _authorController.text.trim().isEmpty
            ? null
            : _authorController.text.trim(),
        synopsis: _synopsisController.text.trim().isEmpty
            ? null
            : _synopsisController.text.trim(),
        coverUrl: _coverUrlController.text.trim().isEmpty
            ? null
            : _coverUrlController.text.trim(),
        totalChapters: _totalChaptersController.text.trim().isEmpty
            ? null
            : int.tryParse(_totalChaptersController.text.trim()),
        readingStatus: widget.manga.readingStatus,
        chapterProgress: widget.manga.chapterProgress,
        source: widget.manga.source,
        hasCustomMetadata: true,
      );

      // Copy the Isar ID if it exists (for existing items)
      updatedManga.id = widget.manga.id;

      widget.onSave(updatedManga);
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<VoidInkColors>()!;

    return Dialog(
      backgroundColor: colors.inkVoid,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        side: BorderSide(
          color: colors.inkBorder,
          width: AppDimensions.borderThin,
        ),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.space24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Row(
                  children: [
                    Icon(Icons.edit_rounded, color: colors.goldSpark, size: 20),
                    const SizedBox(width: AppDimensions.space8),
                    Text(
                      'Edit Manga Info',
                      style: AppTextStyles.titleLarge.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.space4),
                Text(
                  'Correct any incorrect information from the API',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppDimensions.space24),

                // Title field
                _buildTextField(
                  controller: _titleController,
                  label: 'Title',
                  hint: 'Enter manga title',
                  colors: colors,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Title is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.space16),

                // Author field
                _buildTextField(
                  controller: _authorController,
                  label: 'Author',
                  hint: 'Enter author name',
                  colors: colors,
                ),
                const SizedBox(height: AppDimensions.space16),

                // Synopsis field
                _buildTextField(
                  controller: _synopsisController,
                  label: 'Synopsis',
                  hint: 'Enter synopsis or description',
                  colors: colors,
                  maxLines: 4,
                ),
                const SizedBox(height: AppDimensions.space16),

                // Cover URL field
                _buildTextField(
                  controller: _coverUrlController,
                  label: 'Cover URL',
                  hint: 'Enter cover image URL',
                  colors: colors,
                ),
                const SizedBox(height: AppDimensions.space16),

                // Total chapters field
                _buildTextField(
                  controller: _totalChaptersController,
                  label: 'Total Chapters',
                  hint: 'Enter total chapters',
                  colors: colors,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value != null &&
                        value.trim().isNotEmpty &&
                        int.tryParse(value.trim()) == null) {
                      return 'Must be a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.space24),

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => context.pop(),
                      child: Text(
                        'Cancel',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.space12),
                    ElevatedButton(
                      onPressed: _handleSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.goldSpark,
                        foregroundColor: colors.inkVoid,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusSM,
                          ),
                        ),
                      ),
                      child: Text(
                        'Save',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: colors.inkVoid,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required VoidInkColors colors,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(height: AppDimensions.space8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: colors.inkSurface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
              borderSide: BorderSide(
                color: colors.inkBorder,
                width: AppDimensions.borderThin,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
              borderSide: BorderSide(
                color: colors.inkBorder,
                width: AppDimensions.borderThin,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
              borderSide: BorderSide(
                color: colors.goldSpark,
                width: AppDimensions.borderMedium,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
              borderSide: BorderSide(
                color: colors.textHint,
                width: AppDimensions.borderThin,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
