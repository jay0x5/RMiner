﻿using module ..\Modules\Include.psm1

param(
    [PSCustomObject]$Pools,
    [Bool]$InfoOnly
)

if (-not $IsWindows -and -not $IsLinux) {return}
if (-not $Global:DeviceCache.DevicesByTypes.AMD -and -not $Global:DeviceCache.DevicesByTypes.NVIDIA -and -not $InfoOnly) {return} # No AMD/NVIDIA present in system

$ManualUri = "https://bitcointalk.org/index.php?topic=4767892.0"
$Port = "330{0:d2}"
$DevFee = 2.0
$Version = "2.2c"

if ($IsLinux) {
    $Path = ".\Bin\NVIDIA-MiniZ\miniZ"
    $UriCuda = @(
        [PSCustomObject]@{
            Uri = "https://github.com/RainbowMiner/miner-binaries/releases/download/v2.2c-miniz/miniZ_v2.2c_linux-x64.tar.gz"
            Cuda = "8.0"
        }
    )
} else {
    $Path = ".\Bin\NVIDIA-MiniZ\miniZ.exe"
    $UriCuda = @(
        [PSCustomObject]@{
            Uri = "https://github.com/RainbowMiner/miner-binaries/releases/download/v2.2c-miniz/miniZ_v2.2c_win-x64.7z"
            Cuda = "8.0"
        }
    )
}

