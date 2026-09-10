const express = require("express");
const prisma = require("../prismaClient");

const router = express.Router();

// Créer une région
router.post("/regions", async (req, res) => {
  const { nom } = req.body;

  if (!nom) {
    return res.status(400).json({ erreur: "Le nom de la région est requis." });
  }

  try {
    const region = await prisma.region.create({ data: { nom } });
    return res.status(201).json(region);
  } catch (err) {
    if (err.code === "P2002") {
      return res.status(409).json({ erreur: "Cette région existe déjà." });
    }
    throw err;
  }
});

// Créer un cercle
router.post("/cercles", async (req, res) => {
  const { nom, regionId } = req.body;

  if (!nom || !regionId) {
    return res.status(400).json({ erreur: "Le nom et la région sont requis." });
  }

  try {
    const cercle = await prisma.cercle.create({ data: { nom, regionId } });
    return res.status(201).json(cercle);
  } catch (err) {
    if (err.code === "P2002") {
      return res.status(409).json({ erreur: "Ce cercle existe déjà dans cette région." });
    }
    if (err.code === "P2003") {
      return res.status(400).json({ erreur: "Cette région n'existe pas." });
    }
    throw err;
  }
});

// Créer un arrondissement
router.post("/arrondissements", async (req, res) => {
  const { nom, cercleId } = req.body;

  if (!nom || !cercleId) {
    return res.status(400).json({ erreur: "Le nom et le cercle sont requis." });
  }

  try {
    const arrondissement = await prisma.arrondissement.create({ data: { nom, cercleId } });
    return res.status(201).json(arrondissement);
  } catch (err) {
    if (err.code === "P2002") {
      return res.status(409).json({ erreur: "Cet arrondissement existe déjà dans ce cercle." });
    }
    if (err.code === "P2003") {
      return res.status(400).json({ erreur: "Ce cercle n'existe pas." });
    }
    throw err;
  }
});

// Créer une commune
router.post("/communes", async (req, res) => {
  const { nom, arrondissementId } = req.body;

  if (!nom || !arrondissementId) {
    return res.status(400).json({ erreur: "Le nom et l'arrondissement sont requis." });
  }

  try {
    const commune = await prisma.commune.create({ data: { nom, arrondissementId } });
    return res.status(201).json(commune);
  } catch (err) {
    if (err.code === "P2002") {
      return res.status(409).json({ erreur: "Cette commune existe déjà dans cet arrondissement." });
    }
    if (err.code === "P2003") {
      return res.status(400).json({ erreur: "Cet arrondissement n'existe pas." });
    }
    throw err;
  }
});

// Créer un Vfq
router.post("/vfqs", async (req, res) => {
  const { nom, communeId } = req.body;

  if (!nom || !communeId) {
    return res.status(400).json({ erreur: "Le nom et la commune sont requis." });
  }

  try {
    const vfq = await prisma.vfq.create({ data: { nom, communeId } });
    return res.status(201).json(vfq);
  } catch (err) {
    if (err.code === "P2002") {
      return res.status(409).json({ erreur: "Ce Vfq existe déjà dans cette commune." });
    }
    if (err.code === "P2003") {
      return res.status(400).json({ erreur: "Cette commune n'existe pas." });
    }
    throw err;
  }
});

// Créer un centre de vote
router.post("/centres-de-vote", async (req, res) => {
  const { nom, vfqId } = req.body;

  if (!nom || !vfqId) {
    return res.status(400).json({ erreur: "Le nom et le Vfq sont requis." });
  }

  try {
    const centre = await prisma.centreDeVote.create({ data: { nom, vfqId } });
    return res.status(201).json(centre);
  } catch (err) {
    if (err.code === "P2002") {
      return res.status(409).json({ erreur: "Ce centre de vote existe déjà dans ce Vfq." });
    }
    if (err.code === "P2003") {
      return res.status(400).json({ erreur: "Ce Vfq n'existe pas." });
    }
    throw err;
  }
});

// Créer un bureau de vote
router.post("/bureaux-de-vote", async (req, res) => {
  const { nom, centreDeVoteId } = req.body;

  if (!nom || !centreDeVoteId) {
    return res.status(400).json({ erreur: "Le nom et le centre de vote sont requis." });
  }

  try {
    const bureau = await prisma.bureauDeVote.create({ data: { nom, centreDeVoteId } });
    return res.status(201).json(bureau);
  } catch (err) {
    if (err.code === "P2002") {
      return res.status(409).json({ erreur: "Ce bureau de vote existe déjà dans ce centre." });
    }
    if (err.code === "P2003") {
      return res.status(400).json({ erreur: "Ce centre de vote n'existe pas." });
    }
    throw err;
  }
});

module.exports = router;