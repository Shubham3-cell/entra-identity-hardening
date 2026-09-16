<#
    Test-ImpossibleTravel.ps1
    Day 8 - Detection logic.
    Uses the haversine formula to calculate the distance between two sign-in
    locations, derives the implied travel speed (distance / time), and flags
    "impossible travel" when the speed exceeds a commercial flight (~900 km/h).

    Mirrors how Entra ID Protection detects atypical-travel sign-in risk.
    Key insight: impossible travel = distance AND time. The same distance is
    impossible in 1 hour but plausible over 24.
#>

function Get-HaversineKm {
    param([double]$lat1,[double]$lon1,[double]$lat2,[double]$lon2)
    $R = 6371                       # Earth's radius in km
    $rad = [math]::PI / 180         # degrees -> radians
    $dLat = ($lat2 - $lat1) * $rad
    $dLon = ($lon2 - $lon1) * $rad
    $a = [math]::Sin($dLat/2)*[math]::Sin($dLat/2) +
         [math]::Cos($lat1*$rad)*[math]::Cos($lat2*$rad)*
         [math]::Sin($dLon/2)*[math]::Sin($dLon/2)
    $c = 2 * [math]::Atan2([math]::Sqrt($a), [math]::Sqrt(1-$a))
    return [math]::Round($R * $c, 1)
}

# Two sign-ins for the SAME user
$loc1 = @{ City = "Melbourne"; Lat = -37.8136; Lon = 144.9631 }
$loc2 = @{ City = "London";    Lat = 51.5074;  Lon = -0.1278  }
$hoursApart = 1

$distance = Get-HaversineKm $loc1.Lat $loc1.Lon $loc2.Lat $loc2.Lon
$speed    = [math]::Round($distance / $hoursApart)

Write-Host "Sign-in from $($loc1.City) then $($loc2.City), $hoursApart hour(s) apart."
Write-Host "Distance: $distance km  |  Implied speed: $speed km/h"

if ($speed -gt 900) {
    Write-Host "IMPOSSIBLE TRAVEL - faster than a flight. Likely compromised." -ForegroundColor Red
} else {
    Write-Host "Plausible travel." -ForegroundColor Green
}