# Claude-Code theme installer for OpenCode Desktop on Windows.
#
# Double-click install.bat, or run:
#   powershell -ExecutionPolicy Bypass -File install.ps1
#
# It copies the plugin to %LOCALAPPDATA%\opencode-claude-code-theme and adds
# "file:///..." to the plugins array of the global OpenCode config. No Node.js,
# npm or build step is needed: dist\gui-experimental.cjs ships prebuilt.
#
# The script is idempotent. It keeps comments in the config file, writes a
# backup before every change, and leaves unrelated plugins alone.
#
#   -Uninstall   remove the entry and the installed copy
#   -Source      install from a specific folder instead of this one
#   -InstallDir  override %LOCALAPPDATA%\opencode-claude-code-theme
#   -ConfigDir   override %USERPROFILE%\.config\opencode
#
# This file is ASCII on purpose: Windows PowerShell 5.1 reads BOM-less scripts
# with the ANSI code page.

[CmdletBinding()]
param(
    [string]$Source,
    [string]$InstallDir,
    [string]$ConfigDir,
    [switch]$Uninstall
)

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"
try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 } catch { }

$ThemeFolder = "opencode-claude-code-theme"
$RepoZipUrl = "https://codeload.github.com/PenicillinC3/opencode-claude-code-theme/zip/refs/heads/main"
$script:DownloadedRoot = $null

if (-not $InstallDir) { $InstallDir = Join-Path $env:LOCALAPPDATA $ThemeFolder }
if (-not $ConfigDir) {
    $base = $env:XDG_CONFIG_HOME
    if (-not $base) { $base = Join-Path $env:USERPROFILE ".config" }
    $ConfigDir = Join-Path $base "opencode"
}

# ---------------------------------------------------------------------------
# Output helpers
# ---------------------------------------------------------------------------

function Write-Step([string]$message) {
    Write-Host ""
    Write-Host "==> $message" -ForegroundColor Cyan
}

function Write-Ok([string]$message) {
    Write-Host "    $message" -ForegroundColor Green
}

function Write-Warn([string]$message) {
    Write-Host "    $message" -ForegroundColor Yellow
}

# ---------------------------------------------------------------------------
# Paths and sources
# ---------------------------------------------------------------------------

function Test-ThemeSource([string]$path) {
    if (-not $path) { return $false }
    if (-not (Test-Path -LiteralPath (Join-Path $path "package.json"))) { return $false }
    if (-not (Test-Path -LiteralPath (Join-Path $path "src\index.ts"))) { return $false }
    if (-not (Test-Path -LiteralPath (Join-Path $path "dist\gui-experimental.cjs"))) { return $false }
    return $true
}

function Resolve-Source {
    if ($Source) {
        if (-not (Test-ThemeSource $Source)) {
            throw "No theme at $Source (expected package.json, src\index.ts and dist\gui-experimental.cjs)."
        }
        return (Resolve-Path -LiteralPath $Source).Path
    }
    if ($PSScriptRoot -and (Test-ThemeSource $PSScriptRoot)) { return $PSScriptRoot }

    Write-Step "Downloading the theme from GitHub"
    $temp = Join-Path ([IO.Path]::GetTempPath()) ("claude-code-theme-" + [Guid]::NewGuid().ToString("N"))
    New-Item -ItemType Directory -Path $temp -Force | Out-Null
    $script:DownloadedRoot = $temp

    $zip = Join-Path $temp "theme.zip"
    Invoke-WebRequest -UseBasicParsing -Uri $RepoZipUrl -OutFile $zip
    Expand-Archive -LiteralPath $zip -DestinationPath $temp -Force

    $found = Get-ChildItem -LiteralPath $temp -Directory |
        Where-Object { Test-ThemeSource $_.FullName } |
        Select-Object -First 1
    if (-not $found) { throw "The downloaded archive did not contain the theme." }

    Write-Ok ("Downloaded " + [math]::Round((Get-Item -LiteralPath $zip).Length / 1MB, 1) + " MiB")
    return $found.FullName
}

