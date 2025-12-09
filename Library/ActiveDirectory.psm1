function Connect-ActiveDirectory {
    param(
        [string]$Domain
    )

    try {
        $searchRoot = ([ADSI]"LDAP://$Domain")
        $searcher = New-Object DirectoryServices.DirectorySearcher($searchRoot)
        return $searcher
    }
    catch {
        Write-Error "Failed to connect to Active Directory: $_"
        return $null
    }
}

function Get-ADUserStatus {
    param(
        [string]$Domain,
        [string]$SamAccountName
    )

    $searcher = Connect-ActiveDirectory -Domain $Domain
    if ($searcher -eq $null) {
        return "Could not connect to Active Directory."
    }

    $searcher.Filter = "(&(objectCategory=person)(objectClass=user)(samaccountname=$SamAccountName))"
    $user = $searcher.FindOne()

    if (-not $user.Path) {
        return "Could not find $SamAccountName"
    }

    $userProperties = $user.Properties
    $userAccountControl = $userProperties.item("useraccountcontrol")[0]

    $pwdNeverExpires = ($userAccountControl -band 0x10000) -ne 0

    $userEntry = $user.GetDirectoryEntry()
    $userEntry.psbase.refreshcache("msDS-User-Account-Control-Computed")
    $computed = $userEntry.psbase.properties.item("msDS-User-Account-Control-Computed").value
    $pwdExpired = ($computed -band 0x800000) -ne 0

    $lockedout = $userProperties.item("lockoutTime")[0] -ne 0
    $pwdChangeAllowed = ($userAccountControl -band 0x0040) -eq 0

    # Helper function to convert timestamp to date
    function Get-UTCAge {
        param([int64]$Last=0)
        if ($Last -eq 0) { return "N/A" }
        $utc = [datetime]"1/1/1601"
        $i = $Last / 864000000000
        return $utc.AddDays($i)
    }

    # Helper function to get password age
    function Get-PwdAge {
        param([int64]$LastSet=0)
        if ($LastSet -eq 0) { return "N/A" }
        $changeDate = Get-UTCAge $LastSet
        return (Get-Date).Subtract($changeDate).Days
    }

    return [PSCustomObject]@{
        Name = $userProperties.item("name")[0]
        DistinguishedName = $userProperties.item("distinguishedname")[0]
        Description = $userProperties.item("description")[0]
        Email = $userProperties.item("mail")[0]
        AccountCreated = $userProperties.item("whencreated")[0]
        AccountModified = $userProperties.item("WhenChanged")[0]
        LastLogon = Get-UTCAge $userProperties.item("lastlogon")[0]
        PasswordLastChanged = Get-UTCAge $userProperties.item("pwdlastset")[0]
        PasswordExpired = $pwdExpired
        PasswordAge = Get-PwdAge $userProperties.item("pwdlastset")[0]
        PasswordNeverExpires = $pwdNeverExpires
        PasswordChangeAllowed = $pwdChangeAllowed
        BadPasswordTime = Get-UTCAge $userProperties.item("BadPassWordTime")[0]
        Lockout = $lockedout
    }
}

function Reset-ADUserPassword {
    param(
        [string]$Domain,
        [string]$SamAccountName
    )

    try {
        function CreatePassword([int]$length) {
            $specialCharacters = "$@#!"
            $lowerCase = "abcdefghijklmnopqrstuvwxyz"
            $upperCase = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
            $numbers = "1234567890"
            $res = ""
            $rnd = New-Object System.Random
            do {
                $flag = $rnd.Next(4);
                if ($flag -eq 0) { $res += $specialCharacters[$rnd.Next($specialCharacters.Length)]; }
                elseif ($flag -eq 1) { $res += $lowerCase[$rnd.Next($lowerCase.Length)]; }
                elseif ($flag -eq 2) { $res += $upperCase[$rnd.Next($upperCase.Length)]; }
                else { $res += $numbers[$rnd.Next($numbers.Length)]; }
            } while (0 -lt $length--)
            return $res
        }
        $Pwd = CreatePassword 6
        $user = [adsi]"WinNT://$Domain/$SamAccountName"
        $user.SetPassword($Pwd)
        $user.SetInfo()
        return $Pwd
    }
    catch {
        Write-Error "Failed to reset password: $_"
        return $null
    }
}

function Unlock-ADUserAccount {
    param(
        [string]$Domain,
        [string]$SamAccountName
    )

    try {
        $ds = New-Object DirectoryServices.DirectorySearcher([ADSI]"LDAP://$Domain")
        $ds.Filter = "(&(objectCategory=person)(objectClass=user)(samAccountName=$SamAccountName))"
        $dn = $ds.FindOne()
        $user = [ADSI]$dn.Path
        $user.lockoutTime = 0
        $user.SetInfo()
        return "Account unlocked."
    }
    catch {
        Write-Error "Failed to unlock account: $_"
        return $null
    }
}

Export-ModuleMember -Function Connect-ActiveDirectory, Get-ADUserStatus, Reset-ADUserPassword, Unlock-ADUserAccount
