import 'package:dailyme/utils/widgets/custom_nico_modal.dart';
import 'package:flutter/material.dart';

class FutureNoteButton extends StatelessWidget {
  final String futureNote;
  const FutureNoteButton({super.key, required this.futureNote});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showCustomNicoModalBottomSheet(context: context,
         child: Text(futureNote, style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurface),),);
      },
      child: Container(
        // width: double.infinity,
        // margin: const EdgeInsets.symmetric(vertical: 4),
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border.all(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            width: 1.2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          // mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: Text(
                'What you planned',
                style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.85),
                  fontWeight: FontWeight.w400,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
