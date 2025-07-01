# AES Encryption and Decryption for PowerShell 5.1

**Why?**

Of the literally hundreds of similar options out there, none could achieve what I wanted: Decrypt the file and execute along with dynamic parameters in memory without ever having to touch the disk.

**Programming Language**

C# using Visual Studio 2019 with .NET Framework 4.8.1 

The source code is intentionally not published on GitHub.  If I did that, it defeats the purpose of Encryption and Decryption anyway.  While it can be cracked, why make it easy?

**Operating Systems**

Tested on Windows 10 and 11 only.

**Versions:**

1.0.0.1 - Abandoned

2.0.0.1 - eos

3.0.0.1 - eos

4.0.0.1 - Stable

5.0.0.1 - Current

**Cmdlets:**

New-AesKey

New-AesFile

New-RunAesFile

## Changes since stable release.

**Version 3**:

An additonal parameter **-ScriptParameters** is addded for the New-RunAesFile Cmdlet.  This parameter will accept a **Hashtable** object that will be included in the runtime process.

**Version 4**: 

This is a major change from Version 3. In this version, New-AesKey is of no real consequence and is included here for imformational purposes only. The '**Passphrase**' is all you need for Encryption and Decryption. This version also includes file tamper protection that is checked first at runtime.

New-AesKey -Passphrase <string> [-OutputSalt] _(This is optional)_

New-AesFile [-InputFile] <string> -Passphrase <string> 

New-RunAesFile [-InputFile] <string> -Passphrase <string> [-ScriptParameters <hashtable>] 

**Version 5**: 

Major upgrade from Version 4.0.0.1. An additonal parameter -Credential is included.  A valid PowerShell **Credential** Object is required with this parameter. For this to execute, Identity Impersonation is used internally. Do NOT use this parameter if policies are in place preventing Identity Impersonation.

New-AesFile [-InputFile] <string> -Passphrase <string> 

New-RunAesFile [-InputFile] <string> -Passphrase <string> [-Credential <pscredential>] [-ScriptParameters <hashtable>] 

**Note**:  There is a sample workflow located in the v5 level.

### This software is provided "AS IS" for advanced PowerShell Coders with no assistance or warranties provided. Use at your own risk.
