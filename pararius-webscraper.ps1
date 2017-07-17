$done     = $false
$i        = 1
$huizen   = @()
$pararius = New-Object -COMObject "InternetExplorer.Application"
            
while( $done -eq $false ) { 
    $url = "https://www.pararius.nl/huurwoningen/den-haag/0-1000/75m2/page-" + [string]$i
    $pararius.Navigate2($url) 
    $pararius.Visible = $false 
    while($pararius.ReadyState -ne 4) {
        start-sleep -m 100
    }     
    $addressen = $pararius.document.body.getElementsByClassName("details")
    foreach($ad in $addressen) {
        $html  = (($ad | select-object OuterText) -split "`n")        
        if($html[13] -match "€ [0-9]{3}") {
            $prijs = $html[13].substring(0,5)        
        } else {
            $prijs = $html[14].substring(0,5)
        }
        $huizen += [PSCustomObject] @{
                Adres     = $html[1]
                Postcode  = $html[2]
                Prijs     = $prijs
                Oppervlak = $html[9]
        }
        
    }
    
    
    if($pararius.document.body.getElementsByClassName("there-are-no-results")[0].classname -eq "there-are-no-results") {
        $done = $true        
    } else {
        "https://www.pararius.nl/huurwoningen/den-haag/0-1000/75m2/page-" + [string]$i
        $i += 1
    }

    
}

$huizen  | export-csv  -NoTypeInformation -Path "C:\Users\jan.vanaardenne\Desktop\pararius-huisjes.csv" -encoding "unicode" -delimiter "`t"
#$pararius.quit()
#[Runtime.Interopservices.Marshal]::ReleaseComObject($pararius)
#[GC]::Collect()
#[GC]::WaitForPendingFinalizers()