$utf8NoBom = New-Object System.Text.UTF8Encoding $false

Get-ChildItem -Path materials -Filter *.md | ForEach-Object {
    $path = $_.FullName
    $originalText = [System.IO.File]::ReadAllText($path)
    
    # We want to replace p-value with *p*-value, but NOT if it's already *p*-value
    # RegEx: match 'p-value' or 'p-values', preceded by word boundary or space, not preceded by *
    # Actually `(?<!\*)` handles "not preceded by *".
    # And we want `\b` to make sure it's an isolated word.
    
    $newText = [regex]::Replace($originalText, '(?<!\*)\b(P|p)(-values?)\b', '*$1*$2')
    
    if ($newText -cne $originalText) {
        Write-Host "Updated $path"
        [System.IO.File]::WriteAllText($path, $newText, $utf8NoBom)
    }
}
