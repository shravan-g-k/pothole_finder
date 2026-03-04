import { PlacesClient } from "@googlemaps/places";
import { GoogleAuth } from "google-auth-library";
import axios from "axios";
const getTwoPointRoute = async (req, res) => {
  const { startLat, startLng, endLat, endLng } = req.query;
  if (!startLat || !startLng || !endLat || !endLng) {
    return res.status(400).json({ error: "Missing required query parameters." });
  }
  try {
    const apiKey = process.env.OPEN_ROUTE_SERVICE_API_KEY;
    const url = `https://api.openrouteservice.org/v2/directions/driving-car?api_key=${apiKey}&start=${startLng},${startLat}&end=${endLng},${endLat}`;


    const response = await axios.get(url);

    const polyline = response.data.features[0].geometry;
    res.json({ polyline });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

const getMultiPointRoute = async (req, res) => {
  const { coordinates } = req.body;
  if (!coordinates || !Array.isArray(coordinates) || coordinates.length < 2) {
    return res.status(400).json({ error: "'coordinates' array with at least two points is required." });
  }
  try {
    const apiKey = process.env.OPEN_ROUTE_SERVICE_API_KEY;
    const url = `https://api.openrouteservice.org/v2/directions/driving-car?api_key=${apiKey}`;
    // OpenRouteService expects [lng, lat] pairs
    const orsCoordinates = coordinates.map(([lat, lng]) => [parseFloat(lng), parseFloat(lat)]);
    const body = { coordinates: orsCoordinates };
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
}

const placesTextSearch = async (req, res) => {
  const { query } = req.query;
  if (!query) {
    return res.status(400).json({ error: "Missing required 'query' parameter." });
  }
  try {
    const apiKey = process.env.PLACES_API_KEY;

    const authClient = new GoogleAuth().fromAPIKey(apiKey);
    const placesClient = new PlacesClient({
      authClient,
    });

    const payload = { textQuery: query };

    const [response] = await placesClient.searchText(payload, {
      otherArgs: {
        headers: {
          "X-Goog-FieldMask": "places.location,places.displayName,places.formattedAddress",
        },
      },
    });

    //FORMAT it to our expected format
    //{
    //  "name": "Googleplex",
    //  "address": "1600 Amphitheatre Parkway, Mountain View, CA 94043, USA",
    //  "location": {
    //    "lat": 37.422408,
    //    "lng": -122.084068
    //  }
    //}
    const fromattedResponse = response.places.map((place) => {
      return {
        name: place.displayName.text,
        address: place.formattedAddress,
        location: {
          lat: place.location.latitude,
          lng: place.location.longitude
        }
      }
    });
  

    res.json(fromattedResponse);


  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

export {
  getTwoPointRoute,
  getMultiPointRoute,
  placesTextSearch
}