$Commands = [PSCustomObject[]]@(
    [PSCustomObject]@{MainAlgorithm = "BeamHash3";                  MinMemGB = 5; Params = "--par=beam3";      Vendor = @("AMD","NVIDIA"); ExtendInterval = 3; AutoPers = $false; Fee = $DevFee;               Compute = @("RDNA2")} #BeamHash3 (BEAM)
    [PSCustomObject]@{MainAlgorithm = "EtcHash";       DAG = $true; MinMemGB = 2; Params = "--par=etchash --pers=etchash"; Vendor = @("AMD","NVIDIA"); ExtendInterval = 3; AutoPers = $false; Fee = 0.75;    Compute = @("RDNA2")} #Etchash (ETC)
    [PSCustomObject]@{MainAlgorithm = "Ethash";        DAG = $true; MinMemGB = 2; Params = "--par=ethash";     Vendor = @("AMD","NVIDIA"); ExtendInterval = 3; AutoPers = $false; Fee = 0.75;                  Compute = @("RDNA2")} #Ethash (ETH)
    [PSCustomObject]@{MainAlgorithm = "Ethash2g";      DAG = $true; MinMemGB = 1; Params = "--par=ethash";     Vendor = @("AMD","NVIDIA"); ExtendInterval = 3; AutoPers = $false; Fee = 0.75;                  Compute = @("RDNA2")} #Ethash (ETH)
    [PSCustomObject]@{MainAlgorithm = "Ethash3g";      DAG = $true; MinMemGB = 2; Params = "--par=ethash";     Vendor = @("AMD","NVIDIA"); ExtendInterval = 3; AutoPers = $false; Fee = 0.75;                  Compute = @("RDNA2")} #Ethash (ETH)
    [PSCustomObject]@{MainAlgorithm = "Ethash4g";      DAG = $true; MinMemGB = 3; Params = "--par=ethash";     Vendor = @("AMD","NVIDIA"); ExtendInterval = 3; AutoPers = $false; Fee = 0.75;                  Compute = @("RDNA2")} #Ethash (ETH)
    [PSCustomObject]@{MainAlgorithm = "Ethash5g";      DAG = $true; MinMemGB = 4; Params = "--par=ethash";     Vendor = @("AMD","NVIDIA"); ExtendInterval = 3; AutoPers = $false; Fee = 0.75;                  Compute = @("RDNA2")} #Ethash (ETH)
    [PSCustomObject]@{MainAlgorithm = "EthashLowMemory"; DAG = $true; MinMemGB = 1; Params = "--par=ethash";   Vendor = @("AMD","NVIDIA"); ExtendInterval = 3; AutoPers = $false; Fee = 0.75;                  Compute = @("RDNA2")} #Ethash (ETH) for low memory coins
    [PSCustomObject]@{MainAlgorithm = "Equihash16x5";               MinMemGB = 1; Params = "--par=96,5";       Vendor = @("AMD","NVIDIA"); ExtendInterval = 3; AutoPers = $true;  Fee = $DevFee;               Compute = @("RDNA2")} #Equihash 96,5
    [PSCustomObject]@{MainAlgorithm = "Equihash24x5";               MinMemGB = 2; Params = "--par=144,5";      Vendor = @("AMD","NVIDIA"); ExtendInterval = 3; AutoPers = $true;  Fee = $DevFee;               Compute = @("GCN4","RDNA2")} #Equihash 144,5
    [PSCustomObject]@{MainAlgorithm = "Equihash24x7";               MinMemGB = 2; Params = "--par=192,7";      Vendor = @("AMD","NVIDIA"); ExtendInterval = 3; AutoPers = $true;  Fee = $DevFee;               Compute = @("RDNA2")} #Equihash 192,7 
    [PSCustomObject]@{MainAlgorithm = "EquihashR25x4";              MinMemGB = 2; Params = "--par=125,4";      Vendor = @("AMD","NVIDIA"); ExtendInterval = 3; AutoPers = $true;  Fee = $DevFee;               Compute = @("GCN4","RDNA2")} #Equihash 125,4,0 (ZelCash)
    [PSCustomObject]@{MainAlgorithm = "EquihashR25x5";              MinMemGB = 3; Params = "--par=150,5";      Vendor = @("AMD","NVIDIA"); ExtendInterval = 3; AutoPers = $true;  Fee = $DevFee;               Compute = @("GCN4","RDNA2")} #Equihash 150,5,0 (GRIMM)
    [PSCustomObject]@{MainAlgorithm = "Equihash21x9";               MinMemGB = 2; Params = "--par=210,9";      Vendor = @("AMD","NVIDIA"); ExtendInterval = 3; AutoPers = $true;  Fee = $DevFee;               Compute = @("GCN4","RDNA2")} #Equihash 210,9 (AION)
    [PSCustomObject]@{MainAlgorithm = "EvrProgPow";    DAG = $true; MinMemGB = 2; Params = "--par=ProgPow --pers=EVRMORE-PROGPOW"; Vendor = @("AMD","NVIDIA"); ExtendInterval = 3; AutoPers = $false; Fee = 1.00; Compute = @("RDNA2"); ExcludePoolName = "MiningRigRentals"} #EvrProgPow (EVR)
    [PSCustomObject]@{MainAlgorithm = "KawPoW";        DAG = $true; MinMemGB = 2; Params = "--par=kawpow";     Vendor = @("AMD","NVIDIA"); ExtendInterval = 3; AutoPers = $false; Fee = 1.00; Compute = @("RDNA2"); ExcludePoolName = "MiningRigRentals"} #KawPow (RVN)
    [PSCustomObject]@{MainAlgorithm = "KawPoW2g";      DAG = $true; MinMemGB = 2; Params = "--par=kawpow";     Vendor = @("AMD","NVIDIA"); ExtendInterval = 3; AutoPers = $false; Fee = 1.00; Compute = @("RDNA2"); ExcludePoolName = "MiningRigRentals"} #KawPow (RVN)
    [PSCustomObject]@{MainAlgorithm = "KawPoW3g";      DAG = $true; MinMemGB = 2; Params = "--par=kawpow";     Vendor = @("AMD","NVIDIA"); ExtendInterval = 3; AutoPers = $false; Fee = 1.00; Compute = @("RDNA2"); ExcludePoolName = "MiningRigRentals"} #KawPow (RVN)
    [PSCustomObject]@{MainAlgorithm = "KawPoW4g";      DAG = $true; MinMemGB = 2; Params = "--par=kawpow";     Vendor = @("AMD","NVIDIA"); ExtendInterval = 3; AutoPers = $false; Fee = 1.00; Compute = @("RDNA2"); ExcludePoolName = "MiningRigRentals"} #KawPow (RVN)
    [PSCustomObject]@{MainAlgorithm = "KawPoW5g";      DAG = $true; MinMemGB = 2; Params = "--par=kawpow";     Vendor = @("AMD","NVIDIA"); ExtendInterval = 3; AutoPers = $false; Fee = 1.00; Compute = @("RDNA2"); ExcludePoolName = "MiningRigRentals"} #KawPow (RVN)
    [PSCustomObject]@{MainAlgorithm = "kHeavyHash";                 MinMemGB = 2; Params = "--par=kaspa";      Vendor = @("AMD","NVIDIA"); ExtendInterval = 3; AutoPers = $false; Fee = 0.8;                   Compute = @("RDNA2")} #kHeavyHash/KAS
    [PSCustomObject]@{MainAlgorithm = "Octopus";       DAG = $true; MinMemGB = 2; Params = "--par=octopus";    Vendor = @("NVIDIA"); ExtendInterval = 3; AutoPers = $false; Fee = $DevFee;                     Compute = @()} #Octopus (CFX)
    [PSCustomObject]@{MainAlgorithm = "ProgPowSero";   DAG = $true; MinMemGB = 2; Params = "--par=ProgPow --pers=sero";  Vendor = @("AMD","NVIDIA"); ExtendInterval = 3; AutoPers = $false; Fee = 1.00;        Compute = @("RDNA2"); ExcludePoolName = "MiningRigRentals"} #ProgPowSero (SERO)
    [PSCustomObject]@{MainAlgorithm = "ProgPowVeil";   DAG = $true; MinMemGB = 2; Params = "--par=ProgPow --pers=veil";  Vendor = @("AMD","NVIDIA"); ExtendInterval = 3; AutoPers = $false; Fee = 1.00;        Compute = @("RDNA2"); ExcludePoolName = "MiningRigRentals"} #ProgPowVeil (VEIL)
    [PSCustomObject]@{MainAlgorithm = "ProgPowZ";      DAG = $true; MinMemGB = 2; Params = "--par=ProgPowZ --pers=zano"; Vendor = @("AMD","NVIDIA"); ExtendInterval = 3; AutoPers = $false; Fee = 1.00;        Compute = @("RDNA2"); ExcludePoolName = "MiningRigRentals"} #ProgPowZano (ZANO)
    [PSCustomObject]@{MainAlgorithm = "EthashB3";      DAG = $true; MinMemGB = 2; Params = "--par=ethashb3";   Vendor = @("AMD","NVIDIA"); ExtendInterval = 3; AutoPers = $false; Fee = 1.00;                  Compute = @("RDNA2")} #EthashB3 (RTH)
    [PSCustomObject]@{MainAlgorithm = "UbqHash";       DAG = $true; MinMemGB = 2; Params = "--par=ubqhash";    Vendor = @("AMD","NVIDIA"); ExtendInterval = 3; AutoPers = $false; Fee = 0.75;                  Compute = @("RDNA2")} #UbqHash (UBQ)
    [PSCustomObject]@{MainAlgorithm = "vProgPow";      DAG = $true; MinMemGB = 2; Params = "--par=vProgPow --pers=VeriBlock"; Vendor = @("AMD","NVIDIA"); ExtendInterval = 3; AutoPers = $false; Fee = 1.00;   Compute = @("RDNA2"); ExcludePoolName = "MiningRigRentals"} #vProgPow (VBK)

    #[PSCustomObject]@{MainAlgorithm = "FiroPow";       DAG = $true; MinMemGB = 2; Params = "--par=ProgPow --pers=firo";  ExtendInterval = 3; AutoPers = $false; Fee = 1.00} #FiroPow (FIRO)
)

