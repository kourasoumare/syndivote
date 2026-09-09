const express = require("express");
const prisma = require("../prismaClient");
const verifierToken = require("../middlewares/verifierToken");

const router = express.Router();

router.post("/:scrutinId/voter", verifierToken, async (req, res) => {
  const { scrutinId } = req.params;
  const { candidatId } = req.body;
  const { electeurId, scrutinIdToken } = req;

  if (!candidatId) {
    return res.status(400).json({ erreur: "Candidat requis." });
  }

  // 1. Le token correspond-il bien à ce scrutin précis ?
  if (scrutinId !== scrutinIdToken) {
    return res.status(403).json({ erreur: "Ce jeton n'est pas valable pour ce scrutin." });
  }

  // 2. Le scrutin est-il toujours ouvert au vote électronique ?
  const scrutin = await prisma.scrutin.findUnique({ where: { id: scrutinId } });
  if (!scrutin || scrutin.statut !== "OUVERT") {
    return res.status(403).json({ erreur: "Ce scrutin n'est plus ouvert." });
  }

  // 3. Le candidat appartient-il bien à ce scrutin ?
  const candidat = await prisma.candidat.findUnique({ where: { id: candidatId } });
  if (!candidat || candidat.scrutinId !== scrutinId) {
    return res.status(400).json({ erreur: "Candidat invalide pour ce scrutin." });
  }

  // 4. La transaction atomique : Participation + Bulletin, ensemble ou rien
  try {
    await prisma.$transaction([
      prisma.participation.create({
        data: { electeurId, scrutinId, canal: "TELEPHONE" },
      }),
      prisma.bulletin.create({
        data: { scrutinId, candidatId },
      }),
    ]);
  } catch (err) {
    if (err.code === "P2002") {
      // Violation de contrainte unique = a déjà voté
      return res.status(403).json({ erreur: "Vous avez déjà voté pour ce scrutin." });
    }
    throw err;
  }

  return res.json({ message: "Votre vote a été enregistré avec succès." });
});

module.exports = router;