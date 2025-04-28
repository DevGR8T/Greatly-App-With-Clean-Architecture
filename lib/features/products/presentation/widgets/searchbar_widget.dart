import 'dart:async';
import 'package:flutter/material.dart';
import 'package:greatly_user/core/constants/strings.dart';

/// A reusable search bar widget with debounce functionality.
class SearchBarWidget extends StatefulWidget {
  final Function(String) onSearch; // Callback triggered when the search query changes
  final String? initialValue; // Initial value for the search bar
  final String hintText; // Placeholder text for the search bar

  const SearchBarWidget({
    Key? key,
    required this.onSearch,
    this.initialValue,
    this.hintText = Strings.searchHint,
  }) : super(key: key);

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  late final TextEditingController _controller; // Manages the text input
  late final FocusNode _focusNode; // Handles focus for the search bar
  Timer? _debounce; // Timer for implementing debounce functionality

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue); // Initialize with initial value
    _focusNode = FocusNode(); // Initialize focus node
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose of the text controller
    _focusNode.dispose(); // Dispose of the focus node
    _debounce?.cancel(); // Cancel any active debounce timer
    super.dispose();
  }

  /// Handles search query changes with debounce to limit API calls.
  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel(); // Cancel the previous timer
    _debounce = Timer(const Duration(milliseconds: 500), () {
      widget.onSearch(query); // Trigger the search callback after the delay
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50, // Fixed height for the search bar
      child: Card(
        elevation: 0, // No shadow for the card
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0), // Rounded corners
          side: BorderSide(color: Colors.grey[300]!), // Light grey border
        ),
        child: TextField(
          controller: _controller, // Connects the text field to the controller
          textInputAction: TextInputAction.search, // Displays a search action on the keyboard
          decoration: InputDecoration(
            hintText: widget.hintText, // Placeholder text
            prefixIcon: Icon(Icons.search, color: Colors.grey[600]), // Search icon
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear, color: Colors.grey[600]), // Clear icon
                    onPressed: () {
                      _controller.clear(); // Clear the text field
                      widget.onSearch(''); // Trigger search with an empty string
                      FocusScope.of(context).unfocus(); // Remove focus from the text field
                    },
                  )
                : null, // No suffix icon if the text field is empty
            border: InputBorder.none, // Removes the default border
            contentPadding: const EdgeInsets.symmetric(vertical: 15), // Padding inside the text field
          ),
          onSubmitted: widget.onSearch, // Trigger search when the user submits
          onChanged: _onSearchChanged, // Trigger debounce logic on text change
        ),
      ),
    );
  }
}