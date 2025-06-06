import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/address.dart';
import '../bloc/checkout_bloc.dart';
import '../bloc/checkout_event.dart';
import '../widgets/address_form_widget.dart';

class AddressSelectionWidget extends StatefulWidget {
  final bool isLoading;
  final List<Address> addresses;
  final Address? selectedShippingAddress;
  final Address? selectedBillingAddress;
  final bool sameAsBillingAddress;
  final Function(Address?) onShippingAddressSelected;
  final Function(Address?) onBillingAddressSelected;
  final Function(bool) onSameAsBillingChanged;
  final Function(Address) onAddressAdded;

  const AddressSelectionWidget({
    Key? key,
    required this.isLoading,
    required this.addresses,
    required this.selectedShippingAddress,
    required this.selectedBillingAddress,
    required this.sameAsBillingAddress,
    required this.onShippingAddressSelected,
    required this.onBillingAddressSelected,
    required this.onSameAsBillingChanged,
    required this.onAddressAdded,
  }) : super(key: key);

  @override
  State<AddressSelectionWidget> createState() => _AddressSelectionWidgetState();
}

class _AddressSelectionWidgetState extends State<AddressSelectionWidget> {
  // Generate a unique key for an address using relevant fields
  String getUniqueAddressKey(Address address) {
    return '${address.streetAddress}_${address.city}_${address.stateProvince}_${address.postalCode}_${address.country}';
  }

  @override
  Widget build(BuildContext context) {
    print('🏠 AddressSelectionWidget rebuilding with ${widget.addresses.length} addresses');
    print('🏠 Selected shipping address: ${widget.selectedShippingAddress?.id}');
    
    if (widget.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // Show different UI based on whether addresses are available
    return SingleChildScrollView(
      key: UniqueKey(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Shipping Address',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Show address list or empty state message
          if (widget.addresses.isEmpty)
            _buildEmptyAddressState(context)
          else
            _buildAddressList(
              widget.addresses,
              widget.selectedShippingAddress,
              widget.onShippingAddressSelected,
              context,
            ),

          if (widget.addresses.isNotEmpty) ...[
            const SizedBox(height: 24),

            // Billing address section
            Row(
              children: [
                const Text(
                  'Billing Address',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                const Text('Same as shipping'),
                const SizedBox(width: 8),
                Switch(
                  value: widget.sameAsBillingAddress,
                  onChanged: widget.onSameAsBillingChanged,
                  activeColor: Theme.of(context).primaryColor,
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (!widget.sameAsBillingAddress)
              _buildAddressList(
                widget.addresses,
                widget.selectedBillingAddress,
                widget.onBillingAddressSelected,
                context,
              ),
          ],

          const SizedBox(height: 16),
          _buildAddNewAddressButton(context),
        ],
      ),
    );
  }

  Widget _buildEmptyAddressState(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 20),
        Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Icon(
                Icons.location_off,
                size: 48,
                color: Colors.grey.shade500,
              ),
              const SizedBox(height: 16),
              const Text(
                'No saved addresses found',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Please add a shipping address to continue with checkout',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => _navigateToAddressForm(context),
                icon: const Icon(Icons.add),
                label: const Text('Add New Address'),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  backgroundColor: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAddressList(
    List<Address> addresses,
    Address? selectedAddress,
    Function(Address) onAddressSelected,
    BuildContext context,
  ) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: addresses.length,
      itemBuilder: (context, index) {
        final address = addresses[index];
        final isSelected = selectedAddress != null &&
            getUniqueAddressKey(selectedAddress) ==
                getUniqueAddressKey(address);

        return Card(
          elevation: isSelected ? 2 : 0,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: InkWell(
            onTap: () => onAddressSelected(address),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Radio<String>(
                    value: getUniqueAddressKey(address),
                    groupValue: selectedAddress != null
                        ? getUniqueAddressKey(selectedAddress)
                        : '',
                    onChanged: (_) => onAddressSelected(address),
                    activeColor: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          address.streetAddress,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${address.city}, ${address.stateProvince}, ${address.postalCode}',
                        ),
                        const SizedBox(height: 2),
                        Text(address.country),
                        if (address.isDefault) ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Default',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 20),
                        onPressed: () =>
                            _navigateToEditAddressForm(context, address),
                        tooltip: 'Edit address',
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          size: 20,
                          color: Colors.grey.shade600,
                        ),
                        onPressed: () =>
                            _showDeleteAddressDialog(context, address),
                        tooltip: 'Delete address',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

void _showDeleteAddressDialog(BuildContext context, Address address) {
 showDialog(
   context: context,
   builder: (BuildContext dialogContext) {
     return AlertDialog(
       shape: RoundedRectangleBorder(
         borderRadius: BorderRadius.circular(5),
       ),
       title: const Text('Delete Address'),
       content: Text(
         'Are you sure you want to delete this address?\n\n${address.streetAddress}\n${address.city}, ${address.stateProvince}',
       ),
       actions: [
         TextButton(
           onPressed: () => Navigator.of(dialogContext).pop(),
           child: const Text('Cancel'),
         ),
         TextButton(
           onPressed: () {
             Navigator.of(dialogContext).pop();
             print('🗑️ Delete button pressed for address: ${address.id}');
             
             // Use the original context (not dialogContext) to access the bloc
             context.read<CheckoutBloc>().add(
               DeleteAddressEvent(addressId: address.id!),
             );
             
             // Immediately update the local state to remove the address from UI
             setState(() {
               widget.addresses.removeWhere((addr) => addr.id == address.id);
               
               // Clear selections if the deleted address was selected
               if (widget.selectedShippingAddress?.id == address.id) {
                 widget.onShippingAddressSelected(
                   widget.addresses.isNotEmpty ? widget.addresses.first : null
                 );
               }
               if (widget.selectedBillingAddress?.id == address.id) {
                 widget.onBillingAddressSelected(
                   widget.addresses.isNotEmpty ? widget.addresses.first : null
                 );
               }
             });
           },
           style: TextButton.styleFrom(
             foregroundColor: Colors.red,
           ),
           child: const Text('Delete'),
         ),
       ],
     );
   },
 );
}

  Widget _buildAddNewAddressButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _navigateToAddressForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Add New Address'),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  void _navigateToAddressForm(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddressFormWidget(
          onAddressSubmitted: widget.onAddressAdded,
        ),
      ),
    );
  }

  void _navigateToEditAddressForm(BuildContext context, Address address) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddressFormWidget(
          addressToEdit: address,
          onAddressSubmitted: widget.onAddressAdded,
        ),
      ),
    );
  }}