# Genere une fiche .md pour chaque image de static\images qui n'en a pas encore.
# Normalise aussi les noms de fichiers (minuscules, sans accents ni espaces).
# Relancable sans risque : les fiches existantes ne sont jamais modifiees.

$site   = Split-Path -Parent $MyInvocation.MyCommand.Path
$imgDir = Join-Path $site "static\images"
$mdDir  = Join-Path $site "content\photos"

function Normaliser([string]$nom) {
    $n = $nom.ToLower()
    $n = $n.Normalize([Text.NormalizationForm]::FormD) -replace '\p{Mn}', ''   # accents
    $n = $n -replace '[ _]+', '-' -replace '[^a-z0-9\-\.]', '' -replace '-+', '-'
    return $n.Trim('-')
}

$crees = 0; $renommes = 0
Get-ChildItem $imgDir -File | Where-Object { $_.Extension -match '^\.(jpe?g|png|webp)$' } | ForEach-Object {
    $img = $_
    $propre = Normaliser $img.Name
    if ($propre -ne $img.Name) {
        Rename-Item $img.FullName -NewName $propre
        Write-Host "Renomme : $($img.Name) -> $propre"
        $renommes++
    }
    $slug = [IO.Path]::GetFileNameWithoutExtension($propre)
    $md = Join-Path $mdDir "$slug.md"
    if (Test-Path $md) { return }

    $titre = (Get-Culture).TextInfo.ToTitleCase(($slug -replace '-', ' '))
    $date  = Get-Date -Format 'yyyy-MM-dd'
    $contenu = @"
---
title: "$titre"
date: $date
image: "/images/$propre"
sku: "$slug"
base_price: 45
formats:
  - name: "A4 (21 x 29,7 cm)"
    surcharge: 0
  - name: "A3 (29,7 x 42 cm)"
    surcharge: 20
  - name: "60 x 90 cm"
    surcharge: 55
---

Tirage pigmentaire sur papier mat 230 g.
"@
    [IO.File]::WriteAllText($md, $contenu, (New-Object Text.UTF8Encoding $false))
    Write-Host "Fiche creee : content\photos\$slug.md"
    $crees++
}
Write-Host ""
Write-Host "Termine : $crees fiche(s) creee(s), $renommes fichier(s) renomme(s)."
Write-Host "Modifiez ensuite titres, prix et descriptions dans content\photos\, puis commit + push."
Read-Host "Appuyez sur Entree pour fermer"
