import 'package:eshop_multivendor/cubits/downloadFileCubit.dart';
import 'package:eshop_multivendor/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_filex/open_filex.dart';

class DownloadFileDialog extends StatefulWidget {
  final String fileUrl;
  final String fileName;
  final String fileExtension;
  final bool storeInExternalStorage;
  const DownloadFileDialog(
      {Key? key,
      required this.fileExtension,
      required this.fileName,
      required this.fileUrl,
      required this.storeInExternalStorage})
      : super(key: key);

  @override
  State<DownloadFileDialog> createState() => _DownloadFileDialogState();
}

class _DownloadFileDialogState extends State<DownloadFileDialog> {
  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      context.read<DownloadFileCubit>().downloadFile(
          fileUrl: widget.fileUrl,
          fileName: widget.fileName,
          fileExtension: widget.fileExtension,
          storeInExternalStorage: widget.storeInExternalStorage);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (context.read<DownloadFileCubit>().state is DownloadFileInProgress) {
          context.read<DownloadFileCubit>().cancelDownloadProcess();
        }
        return Future.value(true);
      },
      child: BlocConsumer<DownloadFileCubit, DownloadFileState>(
        listener: (context, state) {
          if (state is DownloadFileFailure) {
            setSnackbar(state.errorMessage, context);
            Navigator.of(context).pop();
          } else if (state is DownloadFileSuccess) {
            Navigator.of(context).pop();
            OpenFilex.open(state.downloadedFileUrl);
          }
        },
        builder: (context, state) {
          Widget content = const Text('Progress : -');
          if (state is DownloadFileInProgress) {
            content = Text(
                'Progress : ${state.downloadPercentage.toStringAsFixed(2)}');
          } else if (state is DownloadFileSuccess) {
            content = const Text('File downloaded successfully');
          }

          return AlertDialog(
              title: const Text('Download in progress'), content: content);
        },
      ),
    );
  }
}
