import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../services/auth_service.dart';
import '../widgets/custom_textfield.dart';
import '../widgets/custom_button.dart';
import '../utils/responsive_helper.dart';
import '../utils/snackbar_helper.dart';
import 'organization_approval_waiting_screen.dart';

class OrganizationDetailsScreen extends StatefulWidget {
  const OrganizationDetailsScreen({super.key});

  @override
  State<OrganizationDetailsScreen> createState() => _OrganizationDetailsScreenState();
}

class _OrganizationDetailsScreenState extends State<OrganizationDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _churchNameController = TextEditingController();
  final _organizerNameController = TextEditingController();
  final _churchAddressController = TextEditingController();
  final _churchWebsiteController = TextEditingController();
  final _youtubeLinkController = TextEditingController();
  final _socialMediaLinksController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  final List<XFile> _churchImages = [];
  final List<XFile> _relatedImages = [];
  bool _isLoading = false;
  String _progressMessage = '';

  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _churchNameController.dispose();
    _organizerNameController.dispose();
    _churchAddressController.dispose();
    _churchWebsiteController.dispose();
    _youtubeLinkController.dispose();
    _socialMediaLinksController.dispose();
    super.dispose();
  }

  Future<void> _pickChurchImages() async {
    try {
      debugPrint('Image Selection: Triggered picking church images with compression settings...');
      final List<XFile> pickedFiles = await _picker.pickMultiImage(
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      debugPrint('Image Selection: Successfully selected ${pickedFiles.length} Church Images');
      setState(() {
        _churchImages.addAll(pickedFiles);
      });
    } catch (e) {
      debugPrint('Image Selection Error: Error picking church images: $e');
    }
  }

  Future<void> _pickRelatedImages() async {
    try {
      debugPrint('Image Selection: Triggered picking related images with compression settings...');
      final List<XFile> pickedFiles = await _picker.pickMultiImage(
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      debugPrint('Image Selection: Successfully selected ${pickedFiles.length} Related Images');
      setState(() {
        _relatedImages.addAll(pickedFiles);
      });
    } catch (e) {
      debugPrint('Image Selection Error: Error picking related images: $e');
    }
  }

  Widget _buildThumbnail(XFile file) {
    if (kIsWeb) {
      return Image.network(
        file.path,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
      );
    } else {
      return Image.file(
        File(file.path),
        width: 80,
        height: 80,
        fit: BoxFit.cover,
      );
    }
  }

  Widget _buildImagePreviewList(List<XFile> images) {
    if (images.isEmpty) return const SizedBox.shrink();
    final rh = ResponsiveHelper(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: rh.space(8)),
        SizedBox(
          height: 80,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: images.length,
            separatorBuilder: (context, index) => SizedBox(width: rh.space(8)),
            itemBuilder: (context, index) {
              final file = images[index];
              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(rh.space(8)),
                    child: _buildThumbnail(file),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          images.removeAt(index);
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Future<List<String>> _uploadImagesParallel(List<XFile> files, String path) async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    debugPrint('Storage Upload verification: Active user UID is "$uid" for writing to path "organizations/$uid/$path"');
    if (uid.isEmpty) {
      throw Exception('Authentication required for Storage upload.');
    }

    debugPrint('Storage Upload: Starting parallel upload of ${files.length} files to path "$path"');
    
    final List<Future<String>> uploadFutures = List.generate(files.length, (index) {
      final file = files[index];
      return () async {
        final imgStopwatch = Stopwatch()..start();
        debugPrint('Storage Upload: Starting upload for image $index of "$path" (${file.name})');
        
        final bytes = await file.readAsBytes();
        final extension = file.name.split('.').last;
        final ref = FirebaseStorage.instance
            .ref()
            .child('organizations/$uid/$path/image_${DateTime.now().millisecondsSinceEpoch}_$index.$extension');

        final uploadTask = ref.putData(
          bytes,
          SettableMetadata(contentType: 'image/${extension == 'png' ? 'png' : 'jpeg'}'),
        );

        final snapshot = await uploadTask;
        final url = await snapshot.ref.getDownloadURL();
        
        debugPrint('Storage Upload: Finished upload for image $index of "$path" in ${imgStopwatch.elapsedMilliseconds}ms. URL: $url');
        return url;
      }();
    });

    return await Future.wait(uploadFutures);
  }

  void _uploadImagesInBackground(String uid, List<XFile> churchImages, List<XFile> relatedImages) {
    Future(() async {
      try {
        debugPrint('Background Upload: Starting background image uploads for UID: $uid');
        final results = await Future.wait([
          _uploadImagesParallel(churchImages, 'church_images'),
          _uploadImagesParallel(relatedImages, 'related_images'),
        ]);
        final List<String> churchUrls = results[0];
        final List<String> relatedUrls = results[1];

        debugPrint('Background Upload: Images uploaded successfully. Updating Firestore document at /organizations/$uid');
        await FirebaseFirestore.instance.collection('organizations').doc(uid).update({
          'uploadedImageUrls': FieldValue.arrayUnion(churchUrls),
          'relatedImageUrls': FieldValue.arrayUnion(relatedUrls),
        });
        debugPrint('Background Upload: Firestore document updated successfully.');
      } catch (e) {
        debugPrint('Background Upload Error: Failed uploading images in background: $e');
      } finally {
        debugPrint('Background Upload: Finalizing session sign-out for UID: $uid');
        await _authService.signOut();
      }
    });
  }

  void _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _progressMessage = 'Saving organization details...';
      });

      final totalStopwatch = Stopwatch()..start();
      final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      debugPrint('Submission: Starting details submission for UID: $uid');

      try {
        if (uid.isEmpty) {
          throw Exception('User is not authenticated.');
        }

        // Perform Firestore write instantly, wrapped in a timeout
        await () async {
          // Save to Firestore (instant)
          debugPrint('Firestore: Writing organization document to Firestore at /organizations/$uid');
          final firestoreStopwatch = Stopwatch()..start();
          await FirebaseFirestore.instance.collection('organizations').doc(uid).set({
            'organizationId': uid,
            'churchName': _churchNameController.text.trim(),
            'organizerName': _organizerNameController.text.trim(),
            'churchAddress': _churchAddressController.text.trim(),
            'churchWebsite': _churchWebsiteController.text.trim(),
            'youtubeLink': _youtubeLinkController.text.trim(),
            'socialMediaLinks': _socialMediaLinksController.text.trim(),
            'uploadedImageUrls': [],
            'relatedImageUrls': [],
            'status': 'pending',
            'createdAt': FieldValue.serverTimestamp(),
          });
          debugPrint('Firestore: Successfully created organization document at /organizations/$uid in ${firestoreStopwatch.elapsedMilliseconds}ms');

          // Trigger background image uploads asynchronously
          if (_churchImages.isNotEmpty || _relatedImages.isNotEmpty) {
            _uploadImagesInBackground(uid, _churchImages, _relatedImages);
          } else {
            // Sign out immediately if no images
            debugPrint('Auth: No images selected. Signing out immediately.');
            await _authService.signOut();
          }
        }().timeout(const Duration(seconds: 45));

        debugPrint('Submission Metric: Total submission process finished in ${totalStopwatch.elapsedMilliseconds}ms');

        if (mounted) {
          debugPrint('Navigation: Successfully saved details and redirecting to OrganizationApprovalWaitingScreen');
          SnackbarHelper.show(
            context: context,
            message: 'Details submitted successfully!',
            backgroundColor: const Color(0xFF2ECC71),
          );
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const OrganizationApprovalWaitingScreen(),
            ),
            (route) => false,
          );
        }
      } on TimeoutException catch (e) {
        debugPrint('Submission Error: Process timed out. $e');
        if (mounted) {
          SnackbarHelper.show(
            context: context,
            message: 'Submission timed out. Please check your internet connection and try again.',
            backgroundColor: const Color(0xFFE50914),
          );
        }
      } catch (e) {
        debugPrint('Submission Error: Failed with error: ${e.toString()}');
        if (mounted) {
          SnackbarHelper.show(
            context: context,
            message: 'Error: ${e.toString()}',
            backgroundColor: const Color(0xFFE50914),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _progressMessage = '';
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryRed = Color(0xFFE50914);
    const Color darkSurface = Color(0xFF0A0A0A);
    const Color borderDark = Color(0xFF262626);
    const Color textLight = Color(0xFFB3B3B3);

    final rh = ResponsiveHelper(context);

    final double screenPaddingHorizontal = rh.screenPaddingHorizontal;
    final double screenPaddingVertical = rh.screenPaddingVertical;
    final double cardPaddingHorizontal = rh.cardPaddingHorizontal;
    final double cardPaddingVertical = rh.cardPaddingVertical;
    final double maxContentWidth = rh.maxContentWidth;

    final double titleFontSize = rh.text(20.0);
    final double subtitleFontSize = rh.text(12.0);
    final double fieldSpacing = rh.space(12.0);
    final double buttonSpace = rh.space(20.0);
    final double buttonHeight = rh.screenHeight < 600 ? 44.0 : 48.0;
    final double buttonFontSize = 15.0;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenPaddingHorizontal,
                    vertical: screenPaddingVertical,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: maxContentWidth,
                      ),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: cardPaddingHorizontal,
                          vertical: cardPaddingVertical,
                        ),
                        decoration: BoxDecoration(
                          color: darkSurface,
                          borderRadius: BorderRadius.circular(rh.space(16)),
                          border: Border.all(
                            color: borderDark,
                            width: 1.5,
                          ),
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Organization Details',
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: titleFontSize,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: rh.space(6)),
                              Text(
                                'Complete your profile to request access approval',
                                style: GoogleFonts.inter(
                                  color: textLight,
                                  fontSize: subtitleFontSize,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: rh.space(20)),

                              CustomTextField(
                                label: 'Church Name *',
                                hintText: 'Acme Church',
                                controller: _churchNameController,
                                prefixIcon: Icons.church_outlined,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Church Name is required';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: fieldSpacing),

                              CustomTextField(
                                label: 'Church Organizer Name *',
                                hintText: 'John Doe',
                                controller: _organizerNameController,
                                prefixIcon: Icons.person_outline,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Organizer Name is required';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: fieldSpacing),

                              CustomTextField(
                                label: 'Church Address *',
                                hintText: '123 Main St, City, Country',
                                controller: _churchAddressController,
                                prefixIcon: Icons.location_on_outlined,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Address is required';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: fieldSpacing),

                              CustomTextField(
                                label: 'Church Website (Optional)',
                                hintText: 'https://example.com',
                                controller: _churchWebsiteController,
                                prefixIcon: Icons.language_outlined,
                              ),
                              SizedBox(height: fieldSpacing),

                              CustomTextField(
                                label: 'Church YouTube Link *',
                                hintText: 'https://youtube.com/c/yourchannel',
                                controller: _youtubeLinkController,
                                prefixIcon: Icons.video_library_outlined,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'YouTube link is required';
                                  }
                                  final RegExp youtubeRegex = RegExp(
                                    r'^https?:\/\/(www\.)?(youtube\.com|youtu\.be)\/.*$',
                                    caseSensitive: false,
                                  );
                                  if (!youtubeRegex.hasMatch(value.trim())) {
                                    return 'Enter a valid YouTube link';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: fieldSpacing),

                              CustomTextField(
                                label: 'Church Social Media Links (Optional)',
                                hintText: 'Facebook, Twitter, etc.',
                                controller: _socialMediaLinksController,
                                prefixIcon: Icons.share_outlined,
                              ),
                              SizedBox(height: fieldSpacing),

                              // Upload Church Images Label & Picker
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(left: rh.space(4), bottom: rh.space(2)),
                                    child: Text(
                                      'Upload Church Images (Optional)',
                                      style: GoogleFonts.inter(
                                        color: textLight,
                                        fontWeight: FontWeight.w600,
                                        fontSize: rh.text(14.0),
                                      ),
                                    ),
                                  ),
                                  OutlinedButton.icon(
                                    onPressed: _pickChurchImages,
                                    icon: const Icon(Icons.photo_library_outlined, color: primaryRed),
                                    label: Text(
                                      'Select Church Images',
                                      style: GoogleFonts.inter(color: Colors.white),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(color: borderDark),
                                      padding: EdgeInsets.symmetric(horizontal: rh.space(16), vertical: rh.space(12)),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(rh.space(12)),
                                      ),
                                      backgroundColor: darkSurface,
                                    ),
                                  ),
                                  _buildImagePreviewList(_churchImages),
                                ],
                              ),
                              SizedBox(height: fieldSpacing),

                              // Upload Related Images Label & Picker
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(left: rh.space(4), bottom: rh.space(2)),
                                    child: Text(
                                      'Upload Related Images (Optional)',
                                      style: GoogleFonts.inter(
                                        color: textLight,
                                        fontWeight: FontWeight.w600,
                                        fontSize: rh.text(14.0),
                                      ),
                                    ),
                                  ),
                                  OutlinedButton.icon(
                                    onPressed: _pickRelatedImages,
                                    icon: const Icon(Icons.add_photo_alternate_outlined, color: primaryRed),
                                    label: Text(
                                      'Select Related Images',
                                      style: GoogleFonts.inter(color: Colors.white),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(color: borderDark),
                                      padding: EdgeInsets.symmetric(horizontal: rh.space(16), vertical: rh.space(12)),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(rh.space(12)),
                                      ),
                                      backgroundColor: darkSurface,
                                    ),
                                  ),
                                  _buildImagePreviewList(_relatedImages),
                                ],
                              ),
                              SizedBox(height: buttonSpace),

                              CustomButton(
                                text: 'Submit',
                                isLoading: _isLoading,
                                onPressed: _handleSubmit,
                                height: buttonHeight,
                                fontSize: buttonFontSize,
                              ),
                              if (_isLoading && _progressMessage.isNotEmpty) ...[
                                SizedBox(height: rh.space(8)),
                                Text(
                                  _progressMessage,
                                  style: GoogleFonts.inter(
                                    color: const Color(0xFFB3B3B3),
                                    fontSize: rh.text(13.0),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
