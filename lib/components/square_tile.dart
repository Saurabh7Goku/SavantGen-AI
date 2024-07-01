import 'package:flutter/material.dart';

class SquareTile extends StatefulWidget {
  final String imagePath;
  final Function()? onTap;

  const SquareTile({
    Key? key,
    required this.imagePath,
    required this.onTap,
  }) : super(key: key);

  @override
  _SquareTileState createState() => _SquareTileState();
}

class _SquareTileState extends State<SquareTile> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        // Show loading
        setLoading(true);

        // Execute the onTap callback
        await widget.onTap?.call();

        // Hide loading
        setLoading(false);
      },
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(16),
          color: Colors.grey[200],
        ),
        child: isLoading
            ? CircularProgressIndicator() // Loading indicator
            : Image.asset(
                widget.imagePath,
                height: 40,
              ),
      ),
    );
  }

  void setLoading(bool loading) {
    setState(() {
      isLoading = loading;
    });
  }
}
