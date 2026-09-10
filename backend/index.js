require("dotenv").config();
const express = require("express");

const app = express();
app.use(express.json());

app.use("/auth", require("./routes/auth"));
app.use("/scrutins", require("./routes/vote"));
app.use("/admin", require("./routes/admin"));
app.use("/admin", require("./routes/geographie"));


const PORT = process.env.PORT || 3000;

app.get("/", (req, res) => {
  res.json({ message: "API SyndiVote en ligne" });
});

app.listen(PORT, () => {
  console.log(`Serveur démarré sur http://localhost:${PORT}`);
});