import express from "express";
import axios from "axios";
import dotenv from "dotenv";
dotenv.config();

const router = express.Router();

//It will return the polyline for a given route based on start and end coordinates
//Expected query parameters: startLat, startLng, endLat, endLng
router.get('/get-route-polyline', async (req, res) => {
    const { startLat, startLng, endLat, endLng } = req.query;
    if (!startLat || !startLng || !endLat || !endLng) {
        return res.status(400).json({ error: "Missing required query parameters." });
    }
    try {
        const apiKey = process.env.OPEN_ROUTE_SERVICE_API_KEY;
        const url = `https://api.openrouteservice.org/v2/directions/driving-car?api_key=${apiKey}`;
        const body = {
            coordinates: [
                [parseFloat(startLng), parseFloat(startLat)],
                [parseFloat(endLng), parseFloat(endLat)]
            ]
        };

        const response = await axios.post(url, body, {
            headers: {
                'Content-Type': 'application/json'
            }
        });
        const polyline = response.data.routes[0].geometry;
        res.json({ polyline });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

export default router;