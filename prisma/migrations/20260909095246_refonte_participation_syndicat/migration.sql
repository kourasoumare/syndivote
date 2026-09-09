/*
  Warnings:

  - You are about to drop the column `description` on the `Candidat` table. All the data in the column will be lost.
  - You are about to drop the column `nomSyndicat` on the `Candidat` table. All the data in the column will be lost.
  - You are about to drop the column `aVote` on the `Electeur` table. All the data in the column will be lost.
  - You are about to drop the column `bureauVoteId` on the `Electeur` table. All the data in the column will be lost.
  - A unique constraint covering the columns `[cercleId,nom]` on the table `Arrondissement` will be added. If there are existing duplicate values, this will fail.
  - A unique constraint covering the columns `[centreDeVoteId,nom]` on the table `BureauDeVote` will be added. If there are existing duplicate values, this will fail.
  - A unique constraint covering the columns `[scrutinId,syndicatId]` on the table `Candidat` will be added. If there are existing duplicate values, this will fail.
  - A unique constraint covering the columns `[vfqId,nom]` on the table `CentreDeVote` will be added. If there are existing duplicate values, this will fail.
  - A unique constraint covering the columns `[regionId,nom]` on the table `Cercle` will be added. If there are existing duplicate values, this will fail.
  - A unique constraint covering the columns `[arrondissementId,nom]` on the table `Commune` will be added. If there are existing duplicate values, this will fail.
  - A unique constraint covering the columns `[nom]` on the table `Region` will be added. If there are existing duplicate values, this will fail.
  - A unique constraint covering the columns `[scrutinId,bureauVoteId,candidatId]` on the table `ResultatPhysique` will be added. If there are existing duplicate values, this will fail.
  - A unique constraint covering the columns `[communeId,nom]` on the table `Vfq` will be added. If there are existing duplicate values, this will fail.
  - Added the required column `syndicatId` to the `Candidat` table without a default value. This is not possible if the table is not empty.
  - Added the required column `updatedAt` to the `Candidat` table without a default value. This is not possible if the table is not empty.
  - Added the required column `updatedAt` to the `Electeur` table without a default value. This is not possible if the table is not empty.
  - Added the required column `updatedAt` to the `ResultatPhysique` table without a default value. This is not possible if the table is not empty.
  - Added the required column `listeElectoraleId` to the `Scrutin` table without a default value. This is not possible if the table is not empty.
  - Added the required column `nom` to the `Scrutin` table without a default value. This is not possible if the table is not empty.
  - Added the required column `updatedAt` to the `Scrutin` table without a default value. This is not possible if the table is not empty.

*/
-- CreateEnum
CREATE TYPE "CanalVote" AS ENUM ('TELEPHONE', 'PHYSIQUE');

-- CreateEnum
CREATE TYPE "TypeTripartite" AS ENUM ('GOUVERNEMENT', 'PATRONAT', 'CENTRALE_SYNDICALE');

-- AlterEnum
-- This migration adds more than one value to an enum.
-- With PostgreSQL versions 11 and earlier, this is not possible
-- in a single migration. This can be worked around by creating
-- multiple migrations, each migration adding only one value to
-- the enum.


ALTER TYPE "StatutScrutin" ADD VALUE 'PROGRAMME';
ALTER TYPE "StatutScrutin" ADD VALUE 'RESULTATS_PROVISOIRES';
ALTER TYPE "StatutScrutin" ADD VALUE 'RESULTATS_DEFINITIFS';
ALTER TYPE "StatutScrutin" ADD VALUE 'PUBLIE';

-- DropForeignKey
ALTER TABLE "Electeur" DROP CONSTRAINT "Electeur_bureauVoteId_fkey";

-- AlterTable
ALTER TABLE "Administrateur" ADD COLUMN     "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP;

-- AlterTable
ALTER TABLE "Bulletin" ADD COLUMN     "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP;

-- AlterTable
ALTER TABLE "Candidat" DROP COLUMN "description",
DROP COLUMN "nomSyndicat",
ADD COLUMN     "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN     "descriptionScrutin" TEXT,
ADD COLUMN     "syndicatId" TEXT NOT NULL,
ADD COLUMN     "updatedAt" TIMESTAMP(3) NOT NULL;

-- AlterTable
ALTER TABLE "Electeur" DROP COLUMN "aVote",
DROP COLUMN "bureauVoteId",
ADD COLUMN     "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN     "updatedAt" TIMESTAMP(3) NOT NULL;

-- AlterTable
ALTER TABLE "ResultatPhysique" ADD COLUMN     "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN     "updatedAt" TIMESTAMP(3) NOT NULL;

-- AlterTable
ALTER TABLE "Scrutin" ADD COLUMN     "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN     "listeElectoraleId" TEXT NOT NULL,
ADD COLUMN     "nom" TEXT NOT NULL,
ADD COLUMN     "updatedAt" TIMESTAMP(3) NOT NULL;

