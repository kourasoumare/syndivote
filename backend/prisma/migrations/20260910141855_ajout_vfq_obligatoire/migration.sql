/*
  Warnings:

  - Added the required column `vfqId` to the `InscriptionElectorale` table without a default value. This is not possible if the table is not empty.

*/
-- AlterTable
ALTER TABLE "InscriptionElectorale" ADD COLUMN     "vfqId" TEXT NOT NULL;

-- CreateIndex
CREATE INDEX "InscriptionElectorale_vfqId_idx" ON "InscriptionElectorale"("vfqId");

-- AddForeignKey
ALTER TABLE "InscriptionElectorale" ADD CONSTRAINT "InscriptionElectorale_vfqId_fkey" FOREIGN KEY ("vfqId") REFERENCES "Vfq"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
