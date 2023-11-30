/* eslint-disable max-len */
/* eslint-disable no-unused-vars */

const {logger} = require("firebase-functions");
const {onRequest} = require("firebase-functions/v2/https");
const {
  onDocumentCreated,
  onDocumentUpdated,
} = require("firebase-functions/v2/firestore");

// The Firebase Admin SDK to access Firestore.
const {initializeApp} = require("firebase-admin/app");
const {getFirestore} = require("firebase-admin/firestore");

const geoHandler = require("./geo_handler.js");

const jaccard = require("jaccard");
const geohash = require("ngeohash");


initializeApp();

const db = getFirestore();

/* -------------------------TO DO----------------------------*/ /*
- Set up the system to check the keywords set
- Set up a response in case no case are found,
  a signal to the frontend that says "nothing found, create new case"


*/ /* ----------------------------------------------------------*/

exports.getCases = onRequest(async (req, res) => {
  const lat = req.body.lat;
  const long = req.body.long;
  const boundingBox =
    geoHandler.getBoundingBox({latitude: lat, longitude: long}, 10);

  // by using a geohash instead of normal coordinate, I can query a singular field
  // and avoid dealing with the limit of only 1 inequality query
  const geoHashMax = geohash.encode_int(boundingBox.max.latitude, boundingBox.max.longitude);
  const geoHashMin = geohash.encode_int(boundingBox.min.latitude, boundingBox.min.longitude);


  const casesRef = db.collection("cases");
  const correctCases =
  casesRef.where("coordHash", ">=", geoHashMin)
      .where("coordHash", "<=", geoHashMax);

  const casesQuery = await correctCases.get();
  const casesData = casesQuery.docs.map((doc) => doc.data());

  logger.log(casesData);
  if (casesData.length == 0) {
    res.status(204).json({result: "No cases found"});
    return;
  }
  const keywords = req.body.keywords.map((obj) => obj.description);
  logger.log(keywords);

  logger.log("Entering loop");
  for (let i = 0; i < casesData.length; i++) {
    logger.log(i);
    const currentCase = casesData[i];
    const currentIssues = currentCase.issues;
    logger.log("Entering inner loop");
    for (let j = 0; j < currentIssues.length; j++) {
      logger.log( " Inner loop :"+ j);
      const currentIssue = currentIssues[j];
      const currentKeywords = currentIssue.keywords.map((obj) => obj.description);
      logger.log(currentKeywords);
      const similarity = jaccard.index(keywords, currentKeywords);
      logger.log("Similarity : " + similarity);
      if (similarity < 0.2) {
        casesData.splice(i, 1);
        break;
      }
    }
  }
  if (casesData.length == 0) {
    res.status(204).json({result: "No cases found"});
    return;
  }

  res.json({result: casesData});
  return;
});

exports.createCase = onRequest(async (req, res) => {
  if (req.method == "POST") {
    const body = req.body;
    const writeResult = await db
        .collection("cases")
        .doc()
        .set({
          coordHash: geohash.encode_int(body.lat, body.long),
          averageLat: body.lat,
          averageLong: body.long,
          issues: [
            {
              lat: body.lat,
              long: body.long,
              keywords: body.keywords,
              urlToImage: body.urlToImage,
            },
          ],
        });

    logger.log("Case written ! Here : " + writeResult.id);
    res.status(200).json({result: "Case written ! Here : " + writeResult.id});
  } else {
    res.status(405).json({result: "Send a POST call"});
    return;
  }
});

exports.updateCaseCoord = onDocumentUpdated("cases/{caseId}", async (event) => {
  try {
    const newValue = event.data.after.data();
    const issues = newValue.issues;
    if (!Array.isArray(issues) || issues.length === 0) {
      logger.log("Invalid or empty issues array. Exiting function.");
      return null;
    }

    let newAverageLat = 0;
    let newAverageLong = 0;
    const length = issues.length;
    issues.forEach((element) => {
      newAverageLat += element.lat;
      newAverageLong += element.long;
    });
    newAverageLat = newAverageLat / length;
    newAverageLong = newAverageLong / length;
    const newGeoHash = geohash.encode_int(newAverageLat, newAverageLong);

    await db.collection("cases").doc(event.params.caseId).update({
      coordHash: newGeoHash,
      averageLat: newAverageLat,
      averageLong: newAverageLong,
    });

    logger.log("Case updated successfuly !");
  } catch (error) {
    logger.log("Error updating case coord", error);
  }
});