function Copy-Theme([string]$from, [string]$to) {
    $roboArgs = @(
        $from, $to, "/MIR", "/NFL", "/NDL", "/NJH", "/NJS", "/NP", "/R:1", "/W:1",
        "/XD", ".git", "node_modules", "assets", "source", ".tmp-fonts", ".vscode", ".idea",
        "/XF", "*.map", "*.log", "*.zip"
    )
    & robocopy @roboArgs | Out-Null
    if ($LASTEXITCODE -ge 8) {
        throw "Copying the theme failed (robocopy exit code $LASTEXITCODE)."
    }
}

function ConvertTo-FileUrl([string]$path) {
    $full = [IO.Path]::GetFullPath($path)
    return "file:///" + $full.Replace("\", "/")
}

function Get-ConfigFile([string]$directory) {
    $jsonc = Join-Path $directory "opencode.jsonc"
    $json = Join-Path $directory "opencode.json"
    if (Test-Path -LiteralPath $jsonc) { return $jsonc }
    if (Test-Path -LiteralPath $json) { return $json }
    return $jsonc
}

# ---------------------------------------------------------------------------
# A small JSONC reader.
#
# The config is JSON with comments and trailing commas, so ConvertFrom-Json
# cannot read it. These helpers tokenize the text (keeping comments as trivia),
# which lets the script parse the file and edit the plugins array in place
# without rewriting the user's formatting.
# ---------------------------------------------------------------------------

function Get-JsoncTokens([string]$text) {
    $tokens = New-Object System.Collections.Generic.List[object]
    $i = 0
    $length = $text.Length
    while ($i -lt $length) {
        $char = $text[$i]

        if ([char]::IsWhiteSpace($char)) {
            $start = $i
            while ($i -lt $length -and [char]::IsWhiteSpace($text[$i])) { $i++ }
            $slice = $text.Substring($start, $i - $start)
            [void]$tokens.Add([pscustomobject]@{ Kind = "trivia"; Text = $slice; Start = $start; End = $i })
            continue
        }

        if ($char -eq "/" -and $i + 1 -lt $length -and $text[$i + 1] -eq "/") {
            $start = $i
            while ($i -lt $length -and $text[$i] -ne "`n") { $i++ }
            $slice = $text.Substring($start, $i - $start)
            [void]$tokens.Add([pscustomobject]@{ Kind = "trivia"; Text = $slice; Start = $start; End = $i })
            continue
        }

        if ($char -eq "/" -and $i + 1 -lt $length -and $text[$i + 1] -eq "*") {
            $start = $i
            $i += 2
            while ($i + 1 -lt $length -and -not ($text[$i] -eq "*" -and $text[$i + 1] -eq "/")) { $i++ }
            $i = [Math]::Min($length, $i + 2)
            $slice = $text.Substring($start, $i - $start)
            [void]$tokens.Add([pscustomobject]@{ Kind = "trivia"; Text = $slice; Start = $start; End = $i })
            continue
        }

        if ($char -eq '"') {
            $start = $i
            $i++
            while ($i -lt $length) {
                $inner = $text[$i]
                if ($inner -eq "\") { $i += 2; continue }
                if ($inner -eq '"') { $i++; break }
                $i++
            }
            $slice = $text.Substring($start, $i - $start)
            [void]$tokens.Add([pscustomobject]@{ Kind = "string"; Text = $slice; Start = $start; End = $i })
            continue
        }

        [void]$tokens.Add([pscustomobject]@{ Kind = "punct"; Text = [string]$char; Start = $i; End = $i + 1 })
        $i++
    }
    return $tokens
}

function ConvertFrom-Jsonc([string]$text) {
    $tokens = @(Get-JsoncTokens $text)
    $builder = New-Object System.Text.StringBuilder
    foreach ($token in $tokens) {
        if ($token.Kind -eq "trivia") {
            if ($token.Text -match "^\s+$") { [void]$builder.Append($token.Text) }
            else { [void]$builder.Append(" ") }
            continue
        }
        [void]$builder.Append($token.Text)
    }
    $json = $builder.ToString()
    $json = [regex]::Replace($json, ",(?=\s*[}\]])", "")
    if ([string]::IsNullOrWhiteSpace($json)) { $json = "{}" }
    return ($json | ConvertFrom-Json)
}

function ConvertFrom-JsonString([string]$literal) {
    return ($literal | ConvertFrom-Json)
}

function ConvertTo-JsonString([string]$value) {
    $escaped = $value.Replace("\", "\\").Replace('"', '\"')
    return '"' + $escaped + '"'
}

function Find-JsoncPlugins([object[]]$tokens) {
    $depth = 0
    $rootOpen = -1
    for ($i = 0; $i -lt $tokens.Length; $i++) {
        $token = $tokens[$i]
        if ($token.Kind -eq "trivia") { continue }
        if ($token.Kind -eq "punct") {
            if ($token.Text -eq "{" -or $token.Text -eq "[") {
                $depth++
                if ($depth -eq 1 -and $token.Text -eq "{" -and $rootOpen -lt 0) { $rootOpen = $i }
            }
            elseif ($token.Text -eq "}" -or $token.Text -eq "]") { $depth-- }
            continue
        }
        if ($depth -ne 1 -or $rootOpen -lt 0) { continue }
        if ((ConvertFrom-JsonString $token.Text) -ne "plugins") { continue }

        $colon = $i + 1
        while ($colon -lt $tokens.Length -and $tokens[$colon].Kind -eq "trivia") { $colon++ }
        if ($colon -ge $tokens.Length -or $tokens[$colon].Kind -ne "punct" -or $tokens[$colon].Text -ne ":") { continue }

        $open = $colon + 1
        while ($open -lt $tokens.Length -and $tokens[$open].Kind -eq "trivia") { $open++ }
        if ($open -ge $tokens.Length -or $tokens[$open].Kind -ne "punct" -or $tokens[$open].Text -ne "[") {
            throw 'The "plugins" value is not an array.'
        }
        return @{ RootOpen = $rootOpen; ArrayOpen = $open }
    }
    return $null
}

function Get-JsoncArrayItems([object[]]$tokens, [int]$open) {
    $items = @()
    $depth = 0
    for ($i = $open; $i -lt $tokens.Length; $i++) {
        $token = $tokens[$i]
        if ($token.Kind -eq "trivia") { continue }
        if ($token.Kind -eq "punct") {
            if ($token.Text -eq "[" -or $token.Text -eq "{") { $depth++ }
            elseif ($token.Text -eq "]" -or $token.Text -eq "}") {
                $depth--
                if ($depth -eq 0) { break }
            }
            continue
        }
        if ($depth -eq 1) {
            $items += [pscustomobject]@{
                Index = $i
                Start = $token.Start
                End = $token.End
                Value = (ConvertFrom-JsonString $token.Text)
            }
        }
    }
    return $items
}

function Get-ConfigPluginUrls([string]$text) {
    $config = ConvertFrom-Jsonc $text
    if (-not $config) { return @() }
    $property = $config.PSObject.Properties["plugins"]
    if (-not $property -or $null -eq $property.Value) { return @() }
    return @($property.Value)
}

function Test-ThemeUrl([string]$value) {
    if (-not $value) { return $false }
    if (-not $value.StartsWith("file://")) { return $false }
    $trimmed = $value.TrimEnd("/")
    $leaf = $trimmed.Substring($trimmed.LastIndexOf("/") + 1)
    return ($leaf -ieq $ThemeFolder)
}

function Apply-Edits([string]$text, [object[]]$edits) {
    $result = $text
    foreach ($edit in @($edits | Sort-Object -Property Start, Length -Descending)) {
        $result = $result.Substring(0, $edit.Start) + $edit.Replacement +
            $result.Substring($edit.Start + $edit.Length)
    }
    return $result
}

# Removes every plugins entry that points at a folder named like this theme.
# Re-tokenizes after each removal so neighbouring commas stay valid.
function Remove-ThemeUrls([string]$text) {
    $result = $text
    while ($true) {
        $tokens = @(Get-JsoncTokens $result)
        $info = Find-JsoncPlugins $tokens
        if (-not $info) { return $result }
        $items = @(Get-JsoncArrayItems $tokens $info.ArrayOpen)
        $victim = @($items | Where-Object { Test-ThemeUrl $_.Value }) | Select-Object -First 1
        if (-not $victim) { return $result }
        $result = Apply-Edits $result @((Get-RemovalEdit $result $tokens $victim.Index))
    }
}

function Get-RemovalEdit([string]$text, [object[]]$tokens, [int]$index) {
    $start = $tokens[$index].Start
    $end = $tokens[$index].End

    $next = $index + 1
    while ($next -lt $tokens.Length -and $tokens[$next].Kind -eq "trivia") { $next++ }
    if ($next -lt $tokens.Length -and $tokens[$next].Kind -eq "punct" -and $tokens[$next].Text -eq ",") {
        $end = $tokens[$next].End
    }
    else {
        $previous = $index - 1
        while ($previous -ge 0 -and $tokens[$previous].Kind -eq "trivia") { $previous-- }
        if ($previous -ge 0 -and $tokens[$previous].Kind -eq "punct" -and $tokens[$previous].Text -eq ",") {
            $start = $tokens[$previous].Start
        }
    }

    # When the entry sits alone on its line, drop the whole line so the array
    # does not keep a blank line where it was.
    $lineStart = $text.LastIndexOf("`n", [Math]::Max(0, $start - 1)) + 1
    $prefix = $text.Substring($lineStart, $start - $lineStart)
    if ($prefix -match "^[ \t]*$") {
        $lineEnd = $text.IndexOf("`n", $end)
        if ($lineEnd -lt 0) { $lineEnd = $text.Length }
        $suffix = $text.Substring($end, $lineEnd - $end)
        if ($suffix -match "^[ \t\r]*$") {
            $length = [Math]::Min($text.Length, $lineEnd + 1) - $lineStart
            return [pscustomobject]@{ Start = $lineStart; Length = $length; Replacement = "" }
        }
    }

    return [pscustomobject]@{ Start = $start; Length = $end - $start; Replacement = "" }
}

function Get-PluginsInsertEdit([string]$text, [object[]]$tokens, [string]$url, [string]$file) {
    $rootOpen = -1
    for ($i = 0; $i -lt $tokens.Length; $i++) {
        if ($tokens[$i].Kind -eq "trivia") { continue }
        if ($tokens[$i].Kind -eq "punct" -and $tokens[$i].Text -eq "{") { $rootOpen = $i }
        break
    }
    if ($rootOpen -lt 0) { throw "The root of $file must be a JSON object." }

    $hasProperties = $false
    $depth = 0
    for ($i = $rootOpen; $i -lt $tokens.Length; $i++) {
        $token = $tokens[$i]
        if ($token.Kind -eq "trivia") { continue }
        if ($token.Kind -eq "punct") {
            if ($token.Text -eq "{" -or $token.Text -eq "[") { $depth++ }
            elseif ($token.Text -eq "}" -or $token.Text -eq "]") {
                $depth--
                if ($depth -le 0) { break }
            }
            continue
        }
        if ($depth -eq 1) { $hasProperties = $true; break }
    }

    $insertStart = $tokens[$rootOpen].End
    $indent = "  "
    $multiline = $false
    $next = $rootOpen + 1
    while ($next -lt $tokens.Length -and $tokens[$next].Kind -eq "trivia") { $next++ }
    if ($next -lt $tokens.Length) {
        $gap = $text.Substring($insertStart, $tokens[$next].Start - $insertStart)
        if ($gap -match "`n([ \t]*)$") {
            $indent = $Matches[1]
            $multiline = $true
        }
    }

    $literal = ConvertTo-JsonString $url
    if ($hasProperties) {
        if ($multiline) { $replacement = "`n" + $indent + '"plugins": [' + $literal + "]," }
        else { $replacement = '"plugins": [' + $literal + "]," }
    }
    else {
        $replacement = '"plugins": [' + $literal + "]"
    }
    return [pscustomobject]@{ Start = $insertStart; Length = 0; Replacement = $replacement }
}

function Backup-Config([string]$file) {
    if (-not (Test-Path -LiteralPath $file)) { return }
    $stamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $backup = "$file.bak-$stamp"
    Copy-Item -LiteralPath $file -Destination $backup -Force
    Write-Ok "Backup: $backup"
}

function Write-Config([string]$file, [string]$text) {
    $encoding = New-Object System.Text.UTF8Encoding($false)
    [IO.File]::WriteAllText($file, $text, $encoding)
}

# Returns "created", "updated", "unchanged" or "absent".
function Update-PluginEntry {
    param(
        [string]$File,
        [string]$Url,
        [switch]$Remove
    )

    $exists = Test-Path -LiteralPath $File
    $text = ""
    if ($exists) { $text = [IO.File]::ReadAllText($File) }

    if (-not $exists -or [string]::IsNullOrWhiteSpace($text)) {
        if ($Remove) { return "absent" }
        $template = "{`n  `"`$schema`": `"https://opencode.ai/config.json`",`n  `"plugins`": [" +
            (ConvertTo-JsonString $Url) + "]`n}`n"
        $null = ConvertFrom-Jsonc $template
        Write-Config $File $template
        return "created"
    }

    try { $null = ConvertFrom-Jsonc $text }
    catch {
        throw "The config at $File is not valid JSONC. Fix it first; nothing was changed."
    }

    $tokens = @(Get-JsoncTokens $text)
    $info = Find-JsoncPlugins $tokens

    if (-not $info) {
        if ($Remove) { return "absent" }
        $edit = Get-PluginsInsertEdit $text $tokens $Url $File
        $updated = Apply-Edits $text @($edit)
        if (-not ((Get-ConfigPluginUrls $updated) -contains $Url)) {
            throw "Could not add the plugin to $File."
        }
        Backup-Config $File
        Write-Config $File $updated
        return "updated"
    }

    $items = @(Get-JsoncArrayItems $tokens $info.ArrayOpen)
    $hasOurs = @($items | Where-Object { $_.Value -eq $Url }).Count -gt 0
    $stale = @($items | Where-Object { (Test-ThemeUrl $_.Value) -and ($_.Value -ne $Url) })

    if ($Remove) {
        if (-not $hasOurs -and $stale.Count -eq 0) { return "absent" }
        $updated = Remove-ThemeUrls $text
        if (@(Get-ConfigPluginUrls $updated | Where-Object { Test-ThemeUrl $_ }).Count -gt 0) {
            throw "Could not remove the plugin from $File."
        }
        Backup-Config $File
        Write-Config $File $updated
        return "updated"
    }

    if ($hasOurs -and $stale.Count -eq 0) { return "unchanged" }

    $updated = $text
    if ($stale.Count -gt 0) { $updated = Remove-ThemeUrls $text }

    if (-not $hasOurs) {
        $freshTokens = @(Get-JsoncTokens $updated)
        $freshInfo = Find-JsoncPlugins $freshTokens
        if (-not $freshInfo) {
            $edit = Get-PluginsInsertEdit $updated $freshTokens $Url $File
        }
        else {
            $literal = ConvertTo-JsonString $Url
            $insertAt = $freshTokens[$freshInfo.ArrayOpen].End

            # Match the layout of the existing array: keep a one-line array on
            # one line, and put the new entry on its own line otherwise.
            $prefix = ""
            $next = $freshInfo.ArrayOpen + 1
            while ($next -lt $freshTokens.Length -and $freshTokens[$next].Kind -eq "trivia") { $next++ }
            if ($next -lt $freshTokens.Length) {
                $gap = $updated.Substring($insertAt, $freshTokens[$next].Start - $insertAt)
                if ($gap -match "`n([ \t]*)$") { $prefix = "`n" + $Matches[1] }
            }

            $remaining = @(Get-JsoncArrayItems $freshTokens $freshInfo.ArrayOpen)
            if ($remaining.Count -gt 0) { $literal += "," }
            $edit = [pscustomobject]@{ Start = $insertAt; Length = 0; Replacement = $prefix + $literal }
        }
        $updated = Apply-Edits $updated @($edit)
    }

    if (-not ((Get-ConfigPluginUrls $updated) -contains $Url)) {
        throw "Could not add the plugin to $File."
    }
    Backup-Config $File
    Write-Config $File $updated
    return "updated"
}

# ---------------------------------------------------------------------------
# Install / uninstall
# ---------------------------------------------------------------------------

function Invoke-Install {
    $source = Resolve-Source

    Write-Step "Installing the plugin"
    if (-not (Test-ThemeSource $source)) {
        throw "The theme files are incomplete in $source."
    }

    $sameFolder = $false
    if (Test-Path -LiteralPath $InstallDir) {
        $sourcePath = (Resolve-Path -LiteralPath $source).Path.TrimEnd("\")
        $targetPath = (Resolve-Path -LiteralPath $InstallDir).Path.TrimEnd("\")
        if ($sourcePath -ieq $targetPath) { $sameFolder = $true }
    }

    if ($sameFolder) {
        Write-Ok "Already in place: $InstallDir"
    }
    else {
        Copy-Theme $source $InstallDir
        Write-Ok "Copied to $InstallDir"
    }

    foreach ($required in @("package.json", "src\index.ts", "dist\gui-experimental.cjs")) {
        if (-not (Test-Path -LiteralPath (Join-Path $InstallDir $required))) {
            throw "The installed copy is missing $required."
        }
    }

    Write-Step "Registering the plugin"
    if (-not (Test-Path -LiteralPath $ConfigDir)) {
        New-Item -ItemType Directory -Path $ConfigDir -Force | Out-Null
    }
    $configFile = Get-ConfigFile $ConfigDir
    $url = ConvertTo-FileUrl $InstallDir

    $result = Update-PluginEntry -File $configFile -Url $url
    if ($result -eq "unchanged") {
        Write-Ok "Already registered in $configFile"
    }
    else {
        Write-Ok "Registered in $configFile"
    }

    Write-Host ""
    Write-Host "  Claude-Code is installed." -ForegroundColor Green
    Write-Host ""
    Write-Host "  Next:"
    Write-Host "    1. Restart OpenCode Desktop."
    Write-Host "    2. Open Settings > Appearance > Theme and pick Claude-Code."
    Write-Host ""
    Write-Host "  Plugin: $InstallDir"
    Write-Host "  Config: $configFile"

    if (Get-Process -Name "OpenCode" -ErrorAction SilentlyContinue) {
        Write-Host ""
        Write-Warn "OpenCode Desktop is running. Close it before restarting."
    }
}

function Invoke-Uninstall {
    Write-Step "Removing the plugin entry"
    $url = ConvertTo-FileUrl $InstallDir
    $configFile = Get-ConfigFile $ConfigDir

    if (Test-Path -LiteralPath $configFile) {
        $result = Update-PluginEntry -File $configFile -Url $url -Remove
        if ($result -eq "updated") { Write-Ok "Removed from $configFile" }
        else { Write-Ok "No entry in $configFile" }
    }
    else {
        Write-Ok "No config file at $configFile"
    }

    if (Test-Path -LiteralPath $InstallDir) {
        $packageFile = Join-Path $InstallDir "package.json"
        $isOurs = $false
        if (Test-Path -LiteralPath $packageFile) {
            try {
                $package = [IO.File]::ReadAllText($packageFile) | ConvertFrom-Json
                $isOurs = ($package.name -eq $ThemeFolder)
            }
            catch { $isOurs = $false }
        }
        if ($isOurs) {
            Remove-Item -LiteralPath $InstallDir -Recurse -Force
            Write-Ok "Deleted $InstallDir"
        }
        else {
            Write-Warn "Left $InstallDir alone (it does not look like this theme)."
        }
    }

    Write-Host ""
    Write-Host "  Claude-Code is uninstalled." -ForegroundColor Green
    Write-Host "  Restart OpenCode Desktop to unload it."
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

try {
    if ($Uninstall) { Invoke-Uninstall }
    else { Invoke-Install }
}
catch {
    Write-Host ""
    Write-Host "  ERROR: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "  Nothing was left half-installed on purpose; see the message above."
    exit 1
}
finally {
    if ($script:DownloadedRoot -and (Test-Path -LiteralPath $script:DownloadedRoot)) {
        Remove-Item -LiteralPath $script:DownloadedRoot -Recurse -Force -ErrorAction SilentlyContinue
    }
}
