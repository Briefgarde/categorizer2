/* eslint-disable linebreak-style */
/* eslint-disable require-jsdoc */

function getBoundingBox(baseCoordinate, distanceInMeters) {
  // Radius of the Earth in meters
  const earthRadius = 6371000;

  const latOffset = (distanceInMeters / earthRadius) * (180 / Math.PI);
  const lonOffset =
      (distanceInMeters / earthRadius) * (180 / Math.PI) /
      Math.cos(deg2rad(baseCoordinate.latitude));

  const minLat = baseCoordinate.latitude - latOffset;
  const maxLat = baseCoordinate.latitude + latOffset;
  const minLon = baseCoordinate.longitude - lonOffset;
  const maxLon = baseCoordinate.longitude + lonOffset;

  return {
    min: {latitude: minLat, longitude: minLon},
    max: {latitude: maxLat, longitude: maxLon},
  };
}

function deg2rad(deg) {
  return deg * (Math.PI / 180);
}

exports.getBoundingBox = getBoundingBox;
