# Votre boutique de photos en ligne — guide pas à pas

Ce dossier contient votre site complet. Ce guide suppose que vous partez de zéro : aucune connaissance de GitHub n'est nécessaire. Comptez environ 1 h pour les étapes 1 à 4, puis 30 min pour Snipcart.

---

## Étape 1 — Créer votre compte GitHub (5 min)

1. Ouvrez [github.com/signup](https://github.com/signup).
2. Saisissez votre e-mail, choisissez un mot de passe et un **nom d'utilisateur** (il apparaîtra dans l'adresse technique de votre site, ex. `maurice-photo`).
3. Validez le code reçu par e-mail. Le compte gratuit suffit.

## Étape 2 — Installer GitHub Desktop (5 min)

GitHub Desktop est l'application officielle qui évite d'utiliser des lignes de commande.

1. Téléchargez-la sur [desktop.github.com](https://desktop.github.com) et installez-la.
2. Ouvrez-la, cliquez **Sign in to GitHub.com** et connectez-vous avec le compte créé à l'étape 1.
3. Laissez les options par défaut ("Configure Git"), cliquez **Finish**.

## Étape 3 — Mettre le site sur GitHub (10 min)

1. Dans GitHub Desktop : **File > New repository…**
   - **Name** : `site-photos`
   - **Local path** : choisissez un emplacement facile à retrouver, par ex. `Documents`
   - Laissez le reste par défaut, cliquez **Create repository**.
2. GitHub Desktop a créé un dossier `Documents\site-photos`. Ouvrez ce dossier dans l'Explorateur Windows (**Repository > Show in Explorer**).
3. Copiez-y **tout le contenu** du dossier `site-photos` que je vous ai préparé (config.toml, les dossiers content, layouts, static, .github, etc.).
   > Le dossier `.github` est parfois masqué : dans l'Explorateur, onglet **Affichage**, cochez **Éléments masqués** pour vérifier qu'il a bien été copié.
4. Revenez dans GitHub Desktop : la liste des fichiers apparaît à gauche. En bas à gauche, écrivez `Site initial` dans le champ de résumé, puis cliquez **Commit to main**.
5. Cliquez le bouton **Publish repository** en haut. **Décochez "Keep this code private"** (le site doit être public pour l'hébergement gratuit), puis **Publish repository**.

Vos fichiers sont maintenant sur GitHub. Vérifiez sur `github.com/VOTRE-NOM-UTILISATEUR/site-photos`.

## Étape 4 — Activer l'hébergement du site (5 min)

1. Sur github.com, ouvrez votre dépôt `site-photos`.
2. Cliquez l'onglet **Settings** (roue dentée, en haut à droite du dépôt).
3. Dans le menu de gauche, cliquez **Pages**.
4. Sous **Build and deployment > Source**, choisissez **GitHub Actions**.
5. Cliquez l'onglet **Actions** (en haut) : une tâche "Déployer sur GitHub Pages" tourne. Attendez la coche verte (~2 min).
6. Votre site est en ligne à l'adresse `https://VOTRE-NOM-UTILISATEUR.github.io/site-photos/`. Ouvrez-la pour vérifier.

> Si la tâche échoue (croix rouge), cliquez dessus pour voir l'erreur, ou demandez-moi de l'analyser.

## Étape 5 — Connecter votre nom de domaine (15 min + délai DNS)

D'abord, deux petites modifications de fichiers — faites-les dans le dossier `Documents\site-photos` avec le Bloc-notes :

1. `static\CNAME` : remplacez `VOTRE-DOMAINE.fr` par votre domaine (une seule ligne, rien d'autre).
2. `config.toml` : remplacez `https://VOTRE-DOMAINE.fr/` par votre domaine dans la ligne `baseURL`.
3. Dans GitHub Desktop : résumé `Ajout du domaine`, **Commit to main**, puis bouton **Push origin** (en haut). C'est ainsi que toute modification part en ligne — retenez ce geste, il resservira.

Ensuite, chez votre **registrar** (là où vous avez acheté le domaine : OVH, Gandi, Ionos…), ouvrez la gestion DNS du domaine et créez :

- pour `www` : un enregistrement **CNAME** pointant vers `VOTRE-NOM-UTILISATEUR.github.io`
- pour le domaine racine (sans www) : 4 enregistrements **A** pointant vers `185.199.108.153`, `185.199.109.153`, `185.199.110.153`, `185.199.111.153`

Enfin, sur GitHub : **Settings > Pages > Custom domain**, saisissez votre domaine, **Save**. Attendez la vérification (de quelques minutes à 24 h selon le registrar), puis cochez **Enforce HTTPS**.

## Étape 6 — Activer les paiements Snipcart (30 min)

1. Créez un compte sur [snipcart.com](https://snipcart.com) — gratuit en mode Test.
2. Tableau de bord Snipcart : icône compte > **API Keys** > copiez la **clé publique de Test**.
3. Ouvrez `config.toml` avec le Bloc-notes et collez la clé à la place de `REMPLACEZ_PAR_VOTRE_CLE_PUBLIQUE_SNIPCART`.
4. GitHub Desktop : **Commit to main** puis **Push origin**.
5. Dans Snipcart, configurez : **Regional settings** (devise EUR), **Shipping** (zones et tarifs), **Payment gateway** (créez un compte [Stripe](https://stripe.com) et connectez-le — c'est lui qui encaisse les cartes bancaires).
6. **Domains & URLs** : ajoutez l'adresse de votre site (Snipcart vérifie les prix en lisant vos pages, le site doit être en ligne).
7. Sur votre site, passez une **commande test** complète avec la carte fictive `4242 4242 4242 4242` (date future, CVC 123).
8. Quand tout fonctionne : remplacez la clé Test par la **clé Live** dans `config.toml` (+ commit + push) et activez le compte Stripe réel.

Coûts : Snipcart prélève ~2 % par vente, Stripe ~1,5–2,9 % + 0,25 € (vérifiez leurs grilles actuelles). Aucun abonnement.

## Étape 7 — Remplacer les exemples par vos photos

Pour **ajouter une photo** :

1. Préparez une version web : ~1 600 px de large, JPEG. **Jamais votre fichier haute résolution** — il serait téléchargeable par n'importe qui.
2. Copiez-la dans `static\images\` (ex. `port-de-nuit.jpg`).
3. Dans `content\photos\`, copiez un fichier existant (ex. `dune-du-pilat.md`), renommez-le `port-de-nuit.md` et ouvrez-le avec le Bloc-notes :

   ```yaml
   ---
   title: "Port de nuit"
   date: 2026-07-02
   image: "/images/port-de-nuit.jpg"
   sku: "port-de-nuit"        # identifiant unique, sans espaces ni accents
   base_price: 45             # prix du premier format, en euros
   formats:
     - name: "A4 (21 × 29,7 cm)"
       surcharge: 0
     - name: "A3 (29,7 × 42 cm)"
       surcharge: 20          # ce format coûtera 45 + 20 = 65 €
     - name: "60 × 90 cm"
       surcharge: 55
   ---
   Votre description de la photo.
   ```

4. GitHub Desktop : **Commit to main** puis **Push origin**. En ligne 2 minutes après.

### Beaucoup de photos ? Utilisez le script fourni

Le fichier `generer-fiches.ps1` (à copier aussi dans `Documents\site-photos`) crée automatiquement une fiche pour chaque image de `static\images` qui n'en a pas, et corrige les noms de fichiers (accents, espaces, majuscules).

1. Copiez toutes vos photos exportées dans `static\images\`.
2. Clic droit sur `generer-fiches.ps1` > **Exécuter avec PowerShell**. Si Windows bloque : touche Windows, tapez `powershell`, ouvrez-le, puis collez :
   `powershell -ExecutionPolicy Bypass -File "$env:USERPROFILE\Documents\site-photos\generer-fiches.ps1"`
3. Repassez sur les fiches créées dans `content\photos\` pour ajuster titres, prix et descriptions.
4. GitHub Desktop : **Commit to main** puis **Push origin**.

Relançable sans risque : les fiches déjà existantes ne sont jamais écrasées.

Pour **supprimer** une photo d'exemple : supprimez son fichier `.md` dans `content\photos\` et son image dans `static\images\`, puis commit + push.

## Étape 8 — Avant le vrai lancement

- [ ] Remplir `content\a-propos.md`, `content\mentions-legales.md` et `content\cgv.md` (Bloc-notes)
- [ ] Changer le titre du site dans `config.toml` (ligne `title`)
- [ ] Remplacer les 3 photos d'exemple
- [ ] Décider qui imprime et expédie chaque commande (vous, ou un labo)
- [ ] Vérifier votre statut pour facturer (micro-entreprise si vous êtes en France)
- [ ] Commande test complète, puis passage en clé Live

---

## En cas de problème

- Le site ne se met pas à jour ? Vérifiez dans l'onglet **Actions** du dépôt que la dernière tâche a une coche verte, et que vous avez bien cliqué **Push origin** après le commit.
- Une photo ne s'affiche pas ? Le nom du fichier dans `image:` doit correspondre exactement (minuscules, sans accents ni espaces de préférence).
- Le bouton d'achat ne s'ouvre pas ? Vérifiez la clé API dans `config.toml` et que votre domaine est déclaré dans Snipcart (**Domains & URLs**).

Vous pouvez aussi me redemander de l'aide à tout moment : décrivez ce qui bloque et, si possible, le message d'erreur.
