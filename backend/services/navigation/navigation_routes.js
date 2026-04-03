import express from "express";
import axios from "axios";
import dotenv from "dotenv";
import { getTwoPointRoute, getMultiPointRoute, placesTextSearch } from "../../repo/maps_repo.js";
dotenv.config();

const router = express.Router();

//It will return the polyline for a given route based on start and end coordinates
//Expected query parameters: startLat, startLng, endLat, endLng
router.get('/get-route-polyline', getTwoPointRoute);

// New endpoint to get route polyline for multiple points
// Expects a JSON body: { coordinates: [[lat1, lng1], [lat2, lng2], ...] }
router.post('/get-multi-route-polyline', getMultiPointRoute);

router.get('/places-text-search', placesTextSearch);
export default router;