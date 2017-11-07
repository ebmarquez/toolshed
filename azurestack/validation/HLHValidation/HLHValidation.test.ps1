<#
Use Pester to validate the network deployment from the HLH
#>

function test-subnets{
    begin{
        import-module posh-ssh
    }
    process{

    }

}

function get-networkdetails{
    <# 
    #>
    [CmdletBinding()]
    param($ConfigurationData)
    
    $NamingPrefix = $ConfigurationData.InputData.Cloud.NamingPrefix | sort-object| get-unique
    Write-Verbose -Message "ConfigurationData Name: $namingPrefix"
    $objectDetails = [pscustomobject]@{
        Name = $NamingPrefix
        IPConfigData = $ConfigurationData.IPConfigData
        EnvironmentData = $ConfigurationData.EnvironmentData
        InputData = $ConfigurationData.InputData
        }
    Write-Output $objectDetails

}

Describe "Network Validation"{
    
    $item = Get-ChildItem C:\results\CiscoExample -Filter "ConfigurationData.json" -Recurse -File
    foreach($i in $item){
        $networkData = get-networkdetails `
            -ConfigurationData (Get-Content -raw $i.FullName | ConvertFrom-Json )

        # get a list of all the IP's assigned in the BMCMgmt hash group.
        $bmcmgmtAssignments = ($networkdata.IPConfigData | 
            Where-Object {$_.Name -match "BMCMgmt"}).Assignments
        $hlhosIPv4 = ($bmcmgmtAssignments | 
            Where-Object {$_.Name -match "HLH-OS"}).IPv4Address

        Context "Test $($networkData.Name) P2P Links"{
            $P2PObjects = $networkdata.IPConfigData | Where-Object {$_.Name -match "P2P"}
            foreach($P2p in $P2PObjects){

                it "Test-Netconnection from HLH-OS ($hlhosIPv4) to $($p2p.Name) ($($p2p.IPv4FirstAddress))"{
                    (Test-NetConnection $p2p.IPv4FirstAddress).PingSucceeded |
                        Should be $true
                }

                it "Test-NetConnect from HLH-OS ($hlhosIPv4) to $($p2p.Name) ( $($P2P.IPv4LastAddress) )"{
                    (Test-NetConnection $P2P.IPv4LastAddress).PingSucceeded |
                        Should be $true
                }
            }
        }
        Context "Test $($networkData.Name) VLANs"{
            $vlans = $networkData.IPConfigData | Where-Object {$_.SubnetType -eq 'VLAN'} 

            foreach($vlan in $vlans){

                it "Test-NetConnection from HLH-OS ($hlhosIPv4) to $($vlan.Name) ($($vlan.IPv4Gateway))"{
                    if($vlan.Name -match 'Storage'){
                        (Test-Netconnection -computerName $vlan.IPv4Gateway).PingSucceeded |
                            Should be $false
                    }
                    else{
                        (Test-NetConnection -ComputerName $vlan.IPv4Address).PingSucceeded |
                            Should Be $true
                    } 
                }
            }  
        }
    }
}