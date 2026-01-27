import 'package:basic_single_user_pos_flutter/helpers/color_helper.dart';
import 'package:basic_single_user_pos_flutter/models/product.dart';
import 'package:basic_single_user_pos_flutter/providers/category_provider.dart';
import 'package:basic_single_user_pos_flutter/providers/product_provider.dart';
import 'package:basic_single_user_pos_flutter/repositories/product_repository.dart';
import 'package:basic_single_user_pos_flutter/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';

class ProductsFormPage extends StatefulWidget {
  const ProductsFormPage({super.key});

  @override
  State<ProductsFormPage> createState() => _ProductsFormPageState();
}

final _formKey = GlobalKey<FormBuilderState>();
final databaseService = DatabaseService();
final productRepository = ProductRepository(databaseService);

class _ProductsFormPageState extends State<ProductsFormPage> {
  late Map<String, dynamic> initialValues;
  Product? productArg;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Grab the product from route arguments if widget.product is null
    productArg = ModalRoute.of(context)?.settings.arguments as Product?;

    initialValues = {
      'productName': productArg?.name ?? '',
      'category': productArg?.categoryId ?? 1,
      'cost': productArg?.cost?.toString() ?? '',
      'price': productArg?.price?.toString() ?? '',
      'color': productArg != null
          ? ColorHelper.fromHex(productArg!.color)
          : Colors.grey,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 14, horizontal: 25),
            alignment: Alignment.bottomCenter,
            height: 100,
            decoration: BoxDecoration(color: Colors.teal),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Builder(
                          builder: (context) => IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: Icon(
                              FontAwesomeIcons.angleLeft,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Text(
                          productArg == null ? "Add Product" : "Edit Product",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        if (productArg != null && productArg!.id != null)
                          IconButton(
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: Text("Delete Product"),
                                  content: Text(
                                    "Are you sure you want to delete this product?",
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(ctx, false),
                                      child: Text("Cancel"),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx, true),
                                      child: Text(
                                        "Delete",
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                await context
                                    .read<ProductProvider>()
                                    .deleteProduct(productArg!.id!);
                                Navigator.pop(
                                  context,
                                ); // close form after deletion
                              }
                            },
                            icon: Icon(Icons.delete, color: Colors.red),
                          ),
                        TextButton(
                          onPressed: () {
                            if (_formKey.currentState?.saveAndValidate() ??
                                false) {
                              final formData = _formKey.currentState!.value;

                              final product = Product(
                                id: productArg?.id, // keep id if editing
                                name: formData['productName'],
                                categoryId: formData['category'],
                                cost:
                                    double.tryParse(
                                      formData['cost'].toString(),
                                    ) ??
                                    0,
                                price:
                                    double.tryParse(
                                      formData['price'].toString(),
                                    ) ??
                                    0,
                                color: ColorHelper.toHex(formData['color']),
                              );

                              final productProvider = context
                                  .read<ProductProvider>();

                              if (productArg == null) {
                                productProvider.addProduct(product);
                              } else {
                                productProvider.updateProduct(product);
                              }

                              Navigator.pop(context);
                            }
                          },
                          child: Text(
                            "SAVE",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 200, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
              child:
                  //name
                  FormBuilder(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FormBuilderTextField(
                          name: 'productName',
                          initialValue: initialValues['productName'],
                          decoration: const InputDecoration(labelText: 'Name'),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(),
                          ]),
                        ),
                        SizedBox(height: 20),
                        FormBuilderDropdown<int>(
                          name: 'category',
                          initialValue: initialValues['category'],
                          decoration: const InputDecoration(
                            labelText: 'Category',
                          ),
                          items: [
                            ...context.watch<CategoryProvider>().categories.map(
                              (category) => DropdownMenuItem<int>(
                                value: category.id,
                                child: Text(category.name),
                              ),
                            ),
                            const DropdownMenuItem(
                              enabled: false,
                              child: Divider(),
                            ),
                            const DropdownMenuItem(
                              value: -1,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(Icons.add),
                                  SizedBox(width: 25),
                                  Text('Add Category'),
                                ],
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            if (value == -1) {
                              Navigator.pushReplacementNamed(context, '/sale');
                            }
                          },
                        ),
                        SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: FormBuilderTextField(
                                name: 'cost',
                                initialValue: initialValues['cost'],
                                decoration: const InputDecoration(
                                  labelText: 'Cost',
                                  prefixText: '₱ ',
                                ),
                              ),
                            ),
                            SizedBox(width: 50),
                            Expanded(
                              child: FormBuilderTextField(
                                name: 'price',
                                initialValue: initialValues['price'],
                                decoration: const InputDecoration(
                                  labelText: 'Price',
                                  prefixText: '₱ ',
                                ),
                                validator: FormBuilderValidators.compose([
                                  FormBuilderValidators.required(),
                                  FormBuilderValidators.numeric(),
                                  FormBuilderValidators.min(0),
                                ]),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 40),
                        FormBuilderField<Color>(
                          name: 'color',
                          initialValue: initialValues['color'],
                          builder: (field) {
                            final colors = [
                              Colors.grey,
                              Colors.red,
                              Colors.pink,
                              Colors.orange,
                              Colors.yellow,
                              Colors.lightGreen,
                              Colors.green,
                              Colors.blue,
                              Colors.purple,
                            ];

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Product Color',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: colors.map((color) {
                                    final isSelected =
                                        (field.value?.value ?? 0) ==
                                        color.value;
                                    return GestureDetector(
                                      onTap: () => field.didChange(color),
                                      child: Container(
                                        margin: const EdgeInsets.only(
                                          right: 20,
                                        ),
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          color: color,
                                          border: isSelected
                                              ? Border.all(
                                                  color: Colors.black,
                                                  width: 2,
                                                )
                                              : null,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
