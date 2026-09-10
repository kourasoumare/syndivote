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

// Créer un électeur
router.post("/electeurs", async (req, res) => {
  const { nom, prenom, telephone } = req.body;

  if (!nom || !prenom || !telephone) {
    return res.status(400).json({ erreur: "Nom, prénom et téléphone requis." });
  }

  try {
    const electeur = await prisma.electeur.create({
      data: { nom, prenom, telephone },
    });
    return res.status(201).json(electeur);
  } catch (err) {
    if (err.code === "P2002") {
      return res.status(409).json({ erreur: "Ce numéro de téléphone est déjà utilisé." });
    }
    throw err;
  }
});

// Créer une liste électorale
router.post("/listes-electorales", async (req, res) => {
  const { nom } = req.body;

  if (!nom) {
    return res.status(400).json({ erreur: "Le nom de la liste est requis." });
  }

  const liste = await prisma.listeElectorale.create({ data: { nom } });
  return res.status(201).json(liste);
});

// Inscrire un électeur sur une liste électorale
router.post("/listes-electorales/:listeElectoraleId/inscriptions", async (req, res) => {
  const { listeElectoraleId } = req.params;
  const { electeurId, bureauVoteId } = req.body;

  if (!electeurId) {
    return res.status(400).json({ erreur: "L'électeur est requis." });
  }

  try {
    const inscription = await prisma.inscriptionElectorale.create({
      data: { listeElectoraleId, electeurId, bureauVoteId: bureauVoteId || null },
    });
    return res.status(201).json(inscription);
  } catch (err) {
    if (err.code === "P2002") {
      return res.status(409).json({ erreur: "Cet électeur est déjà inscrit sur cette liste." });
    }
    throw err;
  }
});

// Créer un scrutin
router.post("/scrutins", async (req, res) => {
  const { nom, modeVote, listeElectoraleId } = req.body;

  if (!nom || !modeVote || !listeElectoraleId) {
    return res.status(400).json({ erreur: "Nom, mode de vote et liste électorale requis." });
  }

  const scrutin = await prisma.scrutin.create({
    data: { nom, modeVote, listeElectoraleId },
  });
  return res.status(201).json(scrutin);
});

// Ouvrir ou fermer un scrutin
router.patch("/scrutins/:scrutinId/statut", async (req, res) => {
  const { scrutinId } = req.params;
  const { statut } = req.body;

  const statutsValides = ["CREE", "PROGRAMME", "OUVERT", "FERME", "RESULTATS_PROVISOIRES", "RESULTATS_DEFINITIFS", "PUBLIE"];
  if (!statutsValides.includes(statut)) {
    return res.status(400).json({ erreur: "Statut invalide." });
  }

  const scrutin = await prisma.scrutin.update({
    where: { id: scrutinId },
    data: { statut },
  });
  return res.json(scrutin);
});

module.exports = router;