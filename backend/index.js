import express from "express";
const app = express();
const port = 3000;

import navigationRoutes from "./services/navigation/navigation_routes.js";

app.use(express.json());


app.get("/", (req, res) => {
  res.send("Hello World!");
});

app.use((req, res, next) => {
  console.log("Request: ", req.query);
  next();
});
app.use("/navigation", navigationRoutes);
app.listen(port, () => {
  console.log(`Example app listening on port ${port}`);
});
