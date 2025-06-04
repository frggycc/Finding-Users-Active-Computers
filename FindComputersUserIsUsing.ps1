# Get username
$username = Read-Host "Enter a username"
$username = "DELSOLE\" + $username

# Filter for last logged on dates computer accounts
$computerDate = [DateTime]::Today.AddDays(-14)    # Computers only active if logged on last 14 days

<# 
TODO:
Test out filters to reduce search time
#>
$computers   = Get-ADComputer -Filter {(LastLogonDate -ge $computerDate) -and (Name -like "L-ITD*" -or Name -like "W-ITD*")} -Properties Name, IPv4Address | Select-Object Name
$activeComputerList = @()

# Get active users for each active computer
foreach ($computer in $computers){
    # Check if computer can be connected
    $connected = Test-Connection -Count 2 -ComputerName $computer.Name -Quiet
    
    # Gather computer/user information if computer on
    if ($connected -eq "True"){
        $activeComputer = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $computer.Name | Select-Object Name, UserName
        
        # Only track computers with active users on them
        if ($activeComputer.UserName){
            $activeComputerList += $activeComputer
        }
    }
}

# $activeComputerList | Format-Table -AutoSize
$matchingUsernames = $activeComputerList | Where-Object {$_.UserName -eq $username}

<# 
TODO
Format list output
#>
Write-Host $matchingUsernames

