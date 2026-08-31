class OnboardingModel {
  final String image;
  final String title;
  final String description;

  OnboardingModel({
    required this.image,
    required this.title,
    required this.description,
  });

  static List<OnboardingModel> onboardingList = [
    OnboardingModel(
      image: 'assets/images/onboarding1.jpg',
      title: 'Discover Your Beauty',
      description:
          'Explore our collection of makeup, skincare and beauty products.',
    ),
    OnboardingModel(
      image: 'assets/images/onboarding2.jpg',
      title: 'Add To Your Cart',
      description:
          'Choose your favorite products and add them to your shopping cart.',
    ),
    OnboardingModel(
      image: 'assets/images/onboarding3.jpg',
      title: 'Easy Shopping',
      description: 'Add to cart, adjust quantities, and checkout seamlessly.',
    ),
  ];
}
