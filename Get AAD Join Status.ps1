<#
.SYNOPSIS
Get information from the local computer such as Azure AD join status, tenant Id, device id
.DESCRIPTION
Get information from the local computer such as Azure AD join status, tenant Id, device id and such. Similar information as dsregcmd /status
.EXAMPLE
.\Get-AadJoinInformation.ps1

#>
Import-Module $env:SyncroModule

Add-Type -TypeDefinition @'
using System;
using System.Collections.Generic;
using System.Text;
using System.Runtime.InteropServices;

public class NetAPI32{
    public enum DSREG_JOIN_TYPE {
      DSREG_UNKNOWN_JOIN,
      DSREG_DEVICE_JOIN,
      DSREG_WORKPLACE_JOIN
    }

    [StructLayout(LayoutKind.Sequential, CharSet=CharSet.Unicode)]
    public struct DSREG_USER_INFO {
        [MarshalAs(UnmanagedType.LPWStr)] public string UserEmail;
        [MarshalAs(UnmanagedType.LPWStr)] public string UserKeyId;
        [MarshalAs(UnmanagedType.LPWStr)] public string UserKeyName;
    }

    [StructLayout(LayoutKind.Sequential, CharSet=CharSet.Unicode)]
    public struct CERT_CONTEX {
        public uint   dwCertEncodingType;
        public byte   pbCertEncoded;
        public uint   cbCertEncoded;
        public IntPtr pCertInfo;
        public IntPtr hCertStore;
    }

    [StructLayout(LayoutKind.Sequential, CharSet=CharSet.Unicode)]
    public struct DSREG_JOIN_INFO
    {
        public int joinType;
        public IntPtr pJoinCertificate;
        [MarshalAs(UnmanagedType.LPWStr)] public string DeviceId;
        [MarshalAs(UnmanagedType.LPWStr)] public string IdpDomain;
        [MarshalAs(UnmanagedType.LPWStr)] public string TenantId;
        [MarshalAs(UnmanagedType.LPWStr)] public string JoinUserEmail;
        [MarshalAs(UnmanagedType.LPWStr)] public string TenantDisplayName;
        [MarshalAs(UnmanagedType.LPWStr)] public string MdmEnrollmentUrl;
        [MarshalAs(UnmanagedType.LPWStr)] public string MdmTermsOfUseUrl;
        [MarshalAs(UnmanagedType.LPWStr)] public string MdmComplianceUrl;
        [MarshalAs(UnmanagedType.LPWStr)] public string UserSettingSyncUrl;
        public IntPtr pUserInfo;
    }

    [DllImport("netapi32.dll", CharSet=CharSet.Unicode, SetLastError=true)]
    public static extern void NetFreeAadJoinInformation(
            IntPtr pJoinInfo);

    [DllImport("netapi32.dll", CharSet=CharSet.Unicode, SetLastError=true)]
    public static extern int NetGetAadJoinInformation(
            string pcszTenantId,
            out IntPtr ppJoinInfo);
}
'@

$pcszTenantId = $null
$ptrJoinInfo = [IntPtr]::Zero

$retValue = [NetAPI32]::NetGetAadJoinInformation($pcszTenantId, [ref]$ptrJoinInfo);

if ($retValue -eq 0) {
    $ptrJoinInfoObject = New-Object NetAPI32+DSREG_JOIN_INFO
    $joinInfo = [System.Runtime.InteropServices.Marshal]::PtrToStructure($ptrJoinInfo, [System.Type] $ptrJoinInfoObject.GetType())

    $joinTypeDescription = switch ($joinInfo.joinType) {
        ([NetAPI32+DSREG_JOIN_TYPE]::DSREG_DEVICE_JOIN.value__) {
            "This device is joined to Azure AD."
            break
        }
        ([NetAPI32+DSREG_JOIN_TYPE]::DSREG_UNKNOWN_JOIN.value__) {
            "The device is not joined or has an unknown join type."
            break
        }
        ([NetAPI32+DSREG_JOIN_TYPE]::DSREG_WORKPLACE_JOIN.value__) {
            "This device is registered but not joined to Azure AD."
            break
        }
        default {
            "Unknown join type."
            break
        }
    }

    Write-Host "Join Type Description: $joinTypeDescription"
    Set-Asset-Field -Name "AADJoinStatus" -Value $joinTypeDescription

    if ($joinInfo.pUserInfo -ne [IntPtr]::Zero) {
        [System.Runtime.InteropServices.Marshal]::Release($joinInfo.pUserInfo) | Out-Null
    }
    [NetAPI32]::NetFreeAadJoinInformation($ptrJoinInfo)
} else {
    $joinTypeDescription = switch ($retValue) {
        2 { "The device is not Azure AD joined." }
        default { "Unable to determine Azure AD join status." }
    }

    Write-Host $joinTypeDescription
    Set-Asset-Field -Name "AADJoinStatus" -Value $joinTypeDescription
}

if ($ptrJoinInfo -ne [IntPtr]::Zero) {
    [NetAPI32]::NetFreeAadJoinInformation($ptrJoinInfo)
}