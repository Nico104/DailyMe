import 'package:dailyme/utils/widgets/shy_button.dart';
import 'package:flutter/material.dart';

//TODO localiization

class FutureErrorWidget extends StatelessWidget {
  const FutureErrorWidget({super.key, this.error});

  final Object? error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Spacer(
            flex: 2,
          ),
          Image.asset("assets/tmp/connection_lost.png"),
          const Spacer(
            flex: 2,
          ),
          Text(
            "futureErrorTitle",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Text(
            error.toString(),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            "futureErrorLabel",
            style: Theme.of(context).textTheme.labelMedium,
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          ShyButton(
            showUploadButton: true,
            onTap: () {
              Navigator.pop(context);
            },
            label: "futureErrorButtonLabel",
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }
}
