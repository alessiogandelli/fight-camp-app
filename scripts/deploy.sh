#!/bin/bash

flutter clean
flutter pub get
flutter build ipa   --release

# ipa path 
IPA_PATH='/Users/alessiogandelli/dev/cantiere/fight-camp/fight_camp_app/build/ios/ipa/fight_camp.ipa'

APP_STORE_USERNAME="ganformatica@gmail.com"
gi

xcrun altool --validate-app --file "$IPA_PATH" --type "ios" --username "$APP_STORE_USERNAME" --password @keychain:"appStoreConnect: $APP_STORE_USERNAME"
xcrun altool --upload-app --file "$IPA_PATH" --type "ios"  --username "$APP_STORE_USERNAME" --password @keychain:"appStoreConnect: $APP_STORE_USERNAME" 


