-- CreateEnum
CREATE TYPE "ModeVote" AS ENUM ('ELECTRONIQUE', 'PHYSIQUE', 'LES_DEUX');

-- CreateEnum
CREATE TYPE "StatutScrutin" AS ENUM ('CREE', 'OUVERT', 'FERME');

-- CreateTable
CREATE TABLE "Electeur" (
    "id" TEXT NOT NULL,
    "nom" TEXT NOT NULL,
    "prenom" TEXT NOT NULL,
    "telephone" TEXT NOT NULL,
    "aVote" BOOLEAN NOT NULL DEFAULT false,
    "bureauVoteId" TEXT,

    CONSTRAINT "Electeur_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Scrutin" (
    "id" TEXT NOT NULL,
    "statut" "StatutScrutin" NOT NULL DEFAULT 'CREE',
    "modeVote" "ModeVote" NOT NULL,
    "dateOuverture" TIMESTAMP(3),
    "dateFermeture" TIMESTAMP(3),

    CONSTRAINT "Scrutin_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Candidat" (
    "id" TEXT NOT NULL,
    "nomSyndicat" TEXT NOT NULL,
    "description" TEXT,
    "scrutinId" TEXT NOT NULL,

    CONSTRAINT "Candidat_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Bulletin" (
    "id" TEXT NOT NULL,
    "scrutinId" TEXT NOT NULL,
    "candidatId" TEXT NOT NULL,

    CONSTRAINT "Bulletin_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ResultatPhysique" (
    "id" TEXT NOT NULL,
    "scrutinId" TEXT NOT NULL,
    "bureauVoteId" TEXT NOT NULL,
    "candidatId" TEXT NOT NULL,
    "nombreVoix" INTEGER NOT NULL DEFAULT 0,

    CONSTRAINT "ResultatPhysique_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Administrateur" (
    "id" TEXT NOT NULL,
    "identifiant" TEXT NOT NULL,
    "motDePasseHash" TEXT NOT NULL,

    CONSTRAINT "Administrateur_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Region" (
    "id" TEXT NOT NULL,
    "nom" TEXT NOT NULL,

    CONSTRAINT "Region_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Cercle" (
    "id" TEXT NOT NULL,
    "nom" TEXT NOT NULL,
    "regionId" TEXT NOT NULL,

    CONSTRAINT "Cercle_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Arrondissement" (
    "id" TEXT NOT NULL,
    "nom" TEXT NOT NULL,
    "cercleId" TEXT NOT NULL,

    CONSTRAINT "Arrondissement_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Commune" (
    "id" TEXT NOT NULL,
    "nom" TEXT NOT NULL,
    "arrondissementId" TEXT NOT NULL,

    CONSTRAINT "Commune_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Vfq" (
    "id" TEXT NOT NULL,
    "nom" TEXT NOT NULL,
    "communeId" TEXT NOT NULL,

    CONSTRAINT "Vfq_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "CentreDeVote" (
    "id" TEXT NOT NULL,
    "nom" TEXT NOT NULL,
    "vfqId" TEXT NOT NULL,

    CONSTRAINT "CentreDeVote_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "BureauDeVote" (
    "id" TEXT NOT NULL,
    "nom" TEXT NOT NULL,
    "centreDeVoteId" TEXT NOT NULL,

    CONSTRAINT "BureauDeVote_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "Electeur_telephone_key" ON "Electeur"("telephone");

-- CreateIndex
CREATE UNIQUE INDEX "Administrateur_identifiant_key" ON "Administrateur"("identifiant");

-- AddForeignKey
ALTER TABLE "Electeur" ADD CONSTRAINT "Electeur_bureauVoteId_fkey" FOREIGN KEY ("bureauVoteId") REFERENCES "BureauDeVote"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Candidat" ADD CONSTRAINT "Candidat_scrutinId_fkey" FOREIGN KEY ("scrutinId") REFERENCES "Scrutin"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Bulletin" ADD CONSTRAINT "Bulletin_scrutinId_fkey" FOREIGN KEY ("scrutinId") REFERENCES "Scrutin"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Bulletin" ADD CONSTRAINT "Bulletin_candidatId_fkey" FOREIGN KEY ("candidatId") REFERENCES "Candidat"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ResultatPhysique" ADD CONSTRAINT "ResultatPhysique_scrutinId_fkey" FOREIGN KEY ("scrutinId") REFERENCES "Scrutin"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ResultatPhysique" ADD CONSTRAINT "ResultatPhysique_bureauVoteId_fkey" FOREIGN KEY ("bureauVoteId") REFERENCES "BureauDeVote"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ResultatPhysique" ADD CONSTRAINT "ResultatPhysique_candidatId_fkey" FOREIGN KEY ("candidatId") REFERENCES "Candidat"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Cercle" ADD CONSTRAINT "Cercle_regionId_fkey" FOREIGN KEY ("regionId") REFERENCES "Region"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Arrondissement" ADD CONSTRAINT "Arrondissement_cercleId_fkey" FOREIGN KEY ("cercleId") REFERENCES "Cercle"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Commune" ADD CONSTRAINT "Commune_arrondissementId_fkey" FOREIGN KEY ("arrondissementId") REFERENCES "Arrondissement"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Vfq" ADD CONSTRAINT "Vfq_communeId_fkey" FOREIGN KEY ("communeId") REFERENCES "Commune"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "CentreDeVote" ADD CONSTRAINT "CentreDeVote_vfqId_fkey" FOREIGN KEY ("vfqId") REFERENCES "Vfq"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "BureauDeVote" ADD CONSTRAINT "BureauDeVote_centreDeVoteId_fkey" FOREIGN KEY ("centreDeVoteId") REFERENCES "CentreDeVote"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
