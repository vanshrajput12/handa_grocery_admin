import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../services/product_service.dart';


class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final ProductService service = ProductService();

  String category = ProductService.categories.first;

  Future<void> showProductForm({
    String? id,
    Map<String, dynamic>? product,
  }) async {
    final formKey = GlobalKey<FormState>();
    final name = TextEditingController(
      text: product?['name']?.toString() ?? '',
    );
    final description = TextEditingController(
      text: product?['description']?.toString() ?? '',
    );
    final image = TextEditingController(
      text: product?['image']?.toString() ?? '',
    );
    final price = TextEditingController(
      text: product?['price']?.toString() ?? '',
    );

    try {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(id == null ? 'Add Product' : 'Edit Product'),
          content: SizedBox(
            width: 450,
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: name,
                      decoration: const InputDecoration(
                        labelText: 'Product name',
                      ),
                      validator: (v) =>
                      v == null || v.trim().isEmpty
                          ? 'Enter product name'
                          : null,
                    ),
                    TextFormField(
                      controller: description,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                      ),
                      validator: (v) =>
                      v == null || v.trim().isEmpty
                          ? 'Enter description'
                          : null,
                    ),
                    TextFormField(
                      controller: image,
                      decoration: const InputDecoration(
                        labelText: 'Image path or URL',
                        hintText: 'assets/images/Basmati.png',
                      ),
                      validator: (v) =>
                      v == null || v.trim().isEmpty
                          ? 'Enter image path or URL'
                          : null,
                    ),
                    TextFormField(
                      controller: price,
                      decoration: const InputDecoration(
                        labelText: 'Price',
                        hintText: '150/kg',
                      ),
                      validator: (v) =>
                      v == null || v.trim().isEmpty
                          ? 'Enter price'
                          : null,
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;

                try {
                  if (id == null) {
                    await service.addProduct(
                      category: category,
                      name: name.text,
                      description: description.text,
                      image: image.text,
                      price: price.text,
                    );
                  } else {
                    await service.updateProduct(
                      category: category,
                      productId: id,
                      name: name.text,
                      description: description.text,
                      image: image.text,
                      price: price.text,
                    );
                  }

                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext);
                  }

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          id == null
                              ? 'Product added successfully'
                              : 'Product updated successfully',
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Save failed: $e')),
                    );
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      );
    } finally {
      name.dispose();
      description.dispose();
      image.dispose();
      price.dispose();
    }
  }

  Future<void> confirmDelete(String id, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete product?'),
        content: Text('Delete "$name" permanently?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await service.deleteProduct(
        category: category,
        productId: id,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product deleted')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Delete failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Products')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showProductForm(),
        icon: const Icon(Icons.add),
        label: const Text('Add Product'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: DropdownButtonFormField<String>(
              value: category,
              decoration: const InputDecoration(
                labelText: 'Product category',
                border: OutlineInputBorder(),
              ),
              items: ProductService.categories.map((item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => category = value);
                }
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<
                QuerySnapshot<Map<String, dynamic>>>(
              stream: service.getProducts(category),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text(
                      'Could not load products. Check Firebase access.',
                    ),
                  );
                }

                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final docs = snapshot.data?.docs ?? [];

                if (docs.isEmpty) {
                  return const Center(
                    child: Text('No products in this category'),
                  );
                }

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data();
                    final productName =
                        data['name']?.toString() ?? 'Unnamed product';
                    final imagePath =
                        data['image']?.toString() ?? '';

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.inventory_2),
                        title: Text(productName),
                        subtitle: Text(
                          '${data['price'] ?? ''}\n'
                              '${data['description'] ?? ''}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        isThreeLine: true,
                        trailing: Wrap(
                          spacing: 0,
                          children: [
                            IconButton(
                              tooltip: 'Edit',
                              icon: const Icon(Icons.edit_outlined),
                              onPressed: () => showProductForm(
                                id: doc.id,
                                product: data,
                              ),
                            ),
                            IconButton(
                              tooltip: 'Delete',
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                              ),
                              onPressed: () =>
                                  confirmDelete(doc.id, productName),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