$Name = Get-Item $MyInvocation.MyCommand.Path | Select-Object -ExpandProperty BaseName

if ($InfoOnly) {
    [PSCustomObject]@{
        Type      = @("AMD","NVIDIA")
        Name      = $Name
        Path      = $Path
        Port      = $Miner_Port
        Uri       = $UriCuda.Uri
        DevFee    = $DevFee
        ManualUri = $ManualUri
        Commands  = $Commands
    }
    return
}

$Cuda = $null
if ($Global:DeviceCache.DevicesByTypes.NVIDIA) {
    for($i=0;$i -lt $UriCuda.Count -and -not $Cuda;$i++) {
        if (Confirm-Cuda -ActualVersion $Session.Config.CUDAVersion -RequiredVersion $UriCuda[$i].Cuda -Warning $(if ($i -lt $UriCuda.Count-1) {""}else{$Name})) {
            $Uri  = $UriCuda[$i].Uri
            $Cuda = $UriCuda[$i].Cuda
        }
    }
}

if (-not $Cuda) {
    $Uri = ($UriCuda | Select-Object -Last 1).Uri
}

foreach ($Miner_Vendor in @("AMD","NVIDIA")) {
    $Global:DeviceCache.DevicesByTypes.$Miner_Vendor | Where-Object Type -eq "GPU" | Where-Object {$_.Vendor -ne "NVIDIA" -or $Cuda} | Select-Object Vendor, Model -Unique | ForEach-Object {
        $Miner_Model = $_.Model
        $Device = $Global:DeviceCache.DevicesByTypes."$($_.Vendor)".Where({$_.Model -eq $Miner_Model})

        $ZilParams    = ""

        if ($Session.Config.Pools.CrazyPool.EnableMiniZDual -and $Pools.ZilliqaCP) {
            if ($ZilWallet = $Pools.ZilliqaCP.Wallet) {
                $ZilParams = " --url=$($ZilWallet)@$($Pools.ZilliqaCP.Host):$($Pools.ZilliqaCP.Port)" 
            }
        }

        $Commands.Where({$_.Vendor -icontains $Miner_Vendor}).ForEach({
            $First = $true
            $Algorithm_Norm_0 = Get-Algorithm $_.MainAlgorithm

            $MinMemGB = if ($_.DAG) {Get-EthDAGSize -CoinSymbol $Pools.$Algorithm_Norm_0.CoinSymbol -Algorithm $Algorithm_Norm_0 -Minimum $_.MinMemGb} else {$_.MinMemGb}
            $ExcludeCompute = if ($Miner_Vendor -eq "AMD") {$_.ExcludeCompute}
            $Compute = if ($Miner_Vendor -eq "AMD") {$_.Compute}
            
            $Miner_Device = $Device.Where({(Test-VRAM $_ $MinMemGB) -and (-not $ExcludeCompute -or $_.OpenCL.DeviceCapability -notin $ExcludeCompute) -and (-not $Compute -or $_.OpenCL.DeviceCapability -in $Compute)})

		    foreach($Algorithm_Norm in @($Algorithm_Norm_0,"$($Algorithm_Norm_0)-$($Miner_Model)","$($Algorithm_Norm_0)-GPU")) {
			    if ($Pools.$Algorithm_Norm.Host -and $Miner_Device -and (-not $_.ExcludePoolName -or $Pools.$Algorithm_Norm.Host -notmatch $_.ExcludePoolName)) {
                    if ($First) {
                        $Miner_Port = $Port -f ($Miner_Device | Select-Object -First 1 -ExpandProperty Index)
                        $Miner_Name = (@($Name) + @($Miner_Device.Name | Sort-Object) | Select-Object) -join '-'
                        $DeviceIDsAll = if ($Miner_Vendor -eq "NVIDIA") {$Miner_Device.Type_Vendor_Index -join ' '} else {$Miner_Device.BusId_Type_Vendor_Index -join ' '}
                        $First = $false
                    }
                    $PersCoin = Get-EquihashCoinPers $Pools.$Algorithm_Norm.CoinSymbol -Default "auto"
				    $Pool_Port = if ($Pools.$Algorithm_Norm.Ports -ne $null -and $Pools.$Algorithm_Norm.Ports.GPU) {$Pools.$Algorithm_Norm.Ports.GPU} else {$Pools.$Algorithm_Norm.Port}
                    $Stratum = @()
                    if ($Pools.$Algorithm_Norm.SSL) {$Stratum += "ssl"}
                    if ($Pools.$Algorithm_Norm.Host -match "miningrigrentals" -and $Algorithm_Norm_0 -match "^etc?hash") {$Stratum += "stratum2"}

				    [PSCustomObject]@{
					    Name           = $Miner_Name
					    DeviceName     = $Miner_Device.Name
					    DeviceModel    = $Miner_Model
					    Path           = $Path
					    Arguments      = "--$($Miner_Vendor.ToLower()) --telemetry=`$mport -cd $($DeviceIDsAll) --url=$(if ($Stratum) {"$($Stratum -join '+')://"})$($Pools.$Algorithm_Norm.User -replace "@","%40")@$($Pools.$Algorithm_Norm.Host):$($Pool_Port)$(if ($Pools.$Algorithm_Norm.Pass) {" -p $($Pools.$Algorithm_Norm.Pass)"})$(if ($Pools.$Algorithm_Norm.Worker -and $Pools.$Algorithm_Norm.User -eq $Pools.$Algorithm_Norm.Wallet) {" --worker=$($Pools.$Algorithm_Norm.Worker)"})$(if ($PersCoin -and ($_.AutoPers -or $PersCoin -ne "auto")) {" --pers=$($PersCoin)"}) --gpu-line --extra --latency$(if (-not $Session.Config.ShowMinerWindow) {" --nocolor"})$(if ($Pools.$Algorithm_Norm.Host -notmatch "xxxMiningRigRentals" -and $PersCoin -ne "auto") {" --smart-pers"}) --nohttpheaders$($ZilParams) $($_.Params)"
					    HashRates      = [PSCustomObject]@{$Algorithm_Norm = $($Global:StatsCache."$($Miner_Name)_$($Algorithm_Norm_0)_HashRate".Week)}
					    API            = "MiniZ"
					    Port           = $Miner_Port
                        FaultTolerance = $_.FaultTolerance
					    ExtendInterval = $_.ExtendInterval
                        Penalty        = 0
					    DevFee         = $_.Fee
					    Uri            = $Uri
					    ManualUri      = $ManualUri
                        Version        = $Version
                        PowerDraw      = 0
                        BaseName       = $Name
                        BaseAlgorithm  = $Algorithm_Norm_0
                        Benchmarked    = $Global:StatsCache."$($Miner_Name)_$($Algorithm_Norm_0)_HashRate".Benchmarked
                        LogFile        = $Global:StatsCache."$($Miner_Name)_$($Algorithm_Norm_0)_HashRate".LogFile
                        ExcludePoolName = $_.ExcludePoolName
				    }
			    }
		    }
        })
    }
}