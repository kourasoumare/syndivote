const express = require("express");
const bcrypt = require("bcrypt");
const crypto = require("crypto");
const prisma = require("../prismaClient");

const router = express.Router();
const OTP_EXPIRATION_MINUTES = 5;

router.post("/otp/demander", async (req, res) => {
  const { telephone, scrutinId } = req.body;

  if (!telephone || !scrutinId) {
    return res.status(400).json({ erreur: "Numéro de téléphone et scrutin requis." });
  }

  // 1. L'électeur existe-t-il ?
  const electeur = await prisma.electeur.findUnique({ where: { telephone } });
  if (!electeur) {
    return res.status(404).json({ erreur: "Ce numéro n'est pas reconnu." });
  }

  // 2. Le scrutin existe-t-il et est-il ouvert ?
  const scrutin = await prisma.scrutin.findUnique({ where: { id: scrutinId } });
  if (!scrutin) {
    return res.status(404).json({ erreur: "Scrutin introuvable." });
  }
  if (scrutin.statut !== "OUVERT") {
    return res.status(403).json({ erreur: "Ce scrutin n'est pas ouvert au vote." });
  }

  // 3. L'électeur est-il inscrit sur la liste électorale de ce scrutin ?
  const inscription = await prisma.inscriptionElectorale.findUnique({
    where: {
      listeElectoraleId_electeurId: {
        listeElectoraleId: scrutin.listeElectoraleId,
        electeurId: electeur.id,
      },
    },
  });
  if (!inscription) {
    return res.status(403).json({ erreur: "Vous n'êtes pas éligible à ce scrutin." });
  }

  // 4. L'électeur a-t-il déjà participé à ce scrutin ?
  const dejaParticipe = await prisma.participation.findUnique({
    where: {
      electeurId_scrutinId: {
        electeurId: electeur.id,
        scrutinId: scrutin.id,
      },
    },
  });
  if (dejaParticipe) {
    return res.status(403).json({ erreur: "Vous avez déjà voté pour ce scrutin." });
  }

  // 5. Générer et enregistrer l'OTP
  const code = crypto.randomInt(100000, 999999).toString();
  const codeHash = await bcrypt.hash(code, 10);
  const expiresAt = new Date(Date.now() + OTP_EXPIRATION_MINUTES * 60 * 1000);

  await prisma.otpCode.create({
    data: { electeurId: electeur.id, codeHash, expiresAt },
  });

  // 6. "Envoyer" le SMS — pour l'instant, on l'affiche juste dans la console
  console.log(`[SMS SIMULÉ] Code OTP pour ${telephone} : ${code}`);

  return res.json({ message: "Un code de vérification a été envoyé par SMS." });
});

module.exports = router;