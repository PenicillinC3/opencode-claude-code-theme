# Rebuild the embedded Chinese font subsets from the original Source Han
# variable fonts in ..\source.
#
# The plugin embeds WOFF2 subsets so the desktop app needs no system fonts.
# assets\gb2312.txt lists the covered code points: Latin, common punctuation,
# and every character encodable in GB2312 (7,402 total).
#
# The subsets are instanced at 450 and compressed 8% vertically so the
# Chinese glyphs match the optical height of the UI text at small sizes.
#
# Requires Python with fonttools and brotli:
#   python -m pip install fonttools brotli
#
# Run from anywhere:
#   powershell -ExecutionPolicy Bypass -File scripts\subset-fonts.ps1
#   npm run fonts
#   npm run build

$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$repo = Split-Path -Parent $root
$source = Join-Path $repo "source"
$points = Join-Path $root "assets\gb2312.txt"
$script = Join-Path $PSScriptRoot "build-cjk-fonts.py"

$sansIn = Join-Path $source "SourceHanSansCN-VF.otf"
$serifIn = Join-Path $source "SourceHanSerifSC-VF.otf.ttf"

foreach ($file in @($sansIn, $serifIn, $points, $script)) {
  if (-not (Test-Path $file)) {
    throw "Missing input: $file"
  }
}

python -c "import fontTools, brotli" 2>$null
if ($LASTEXITCODE -ne 0) {
  throw "Python fonttools/brotli not available. Install with: python -m pip install fonttools brotli"
}

python $script
if ($LASTEXITCODE -ne 0) { throw "build-cjk-fonts.py failed" }
