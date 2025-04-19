import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greatly_user/core/constants/strings.dart';
import 'package:greatly_user/core/theme/app_colors.dart';
import 'package:greatly_user/features/main/presentation/pages/main_page.dart';
import '../../../home/presentation/pages/homepage.dart';
import '../bloc/onboarding_bloc.dart';
import '../bloc/onboarding_event.dart';
import '../bloc/onboarding_state.dart';
import '../widgets/onboarding_item_widget.dart';
import '../widgets/onboarding_indicator.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  _OnboardingPageState createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    // Trigger event to load onboarding items
    context.read<OnboardingBloc>().add(LoadOnboardingItemsEvent());
  }

  @override
  void dispose() {
    // Dispose the PageController to free resources
    _pageController.dispose();
    super.dispose();
  }

  void _navigateToMainPage(BuildContext context) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const MainPage(), // Navigate to the main page
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0); // Start from the right
          const end = Offset.zero; // End at the current position
          const curve = Curves.easeInOut;

          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.primary,
        body: BlocConsumer<OnboardingBloc, OnboardingState>(
          listener: (context, state) {
            // Listen for state changes that require navigation or page controller updates
            if (state is OnboardingCompleted) {
              _navigateToMainPage(context); // Navigate with a custom transition
            }

            // Handle page controller updates when page changes are initiated by BLoC
            if (state is OnboardingLoaded &&
                _pageController.hasClients &&
                _pageController.page?.round() != state.currentIndex) {
              _pageController.animateToPage(
                state.currentIndex,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeIn,
              );
            }
          },
          builder: (context, state) {
            if (state is OnboardingLoaded) {
              // Display onboarding content when items are loaded
              return Column(
                children: [
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: state.items.length,
                      onPageChanged: (index) {
                        // Notify Bloc when the page changes
                        context.read<OnboardingBloc>().add(OnboardingPageChangedEvent(index: index));
                      },
                      itemBuilder: (context, index) {
                        // Display each onboarding item
                        return OnboardingItemWidget(item: state.items[index]);
                      },
                    ),
                  ),
                  // Display the onboarding indicator
                  OnboardingIndicator(
                    count: state.items.length,
                    currentIndex: state.currentIndex,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                    child: state.currentIndex == state.items.length - 1
                        ? Center(
                            // Display "Get Started" button on the last page
                            child: ElevatedButton(
                              onPressed: () {
                                // Notify Bloc that onboarding is completed
                                context.read<OnboardingBloc>().add(CompleteOnboardingEvent(completed: true));
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black38, // Black button
                                padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 12.0),
                              ),
                              child: const Text(
                                Strings.getStarted,
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Skip Button
                              TextButton(
                                onPressed: () {
                                  // Notify Bloc that onboarding is completed
                                  context.read<OnboardingBloc>().add(CompleteOnboardingEvent(completed: true));
                                },
                                child: const Text(
                                  Strings.skip,
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              // Next Button
                              TextButton(
                                onPressed: () {
                                  // Delegate navigation logic to BLoC
                                  context.read<OnboardingBloc>().add(
                                    RequestNextPageEvent(),
                                  );
                                },
                                child: const Text(
                                  Strings.next,
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                  ),
                ],
              );
            } else if (state is OnboardingError) {
              // Display error message if onboarding items fail to load
              return Center(
                child: Text(
                  'Failed to load onboarding items. Please try again.',
                  style: TextStyle(color: Colors.white),
                ),
              );
            }
            // Display loading indicator while loading items
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}