-- CreateTable
CREATE TABLE "ListeElectorale" (
    "id" TEXT NOT NULL,
    "nom" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "ListeElectorale_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "InscriptionElectorale" (
    "id" TEXT NOT NULL,
    "listeElectoraleId" TEXT NOT NULL,
    "electeurId" TEXT NOT NULL,
    "bureauVoteId" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "InscriptionElectorale_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Participation" (
    "id" TEXT NOT NULL,
    "electeurId" TEXT NOT NULL,
    "scrutinId" TEXT NOT NULL,
    "canal" "CanalVote" NOT NULL,
    "votedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Participation_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Syndicat" (
    "id" TEXT NOT NULL,
    "nom" TEXT NOT NULL,
    "description" TEXT,
    "actif" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Syndicat_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "OtpCode" (
    "id" TEXT NOT NULL,
    "electeurId" TEXT NOT NULL,
    "codeHash" TEXT NOT NULL,
    "expiresAt" TIMESTAMP(3) NOT NULL,
    "usedAt" TIMESTAMP(3),
    "attempts" INTEGER NOT NULL DEFAULT 0,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "OtpCode_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Tripartite" (
    "id" TEXT NOT NULL,
    "type" "TypeTripartite" NOT NULL,
    "nomOrganisation" TEXT NOT NULL,
    "identifiant" TEXT NOT NULL,
    "motDePasseHash" TEXT NOT NULL,
    "actif" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Tripartite_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "AuditLog" (
    "id" TEXT NOT NULL,
    "administrateurId" TEXT NOT NULL,
    "action" TEXT NOT NULL,
    "entite" TEXT NOT NULL,
    "entiteId" TEXT,
    "details" JSONB,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "AuditLog_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "InscriptionElectorale_listeElectoraleId_electeurId_key" ON "InscriptionElectorale"("listeElectoraleId", "electeurId");

-- CreateIndex
CREATE INDEX "Participation_scrutinId_idx" ON "Participation"("scrutinId");

-- CreateIndex
CREATE UNIQUE INDEX "Participation_electeurId_scrutinId_key" ON "Participation"("electeurId", "scrutinId");

-- CreateIndex
CREATE UNIQUE INDEX "Syndicat_nom_key" ON "Syndicat"("nom");

-- CreateIndex
CREATE INDEX "OtpCode_electeurId_idx" ON "OtpCode"("electeurId");

-- CreateIndex
CREATE UNIQUE INDEX "Tripartite_identifiant_key" ON "Tripartite"("identifiant");

-- CreateIndex
CREATE INDEX "AuditLog_administrateurId_idx" ON "AuditLog"("administrateurId");

-- CreateIndex
CREATE INDEX "AuditLog_createdAt_idx" ON "AuditLog"("createdAt");

-- CreateIndex
CREATE UNIQUE INDEX "Arrondissement_cercleId_nom_key" ON "Arrondissement"("cercleId", "nom");

-- CreateIndex
CREATE INDEX "Bulletin_scrutinId_idx" ON "Bulletin"("scrutinId");

-- CreateIndex
CREATE INDEX "Bulletin_candidatId_idx" ON "Bulletin"("candidatId");

-- CreateIndex
CREATE UNIQUE INDEX "BureauDeVote_centreDeVoteId_nom_key" ON "BureauDeVote"("centreDeVoteId", "nom");

-- CreateIndex
CREATE UNIQUE INDEX "Candidat_scrutinId_syndicatId_key" ON "Candidat"("scrutinId", "syndicatId");

-- CreateIndex
CREATE UNIQUE INDEX "CentreDeVote_vfqId_nom_key" ON "CentreDeVote"("vfqId", "nom");

-- CreateIndex
CREATE UNIQUE INDEX "Cercle_regionId_nom_key" ON "Cercle"("regionId", "nom");

-- CreateIndex
CREATE UNIQUE INDEX "Commune_arrondissementId_nom_key" ON "Commune"("arrondissementId", "nom");

-- CreateIndex
CREATE UNIQUE INDEX "Region_nom_key" ON "Region"("nom");

-- CreateIndex
CREATE UNIQUE INDEX "ResultatPhysique_scrutinId_bureauVoteId_candidatId_key" ON "ResultatPhysique"("scrutinId", "bureauVoteId", "candidatId");

-- CreateIndex
CREATE UNIQUE INDEX "Vfq_communeId_nom_key" ON "Vfq"("communeId", "nom");

-- AddForeignKey
ALTER TABLE "InscriptionElectorale" ADD CONSTRAINT "InscriptionElectorale_listeElectoraleId_fkey" FOREIGN KEY ("listeElectoraleId") REFERENCES "ListeElectorale"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "InscriptionElectorale" ADD CONSTRAINT "InscriptionElectorale_electeurId_fkey" FOREIGN KEY ("electeurId") REFERENCES "Electeur"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "InscriptionElectorale" ADD CONSTRAINT "InscriptionElectorale_bureauVoteId_fkey" FOREIGN KEY ("bureauVoteId") REFERENCES "BureauDeVote"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Scrutin" ADD CONSTRAINT "Scrutin_listeElectoraleId_fkey" FOREIGN KEY ("listeElectoraleId") REFERENCES "ListeElectorale"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Participation" ADD CONSTRAINT "Participation_electeurId_fkey" FOREIGN KEY ("electeurId") REFERENCES "Electeur"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Participation" ADD CONSTRAINT "Participation_scrutinId_fkey" FOREIGN KEY ("scrutinId") REFERENCES "Scrutin"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Candidat" ADD CONSTRAINT "Candidat_syndicatId_fkey" FOREIGN KEY ("syndicatId") REFERENCES "Syndicat"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "OtpCode" ADD CONSTRAINT "OtpCode_electeurId_fkey" FOREIGN KEY ("electeurId") REFERENCES "Electeur"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "AuditLog" ADD CONSTRAINT "AuditLog_administrateurId_fkey" FOREIGN KEY ("administrateurId") REFERENCES "Administrateur"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
