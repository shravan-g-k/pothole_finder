const getTwoPointRoute = async (req, res) => {
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

export  {
  getTwoPointRoute,
  getMultiPointRoute
}