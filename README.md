# Body Weight Tracker

This repository contains the code used for a simple body weight tracker created using Flutter and using Firebase as the backend. The user can keep track of their weight on a daily basis and also set a target weight that they aim to meet. The app gives instant and accurate responses to new weight inputs and prevents duplicate daily weight inputs. This code can be modified to store data locally inside a mobile device or so it can be used by another remote database. 

Added an additional lib folder "lib_ios_and_android" which contains the flutter code that can be used in both Android and IOS devices to give a more native feel for both devices, the code primarily uses the "flutter_platform_widgets" package to do this. This same folder also uses the flutter_screenutil package to control UI elements based on different device sizes.

In another version of this app, the sqflite package is used instead of Firebase, this has been uploaded onto the Google Play 
Store at https://play.google.com/store/apps/details?id=com.allenapplications.bodyweighttracker&gl=GB. 

<p align="center">
<img src = "https://user-images.githubusercontent.com/65980399/160705103-b8f19a23-04a9-4e1d-a99f-803a50fbeec2.gif"/> <img src = "https://user-images.githubusercontent.com/65980399/160704629-f574f03a-fec0-469c-9632-dac8785138bc.gif"/>
  </p>
