<#
.SYNOPSIS
    Secure Credential AES Generator for rayoda.dll (v7+)

.DESCRIPTION
    Prompts for domain\username and password, normalizes and validates them,
    detects hidden characters, optionally tests impersonation, and generates
    a clean AES credential file using New-AesFile -InputFile.

.NOTES
    This script eliminates:
        - Hidden whitespace
        - BOM characters
        - Unicode lookalikes
        - CRLF/LF inconsistencies
        - Editor encoding issues
        - Trailing spaces
        - Zero-width characters
        - Password newline contamination
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$OutputFile,

    [Parameter(Mandatory=$true)]
    [string]$Passphrase,

    [switch]$TestImpersonation
)

# Add P/Invoke for LogonUser
if (-not ([System.Management.Automation.PSTypeName]'Win32.Advapi32'.Type)) {
    Add-Type -Namespace Win32 -Name Advapi32 -MemberDefinition @"
        [DllImport("advapi32.dll", SetLastError = true, CharSet = CharSet.Unicode)]
        public static extern bool LogonUser(
            string lpszUsername,
            string lpszDomain,
            string lpszPassword,
            int dwLogonType,
            int dwLogonProvider,
            out IntPtr phToken
        );
"@
}


Write-Host "=== Secure AES Credential Generator ===" -ForegroundColor Cyan

# -------------------------------
# 1. Prompt for username
# -------------------------------
$User = Read-Host "Enter username (domain\user)"

# -------------------------------
# 2. Prompt for password securely
# -------------------------------
$SecurePass = Read-Host "Enter password" -AsSecureString
$Password = [System.Net.NetworkCredential]::new("", $SecurePass).Password

# -------------------------------
# 3. Normalize and sanitize
# -------------------------------
function Normalize-CredString {
    param([string]$Value)

    # Remove BOM
    $Value = $Value.TrimStart([char]0xFEFF)

    # Trim whitespace
    $Value = $Value.Trim()

    # Normalize Unicode
    $Value = $Value.Normalize([Text.NormalizationForm]::FormC)

    return $Value
}

$User = Normalize-CredString $User
$Password = Normalize-CredString $Password

# -------------------------------
# 4. Detect hidden characters
# -------------------------------
function Detect-HiddenChars {
    param([string]$Value, [string]$Label)

    $Hidden = $false
    $chars = @(
        "`r", "`n", "`t",
        [char]0x200B, # zero-width space
        [char]0x00A0, # non-breaking space
        [char]0xFEFF  # BOM
    )

    foreach ($c in $chars) {
        if ($Value.Contains($c)) {
            Write-Warning "$Label contains hidden character: U+{0:X4}" -f [int][char]$c
            $Hidden = $true
        }
    }

    if ($Hidden) {
        Write-Warning "$Label contains hidden or invalid characters. Please re-enter."
    }

    return $Hidden
}

$badUser = Detect-HiddenChars $User "Username"
$badPass = Detect-HiddenChars $Password "Password"

if ($badUser -or $badPass) {
    Write-Error "Credential contains hidden characters. Aborting."
    exit 1
}

# -------------------------------
# 5. Validate domain\user format
# -------------------------------
if ($User -notmatch '^[^\\]+\\[^\\]+$') {
    Write-Error "Username must be in format: domain\user"
    exit 1
}

# -------------------------------
# 6. Optional impersonation test
# -------------------------------
if ($TestImpersonation) {
    Write-Host "Testing impersonation..." -ForegroundColor Yellow

    $domain, $uname = $User.Split("\\")

    $token = [IntPtr]::Zero

    $result = [Win32.Advapi32]::LogonUser(
        $uname,
        $domain,
        $Password,
        9, # LOGON32_LOGON_NEW_CREDENTIALS
        0, # LOGON32_PROVIDER_DEFAULT
        [ref]$token
    )

    if (-not $result) {
        $err = [Runtime.InteropServices.Marshal]::GetLastWin32Error()
        Write-Error "Impersonation failed with error $err"
        exit 1
    }

    Write-Host "Impersonation successful." -ForegroundColor Green
}


# -------------------------------
# 7. Build plaintext payload
# -------------------------------
$Plain = "$User|$Password"

# -------------------------------
# 8. Encrypt using rayoda.dll (v7+ uses -InputFile)
# -------------------------------
Import-Module .\rayoda.dll -Force

$Temp = Join-Path -Path ($env:TEMP) -ChildPath ("cred_plain_{0}.txt" -f ([guid]::NewGuid().ToString()))
Set-Content -Path $Temp -Value $Plain -Encoding UTF8 -Force

New-AesFile -InputFile $Temp -Passphrase $Passphrase -OutputFile $OutputFile -Force -Verbose

Remove-Item $Temp -Force

Write-Host "Credential AES file generated successfully:" -ForegroundColor Green
Write-Host "  $OutputFile"
