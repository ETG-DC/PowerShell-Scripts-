<#
.SYNOPSIS
This script is designed to query and process Azure AD (AAD) join information for a local computer. 
It leverages custom .NET types and interacts with the netapi32.dll library through P/Invoke (Platform Invocation Services) to call unmanaged code and retrieve detailed join status information. 
.DESCRIPTION
The script retrieves Azure AD join information, including:
    Join type (e.g., joined, registered, or unknown)
    Device ID
    Tenant ID
    Tenant display name
    Additional user and device-specific metadata

Technical Process:
    Initialization:
        Loads the Syncro RMM module (Import-Module $env:SyncroModule).
        Dynamically defines the NetAPI32 class with required enums, structs, and DLL imports.
    
    Retrieve Join Information:
        Calls NetGetAadJoinInformation with pcszTenantId set to null to get join information for the current tenant.
    
    Process Join Information:
        Converts the unmanaged pointer (IntPtr) returned by NetGetAadJoinInformation into a managed DSREG_JOIN_INFO object.
        Interprets and maps the join type to a human-readable description.
    
    Store Results:
        Outputs the join type description to the console.
        Updates the AADJoinStatus custom field in Syncro RMM with the description.
    
    Cleanup:
        Releases unmanaged memory for user info (pUserInfo) and join information (pJoinInfo) using appropriate methods.


.NOTES   
Can't we just use dsregcmd /status for this? The problem with dsregcmd is its unstructured text output; the data is not encapsulated within objects. This makes it difficult to parse the data accurately and reliably.
As far as I know, there are currently no native PowerShell cmdlets available for accessing this data (I'm excluding any potential cmdlets that are part of the AAD or MgGraph PowerShell modules I might not know about since they won't work for us). I'm also aware this info can be obtained in the Entra ID admin center, but that's boring and tedious.
#>


# Import the Syncro RMM module to enable the use of its functions
Import-Module $env:SyncroModule

# Dynamically define a .NET class to interact with the NetAPI32 library
Add-Type -TypeDefinition @'
using System;
using System.Collections.Generic;
using System.Text;
using System.Runtime.InteropServices;

public class NetAPI32{
    // Enum to represent different Azure AD join types
    public enum DSREG_JOIN_TYPE {
      DSREG_UNKNOWN_JOIN,
      DSREG_DEVICE_JOIN,
      DSREG_WORKPLACE_JOIN
    }

    // Structure for storing user-specific Azure AD join information
    [StructLayout(LayoutKind.Sequential, CharSet=CharSet.Unicode)]
    public struct DSREG_USER_INFO {
        [MarshalAs(UnmanagedType.LPWStr)] public string UserEmail;
        [MarshalAs(UnmanagedType.LPWStr)] public string UserKeyId;
        [MarshalAs(UnmanagedType.LPWStr)] public string UserKeyName;
    }

    // Structure for storing certificate context information (not directly used here)
    [StructLayout(LayoutKind.Sequential, CharSet=CharSet.Unicode)]
    public struct CERT_CONTEX {
        public uint   dwCertEncodingType;
        public byte   pbCertEncoded;
        public uint   cbCertEncoded;
        public IntPtr pCertInfo;
        public IntPtr hCertStore;
    }

    // Structure for storing Azure AD join information
    [StructLayout(LayoutKind.Sequential, CharSet=CharSet.Unicode)]
    public struct DSREG_JOIN_INFO
    {
        public int joinType; // The type of Azure AD join
        public IntPtr pJoinCertificate; // Pointer to the join certificate
        [MarshalAs(UnmanagedType.LPWStr)] public string DeviceId; // Device ID in Azure AD
        [MarshalAs(UnmanagedType.LPWStr)] public string IdpDomain; // Identity provider domain
        [MarshalAs(UnmanagedType.LPWStr)] public string TenantId; // Azure AD tenant ID
        [MarshalAs(UnmanagedType.LPWStr)] public string JoinUserEmail; // Email of the user associated with the join
        [MarshalAs(UnmanagedType.LPWStr)] public string TenantDisplayName; // Display name of the Azure AD tenant
        [MarshalAs(UnmanagedType.LPWStr)] public string MdmEnrollmentUrl; // URL for MDM enrollment
        [MarshalAs(UnmanagedType.LPWStr)] public string MdmTermsOfUseUrl; // URL for MDM terms of use
        [MarshalAs(UnmanagedType.LPWStr)] public string MdmComplianceUrl; // URL for MDM compliance
        [MarshalAs(UnmanagedType.LPWStr)] public string UserSettingSyncUrl; // URL for user settings synchronization
        public IntPtr pUserInfo; // Pointer to user-specific information
    }

    // Method to free memory allocated for Azure AD join information
    [DllImport("netapi32.dll", CharSet=CharSet.Unicode, SetLastError=true)]
    public static extern void NetFreeAadJoinInformation(
            IntPtr pJoinInfo);

    // Method to retrieve Azure AD join information from the system
    [DllImport("netapi32.dll", CharSet=CharSet.Unicode, SetLastError=true)]
    public static extern int NetGetAadJoinInformation(
            string pcszTenantId,
            out IntPtr ppJoinInfo);
}
'@

# Initialize variables for tenant ID and pointer to join information
$pcszTenantId = $null
$ptrJoinInfo = [IntPtr]::Zero

# Call the NetGetAadJoinInformation method to retrieve join information
$retValue = [NetAPI32]::NetGetAadJoinInformation($pcszTenantId, [ref]$ptrJoinInfo);

# Check if the function call was successful
if ($retValue -eq 0) {
    # Create a new object to hold the join information structure
    $ptrJoinInfoObject = New-Object NetAPI32+DSREG_JOIN_INFO
    # Marshal the unmanaged memory into a managed .NET object
    $joinInfo = [System.Runtime.InteropServices.Marshal]::PtrToStructure($ptrJoinInfo, [System.Type] $ptrJoinInfoObject.GetType())

    # Map the join type to a human-readable description
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

    # Output the join type description to the console
    Write-Host "Join Type Description: $joinTypeDescription"
    # Update the Syncro RMM asset field with the join type description
    Set-Asset-Field -Name "AADJoinStatus" -Value $joinTypeDescription

    # Release the memory for user-specific information if it exists
    if ($joinInfo.pUserInfo -ne [IntPtr]::Zero) {
        [System.Runtime.InteropServices.Marshal]::Release($joinInfo.pUserInfo) | Out-Null
    }
    # Free the memory allocated for the join information structure
    [NetAPI32]::NetFreeAadJoinInformation($ptrJoinInfo)
} else {
    # Handle errors or cases where the device is not Azure AD joined
    $joinTypeDescription = switch ($retValue) {
        2 { "The device is not Azure AD joined." }
        default { "Unable to determine Azure AD join status." }
    }

    # Output the join type description to the console
    Write-Host $joinTypeDescription
    # Update the Syncro RMM asset field with the join type description
    Set-Asset-Field -Name "AADJoinStatus" -Value $joinTypeDescription
}

# Free the memory allocated for the join information pointer if necessary
if ($ptrJoinInfo -ne [IntPtr]::Zero) {
    [NetAPI32]::NetFreeAadJoinInformation($ptrJoinInfo)
}
