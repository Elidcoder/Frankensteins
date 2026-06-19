// External Import
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:frankenstein/shared/widgets/top_bar.dart' show RegularTop;

import '../../../core/services/global_list_manager.dart' show GlobalListManager;
import '../../../core/theme/theme_manager.dart';
import '../../../core/utils/style_utils.dart';
import 'export_content_screen.dart';

/* Serves as a linker page for sharing content functionality (downloading and managing shared content). */
class SharingContent extends StatelessWidget {
  const SharingContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        /* Page title (Sharing content) */
        appBar: StyleUtils.buildStyledAppBar(
          title: "Share content",
          titleStyle: TextStyle(
            fontSize: 45,
            fontWeight: FontWeight.w700,
            color: ThemeManager.instance.currentScheme.textColour,
          ),
        ),
        backgroundColor: ThemeManager.instance.currentScheme.backgroundColour,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 100),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                /* Button to download content from file */
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor:
                        ThemeManager.instance.currentScheme.backingColour,
                    padding: const EdgeInsets.fromLTRB(55, 25, 55, 25),
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    side: const BorderSide(width: 3, color: Colors.black),
                  ),
                  onPressed: () async {
                    await _handleDownloadContent(context);
                  },
                  child: Text(
                    textAlign: TextAlign.center,
                    "Download\nContent",
                    style: TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.w700,
                        color: ThemeManager.instance.currentScheme.textColour),
                  ),
                ),
                const SizedBox(width: 100),
                /* Button to export content to file */
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor:
                        ThemeManager.instance.currentScheme.backingColour,
                    padding: const EdgeInsets.fromLTRB(55, 25, 55, 25),
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    side: const BorderSide(width: 3, color: Colors.black),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              RegularTop(pagechoice: () => ExportContent())),
                    );
                  },
                  child: Text(
                    textAlign: TextAlign.center,
                    "Export\nContent",
                    style: TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.w700,
                        color: ThemeManager.instance.currentScheme.textColour),
                  ),
                ),
              ],
            ),
          ],
        ));
  }

  /// Handles the download content file picker functionality
  Future<void> _handleDownloadContent(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      dialogTitle:
          "Navigate to and select a Json file to download the contents from, this content can then be used in your characters",
      type: FileType.custom,
      allowedExtensions: ["json"],
      // Request the file contents directly so this works on web (where there
      // is no file path) as well as desktop.
      withData: true,
    );

    try {
      if (result == null) throw Exception("File cannot be found");
      final bytes = result.files.single.bytes;
      if (bytes == null) {
        throw Exception("File contents could not be read");
      }
      await GlobalListManager().loadContentFromJson(utf8.decode(bytes));

      // Show success message
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Content downloaded successfully!'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (err) {
      // ignore: use_build_context_synchronously
      _showErrorDialog(context, err);
    }
  }

  /// Display an error dialog letting the user know that the download was bad
  void _showErrorDialog(BuildContext context, Object error) {
    showDialog(
      context: context,
      builder: (context) => StyleUtils.buildStyledAlertDialog(
        title: "Error",
        content: error.toString(),
        titleWidget: StyleUtils.buildStyledLargeTextBox(
          text: "Json format incorrect, reformat and try again!",
          color: Colors.red,
        ),
        actions: [
          StyleUtils.buildStyledTextButton(
            text: "Continue",
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
