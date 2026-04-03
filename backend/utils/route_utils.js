import polyline from "@mapbox/polyline";
import zlib from "zlib";

/**
 * Encodes an array of [lng, lat] coordinates into a Mapbox polyline string.
 * ORS returns [lng, lat] but the polyline spec expects [lat, lng], so we flip.
 * @param {number[][]} coordinates - Array of [lng, lat] pairs
 * @returns {string} Encoded polyline string
 */
export function encodePolyline(coordinates) {
  // Flip [lng, lat] → [lat, lng] for polyline encoding
  const latLngPairs = coordinates.map(([lng, lat]) => [lat, lng]);
  return polyline.encode(latLngPairs);
}

/**
 * Compresses a segments array using Brotli and returns a Base64 string.
 * @param {object[]} segments - The segments array from the ORS response
 * @returns {string} Base64-encoded Brotli-compressed JSON string
 */
export function compressSegments(segments) {
  const json = JSON.stringify(segments);
  const compressed = zlib.brotliCompressSync(Buffer.from(json));
  return compressed.toString("base64");
}
