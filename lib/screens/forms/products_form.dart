import 'package:basic_single_user_pos_flutter/helpers/color_helper.dart';
import 'package:basic_single_user_pos_flutter/models/product.dart';
import 'package:basic_single_user_pos_flutter/providers/category_provider.dart';
import 'package:basic_single_user_pos_flutter/providers/product_provider.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';
import 'package:basic_single_user_pos_flutter/providers/modifier_provider.dart';

class ProductsFormPage extends StatefulWidget {
  const ProductsFormPage({super.key});

  @override
  State<ProductsFormPage> createState() => _ProductsFormPageState();
}

class _ProductsFormPageState extends State<ProductsFormPage> {
  late GlobalKey<FormBuilderState> _formKey;
  late Map<String, dynamic> initialValues;
  Product? productArg;
  List<int> _enabledModifierIds = [];

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormBuilderState>();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    productArg = ModalRoute.of(context)?.settings.arguments as Product?;

    if (productArg != null) {
      _enabledModifierIds = List.from(productArg!.enabledModifierIds);
    } else {
      _enabledModifierIds = [];
    }

    initialValues = {
      'productName': productArg?.name ?? '',
      'category': productArg?.categoryId ?? 1,
      'cost': productArg?.cost?.toString() ?? '',
      'price': productArg?.price.toString() ?? '',
      'color': productArg != null
          ? ColorHelper.fromHex(productArg!.color)
          : Colors.grey,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Column(children: [_buildHeader(), _buildForm()]));
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 25),
      alignment: Alignment.bottomCenter,
      height: 100,
      decoration: const BoxDecoration(color: Colors.teal),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      FontAwesomeIcons.angleLeft,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    productArg == null ? "Add Product" : "Edit Product",
                    style: const TextStyle(
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
                    _buildDeleteButton(),
                  _buildSaveButton(),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteButton() {
    return IconButton(
      onPressed: () async {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Delete Product"),
            content: const Text(
              "Are you sure you want to delete this product?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text(
                  "Delete",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        );

        if (confirm == true) {
          await context.read<ProductProvider>().deleteProduct(productArg!.id!);
          Navigator.pop(context);
        }
      },
      icon: const Icon(Icons.delete, color: Colors.red),
    );
  }

  Widget _buildSaveButton() {
    return TextButton(
      onPressed: () async {
        if (_formKey.currentState?.saveAndValidate() ?? false) {
          final formData = _formKey.currentState!.value;
          final productProvider = context.read<ProductProvider>();

          final product = Product(
            id: productArg?.id,
            name: formData['productName'],
            categoryId: formData['category'],
            cost: double.tryParse(formData['cost'].toString()) ?? 0,
            price: double.tryParse(formData['price'].toString()) ?? 0,
            color: ColorHelper.toHex(formData['color']),
            enabledModifierIds: _enabledModifierIds,
          );

          int productId;
          if (productArg == null) {
            productId = await productProvider.addProduct(product);
          } else {
            productId = productArg!.id!;
            await productProvider.updateProduct(product);
          }

          await productProvider.updateProductModifiers(
            productId,
            _enabledModifierIds,
          );

          Navigator.pop(context);
        }
      },
      child: const Text(
        "SAVE",
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 200, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 4),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
        child: FormBuilder(
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
              const SizedBox(height: 20),
              _buildCategoryDropdown(),
              const SizedBox(height: 20),
              _buildCostAndPriceFields(),
              const SizedBox(height: 40),
              _buildModifiersSection(),
              const SizedBox(height: 40),
              _buildColorPicker(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return FormBuilderDropdown<int>(
      name: 'category',
      initialValue: initialValues['category'],
      decoration: const InputDecoration(labelText: 'Category'),
      onChanged: (value) {
        if (value == -1) {
          // Reset the dropdown value immediately
          _formKey.currentState!.fields['category']!.didChange(
            initialValues['category'],
          );

          // Navigate safely after microtask
          Future.microtask(() {
            if (!mounted) return; // <- guard against disposed widget
            Navigator.pushNamed(context, '/addCategory');
          });
        }
      },

      items: [
        ...context.watch<CategoryProvider>().categories.map(
          (category) => DropdownMenuItem<int>(
            value: category.id,
            child: Text(category.name),
          ),
        ),
        const DropdownMenuItem<int>(enabled: false, child: Divider()),
        const DropdownMenuItem<int>(
          value: -1,
          child: Row(
            children: [
              Icon(Icons.add),
              SizedBox(width: 25),
              Text('Add Category'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCostAndPriceFields() {
    return Row(
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
        const SizedBox(width: 50),
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
    );
  }

  Widget _buildModifiersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: context.watch<ModifierProvider>().modifiers.map((modifier) {
        return FormBuilderField<bool>(
          name: 'modifier_${modifier.id}',
          initialValue: _enabledModifierIds.contains(modifier.id),
          builder: (field) => SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(modifier.name),
            value: field.value ?? false,
            onChanged: (val) {
              field.didChange(val);
              setState(() {
                if (val) {
                  if (!_enabledModifierIds.contains(modifier.id)) {
                    _enabledModifierIds.add(modifier.id!);
                  }
                } else {
                  _enabledModifierIds.remove(modifier.id);
                }
              });
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildColorPicker() {
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

    return FormBuilderField<Color>(
      name: 'color',
      initialValue: initialValues['color'],
      builder: (field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Product Color',
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: colors.map((color) {
                final isSelected = (field.value?.value ?? 0) == color.value;
                return GestureDetector(
                  onTap: () => field.didChange(color),
                  child: Container(
                    margin: const EdgeInsets.only(right: 20),
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: color,
                      border: isSelected
                          ? Border.all(color: Colors.black, width: 2)
                          : null,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }
}
