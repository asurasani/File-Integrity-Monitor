Write-Host ""
Write-Host "what would you like to do?"
Write-Host "    A) Collect new Baseline?"
Write-Host "    B) Being monitoring files with saved Baseline?"

$response = Read-Host -Prompt "Please enter 'A' or 'B'"
Write-Host ""

Function Calculate-File-Hash($filepath) {
    $filehash = Get-FileHash -Path $filepath -Algorithm SHA512
    return $filehash

}

Function Erase-Baseline-If-Exists() {
    $baselineExists = Test-Path -Path .\baseline.txt

    if ($baselineExists) {
        Remove-Item -Path .\baseline.txt
    }
    
}

Write-Host "User entered $($response)"

if ($response -eq "A".ToUpper()) {
    #delete baseline.txt if it exists
    Erase-Baseline-If-Exists
    #calculate form hash target files and store in baseline.txt

    #collect all files in target folder
    $files = Get-ChildItem -Path ./Files

    #for file, calculate hash and write to baseline.txt
    foreach ($f in $files) {
        $hash = Calculate-File-Hash $f.FullName

        "$($hash.Path) | $($hash.Hash)" | Out-File -FilePath .\baseline.txt -Append
    }

}

elseif ($response -eq "B".ToUpper()) {
    Write-Host "Read existing baseline.txt, start monitoring files." -ForegroundColor Yellow
}