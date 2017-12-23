# User Authentication and Authorization Sample App
This sample app uses the MASFoundation and MASUI frameworks of the MAS SDK.

**Required:**
* Xcode (Latest Version) - Install from App Store
* Cocoapods (latest version) - Install from https://cocoapods.org/

## Getting Started
1. Open a terminal window to the top level folder of this Sample App (ie: ~/iOS - Login - User Authentication and Authorization)
2. In Terminal type: pod update    (If this fails try: pod install)
3. Open the .xcworkspace (ie: MASAuthentication.xcworkspace)
4. Go to your servers policy manager or Mobile Developer Console if you have one, and create an app and download export the msso_config (https://you_server_name:8443/oauth/manager) [Visit mas.ca.com and navigate to the iOS Guides under docs for more info]
5. Copy the entire contents of the exported msso_config into the msso_config file in xcode workspace
6. Build and Deploy the app to a device or Simulator
