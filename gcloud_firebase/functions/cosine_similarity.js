/* eslint-disable linebreak-style */
/* eslint-disable max-len */
/* eslint-disable require-jsdoc */

// this code is vastly inspired by a pyhton snippet I found, and adapted to JS,
// hence the notion of Counter-like object

// Function to convert array to Counter object
function listToCounter(list) {
  return list.reduce((counter, item) => {
    counter[item] = (counter[item] || 0) + 1;
    return counter;
  }, {});
}

// Function to calculate cosine similarity
function counterCosineSimilarity(list1, list2) {
  const c1 = listToCounter(list1);
  const c2 = listToCounter(list2);
  const terms = new Set([...Object.keys(c1), ...Object.keys(c2)]);
  const dotprod = [...terms].reduce((sum, k) => sum + (c1[k] || 0) * (c2[k] || 0), 0);
  const magA = Math.sqrt([...terms].reduce((sum, k) => sum + (c1[k] || 0) ** 2, 0));
  const magB = Math.sqrt([...terms].reduce((sum, k) => sum + (c2[k] || 0) ** 2, 0));

  return dotprod / (magA * magB);
}

exports.cosine = counterCosineSimilarity;
