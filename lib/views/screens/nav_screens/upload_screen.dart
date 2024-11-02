import 'dart:io';

import 'package:ecomerce_vendor_store/controllers/category_controller.dart';
import 'package:ecomerce_vendor_store/controllers/product_controller.dart';
import 'package:ecomerce_vendor_store/controllers/subcategory_controller.dart';
import 'package:ecomerce_vendor_store/models/category.dart';
import 'package:ecomerce_vendor_store/models/subcategory.dart';
import 'package:ecomerce_vendor_store/provider/vendor_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class UploadScreen extends ConsumerStatefulWidget {
  const UploadScreen({super.key});

  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class _UploadScreenState extends ConsumerState<UploadScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ProductController _productController = ProductController();
  late Future<List<Category>> futureCategories;
  Future<List<Subcategory>>? futureSubcategories;
  Category? selectedCategory;
  Subcategory? selectedSubcategory;
  late String productName;
  late int productPrice;
  late int quantity;
  late String description;

  bool isLoading = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    futureCategories = CategoryController().loadCategories();
  }

  //create an inatance of imagePicker to handle image selection
  final ImagePicker picker = ImagePicker();

  //inititalize an empty list to store the selected images
  List<File> images = [];

  //Defind a function to choose image from the gallary
  chooseImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    //check if the image was picked
    if (pickedFile == null) {
      print('No image picked ');
    } else {
      //if the image was picked, update the state and add the image to the list
      setState(() {
        images.add(File(pickedFile.path));
      });
    }
  }

  getSubcategoryByCategory(value) async {
    //fetch subcategories base on the selected category
    futureSubcategories =
        SubcategoryController().getSubcategoriesByCategoryName(value.name);
    //reset the selected Subcategory
    selectedSubcategory = null;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GridView.builder(
              shrinkWrap:
                  true, //allow the girdview to shrink to fit the content
              physics: NeverScrollableScrollPhysics(),
              itemCount: images.length +
                  1, //the number of item in the grid (+1) for the add button
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                  childAspectRatio: 1),
              itemBuilder: (context, index) {
                //if the index is 0, display an iconbutton to add new image
                return index == 0
                    ? Center(
                        child: IconButton(
                            onPressed: () {
                              chooseImage();
                            },
                            icon: Icon(Icons.add)),
                      )
                    : SizedBox(
                        width: 50,
                        height: 40,
                        child: Image.file(images[index - 1]),
                      );
              },
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 200,
                    child: TextFormField(
                      onChanged: (value) {
                        productName = value;
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Enter Product Name";
                        }
                      },
                      decoration: const InputDecoration(
                          labelText: 'Enter Product Name',
                          hintText: 'Enter product Name',
                          border: OutlineInputBorder()),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    width: 200,
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        productPrice = int.parse(value);
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Enter Product Price";
                        }
                      },
                      decoration: const InputDecoration(
                        labelText: 'Enter Product Price',
                        hintText: 'Enter product Price',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    width: 200,
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        quantity = int.parse(value);
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Enter Product Quantity";
                        }
                      },
                      decoration: const InputDecoration(
                        labelText: 'Enter Product Quantity',
                        hintText: 'Enter product Quantity',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 200,
                    child: FutureBuilder<List<Category>>(
                        future: futureCategories,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          } else if (snapshot.hasError) {
                            return Center(
                              child: Text('Error:${snapshot.error}'),
                            );
                          } else if (!snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            return const Center(
                              child: Text('No categories'),
                            );
                          } else {
                            return DropdownButton<Category>(
                                value: selectedCategory,
                                hint: const Text('Select Category'),
                                items: snapshot.data!.map((Category category) {
                                  return DropdownMenuItem(
                                      value: category,
                                      child: Text(category.name));
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedCategory = value;
                                  });
                                  getSubcategoryByCategory(selectedCategory);
                                });
                          }
                        }),
                  ),
                  SizedBox(
                    width: 200,
                    child: FutureBuilder<List<Subcategory>>(
                        future: futureSubcategories,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          } else if (snapshot.hasError) {
                            return Center(
                              child: Text('Error:${snapshot.error}'),
                            );
                          } else if (!snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            return const Center(
                              child: Text('No Subcategories'),
                            );
                          } else {
                            return DropdownButton<Subcategory>(
                                value: selectedSubcategory,
                                hint: const Text('Select Subcategory'),
                                items: snapshot.data!
                                    .map((Subcategory subcategory) {
                                  return DropdownMenuItem(
                                      value: subcategory,
                                      child: Text(subcategory.subCategoryName));
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedSubcategory = value;
                                  });
                                });
                          }
                        }),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    width: 400,
                    child: TextFormField(
                      onChanged: (value) {
                        description = value;
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Enter Product Description";
                        }
                      },
                      maxLines: 3,
                      maxLength: 500,
                      decoration: const InputDecoration(
                        labelText: 'Enter Product Description',
                        hintText: 'Enter product Description',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: InkWell(
                onTap: () async {
                  final fullName = ref.read(vendorProvider)!.fullName;
                  final vendorId = ref.read(vendorProvider)!.id;
                  if (_formKey.currentState!.validate()) {
                    setState(() {
                      isLoading = true;
                    });
                    await _productController
                        .uploadProduct(
                            productName: productName,
                            productPrice: productPrice,
                            quantity: quantity,
                            description: description,
                            category: selectedCategory!.name,
                            vendorId: vendorId,
                            fullName: fullName,
                            subCategory: selectedSubcategory!.subCategoryName,
                            pickedImages: images,
                            context: context)
                        .whenComplete(() {
                      setState(() {
                        isLoading = false;
                      });
                      selectedCategory = null;
                      selectedSubcategory = null;
                      images.clear();
                    });
                  } else {
                    print("please enter all the fields");
                  }
                },
                child: Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade900,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Center(
                    child: isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : const Text(
                            'Upload Product',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.7,
                            ),
                          ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
