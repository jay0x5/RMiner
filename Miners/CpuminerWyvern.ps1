﻿using module ..\Modules\Include.psm1

param(
    [PSCustomObject]$Pools,
    [Bool]$InfoOnly
)

if (-not $IsWindows -and -not $IsLinux) {return}
if (-not $Global:DeviceCache.DevicesByTypes.CPU -and -not $InfoOnly) {return} # No CPU present in system

$ManualUri = "https://github.com/WyvernTKC/cpuminer-gr-avx2/releases"
$Port = "211{0:d2}"
$DevFee = 0.0
$Version = "1.2.4.1"

if ($IsLinux) {
    $Path = ".\Bin\CPU-Wyvern\cpuminer-$($f = $Global:GlobalCPUInfo.Features;$(if ($f.iszen3) {"zen3"}elseif($f.iszen2){"zen2"}elseif($f.iszenplus -or $f.iszen){"zen"}elseif($f.avx512 -and $f.sha -and $f.vaes){'avx512-sha-vaes'}elseif($f.avx512 -and $f.sha){'avx512-sha'}elseif($f.avx512){'avx512'}elseif($f.avx2 -and $f.sha -and $f.vaes){'avx2-sha-vaes'}elseif($f.avx2 -and $f.aes){'avx2'}elseif($f.avx -and $f.aes){'avx'}elseif($f.sse42 -and $f.aes){'aes-sse42'}elseif($f.sse42){'sse42'}else{'sse2'}))"
    $URI = "https://github.com/RainbowMiner/miner-binaries/releases/download/v1.2.4.1-wyvern/cpuminer-gr-1.2.4.1-x86_64_linux.7z"
} else {
    $Path = ".\Bin\CPU-Wyvern\cpuminer-$($f=$Global:GlobalCPUInfo.Features;$(if ($f.iszen3) {"zen3"}elseif($f.iszen2){"zen2"}elseif($f.iszenplus -or $f.iszen){"zen"}elseif($f.avx512 -and $f.sha -and $f.vaes){'avx512-sha-vaes'}elseif($f.avx512 -and $f.sha){'avx512-sha'}elseif($f.avx512){'avx512'}elseif($f.avx2 -and $f.sha -and $f.vaes){'avx2-sha-vaes'}elseif($f.avx2 -and $f.aes){'avx2'}elseif($f.avx -and $f.aes){'avx'}elseif($f.sse42 -and $f.aes){'aes-sse42'}elseif($f.sse42){'sse42'}else{'sse2'})).exe"
    $Uri = "https://github.com/RainbowMiner/miner-binaries/releases/download/v1.2.4.1-wyvern/cpuminer-gr-1.2.4.1-x86_64_windows.7z"
}

$Commands = [PSCustomObject[]]@(
    [PSCustomObject]@{MainAlgorithm = "gr"; Params = ""; FaultTolerance = 10; ExtendInterval = 3; ExcludePoolName = "C3pool|MoneroOcean"} #RTM/Take2
)

$Name = Get-Item $MyInvocation.MyCommand.Path | Select-Object -ExpandProperty BaseName

if ($InfoOnly) {
    [PSCustomObject]@{
        Type      = @("CPU")
        Name      = $Name
        Path      = $Path
        Port      = $Miner_Port
        Uri       = $Uri
        DevFee    = $DevFee
        ManualUri = $ManualUri
        Commands  = $Commands
    }
    return
}

$Global:DeviceCache.DevicesByTypes.CPU | Select-Object Vendor, Model -Unique | ForEach-Object {
    $First = $true
    $Miner_Model = $_.Model
    $Miner_Device = $Global:DeviceCache.DevicesByTypes.CPU.Where({$_.Model -eq $Miner_Model})

    $Commands.Where({-not $_.LinuxOnly -or $IsLinux}).ForEach({

        $Algorithm_Norm_0 = Get-Algorithm "$(if ($_.Algorithm) {$_.Algorithm} else {$_.MainAlgorithm})"

        $CPUThreads = if ($Session.Config.Miners."$Name-CPU-$Algorithm_Norm_0".Threads)  {$Session.Config.Miners."$Name-CPU-$Algorithm_Norm_0".Threads}  elseif ($Session.Config.Miners."$Name-CPU".Threads)  {$Session.Config.Miners."$Name-CPU".Threads}  elseif ($Session.Config.CPUMiningThreads)  {$Session.Config.CPUMiningThreads}
        $CPUAffinity= if ($Session.Config.Miners."$Name-CPU-$Algorithm_Norm_0".Affinity) {$Session.Config.Miners."$Name-CPU-$Algorithm_Norm_0".Affinity} elseif ($Session.Config.Miners."$Name-CPU".Affinity) {$Session.Config.Miners."$Name-CPU".Affinity} elseif ($Session.Config.CPUMiningAffinity) {$Session.Config.CPUMiningAffinity}
        $Run_Tuning = $Session.Config.Miners."$Name-CPU-$Algorithm_Norm_0".Tuning

        $DeviceParams = "$(if ($CPUThreads){" -t $CPUThreads"})$(if ($CPUAffinity){" --cpu-affinity $CPUAffinity"})"

		foreach($Algorithm_Norm in @($Algorithm_Norm_0,"$($Algorithm_Norm_0)-$($Miner_Model)")) {
			if ($Pools.$Algorithm_Norm.Host -and $Miner_Device -and (-not $_.ExcludePoolName -or $Pools.$Algorithm_Norm.Host -notmatch $_.ExcludePoolName)) {
                if ($First) {
                    $Miner_Port = $Port -f ($Miner_Device | Select-Object -First 1 -ExpandProperty Index)
                    $Miner_Name = (@($Name) + @($Miner_Device.Name | Sort-Object) | Select-Object) -join '-'
                    $TuneConfig_File = "tune_config"
                    $Preset_Found = Test-Path "$(Join-Path (Split-path $Path) $TuneConfig_File)"
                    $HashRate   = $Global:StatsCache."$($Miner_Name)_$($Algorithm_Norm_0)_HashRate".Week
                    if ($HashRate -and $Run_Tuning -and -not $Preset_Found) {
                        $HashRate = $null
                    }
                    $First = $false
                }
				[PSCustomObject]@{
					Name           = $Miner_Name
					DeviceName     = $Miner_Device.Name
					DeviceModel    = $Miner_Model
					Path           = $Path
					Arguments      = "-b `$mport -a gr -o stratum+tcp$(if ($Pools.$Algorithm_Norm.SSL) {"s"})://$($Pools.$Algorithm_Norm.Host):$($Pools.$Algorithm_Norm.Port) -u $($Pools.$Algorithm_Norm.User)$(if ($Pools.$Algorithm_Norm.Pass) {" -p $($Pools.$Algorithm_Norm.Pass)"})$($DeviceParams) $(if ($Preset_Found -or $Run_Tuning) {"--tune-config=$($TuneConfig_File)"} else {"--no-tune"}) $($_.Params)"
					HashRates      = [PSCustomObject]@{$Algorithm_Norm = $HashRate}
					API            = "Ccminer"
					Port           = $Miner_Port
					Uri            = $Uri
                    FaultTolerance = $_.FaultTolerance
					ExtendInterval = if ($_.ExtendInterval -ne $null) {$_.ExtendInterval} else {2}
                    Penalty        = 0
                    MaxRejectedShareRatio = $_.MaxRejectedShareRatio
					DevFee         = if ($Pools.$Algorithm_Norm.Host -match "FlockPool") {1.50} else {$DevFee}
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
