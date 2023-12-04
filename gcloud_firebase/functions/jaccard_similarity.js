/* eslint-disable linebreak-style */
/* eslint-disable require-jsdoc */
function calculateJaccardSimilarity(list1, list2) {
  const intersection = new Set([...list1].filter((x) => list2.includes(x)));
  const union = new Set([...list1, ...list2]);

  const similarity = intersection.size / union.size;
  return similarity;
}

exports.jaccard = calculateJaccardSimilarity;
