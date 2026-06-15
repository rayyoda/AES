# AES Encryption & In‑Memory Execution for PowerShell 5.1
## Version 7.1.0.2 — Ultra‑Minimal Invocation
A compact, security‑focused toolkit for encrypting PowerShell scripts and executing them entirely in memory — without writing decrypted content to disk and without exposing code through default PowerShell logging.

“Decrypt the file and execute along with dynamic parameters in memory without ever having to touch the disk.”

Built for advanced PowerShell users who need controlled, tamper‑resistant, disk‑less execution.

**✔ AES‑256 encryption of PowerShell scripts**
    Scripts are encrypted into .aes files using:

    PBKDF2‑SHA256 key derivation
    AES‑256‑CBC encryption
    HMAC‑SHA256 integrity protection
    UTF‑8 stable encoding

**✔ In‑memory decryption & execution**
    Decrypted script never touches disk

    Execution performed via System.Management.Automation.PowerShell

    Supports dynamic parameters via hashtable

**✔ Optional credential impersonation**
    Use either:

    -Credential (PSCredential), or

    -CredentialAesFile (AES‑encrypted username|password payload)

    Execution occurs under the impersonated identity using:
    LogonUser
    DuplicateToken
    WindowsIdentity.Impersonate()

**✔ Logging suppression (default)**
    To prevent decrypted script content from being captured by PowerShell logging subsystems, the module temporarily disables:

    ScriptBlockLogging
    ScriptBlockInvocationLogging
    ModuleLogging
    Transcription policy auto‑start
    Use -PreservePSLogging to leave logging intact.

**✔ Ultra‑Minimal Invocation (v7.1.x)**
    To minimize transcript exposure, the module executes scripts using:

    Code:
    
    $sb = { <script> }
    & $sb
    
    Only the invocation (& $sb) appears in the transcript.

**✔ Tamper protection**
    HMAC verification ensures the encrypted file has not been modified.

    Cmdlets:
    New-AesFile
    Encrypts a PowerShell script into a .aes file.

    Code:
    New-AesFile -InputFile <string> -Passphrase <string> [-OutputFile <string>] [-Force] [-Verbose]
    
    New-AesKey
    Derives an AES key from a passphrase and random salt.

    Code
    New-AesKey -Passphrase <string> [-OutputSalt]
    
    Outputs:

    Code:
    @{
        Key  = [byte[]]
        Salt = [byte[]]  # null unless -OutputSalt is used
    }

    New-RunAesFile
    Decrypts and executes an AES‑encrypted script entirely in memory.

    Code:
    New-RunAesFile `
        -InputFile <string> `
        -Passphrase <string> `
        [-ScriptParameters <hashtable>] `
        [-Credential <pscredential>] `
        [-CredentialAesFile <string>] `
        [-PreservePSLogging] `
        [-SilentOutput] `
        [-BasePath <string>] `
        [-Verbose]
    
    Key behaviors:

    Decrypts [HMAC][Salt][IV][Ciphertext]
    Verifies HMAC before execution
    Executes in current or impersonated context
    Suppresses logging unless -PreservePSLogging is used
    Uses Ultra‑Minimal Invocation to reduce transcript exposure

**End‑to‑End Test Flow (v7)**
1. Create a test script
    powershell:
    "Hello from inside the encrypted script!"
    "User running this script: $([Environment]::UserName)"

    Save as TestScript.ps1.

2. Encrypt it
    Code:
    New-AesFile -InputFile .\TestScript.ps1 -Passphrase "P@ssw0rd!" -Verbose
    Produces: TestScript.aes.

3. Run with logging suppression (default)
    Code:
    New-RunAesFile -InputFile .\TestScript.aes -Passphrase "P@ssw0rd!" -Verbose

   Expected:

    Code:
    VERBOSE: PowerShell logging disabled for secure execution.
    Hello from inside the encrypted script!
    User running this script: Ray

4. Run with logging preserved
    Code:
    New-RunAesFile -InputFile .\TestScript.aes -Passphrase "P@ssw0rd!" -PreservePSLogging -Verbose

5. Encrypt credentials
    Create creds.txt:

    Code:
    DOMAIN\User|SuperSecretPassword

    Encrypt:

    Code:
    New-AesFile -InputFile .\creds.txt -Passphrase "P@ssw0rd!" -OutputFile .\Creds.aes

6. Run using encrypted credentials

   Code:
    New-RunAesFile `
       -InputFile .\TestScript.aes `
        -Passphrase "P@ssw0rd!" `
        -CredentialAesFile .\Creds.aes `
        -Verbose

    Expected:

    Code:
    VERBOSE: Impersonating user DOMAIN\User
    Hello from inside the encrypted script!
    User running this script: User

**🛡 Security Notes**
    
    Decrypted script content never touches disk
    Logging suppression prevents decrypted script from appearing in:
    ScriptBlockLogging
    ModuleLogging
    Transcription auto‑start
    HMAC verification prevents tampering
    Credential AES files must contain username|password
    Use only in environments where impersonation is permitted

**⚠ What This Module Cannot Prevent**
    These limitations are inherent to PowerShell and apply to all PowerShell hosts.

    PowerShell transcription logs the command line  
    If transcription is already active, PowerShell will always log:

    Code:
    $sb = { <script> }
    & $sb
    This is unavoidable.

    PowerShell transcription logs script output  
    Unless -SilentOutput is used.

    A user with administrative access can inspect memory  
    True for any in‑memory decryption mechanism.

    A compromised host cannot be secured by this module  
    No encryption wrapper can protect a compromised machine.

**🧭 Summary**
    
    This module provides strong protection for encrypted PowerShell scripts by preventing 
    plaintext exposure through:

    Disk writes
    ScriptBlockLogging
    ModuleLogging
    Transcription auto‑start
    Function‑definition echoing
    Invocation leakage
    
    However:
    PowerShell transcription will always log the command line
    Script output will always be logged unless suppressed

    This is the maximum achievable security within the PowerShell execution model.

**Environment**
    
    Programming language
    C# (.NET Framework 4.8.1)

    Built with Visual Studio 2019
    Windows PowerShell 5.1

    Operating systems
        Windows 10
        Windows 11

**Versioning**
    
    1.0.0.1 – Abandoned
    2.0.0.1 – End of support
    3.0.0.1 – End of support
    4.0.0.1 – Stable
    5.0.0.1 – Stable
    6.0.0.1 – Stable
    7.0.0.1 – Stable
    7.1.0.2 – Current (Ultra‑Minimal Invocation)

**⚠ Disclaimer**

    This software is provided “AS IS” with no warranties or support.
    Use at your own risk.
    Designed for advanced PowerShell users who understand the security implications.
