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
    
    foreach($cd in $ConfigurationData){
        $NamingPrefix = $cd.InputData.NamingPrefix
        $objectDetails = [customepsobject]@{
            Name = $NamingPrefix
            IPConfigData = $cd.IPConfigData
            EnvironmentData = $cd.EnvironmentData
            InputData = $cd.InputData
            }
        Write-Output $objectDetails
    }
}

Describe "Test From HLH"{

    it "Test-NetConnection to $item.name"
}