import 'dart:io';

import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import 'package:sis_patrullaje_cusco/src/domain/repositories/media_repository.dart';
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

class MediaRepositoryImpl implements MediaRepository {
  final ImagePicker picker;
  final AudioRecorder audioRecorder;

  CameraController? _cameraController;

  bool _isRecordingVideo = false;
  bool _isRecordingAudio = false;

  MediaRepositoryImpl({required this.picker, required this.audioRecorder});

  // ======================================================
  // 1. FOTOGRAFÍA DESDE CÁMARA
  // ======================================================
  @override
  Future<Resource<File?>> takePhoto() async {
    try {
      final XFile? selectedFile = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (selectedFile == null) {
        return Success<File?>(null);
      }

      final file = File(selectedFile.path);

      if (!await file.exists()) {
        return ErrorData<File?>(
          message: 'No se encontró la fotografía capturada.',
        );
      }

      return Success<File?>(file);
    } catch (error) {
      return ErrorData<File?>(
        message: 'No se pudo tomar la fotografía: $error',
      );
    }
  }

  // ======================================================
  // 2. SELECCIONAR IMAGEN
  // ======================================================
  @override
  Future<Resource<File?>> pickImage() async {
    try {
      final XFile? selectedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (selectedFile == null) {
        return Success<File?>(null);
      }

      final file = File(selectedFile.path);

      if (!await file.exists()) {
        return ErrorData<File?>(
          message: 'No se encontró la imagen seleccionada.',
        );
      }

      return Success<File?>(file);
    } catch (error) {
      return ErrorData<File?>(
        message: 'No se pudo seleccionar la imagen: $error',
      );
    }
  }

  // ======================================================
  // 3. SELECCIONAR VIDEO
  // ======================================================
  @override
  Future<Resource<File?>> pickVideo() async {
    try {
      final XFile? selectedFile = await picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 2),
      );

      if (selectedFile == null) {
        return Success<File?>(null);
      }

      final file = File(selectedFile.path);

      if (!await file.exists()) {
        return ErrorData<File?>(
          message: 'No se encontró el video seleccionado.',
        );
      }

