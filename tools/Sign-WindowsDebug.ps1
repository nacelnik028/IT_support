param(
    [Parameter(Mandatory = $true)][string]$ExePath,
    [Parameter(Mandatory = $true)][string]$ReportPath
)
$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSHOME 'Modules/Microsoft.PowerShell.Security/Microsoft.PowerShell.Security.psd1')
$target = (Resolve-Path -LiteralPath $ExePath).Path
if ([IO.Path]::GetExtension($target) -ne '.exe') { throw 'Expected a Windows EXE.' }

# Keep a reusable, non-exportable private key in this user's personal store.
# Do not add this self-signed certificate to any trusted certificate store.
$subject = 'CN=Training academy Local Debug'
$friendlyName = 'IT Support Simulator local debug signing'
$certificate = Get-ChildItem -Path Cert:\CurrentUser\My |
    Where-Object {
        $_.Subject -eq $subject -and $_.FriendlyName -eq $friendlyName -and $_.HasPrivateKey -and
        ($_.EnhancedKeyUsageList.ObjectId -contains '1.3.6.1.5.5.7.3.3') -and
        $_.NotBefore -le (Get-Date) -and $_.NotAfter -gt (Get-Date).AddDays(30)
    } | Sort-Object NotAfter -Descending | Select-Object -First 1
if (-not $certificate) {
    $certificate = New-SelfSignedCertificate -Type CodeSigningCert -Subject $subject `
        -FriendlyName $friendlyName -CertStoreLocation Cert:\CurrentUser\My `
        -KeyAlgorithm RSA -KeyLength 3072 -HashAlgorithm SHA256 `
        -KeyExportPolicy NonExportable -NotAfter (Get-Date).AddYears(3)
}
$signature = Set-AuthenticodeSignature -LiteralPath $target -Certificate $certificate `
    -HashAlgorithm SHA256 -IncludeChain Signer
if (-not $signature.SignerCertificate -or
    $signature.SignerCertificate.Thumbprint -ne $certificate.Thumbprint -or
    $signature.Status -notin @('Valid', 'NotTrusted', 'UnknownError')) {
    throw "Could not sign EXE: $($signature.Status): $($signature.StatusMessage)"
}

# Check the PKCS#7 signature itself independently of root trust. The Python
# builder also verifies the signed PE digest and unchanged embedded game pack.
$binary = [IO.File]::ReadAllBytes($target)
$peOffset = [BitConverter]::ToInt32($binary, 0x3c)
$securityEntry = $peOffset + 24 + 112 + 4 * 8
$certificateOffset = [BitConverter]::ToInt32($binary, $securityEntry)
$certificateLength = [BitConverter]::ToInt32($binary, $certificateOffset)
$cmsBytes = New-Object byte[] ($certificateLength - 8)
[Array]::Copy($binary, $certificateOffset + 8, $cmsBytes, 0, $cmsBytes.Length)
Add-Type -AssemblyName System.Security
$cms = New-Object System.Security.Cryptography.Pkcs.SignedCms
$cms.Decode($cmsBytes)
$cms.CheckSignature($true)
$sha256 = [Security.Cryptography.SHA256]::Create()
$certificateHash = [BitConverter]::ToString($sha256.ComputeHash($certificate.RawData)).Replace('-', '').ToLowerInvariant()
$sha256.Dispose()

[ordered]@{
    type = 'self-signed local debug'
    subject = $certificate.Subject
    thumbprint = $certificate.Thumbprint
    certificate_sha256 = $certificateHash
    not_after = $certificate.NotAfter.ToUniversalTime().ToString('o')
    hash_algorithm = 'SHA256'
    cms_signature_verified = $true
    authenticode_status = $signature.Status.ToString()
    authenticode_message = $signature.StatusMessage
    timestamped = $false
    trusted_publisher = $false
    trust_store_modified = $false
    private_key = 'Non-exportable; Cert:\CurrentUser\My on the build computer'
    signed_content_base64 = [Convert]::ToBase64String($cms.ContentInfo.Content)
} | ConvertTo-Json | Set-Content -LiteralPath $ReportPath -Encoding UTF8
