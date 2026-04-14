import 'package:flutter/material.dart';
import 'package:storysync/core/theme/app_colors.dart';
import 'package:storysync/core/theme/app_dimensions.dart';
import 'package:storysync/core/theme/app_text_styles.dart';
import 'package:storysync/features/library/data/models/manga_item.dart';
import 'package:uuid/uuid.dart';

class ManualAddDialog extends StatefulWidget {
  final void Function(MangaItem item) onSave;

  const ManualAddDialog({super.key, required this.onSave});

  @override
  State<ManualAddDialog> createState() => _ManualAddDialogState();
}

class _ManualAddDialogState extends State<ManualAddDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _synopsisController = TextEditingController();
  final _chaptersController = TextEditingController();

  ReadingStatus _status = ReadingStatus.reading;

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _synopsisController.dispose();
    _chaptersController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (_formKey.currentState?.validate() ?? false) {
      final String genId = const Uuid().v4();
      final newItem = MangaItem.create(
        mangaDexId: genId,
        title: _titleController.text.trim(),
        author: _authorController.text.trim().isEmpty ? null : _authorController.text.trim(),
        synopsis: _synopsisController.text.trim().isEmpty ? null : _synopsisController.text.trim(),
        readingStatus: _status,
        chapterProgress: 0,
        totalChapters: _chaptersController.text.trim().isEmpty ? null : int.tryParse(_chaptersController.text.trim()),
        source: 'manual',
        hasCustomMetadata: true,
      );

      widget.onSave(newItem);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<VoidInkColors>()!;

    return Dialog(
      backgroundColor: colors.inkVoid,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        side: BorderSide(color: colors.inkBorder, width: AppDimensions.borderThin),
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
                Row(
                  children: [
                    Icon(Icons.add_circle_outline_rounded, color: colors.goldSpark, size: 20),
                    const SizedBox(width: AppDimensions.space8),
                    Text(
                      'Manual Add',
                      style: AppTextStyles.titleLarge.copyWith(color: colors.textPrimary),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.space4),
                Text(
                  'Add a custom title not found on MangaDex.',
                  style: AppTextStyles.bodySmall.copyWith(color: colors.textSecondary),
                ),
                const SizedBox(height: AppDimensions.space24),
                
                _buildTextField(
                  controller: _titleController,
                  label: 'Title',
                  hint: 'Enter manga title',
                  colors: colors,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Title is required' : null,
                ),
                const SizedBox(height: AppDimensions.space16),

                _buildTextField(
                  controller: _authorController,
                  label: 'Author (Optional)',
                  hint: 'Enter author name',
                  colors: colors,
                ),
                const SizedBox(height: AppDimensions.space16),

                _buildTextField(
                  controller: _synopsisController,
                  label: 'Synopsis (Optional)',
                  hint: 'Enter synopsis...',
                  colors: colors,
                  maxLines: 3,
                ),
                const SizedBox(height: AppDimensions.space16),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Status', style: AppTextStyles.labelMedium.copyWith(color: colors.textSecondary)),
                    const SizedBox(height: AppDimensions.space8),
                    DropdownButtonFormField<ReadingStatus>(
                      initialValue: _status,
                      dropdownColor: colors.inkSurface,
                      validator: (v) => v == null ? 'Status required' : null,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: colors.inkSurface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                          borderSide: BorderSide(color: colors.inkBorder),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                          borderSide: BorderSide(color: colors.inkBorder),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                          borderSide: BorderSide(color: colors.goldSpark),
                        ),
                      ),
                      items: ReadingStatus.values.map((s) {
                        return DropdownMenuItem(
                          value: s,
                          child: Text(s.displayLabel, style: AppTextStyles.bodyMedium.copyWith(color: colors.textPrimary)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _status = val);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.space16),

                _buildTextField(
                  controller: _chaptersController,
                  label: 'Total Chapters (Optional)',
                  hint: 'Enter total chapters',
                  colors: colors,
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v != null && v.trim().isNotEmpty && int.tryParse(v.trim()) == null) {
                      return 'Must be an integer';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.space24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Cancel', style: AppTextStyles.labelMedium.copyWith(color: colors.textSecondary)),
                    ),
                    const SizedBox(width: AppDimensions.space12),
                    ElevatedButton(
                      onPressed: _handleSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.goldSpark,
                        foregroundColor: colors.inkVoid,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusSM)),
                      ),
                      child: Text('Add', style: AppTextStyles.labelMedium.copyWith(color: colors.inkVoid)),
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
        Text(label, style: AppTextStyles.labelMedium.copyWith(color: colors.textSecondary)),
        const SizedBox(height: AppDimensions.space8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          style: AppTextStyles.bodyMedium.copyWith(color: colors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodyMedium.copyWith(color: colors.textHint),
            filled: true,
            fillColor: colors.inkSurface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
              borderSide: BorderSide(color: colors.inkBorder, width: AppDimensions.borderThin),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
              borderSide: BorderSide(color: colors.inkBorder, width: AppDimensions.borderThin),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
              borderSide: BorderSide(color: colors.goldSpark, width: AppDimensions.borderMedium),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
              borderSide: BorderSide(color: colors.statusDropped, width: AppDimensions.borderThin),
            ),
          ),
        ),
      ],
    );
  }
}
