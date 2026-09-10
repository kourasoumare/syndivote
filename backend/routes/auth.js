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


const jwt = require("jsonwebtoken");

const MAX_TENTATIVES = 5;

router.post("/otp/valider", async (req, res) => {
  const { telephone, code, scrutinId } = req.body;

  if (!telephone || !code || !scrutinId) {
    return res.status(400).json({ erreur: "Téléphone, code et scrutin requis." });
  }

  // 1. Retrouver l'électeur
  const electeur = await prisma.electeur.findUnique({ where: { telephone } });
  if (!electeur) {
    return res.status(404).json({ erreur: "Ce numéro n'est pas reconnu." });
  }

  // 2. Retrouver le dernier OTP actif (non utilisé) de cet électeur
  const otp = await prisma.otpCode.findFirst({
    where: { electeurId: electeur.id, usedAt: null },
    orderBy: { createdAt: "desc" },
  });

  if (!otp) {
    return res.status(400).json({ erreur: "Aucun code actif. Veuillez en redemander un." });
  }

  // 3. Vérifier l'expiration
  if (otp.expiresAt < new Date()) {
    return res.status(400).json({ erreur: "Ce code a expiré. Veuillez en redemander un." });
  }

  // 4. Vérifier le nombre de tentatives
  if (otp.attempts >= MAX_TENTATIVES) {
    return res.status(403).json({ erreur: "Trop de tentatives. Veuillez redemander un nouveau code." });
  }

  // 5. Comparer le code fourni avec le hash stocké
  const codeValide = await bcrypt.compare(code, otp.codeHash);

  if (!codeValide) {
    await prisma.otpCode.update({
      where: { id: otp.id },
      data: { attempts: { increment: 1 } },
    });
    return res.status(400).json({ erreur: "Code incorrect." });
  }

  // 6. Marquer l'OTP comme utilisé (ne peut plus jamais resservir)
  await prisma.otpCode.update({
    where: { id: otp.id },
    data: { usedAt: new Date() },
  });

  // 7. Délivrer un jeton temporaire pour la suite du parcours de vote
  const token = jwt.sign(
    { electeurId: electeur.id, scrutinId },
    process.env.JWT_SECRET,
    { expiresIn: "10m" }
  );

  return res.json({ message: "Code validé.", token });
});



module.exports = router;