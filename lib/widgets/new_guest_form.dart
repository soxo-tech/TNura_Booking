// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'package:booking/core/colors.dart';
import 'package:booking/core/constants.dart';
import 'package:booking/main.dart';
import 'package:booking/provider/guests_provider.dart';
import 'package:booking/widgets/guests_textfields.dart';
import 'package:booking/widgets/delete_guest.dart';
import 'package:booking/widgets/refracted_text.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class GuestForm extends StatefulWidget {
  final Guest guest;
  // Add index to track guest number
  final int index;

  const GuestForm({
    super.key,
    required this.guest,
    required this.index,
  });

  @override
  State<GuestForm> createState() => _GuestFormState();
}

class _GuestFormState extends State<GuestForm> with TickerProviderStateMixin {
  // ignore: unused_field
  final bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    final guestProvider = Provider.of<GuestProvider>(context, listen: false);
    return Card(
      elevation: 0.2,
      color: AppColors.containerBackgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// **Display Guest Count at the Top**
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Transform.translate(
                  offset: Offset(0, -1),
                  child: SvgPicture.asset(
                    bookingAssetPath('assets/svg/img_guest.svg'),
                    colorFilter: ColorFilter.mode(
                      AppColors.packageTextPrimary,
                      BlendMode.srcIn,
                    ),
                    height: 11,
                    width: 11,
                  ),
                ),
                SizedBox(width: 9),
                RefractedText(
                  text: 'Guest',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  textColor: AppColors.packageTextPrimary,
                ),
              ],
            ),
            SizedBox(height: 10),

            GuestsTextfield(
              keyboardType: TextInputType.name,
              textCapitalization: TextCapitalization.words,
              controller: widget.guest.firstNameController,
              labelText: 'First name',
              textfieldBorderColor:
                  widget.guest.firstNameError ? Colors.red : AppColors.white,
            ),
            SizedBox(height: 18),
            GuestsTextfield(
              keyboardType: TextInputType.name,
              controller: widget.guest.secondNameController,
              labelText: 'Last name',
              textfieldBorderColor:
                  widget.guest.lastNameError ? Colors.red : AppColors.white,
            ),
            SizedBox(height: 18),
            GuestsTextfield(
              keyboardType: TextInputType.number,
              controller: widget.guest.ageController,
              maxLength: 2,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(2),
              ],
              labelText: 'Age',
              textfieldBorderColor:
                  widget.guest.ageError ? Colors.red : AppColors.white,
            ),
            SizedBox(height: 5),
            _buildGenderSelection(guestProvider),
            SizedBox(height: 5),
            GuestsTextfield(
              keyboardType: TextInputType.emailAddress,
              controller: widget.guest.emailController,
              labelText: isEmailMadatory ? 'Email' : 'Email(Optional)',
              textfieldBorderColor:
                  widget.guest.emailError ? Colors.red : AppColors.white,
            ),
            Padding(
              padding: EdgeInsets.only(left: 3, top: 2),
              child: RefractedText(
                text: 'Digital reports will be sent to this address',
                fontSize: 12,
                fontWeight: FontWeight.w400,
                textColor: AppColors.guestsOptionalTextColor,
              ),
            ),
            SizedBox(height: 17),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: EdgeInsets.fromLTRB(0, 0, 2, 0),
                    height: 40.4,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      border: Border.all(
                        color: widget.guest.showError &&
                                widget.guest.countryCode.isEmpty
                            ? Colors.red
                            : AppColors.white,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        CountryCodePicker(
                          padding: EdgeInsets.only(bottom: 4),
                          margin: EdgeInsets.zero,
                          showFlagDialog: true,
                          showFlag: false,
                          onChanged: (code) {
                            setState(() {
                              widget.guest.countryCode = code.dialCode!;
                            });
                          },
                          initialSelection: 'IN',
                          favorite: ['+91', 'US'],
                          showCountryOnly: false,
                          showOnlyCountryWhenClosed: false,
                          alignLeft: false,
                          textStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textFieldHintColor,
                          ),
                        ),
                        Expanded(
                          child: Transform.translate(
                            offset: Offset(-17, 0),
                            child: Icon(
                              Icons.arrow_drop_down,
                              color: AppColors.primaryDark,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: 9,
                ),
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GuestsTextfield(
                        maxLength: guestProvider
                            .getMaxPhoneLength(widget.guest.countryCode),
                        onTap: () {
                          guestProvider.openDropdown('Phone Number');
                        },
                        onChanged: (value) {
                          guestProvider.filterOptions(value);
                          final isValid = guestProvider.isPhoneLengthValid(
                              value, widget.guest.countryCode,);
                          widget.guest.phoneError = !isValid;

                          // Auto-set OTP verified if phone is already verified
                          final currentPhone = guestProvider.sanitisePhone(
                              value, widget.guest.countryCode,);
                          final isAlreadyVerified = guestProvider
                              .verifiedPhoneNumbers
                              .contains(currentPhone);
                          if (isAlreadyVerified) {
                            widget.guest.otpVerified = true;
                            widget.guest.verifiedPhoneNumber = currentPhone;
                          } else {
                            widget.guest.otpVerified = false;
                          }

                          setState(() {});
                        },
                        keyboardType: TextInputType.number,
                        controller: widget.guest.phoneController,
                        labelText: 'Phone Number',
                        textfieldBorderColor: widget.guest.phoneError
                            ? Colors.red
                            : AppColors.white,
                      ),
                      if (guestProvider.isDropdownOpen &&
                          guestProvider.currentField == 'Phone Number' &&
                          guestProvider.filteredOptions.isNotEmpty)
                        _buildDropdown(
                          guestProvider.filteredOptions,
                          guestProvider.selectPhone,
                        ),
                    ],
                  ),
                ),
              ],
            ),

            Padding(
              padding: EdgeInsets.only(left: 3, top: 2),
              child: RefractedText(
                text: 'We will send a one-time password (OTP) for verification',
                fontSize: 12,
                fontWeight: FontWeight.w400,
                textColor: AppColors.guestsOptionalTextColor,
              ),
            ),

            SizedBox(height: 7),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(
    List<String> options,
    Function(String, Guest) onSelect,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.primaryGreyDark),
        borderRadius: BorderRadius.circular(5),
      ),
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: options.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              onSelect(
                options[index],
                widget.guest,
              );
              setState(() {});
            },
            child: Container(
              padding: EdgeInsets.fromLTRB(11, 5, 3, 5),
              child: RefractedText(
                text: options[index],
                fontSize: 16,
                fontWeight: FontWeight.w400,
                textColor: AppColors.packageTextPrimary,
              ),
            ),
          );
        },
      ),
    );
  }

  // ignore: unused_element
  void _showDeleteConfirmationDialog(
    BuildContext context,
    int index,
    GuestProvider guestProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) => DeleteGuestDialog(
        onDelete: () {
          guestProvider.removeGuest(index);
        },
      ),
    );
  }

  ///Widget to select gender with coresponsing radio buttons
  /// Gender Selection with Provider
  Widget _buildGenderSelection(GuestProvider guestProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RadioGroup<String>(
          groupValue: widget.guest.selectedGender,
          onChanged: (value) {
            setState(() {
              widget.guest.selectedGender = value;
            });
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _buildRadioButton("Male", guestProvider),
              _buildRadioButton("Female", guestProvider),
              _buildRadioButton("Other", guestProvider),
            ],
          ),
        ),
      ],
    );
  }

  /// Radio Button Builder
  Widget _buildRadioButton(String gender, guestProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Radio<String>(
          activeColor: AppColors.textFieldHintColor,
          value: gender,
          fillColor: WidgetStateProperty.resolveWith<Color>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.selected)) {
                return AppColors.textFieldHintColor; // Selected color
              }
              return AppColors.textFieldBorderColor; // Unselected color
            },
          ),
        ),
        Transform.translate(
          offset: Offset(-8, 0),
          child: RefractedText(
            text: gender,
            fontSize: 16,
            fontWeight: FontWeight.w400,
            textColor: AppColors.packageTextPrimary,
          ),
        ),
      ],
    );
  }
}
