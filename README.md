# AES Encryption and Decryption for PowerShell 5.1

Version: 1.0.0.1 - Abandoned

Version: 2.0.0.1 - Stable

Version: 3.0.0.1 - Beta

Version: 4.0.0.1 - Beta

Note: All versions require the .NET Framework 4.8.1 and have three Cmdlets:

New-AesKey

New-AesFile

New-RunAesFile

## Changes since stable release.

**Version 3 onwards**:

An additonal parameter **-ScriptParameters** is addded for the New-RunAesFile Cmdlet.  This parameter will accept a **Hashtable** object that will be included in the runtime process.

**Version 4**: 

This is a major change from Version 3. In this version, New-AesKey is of no consequence and is included here for imformational purposes only. The '**Passphrase**' is all you need for Encryption and Decryption. This version also includes file tamper protection that is checked first during runtime.

New-AesKey -Passphrase <string> [-OutputSalt] 

New-AesFile [-InputFile] <string> -Passphrase <string> 

New-RunAesFile [-InputFile] <string> -Passphrase <string> [-ScriptParameters <hashtable>] 


### This software is provided "AS IS" with no assistance or warranties for advanced PowerShell Coders. Use at your own risk.
