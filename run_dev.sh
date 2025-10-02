#!/bin/bash

# Load environment variables from .env.local
if [ -f .env.local ]; then
    export $(cat .env.local | grep -v '^#' | xargs)
fi

# Run Flutter with environment variables
flutter run lib/main_development.dart --dart-define=API_URL=${API_URL:-https://dev.companionintelligence.com}
