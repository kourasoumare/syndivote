const jwt = require("jsonwebtoken");

function verifierToken(req, res, next) {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    return res.status(401).json({ erreur: "Jeton d'authentification manquant." });
  }

  const token = authHeader.split(" ")[1];

  try {
    const payload = jwt.verify(token, process.env.JWT_SECRET);
    req.electeurId = payload.electeurId;
    req.scrutinIdToken = payload.scrutinId;
    next();
  } catch (err) {
    return res.status(401).json({ erreur: "Jeton invalide ou expiré." });
  }
}

module.exports = verifierToken;