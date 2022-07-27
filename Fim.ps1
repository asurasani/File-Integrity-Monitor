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
Write-Host ""
Write-Host "what would you like to do?"
Write-Host ""
Write-Host "    A) Collect new Baseline?"
Write-Host "    B) Being monitoring files with saved Baseline?"
Write-Host ""

$response = Read-Host -Prompt "Please enter 'A' or 'B'"
Write-Host ""
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
    #Load file|hash from baseline.txt and store thime in a dictionary
    $fileHashDictionary = @{}

    $filePathsAndHashes = Get-Content -Path .\baseline.txt

    foreach ($f in $filePathsAndHashes) {
        $fileHashDictionary.add($f.Split("|")[0], $f.Split("|")[1])
    }

    #Begin(continuously) monitoring fiels with saved Baseline

    while ($true) {
        Start-Sleep -Seconds 1
        
        $files = Get-ChildItem -Path .\Files

        # For each file, calculate the hash, and write to baseline.txt
        foreach ($f in $files) {
            $hash = Calculate-File-Hash $f.FullName
            #"$($hash.Path)|$($hash.Hash)" | Out-File -FilePath .\baseline.txt -Append

            # Notify if a new file has been created
            if ($null -eq $fileHashDictionary[$hash.Path]) {
                # A new file has been created!
                Write-Host "$($hash.Path) has been created!" -ForegroundColor Green
            }
            else {

                # Notify if a new file has been changed
                if ($fileHashDictionary[$hash.Path] -eq $hash.Hash) {
                    # The file has not changed
                }
                else {
                    # File file has been compromised!, notify the user
                    Write-Host "$($hash.Path) has changed!!!" -ForegroundColor Yellow
                }
            }
        }

        foreach ($key in $fileHashDictionary.Keys) {
            $baselineFileStillExists = Test-Path -Path $key
            if (-Not $baselineFileStillExists) {
                # One of the baseline files must have been deleted, notify the user
                Write-Host "$($key) has been deleted!" -ForegroundColor DarkRed -BackgroundColor Gray
            }
        }
    }
}