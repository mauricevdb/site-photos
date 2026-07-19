# Back office — mode d'emploi

Adresse : https://radio-paris-samarcande.eu/admin/

## Activation (une seule fois)

Le back office a besoin d'un service d'authentification gratuit (Cloudflare Worker) pour vous connecter avec votre compte GitHub.

1. Créez un compte gratuit sur https://dash.cloudflare.com/sign-up (si vous n'en avez pas).
2. Ouvrez https://github.com/sveltia/sveltia-cms-auth et cliquez le bouton **Deploy to Cloudflare Workers**. Suivez l'assistant ; notez l'adresse du worker créé (ex. `https://sveltia-cms-auth.XXXX.workers.dev`).
3. Sur GitHub : photo de profil > **Settings > Developer settings > OAuth Apps > New OAuth App** :
   - Application name : `Back office site photos`
   - Homepage URL : `https://radio-paris-samarcande.eu`
   - Authorization callback URL : `https://VOTRE-WORKER.workers.dev/callback`
   Créez, puis notez le **Client ID** et générez un **Client Secret**.
4. Dans Cloudflare (Workers > votre worker > Settings > Variables), ajoutez :
   - `GITHUB_CLIENT_ID` = le Client ID
   - `GITHUB_CLIENT_SECRET` = le Client Secret (variable chiffrée)
   - `ALLOWED_DOMAINS` = `radio-paris-samarcande.eu`
5. Dans le dépôt, éditez `static/admin/config.yml` : remplacez `https://VOTRE-WORKER.workers.dev` par l'adresse réelle du worker. Commit.
6. Ouvrez https://radio-paris-samarcande.eu/admin/ et connectez-vous avec GitHub.

## Usage quotidien

- **Photos** : modifier titre, pays, prix, série, mise en avant, description ; ajouter une photo (glisser l'image, remplir le formulaire).
- **Pages du site** : textes À propos, CGV, mentions légales.
- **Mosaïque (À propos)** : composition de la mosaïque — choix des photos, taille de chacune (petite/moyenne/grande), nombre de colonnes, espacement. L'ordre de la liste est l'ordre d'affichage.
- **Séries** : il suffit de nommer les photos « Nom de série #1 », « Nom de série #2 »… puis de lancer Actions > Générer les fiches photos : elles sont rattachées automatiquement.
- Chaque « Enregistrer » publie automatiquement (2-3 min).

Après un ajout de photos en masse, lancez aussi **Actions > Générer les fiches photos** pour compléter orientation et date EXIF.
