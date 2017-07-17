$done   = $false
$i      = 1
$huizen = @()

while( $done -eq $false ) {    
    
    $funda     = invoke-webrequest -URI ("http://www.funda.nl/huur/den-haag/0-1000/75+woonopp/3+kamers/p" + [string]$i)
    $addressen = $funda.parsedhtml.body.getelEmentsByClassName("search-result-content")

    foreach($ad in $addressen) {
        $html  = (($ad | select-object OuterText) -split "`n")                            
        if($html[2] -match "[0-9]{4} [A-Z]{2}") {
            $huizen += [PSCustomObject] @{  
                Adres     = ($html[2] -split $matches[0])[0].Trim()
                Postcode  = $matches[0]
                Prijs     = ($html[4] -replace " /mnd Geen kosten huurder")
                Oppervlak = $html[6].Trim()
            }
        }
                
    }
                
    if($funda.ParsedHtml.body.getElementsByClassName("search-no-results-header h3")[0].classname -eq "search-no-results-header h3") {
        $done = $true        
    } else {
        "http://www.funda.nl/huur/den-haag/0-1000/75+woonopp/3+kamers/p" + [string] $i
        $i += 1
    }
}

$huizen  | export-csv  -NoTypeInformation -Path "C:\Users\jan.vanaardenne\Desktop\funda-huisjes.csv" -encoding "unicode" -delimiter "`t"