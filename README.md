<img src="/Parking Space Booking System⁩/Assets.xcassets⁩/⁨AppIcon.appiconset⁩/Icon-180.png" align="right"/>

## ParkYourCar - Demo application for iOS

Originally this application was part of the final project for college's iOS course, however I decided to expand it functionality in order to learn new technology and to implement them into current app. I've added Firebase authentication, Firebase datebase for storing user data and Firebase storage to store images.

Basically, user can create new account, add new car to personal car list and create new parking ticket with PDF version.

I used <b>MVC</b> concept during creation of this project as well as SOLID concept.

### Cocoapods libraries

- [Firebase](https://firebase.google.com) - authentication, storing data
- [KeychainAccess](https://github.com/kishikawakatsumi/KeychainAccess) - a simple Swift wrapper for Keychain
- [IQKeyboard](https://github.com/hackiftekhar/IQKeyboardManager) - allows to prevent issues of keyboard sliding up and cover UITextField/UITextView
- [SkyFloatingLabelTextField](https://github.com/Skyscanner/SkyFloatingLabelTextField) - A beautiful and flexible text field control implementation of "Float Label Pattern"

### Summary

During creation of this app I've learned a plenty of new technology and dived into development process. I learned how to use CocoaPods dependency manager, how to implement Firebase functionality in iOS application, how to manage project using Trello as task manager I divide project on little parts and did them with scrum methodology. In this application I more dived in MVC and SOLID concepts for creating application.

### Demos

- SignUp screen
[signup](Demos/signup.gif)

- Login screen
[signin](Demos/signin.gif)

- Update profile - taping "edit profile" button on home screen
[update](Demos/updateprofile.gif)

- Add new ticket - during creating new ticket user can choose car from personal lsit or add new car to list

[add](Demos/addnewticket.gif)

- Edit cars list - user can add new car into the list as well as delete one from there

[edit](Demos/editcarlist.gif)

- Report screen - list of all created tickets by user. They can be filetered by plate number

[report](Demos/report.gif)

- Ticket - generating PDF file from parking ticket

[pdf](Demos/receipt-generatepdf)

- Contact - taping help button on home screen

[contacts](Demos/contact.gif)

- Instruction - I've just got this instruction from third party parking website. I use JavaScript code to crop webpage for proper format.

[instruction](Demos/instruction.gif)