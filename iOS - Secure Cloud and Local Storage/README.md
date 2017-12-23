# Secure Cloud and Local Storage Sample App
This sample app uses the MASFoundation, MASStorage and MASUI frameworks of the MAS SDK.

**Required:**
* Xcode (Latest Version) - Install from App Store
* Cocoapods (latest version) - Install from https://cocoapods.org/

## Getting Started
1. Open a terminal window to the top level folder of this Sample App (ie: ~/iOS - Secure Cloud and Local Storage)
2. In Terminal type: pod update    (If this fails try: pod install)
3. Open the .xcworkspace (ie: StorageApp.xcworkspace)
4. Go to your servers policy manager or Mobile Developer Console if you have one, and create an app and download export the msso_config (https://you_server_name:8443/oauth/manager) [Visit mas.ca.com and navigate to the iOS Guides under docs for more info]
5. Copy the entire contents of the exported msso_config into the msso_config file in xcode workspace
6. Open up the class StorageApp/classes/StorageTableViewController.m and add in your SampleUser and SampleUserPassword from your servers database
7. Build and Deploy the app to a device or Simulator
