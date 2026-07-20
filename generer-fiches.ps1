# v2 — Pour chaque image de static\images :
#  - normalise le nom de fichier (minuscules, sans accents ni espaces)
#  - cree une fiche .md si elle n'existe pas
#  - met a jour les fiches : orientation (lue dans l'image) et date de capture (EXIF)
#  - retire le bloc "formats:" genere automatiquement en v1 (les formats sont
#    desormais centralises dans config.toml selon l'orientation)
# Les titres, prix et descriptions modifies a la main ne sont jamais touches.

Add-Type -AssemblyName System.Drawing

$site   = Split-Path -Parent $MyInvocation.MyCommand.Path
$imgDir = Join-Path $site "assets\images"
$mdDir  = Join-Path $site "content\photos"

function Normaliser([string]$nom) {
    $n = $nom.ToLower()
    $n = $n.Normalize([Text.NormalizationForm]::FormD) -replace '\p{Mn}', ''
    $n = $n -replace '[ _]+', '-' -replace '[^a-z0-9\-\.]', '' -replace '-+', '-'
    return $n.Trim('-')
}

function LireImage([string]$chemin) {
    $img = [System.Drawing.Image]::FromFile($chemin)
    try {
        $orient = if ($img.Height -gt $img.Width) { "portrait" } else { "paysage" }
        $date = $null
        if ($img.PropertyIdList -contains 36867) {   # EXIF DateTimeOriginal
            $brut = [Text.Encoding]::ASCII.GetString($img.GetPropertyItem(36867).Value).Trim([char]0)
            try { $date = [datetime]::ParseExact($brut.Substring(0,10), 'yyyy:MM:dd', $null).ToString('yyyy-MM-dd') } catch {}
        }
        return @{ orientation = $orient; date = $date }
    } finally { $img.Dispose() }
}

$crees = 0; $maj = 0; $renommes = 0
Get-ChildItem $imgDir -File | Where-Object { $_.Extension -match '^\.(jpe?g|png|webp)$' } | ForEach-Object {
    $img = $_
    $propre = Normaliser $img.Name
    if ($propre -ne $img.Name) {
        Rename-Item $img.FullName -NewName $propre
        Write-Host "Renomme : $($img.Name) -> $propre"
        $renommes++
    }
    $chemin = Join-Path $imgDir $propre
    $info = LireImage $chemin
    $slug = [IO.Path]::GetFileNameWithoutExtension($propre)
    $md = Join-Path $mdDir "$slug.md"

    if (-not (Test-Path $md)) {
        if ($slug -match '^(.*)--(\d+)$') {
            $titre = (Get-Culture).TextInfo.ToTitleCase(($Matches[1] -replace '-', ' ')) + " #" + $Matches[2]
        } else {
            $titre = (Get-Culture).TextInfo.ToTitleCase(($slug -replace '-', ' '))
        }
        $date  = if ($info.date) { $info.date } else { Get-Date -Format 'yyyy-MM-dd' }
        $contenu = @"
---
title: "$titre"
date: $date
image: "/images/$propre"
orientation: $($info.orientation)
sku: "$slug"
base_price: 45
---

Tirage pigmentaire sur papier mat 230 g.
"@
        [IO.File]::WriteAllText($md, $contenu, (New-Object Text.UTF8Encoding $false))
        Write-Host "Fiche creee : $slug.md ($($info.orientation)$(if ($info.date) { ", capture $($info.date)" }))"
        $crees++
        return
    }

    # Mise a jour d'une fiche existante
    $t = [IO.File]::ReadAllText($md)
    $avant = $t
    if ($info.date) { $t = $t -replace '(?m)^date:.*$', "date: $($info.date)" }
    if ($t -match '(?m)^orientation:') {
        $t = $t -replace '(?m)^orientation:.*$', "orientation: $($info.orientation)"
    } else {
        $t = $t -replace '(?m)^(image:.*)$', "`$1`norientation: $($info.orientation)"
    }
    # Retire le bloc formats: uniquement s'il est identique a celui genere en v1
    if ($t -match '(?m)^formats:\r?\n((?:[ \t]+.*\r?\n?)+)') {
        $bloc = $Matches[0]
        if (($bloc -match 'surcharge:\s*0\b') -and ($bloc -match 'surcharge:\s*20\b') -and
            ($bloc -match 'surcharge:\s*55\b') -and ([regex]::Matches($bloc, '- name:').Count -eq 3)) {
            $t = $t.Replace($bloc, '')
        }
    }
    if ($t -ne $avant) {
        [IO.File]::WriteAllText($md, $t, (New-Object Text.UTF8Encoding $false))
        Write-Host "Fiche mise a jour : $slug.md ($($info.orientation)$(if ($info.date) { ", capture $($info.date)" }))"
        $maj++
    }
}
# Passe series : tout titre "X #N" rejoint automatiquement la serie X
$series_maj = 0
Get-ChildItem $mdDir -Filter *.md | ForEach-Object {
    $t = [IO.File]::ReadAllText($_.FullName)
    if ($t -match '(?m)^title:\s*"(.+?)\s*#(\d+)"') {
        $nom = $Matches[1] -replace '"', '\"'
        $num = $Matches[2]
        $avant2 = $t
        if ($t -match '(?m)^series\s*:') { $t = $t -replace '(?m)^series\s*:.*$', "series: [`"$nom`"]" }
        else { $idx = $t.IndexOf("`n---", 4); if ($idx -ge 0) { $t = $t.Substring(0, $idx) + "`nseries: [`"$nom`"]" + $t.Substring($idx) } }
        if ($t -match '(?m)^ordre\s*:') { $t = $t -replace '(?m)^ordre\s*:.*$', "ordre: $num" }
        else { $idx = $t.IndexOf("`n---", 4); if ($idx -ge 0) { $t = $t.Substring(0, $idx) + "`nordre: $num" + $t.Substring($idx) } }
        if ($t -ne $avant2) {
            [IO.File]::WriteAllText($_.FullName, $t, (New-Object Text.UTF8Encoding $false))
            $series_maj++
        }
    }
}
if ($series_maj) { Write-Host "$series_maj fiche(s) rattachee(s) a une serie d'apres leur titre." }

Write-Host ""
Write-Host "Termine : $crees creee(s), $maj mise(s) a jour, $renommes renommee(s)."
Write-Host "Pensez a : Commit to main puis Push origin dans GitHub Desktop."
if (-not $env:CI) { Read-Host "Appuyez sur Entree pour fermer" }
