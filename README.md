# QuoteMaster - Daily Wisdom App
A Flutter application that displays daily quotes and allows users to save their favorites. This project implements the design from the provided SVG mockup.

## Demo Video
https://github.com/user-attachments/assets/13df4ba4-dabb-4ecd-92f8-f9ee9259eec7


## Screenshots
![image](https://github.com/user-attachments/assets/96c66798-6404-4337-acd3-34e29c267e2e)
![image](https://github.com/user-attachments/assets/72ab598f-da73-49cd-9644-4164bf52a70a)
![image](https://github.com/user-attachments/assets/5b5aec73-87c5-4c3e-a761-a60c45214158)
![image](https://github.com/user-attachments/assets/fd79e46a-66f3-4856-8606-0275cd9fe661)

![image](https://github.com/user-attachments/assets/936cf6d2-8007-4b50-a084-cc5ecf656a31)





## Features

- Splash screen with loading animation
- Display random quotes from an external API
- Save favorite quotes locally
- View and manage favorite quotes
- Smooth animations for better visual appearance
- Share quotes functionality

## Project Structure

The project follows a clean architecture pattern with separation of concerns:

- **Models**: Data structures (Quote)
- **Screens**: UI pages (Splash, Quote, LikedQuotes)
- **Widgets**: Reusable UI components (QuoteCard, LoadingAnimation)
- **Services**: Business logic and API integration (QuoteService, shareService)
- **Utils**: Helper classes (StorageHelper)
- **Constants**: App-wide styling constants (colors, text styles)

## Setting Up The Project

1. Make sure you have Flutter installed and set up on your machine
2. Clone this repository
3. Run `flutter pub get` to install dependencies
4. Run `flutter run` to start the application

## Dependencies

- **http**: For API requests to fetch quotes
- **shared_preferences**: For storing favorite quotes locally
- **provider**: For state management
- **flutter_spinkit**: For loading animations
- **intl**: For date formatting
- **share_plus**: For sharing quotes

## Screens

1. **Splash Screen**: Displays when the app is launched
2. **Quote Screen**: Main screen showing a random quote with options to fetch a new one, like, or share
3. **Liked Quotes Screen**: Displays all favorite quotes with options to share or remove

## Customization

You can customize the app by modifying the color constants in `lib/constants/colors.dart` and text styles in `lib/constants/text_styles.dart`.

## API Integration

The app uses multiple quote APIs for reliability:

1. **Primary API**: [Quotable.io](https://api.quotable.io/random)
   ```json
   {
     "content": "The best preparation for tomorrow is doing your best today.",
     "author": "H. Jackson Brown Jr.",
     "_id": "abc123"
   }
   ```

2. **Backup API**: [Type.fit](https://type.fit/api/quotes)
   ```json
   [
     {
       "text": "The best preparation for tomorrow is doing your best today.",
       "author": "H. Jackson Brown Jr."
     }
   ]
   ```

3. **Fallback Quotes**: If both APIs fail, the app uses a built-in collection of quotes.

This multi-API approach ensures users always get a new quote, even if one service is unavailable. If you want to use different APIs, you can modify the `fetchRandomQuote()` and `_tryAlternateAPI()` methods in the `QuoteService` class.

