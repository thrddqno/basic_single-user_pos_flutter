import 'package:basic_single_user_pos_flutter/models/category.dart';
import 'package:basic_single_user_pos_flutter/providers/category_provider.dart';
import 'package:basic_single_user_pos_flutter/providers/product_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';

class CategoryFormPage extends StatefulWidget {
  const CategoryFormPage({super.key});

  @override
  State<CategoryFormPage> createState() => _CategoryFormPageState();
}

class _CategoryFormPageState extends State<CategoryFormPage> {
  late GlobalKey<FormBuilderState> _formKey;
  late Map<String, dynamic> initialValues;
  Category? categoryArg;

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormBuilderState>();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    categoryArg = ModalRoute.of(context)?.settings.arguments as Category?;
    initialValues = {'categoryName': categoryArg?.name ?? ''};
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
                    categoryArg == null ? "Add Category" : "Edit Category",
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
                  if (categoryArg != null && categoryArg!.id != null)
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
            title: const Text("Delete Category"),
            content: const Text(
              "Are you sure you want to delete this category?",
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
          await context.read<CategoryProvider>().deleteCategory(
            categoryArg!.id!,
          );
          await context.read<ProductProvider>().loadProducts();
          Navigator.pop(context);
        }
      },
      icon: const Icon(Icons.delete, color: Colors.red),
    );
  }

  Widget _buildSaveButton() {
    return TextButton(
      onPressed: () {
        if (_formKey.currentState?.saveAndValidate() ?? false) {
          final formData = _formKey.currentState!.value;

          final category = Category(
            id: categoryArg?.id,
            name: formData['categoryName'],
          );

          final categoryProvider = context.read<CategoryProvider>();

          if (categoryArg == null) {
            categoryProvider.addCategory(category);
          } else {
            categoryProvider.updateCategory(category);
          }

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
            children: [
              FormBuilderTextField(
                name: 'categoryName',
                initialValue: initialValues['categoryName'],
                decoration: const InputDecoration(labelText: 'Name'),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
