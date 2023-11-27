/* eslint-disable no-unused-vars */

const {logger} = require("firebase-functions");
const {onRequest} = require("firebase-functions/v2/https");
const {onDocumentCreated} = require("firebase-functions/v2/firestore");

// The Firebase Admin SDK to access Firestore.
const {initializeApp} = require("firebase-admin/app");
const {getFirestore} = require("firebase-admin/firestore");

const geoHandler = require("./geo_handler.js");

const jaccard = require("jaccard");


initializeApp();

const db = getFirestore();

/* -------------------------TO DO----------------------------*//*
- Set up the system to check the keywords set
- Set up a response in case no case are found,
  a signal to the frontend that says "nothing found, create new case"


*//* ----------------------------------------------------------*/


// exports.getCases = onRequest(async (req, res) => {
//   const lat = req.body.lat;
//   const long = req.body.long;
//   const boundingBox =
//     geoHandler.getBoundingBox({latitude: lat, longitude: long}, 10);
//   const casesQuery =
//     await db.collection("cases")
//         .where("latitude", ">=", boundingBox.min.latitude)
//         .where("latitude", "<=", boundingBox.max.latitude)
//         .where("longitude", ">=", boundingBox.min.longitude)
//         .where("longitude", "<=", boundingBox.max.longitude)
//         .get;

//   if (casesQuery.data() != null) {
//     if () {
//       res.status(200).json({});
//     } else {
//       res.status(204);
//       return;
//     }
//   } else {
//     res.status(204);
//     return;
//   }
// });

exports.createCase = onRequest(async (req, res) => {
  if (req.method =="POST") {
    const body = req.body;
    const writeResult = await db
        .collection("cases")
        .doc()
        .set({
          averageLat: body.lat,
          averageLong: body.long,
          issues: [{
            lat: body.lat,
            long: body.long,
            keywords: body.keywords,
            urlToImage: body.urlToImage}],
        });

    logger.log( "Case written ! Here : " + writeResult.id);
  } else {
    res.status(405).json({result: "Send a POST call"});
    return;
  }
});
