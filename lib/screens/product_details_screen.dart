import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_providers.dart';

class ProductDetailsScreen extends StatelessWidget {
  static const String routeName = 'product_details';

  @override
  Widget build(BuildContext context) {
    final productId = ModalRoute.of(context)?.settings.arguments as String;
    final loadProduct = Provider.of<ProductProvider>(
      context,
      listen: false, // false maksudnya tidak mentrigger update pada provider
    ).findById(productId);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          loadProduct.title,
        ),
      ),
      body: SingleChildScrollView( //todo 1 (finish)
        child: Column(
          children: [
            Container(
              height: 300,
              width: double.infinity,
              child: Image.network(
                loadProduct.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              '\$${loadProduct.price}',
              style: TextStyle(color: Colors.grey, fontSize: 20),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 10,),
              child: Text(
                loadProduct.description,
                textAlign: TextAlign.center,
                softWrap: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
