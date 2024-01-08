# **Disclaimer**

**This project is being done as a school project for the HE-ARC's pilot application, CityMobis. This is solely a Proof of Concept.**

# Categorizer

Categorizer is intented to be an add-on to CityMobis to help the app better handle the cases and issues submitted by its users. Categorizer uses Image Tagging with Google Vision to add keywords to an image, then uses those keywords to compare the similarity of a potential new case to avoid potentially duplicating into two separates issues a problem that is, in real life, the same. 

## Techno used 
- Frontend :
  - Flutter
  - OpenStreetMap
- Backend : 
  - Firebase
    - Functions
    - Storage
    - Firestore Database
  - Google Vision

## Requirement to run the project 
Nothing is required to run the project as an emulator or to create an .apk on your phone. See the "How to run" segment for this. 

However, to be able to make change to the backend, it is necessary to connect to the Firebase Instance, which require to have initialiazed the Google CLI on your machine, which itself require Python 3.8. See [this tutorial](https://cloud.google.com/sdk/docs/install) for info. 
We recommend you do **NOT** try to run this project while connecting it to a different Firebase instance, as this PoC has not been configured to handle this well. Instead, if you need editor's privilege to the Firebase instance, please email briefgarde@gmail.com with your Google Account's email address so that I may add you to the instance. 

## How to run
- Clone the repo
- Run `flutter pub get` at the root of the project. 
- You should now be able to run the app on an emulator / as an .apk. 
- Run `npm install` in the `/gcloud_firebase` folder. It might be needed to run this again at `/gcloud_firebase/functions`. For safety, do so as well. 
- - Then run `firebase login` from the project's root to connect your Google Account to the project. The Firebase instance should be called "categorizer". 
- If this ran successfully and you're connected, you should now be able to run the app from the main.dart file.

 