      return Success<File?>(file);
    } catch (error) {
      return ErrorData<File?>(
        message: 'No se pudo seleccionar el video: $error',
      );
    }
  }

  // ======================================================
  // 4. INICIAR GRABACIÓN DE VIDEO
  // ======================================================
  @override
  Future<Resource<bool>> startVideoRecording() async {
    try {
      if (_isRecordingVideo) {
        return ErrorData<bool>(
          message: 'Ya existe una grabación de video en curso.',
        );
      }

      if (_isRecordingAudio) {
        return ErrorData<bool>(
          message: 'Debe detener la grabación de audio antes de grabar video.',
        );
      }

      final controllerResult = await _initializeCameraController();

      if (controllerResult is ErrorData<CameraController>) {
        return ErrorData<bool>(message: controllerResult.message);
      }

      final controller = _cameraController;

      if (controller == null || !controller.value.isInitialized) {
        return ErrorData<bool>(message: 'La cámara no pudo inicializarse.');
      }

      if (controller.value.isRecordingVideo) {
        _isRecordingVideo = true;
        return Success<bool>(true);
      }

      await controller.prepareForVideoRecording();
      await controller.startVideoRecording();

      _isRecordingVideo = true;

      return Success<bool>(true);
    } on CameraException catch (error) {
      _isRecordingVideo = false;

      return ErrorData<bool>(message: _cameraErrorMessage(error));
    } catch (error) {
      _isRecordingVideo = false;

      return ErrorData<bool>(
        message: 'No se pudo iniciar la grabación de video: $error',
      );
    }
  }

  // ======================================================
  // 5. DETENER GRABACIÓN DE VIDEO
  // ======================================================
  @override
  Future<Resource<File?>> stopVideoRecording() async {
    try {
      final controller = _cameraController;

      if (!_isRecordingVideo ||
          controller == null ||
          !controller.value.isInitialized ||
          !controller.value.isRecordingVideo) {
        return ErrorData<File?>(
          message: 'No existe una grabación de video activa.',
        );
      }

      final XFile recordedFile = await controller.stopVideoRecording();

      _isRecordingVideo = false;

      final file = File(recordedFile.path);

      if (!await file.exists()) {
        return ErrorData<File?>(message: 'No se encontró el video grabado.');
      }

      return Success<File?>(file);
    } on CameraException catch (error) {
      _isRecordingVideo = false;

      return ErrorData<File?>(message: _cameraErrorMessage(error));
    } catch (error) {
      _isRecordingVideo = false;

      return ErrorData<File?>(
        message: 'No se pudo detener la grabación de video: $error',
      );
    }
  }

  // ======================================================
  // 6. INICIAR GRABACIÓN DE AUDIO
  // ======================================================
  @override
  Future<Resource<bool>> startAudioRecording() async {
    try {
      if (_isRecordingAudio) {
        return ErrorData<bool>(
          message: 'Ya existe una grabación de audio en curso.',
        );
      }

      if (_isRecordingVideo) {
        return ErrorData<bool>(
          message: 'Debe detener la grabación de video antes de grabar audio.',
        );
      }

      final hasPermission = await audioRecorder.hasPermission();

      if (!hasPermission) {
        return ErrorData<bool>(
          message: 'No se concedió permiso para utilizar el micrófono.',
        );
      }

      final directory = await getTemporaryDirectory();

      final audioPath = path.join(
        directory.path,
        'incidencia_audio_${DateTime.now().millisecondsSinceEpoch}.m4a',
      );

      const config = RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        sampleRate: 44100,
        numChannels: 1,
      );

      await audioRecorder.start(config, path: audioPath);

      _isRecordingAudio = true;

      return Success<bool>(true);
    } catch (error) {
      _isRecordingAudio = false;

      return ErrorData<bool>(
        message: 'No se pudo iniciar la grabación de audio: $error',
      );
    }
  }

  // ======================================================
  // 7. DETENER GRABACIÓN DE AUDIO
  // ======================================================
  @override
  Future<Resource<File?>> stopAudioRecording() async {
    try {
      if (!_isRecordingAudio) {
        return ErrorData<File?>(
          message: 'No existe una grabación de audio activa.',
        );
      }

      final String? recordedPath = await audioRecorder.stop();

      _isRecordingAudio = false;

      if (recordedPath == null || recordedPath.isEmpty) {
        return ErrorData<File?>(
          message: 'No se obtuvo el archivo de audio grabado.',
        );
      }

      final file = File(recordedPath);

      if (!await file.exists()) {
        return ErrorData<File?>(
          message: 'No se encontró el archivo de audio grabado.',
        );
      }

      return Success<File?>(file);
    } catch (error) {
      _isRecordingAudio = false;

      return ErrorData<File?>(
        message: 'No se pudo detener la grabación de audio: $error',
      );
    }
  }

  // ======================================================
  // INICIALIZAR CÁMARA
  // ======================================================

  Future<Resource<CameraController>> _initializeCameraController() async {
    try {
      final currentController = _cameraController;

      if (currentController != null && currentController.value.isInitialized) {
        return Success<CameraController>(currentController);
      }

      await currentController?.dispose();
      _cameraController = null;

      final cameras = await availableCameras();

      if (cameras.isEmpty) {
        return ErrorData<CameraController>(
          message: 'No se encontraron cámaras disponibles.',
        );
      }

      final selectedCamera = _selectRearCamera(cameras);

      final controller = CameraController(
        selectedCamera,
        ResolutionPreset.high,
        enableAudio: true,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await controller.initialize();

      _cameraController = controller;

      return Success<CameraController>(controller);
    } on CameraException catch (error) {
      return ErrorData<CameraController>(message: _cameraErrorMessage(error));
    } catch (error) {
      return ErrorData<CameraController>(
        message: 'No se pudo inicializar la cámara: $error',
      );
    }
  }

  CameraDescription _selectRearCamera(List<CameraDescription> cameras) {
    return cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );
  }

  // ======================================================
  // 8. LIBERAR RECURSOS
  // ======================================================
  @override
  Future<void> dispose() async {
    try {
      if (_isRecordingVideo &&
          _cameraController?.value.isRecordingVideo == true) {
        await _cameraController?.stopVideoRecording();
      }
    } catch (_) {
      // Se continúa con la liberación de recursos.
    }

    try {
      if (_isRecordingAudio) {
        await audioRecorder.stop();
      }
    } catch (_) {
      // Se continúa con la liberación de recursos.
    }

    _isRecordingVideo = false;
    _isRecordingAudio = false;

    await _cameraController?.dispose();
    _cameraController = null;

    audioRecorder.dispose();
  }

  // ======================================================
  // MENSAJES DE ERROR DE CÁMARA
  // ======================================================
  String _cameraErrorMessage(CameraException error) {
    switch (error.code) {
      case 'CameraAccessDenied':
        return 'No se concedió permiso para utilizar la cámara.';

      case 'CameraAccessDeniedWithoutPrompt':
        return 'El permiso de cámara fue rechazado previamente. '
            'Debe habilitarlo desde la configuración del dispositivo.';

      case 'CameraAccessRestricted':
        return 'El acceso a la cámara está restringido en este dispositivo.';

      case 'AudioAccessDenied':
        return 'No se concedió permiso para utilizar el micrófono.';

      default:
        return 'Error de cámara: ${error.description ?? error.code}';
    }
  }
}
