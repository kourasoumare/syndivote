const express = require("express");
const prisma = require("../prismaClient");

const router = express.Router();

// Créer un syndicat
router.post("/syndicats", async (req, res) => {
  const { nom, description } = req.body;

  if (!nom) {
    return res.status(400).json({ erreur: "Le nom du syndicat est requis." });
  }

  const syndicat = await prisma.syndicat.create({
    data: { nom, description },
  });

  return res.status(201).json(syndicat);
});

// Ajouter un candidat (syndicat) à un scrutin
router.post("/scrutins/:scrutinId/candidats", async (req, res) => {
  const { scrutinId } = req.params;
  const { syndicatId, descriptionScrutin } = req.body;

  if (!syndicatId) {
    return res.status(400).json({ erreur: "Le syndicat est requis." });
  }

  const candidat = await prisma.candidat.create({
    data: { scrutinId, syndicatId, descriptionScrutin },
  });

  return res.status(201).json(candidat);
});

module.exports = router;