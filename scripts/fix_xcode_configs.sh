#!/bin/bash

echo "🔧 Xcode Build Configuration Fix Script"
echo "======================================"
echo ""

echo "This script will help you fix the Xcode build configuration issue."
echo ""

echo "📋 Steps to follow:"
echo "1. Open Xcode: open ios/Runner.xcworkspace"
echo "2. Click on 'Runner' in the project navigator"
echo "3. Ensure the 'Runner PROJECT' is selected (not TARGET)"
echo "4. Add standard configurations:"
echo "   - Editor → Add Configuration → Duplicate 'Debug-development' → Name it 'Debug'"
echo "   - Editor → Add Configuration → Duplicate 'Release-development' → Name it 'Release'"
echo "   - Editor → Add Configuration → Duplicate 'Profile-development' → Name it 'Profile'"
echo ""

echo "🔍 Current Xcode project configurations:"
if [ -f "ios/Runner.xcodeproj/project.pbxproj" ]; then
    echo "Found Xcode project file. Checking configurations..."
    
    # Extract build configurations from project.pbxproj
    grep -A 20 "buildConfigurationList" ios/Runner.xcodeproj/project.pbxproj | grep -E "name = " | sed 's/.*name = //' | sed 's/;.*//' | sort | uniq
    
    echo ""
    echo "✅ If you see 'Debug', 'Release', and 'Profile' in the list above, you're good!"
    echo "❌ If you only see environment-specific names, follow the steps above."
else
    echo "❌ Could not find Xcode project file at ios/Runner.xcodeproj/project.pbxproj"
fi

echo ""
echo "🚀 After adding the standard configurations, try running:"
echo "flutter clean"
echo "flutter pub get"
echo "flutter run lib/main_development.dart --dart-define=API_URL=https://dev.companionintelligence.com"
