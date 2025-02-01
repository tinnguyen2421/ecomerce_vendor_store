import 'dart:io';

import 'package:ecomerce_vendor_store/controllers/product_controller.dart';
import 'package:ecomerce_vendor_store/models/product.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProductDetailScreen extends StatefulWidget {
  final Product product;

  const EditProductDetailScreen({super.key, required this.product});

  @override
  State<EditProductDetailScreen> createState() =>
      _EditProductDetailScreenState();
}

class _EditProductDetailScreenState extends State<EditProductDetailScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ProductController _productController = ProductController();
  late TextEditingController productNameController;
  late TextEditingController productPriceController;
  late TextEditingController quantityController;
  late TextEditingController descriptionController;
  List<File>? pickedImages;
  @override
  void initState() {
    super.initState();
    productNameController =
        TextEditingController(text: widget.product.productName);
    productPriceController =
        TextEditingController(text: widget.product.productPrice.toString());
    quantityController =
        TextEditingController(text: widget.product.quantity.toString());
    descriptionController =
        TextEditingController(text: widget.product.description);
  }

  Future<void> _pickedImages() async {
    final pickedFiles = await ImagePicker().pickMultiImage();
    setState(() {
      pickedImages = pickedFiles.map((file) => File(file.path)).toList();
    });
  }

  Future<void> _updateProduct() async {
    if (_formKey.currentState!.validate()) {
      //create an instance of the product model object
      List<String> uploadedImages =
          pickedImages != null && pickedImages!.isNotEmpty
              ? await _productController.uploadImagesToCloudinary(
                  pickedImages, widget.product)
              : widget.product.images;
      final updatedProduct = Product(
        id: widget.product.id,
        productName: productNameController.text,
        productPrice: int.parse(productPriceController.text),
        quantity: int.parse(quantityController.text),
        description: descriptionController.text,
        category: widget.product.category,
        vendorId: widget.product.vendorId,
        fullName: widget.product.fullName,
        subCategory: widget.product.subCategory,
        images: pickedImages != null && pickedImages!.isNotEmpty
            ? uploadedImages
            : widget.product.images,
        averageRating: widget.product.averageRating,
        totalRatings: widget.product.totalRatings,
      );
      await _productController.updateProduct(
          product: updatedProduct,
          pickedImages: pickedImages,
          context: context);
    } else {
      print('fill in all fields');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextFormField(
                keyboardType: TextInputType.name,
                validator: (value) =>
                    value!.isEmpty ? "Enter product name" : null,
                controller: productNameController,
                decoration: const InputDecoration(labelText: 'Product Name'),
              ),
              TextFormField(
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty ? "Enter product price" : null,
                controller: productPriceController,
                decoration: const InputDecoration(labelText: 'Product price'),
              ),
              TextFormField(
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? "Enter quantity" : null,
                controller: quantityController,
                decoration:
                    const InputDecoration(labelText: 'Product quantity'),
              ),
              TextFormField(
                keyboardType: TextInputType.name,
                validator: (value) =>
                    value!.isEmpty ? "Enter product description" : null,
                controller: descriptionController,
                decoration:
                    const InputDecoration(labelText: 'Product description'),
              ),
              const SizedBox(
                height: 20,
              ),
              if (widget.product.images.isNotEmpty)
                Wrap(
                  spacing: 10,
                  children: widget.product.images.map((imageUrl) {
                    return InkWell(
                      onTap: () {
                        _pickedImages();
                      },
                      child: Image.network(
                        imageUrl,
                        width: 100,
                        height: 100,
                      ),
                    );
                  }).toList(),
                ),
              if (pickedImages != null)
                Wrap(
                  spacing: 10,
                  children: pickedImages!.map((image) {
                    return Image.file(
                      image,
                      width: 100,
                      height: 100,
                    );
                  }).toList(),
                ),
              ElevatedButton(
                onPressed: () async {
                  await _updateProduct();
                },
                child: const Text('Cập nhật sản phẩm'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
