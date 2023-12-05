/* eslint-disable linebreak-style */
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
const {getFirestore, FieldValue} = require("firebase-admin/firestore");

const geoHandler = require("./geo_handler.js");
const jaccardSimilarity = require("./jaccard_similarity.js");

const geohash = require("ngeohash");

initializeApp();

const db = getFirestore();

/* -------------------------TO DO----------------------------*/ /*
- Set up the system to check the keywords set
- Set up a response in case no case are found,
  a signal to the frontend that says "nothing found, create new case"


*/ /* ----------------------------------------------------------*/

exports.getCases = onRequest(async (req, res) => {
  logger.log("GET CASES activated at : " + Date.now.toString());
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
  const casesData = casesQuery.docs.map((doc) => ({
    ...doc.data(),
    id: doc.id,
  }));


  if (casesData.length == 0) {
    logger.log("No cases found");
    res.status(204).json({result: "No cases found"});
    return;
  } // first test of the system, after just the geo stuff. if no cases are found, return a 204
  logger.log(casesData.length + " cases found by geo");

  const keywords = req.body.keywords.map((obj) => obj.description);

  const casesDateCopy = casesData.slice();

  for (let i = 0; i < casesData.length; i++) {
    const currentCase = casesData[i];
    const currentIssues = currentCase.issues;
    for (let j = 0; j < currentIssues.length; j++) {
      const currentIssue = currentIssues[j];
      const currentKeywords = currentIssue.keywords.map((obj) => obj.description);
      const similarity = jaccardSimilarity.jaccard(currentKeywords, keywords);
      if (similarity < 0.2) {
        // as soon as one of the issue is bad, the whole case is bad
        casesDateCopy.splice(i, 1);
        break;
      }
    }
  }

  if (casesDateCopy.length == 0) {
    logger.log("All cases eliminated by keywords");
    res.status(204).json({result: "No cases found"});
    return;
  } // second test of the cases, if the keywords still match. if no cases are found, return a 204
  logger.log(casesDateCopy.length + " cases found by keywords");

  res.status(200).json({result: casesDateCopy});
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
          id: "",
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

exports.updateCase = onRequest(async (req, res) => {
  if (req.method != "POST") {
    res.status(405).json({result: "Send a POST call"});
    return;
  }

  const body = req.body;
  const docID = body.docID;

  const newData = {
    "keywords": body.keywords,
    "lat": body.lat,
    "long": body.long,
    "urlToImage": body.urlToImage,
  };

  // done like this, this should ADD the issue, instead of deleting overwriting the current Issues.
  const updateRes = await db.collection("cases").doc(docID).update({
    issues: FieldValue.arrayUnion(newData),
  });
  return res.status(200).json({result: "Case updated !"});
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
