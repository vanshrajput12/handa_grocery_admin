import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../models/product_model.dart';
import '../cubit/products_cubit.dart';
import 'product_thumb.dart';

/// Add a product (existing == null) or edit one.
class ProductFormDialog extends StatefulWidget {
  const ProductFormDialog({super.key, required this.cubit, this.existing});

  final ProductsCubit cubit;
  final ProductModel? existing;

  @override
  State<ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _price = TextEditingController();
  final _image = TextEditingController();
  final Map<String, TextEditingController> _extras = {};
  final List<TextEditingController> _retired = [];

  late String _category;
  dynamic _priceLike; // a sample price, so we store the same type
  Map<String, dynamic> _template = {};
  bool _saving = false;

  bool get _editing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final p = widget.existing;
    _category = p?.category ?? kProductCategories.first;
    _name.text = p?.name ?? '';
    _price.text = p?.priceText ?? '';
    _image.text = p?.image ?? '';
    _loadTemplate();
  }

  /// Works out which extra fields to show. When adding, they are copied from
  /// an existing product in the same category so new products have the same
  /// shape the customer app already expects.
  void _loadTemplate() {
    _retired.addAll(_extras.values);
    _extras.clear();

    final p = widget.existing;
    if (p != null) {
      _priceLike = p.price;
      _template = p.extraFields;
      _template.forEach(
        (k, v) => _extras[k] = TextEditingController(text: v.toString()),
      );
    } else {
      ProductModel? sample;
      for (final x in widget.cubit.state.products) {
        if (x.category == _category) {
          sample = x;
          break;
        }
      }
      _priceLike = sample?.price;
      _template = sample?.extraFields ?? <String, dynamic>{};
      for (final k in _template.keys) {
        _extras[k] = TextEditingController();
      }
    }
  }

  @override
  void dispose() {
    for (final c in [_name, _price, _image, ..._extras.values, ..._retired]) {
      c.dispose();
    }
    super.dispose();
  }

  dynamic _parsePrice(String text) {
    final t = text.trim();
    final like = _priceLike;
    if (like is String) return t;
    if (like is int) return int.tryParse(t) ?? num.tryParse(t);
    if (like is num) return num.tryParse(t);
    return num.tryParse(t) ?? t;
  }

  String _label(String key) =>
      key.isEmpty ? key : key[0].toUpperCase() + key.substring(1);

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final values = <String, dynamic>{
      'text': _name.text.trim(),
      'price': _parsePrice(_price.text),
      'image': _image.text.trim(),
    };
    _extras.forEach((key, ctrl) {
      final t = ctrl.text.trim();
      if (_template[key] is num) {
        final n = num.tryParse(t);
        if (n != null) values[key] = n;
      } else {
        values[key] = t;
      }
    });

    var payload = values;
    final existing = widget.existing;
    if (existing != null) {
      payload = {
        for (final e in values.entries)
          if (existing.data[e.key] != e.value) e.key: e.value,
      };
      if (payload.isEmpty) {
        Navigator.of(context).pop();
        return;
      }
    }

    setState(() => _saving = true);
    final ok = await widget.cubit.save(
      existing: existing,
      category: _category,
      data: payload,
    );
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop();
    } else {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  _editing ? 'Edit product' : 'Add product',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _editing
                      ? 'Changes appear in the customer app straight away.'
                      : 'The product appears in the customer app straight away.',
                  style: const TextStyle(color: AppColors.inkSoft),
                ),
                const SizedBox(height: 20),
                if (_editing)
                  TextFormField(
                    initialValue: _category,
                    enabled: false,
                    decoration: const InputDecoration(labelText: 'Category'),
                  )
                else
                  InputDecorator(
                    decoration: const InputDecoration(labelText: 'Category'),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _category,
                        isExpanded: true,
                        isDense: true,
                        items: [
                          for (final c in kProductCategories)
                            DropdownMenuItem(value: c, child: Text(c)),
                        ],
                        onChanged: _saving
                            ? null
                            : (v) {
                                if (v == null) return;
                                setState(() {
                                  _category = v;
                                  _loadTemplate();
                                });
                              },
                      ),
                    ),
                  ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _name,
                  enabled: !_saving,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(labelText: 'Product name'),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Enter the product name'
                      : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _price,
                  enabled: !_saving,
                  textInputAction: TextInputAction.next,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Price',
                    helperText: 'Numbers only, for example 120',
                  ),
                  validator: (v) {
                    final t = v?.trim() ?? '';
                    if (t.isEmpty) return 'Enter the price';
                    if (_parsePrice(t) == null) return 'Enter a valid number';
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _image,
                  enabled: !_saving,
                  textInputAction: TextInputAction.next,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    labelText: 'Image link',
                    helperText:
                        'A link starting with https://  (or assets/... for an image already inside the app)',
                    helperMaxLines: 2,
                  ),
                  validator: (v) {
                    final t = v?.trim() ?? '';
                    if (t.isEmpty) return 'Enter an image link';
                    if (!t.startsWith('http') && !t.startsWith('assets/')) {
                      return 'Use a link starting with https:// or assets/';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: SizedBox(
                    height: 140,
                    child: ProductThumb(image: _image.text.trim()),
                  ),
                ),
                if (_extras.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const Text(
                    'More details',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 10),
                  for (final e in _extras.entries) ...[
                    TextFormField(
                      key: ValueKey('$_category-${e.key}'),
                      controller: e.value,
                      enabled: !_saving,
                      decoration: InputDecoration(labelText: _label(e.key)),
                    ),
                    const SizedBox(height: 14),
                  ],
                ],
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed:
                          _saving ? null : () => Navigator.of(context).pop(),
                      style:
                          TextButton.styleFrom(foregroundColor: AppColors.ink),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: _saving ? null : _save,
                      child: _saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: AppColors.amber,
                              ),
                            )
                          : Text(_editing ? 'Save changes' : 'Add product'),
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
}
