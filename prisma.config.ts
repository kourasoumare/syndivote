import "dotenv/config";
import { defineConfig, env } from "prisma/config"; /*charge automatiquement le contenu de ton fichier .env dans 
l'environnement, dès le démarrage — sans cette ligne, DATABASE_URL ne serait pas trouvé*/

export default defineConfig({
  schema: "prisma/schema.prisma", //dit à Prisma où se trouve ton fichier de schéma (celui qu'on vient de créer)
  migrations: {
    path: "prisma/migrations",
  }, /*dit où stocker l'historique des changements de structure de la base de données (un dossier qui sera créé 
  automatiquement au premier changement)*/ 
  datasource: {
    url: env("DATABASE_URL"),//c'est la ligne clé — elle va chercher la valeur de DATABASE_URL dans ton fichier .env
  },
});