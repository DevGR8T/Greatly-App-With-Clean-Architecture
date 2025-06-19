import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/address.dart';
import '../bloc/checkout_bloc.dart';
import '../bloc/checkout_event.dart';
import '../bloc/checkout_state.dart';

class AddressFormWidget extends StatefulWidget {
  final Address? addressToEdit;
  final Function(Address) onAddressSubmitted;

  const AddressFormWidget({
    Key? key,
    this.addressToEdit,
    required this.onAddressSubmitted,
  }) : super(key: key);

  @override
  State<AddressFormWidget> createState() => _AddressFormWidgetState();
}

class _AddressFormWidgetState extends State<AddressFormWidget> {
  final _formKey = GlobalKey<FormState>();

  final _streetAddressController = TextEditingController();
  final _additionalInfoController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _countryController = TextEditingController();

  bool _isDefault = false;

  @override
  void initState() {
    super.initState();

    // Populate fields if editing an existing address
    if (widget.addressToEdit != null) {
      _streetAddressController.text = widget.addressToEdit!.streetAddress;
      _additionalInfoController.text =
          widget.addressToEdit!.apartmentSuite ?? '';
      _cityController.text = widget.addressToEdit!.city;
      _stateController.text = widget.addressToEdit!.stateProvince;
      _postalCodeController.text = widget.addressToEdit!.postalCode;
      _countryController.text = widget.addressToEdit!.country;
      _isDefault = widget.addressToEdit!.isDefault;
    } else {
      // Default country selection
      _countryController.text = 'United States';
    }
  }

  @override
  void dispose() {
    _streetAddressController.dispose();
    _additionalInfoController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final firebaseUser = FirebaseAuth.instance.currentUser;
      final firebaseUid = firebaseUser?.uid;

      if (firebaseUid == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not authenticated!')),
        );
        return;
      }

      final newAddress = Address(
        firebaseUserId: firebaseUid,
        streetAddress: _streetAddressController.text.trim(),
        apartmentSuite: _additionalInfoController.text.trim().isEmpty
            ? null
            : _additionalInfoController.text.trim(),
        city: _cityController.text.trim(),
        stateProvince: _stateController.text.trim(),
        postalCode: _postalCodeController.text.trim(),
        country: _countryController.text.trim(),
        isDefault: _isDefault,
      );

      // Only dispatch to Bloc. Do NOT pop or call the callback here!
      context.read<CheckoutBloc>().add(SaveAddressEvent(newAddress));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CheckoutBloc, CheckoutState>(
      listener: (context, state) {
        if (state is AddressSaveSuccess) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Address saved!'),
              backgroundColor: AppColors.success,
              duration: Duration(seconds: 1),
            ),
          );
          widget.onAddressSubmitted(
              state.address); // This triggers _handleAddressAdded
        }
        if (state is AddressSaveFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to save address: ${state.message}'),
              duration: Duration(seconds: 1),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.addressToEdit != null
              ? 'Edit Address'
              : 'Add New Address'),
          elevation: 0,
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              TextFormField(
                controller: _streetAddressController,
                decoration: const InputDecoration(
                  labelText: 'Street Address',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your street address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _additionalInfoController,
                decoration: const InputDecoration(
                  labelText: 'Apartment, suite, etc. (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(
                  labelText: 'City',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your city';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _stateController,
                      decoration: const InputDecoration(
                        labelText: 'State/Province',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your state';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _postalCodeController,
                      decoration: const InputDecoration(
                        labelText: 'Postal Code',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your postal code';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _countryController,
                decoration: const InputDecoration(
                  labelText: 'Country',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your country';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Checkbox(
                    value: _isDefault,
                    onChanged: (value) {
                      setState(() {
                        _isDefault = value ?? false;
                      });
                    },
                    activeColor: Theme.of(context).primaryColor,
                  ),
                  const Text('Set as default address'),
                ],
              ),
              const SizedBox(height: 32),
              BlocBuilder<CheckoutBloc, CheckoutState>(
                builder: (context, state) {
                  final isSaving = state is AddressSaving;
                  return ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                    child: isSaving
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            widget.addressToEdit != null
                                ? 'Update Address'
                                : 'Save Address',
                            style: const TextStyle(fontSize: 16),
                          ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
