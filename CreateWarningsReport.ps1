$buildLogs = $env:BUILD_LOGS.Split("`n", [System.StringSplitOptions]::RemoveEmptyEntries)
$warningsList = @()

foreach ($log in $buildLogs) {
    $filename = [System.IO.Path]::GetFileName($log)
    if ($filename -match "^(?<compiler>[^_]+)_(?<config>[^_]+)_build\.log$") {
        $compiler = $matches['compiler']
        $config = $matches['config']
        $logContent = Get-Content $log

        $gccRegex = '^.*:\d+:\d+:\s+warning:\s+.*\[-.*\]$'
        $clangRegex = $gccRegex
        $msvcRegex = '^.*\((\d+|\d+,\d+|\d+,\d+,\d+,\d+)\)\s*:\s+warning\s+\w{1,2}\d+\s*:\s*.*$'
        $clangClRegex = '^.*\(\d+,\d+\):\s+warning:\s+.*\[-.*\]$'
        $clangTidyRegex = '^.*:\d+:\d+:\s+warning:\s+.*\[[^-].*\]$'
        switch ($compiler) {
            "gcc" { $compilerRegex = $gccRegex }
            "clang" { $compilerRegex = $clangRegex }
            "msvc" { $compilerRegex = $msvcRegex }
            "clang-cl" { $compilerRegex = $clangClRegex }
            "clangcl" { $compilerRegex = $clangClRegex }
            default {
                Write-Output "Unknown compiler: $compiler"
                continue
            }
        }

        $nCompilerWarnings = ($logContent -match $compilerRegex).Count
        $nWarnings = $nCompilerWarnings
        if ($env:INCLUDE_CLANG_TIDY_WARNINGS -eq "true") {
            $nClangTidyWarnings = ($logContent -match $clangTidyRegex).Count
            $nWarnings += $nClangTidyWarnings
        }
        $warningsList += [PSCustomObject]@{ Compiler = $compiler; Configuration = $config; NWarnings = $nWarnings; NCompilerWarnings = $nCompilerWarnings; NClangTidyWarnings = $nClangTidyWarnings }
    }
    else {
        Write-Output "Invalid log filename: '$filename'"
    }
}

if($env:ADD_ANNOTATIONS -eq "true") {
    $compilersWithWarnings = $warningsList | Where-Object { $_.NWarnings -gt 0 } | Select-Object -ExpandProperty Compiler -Unique
    foreach ($compiler in $compilersWithWarnings) {
        Write-Output "::warning::$compiler found warnings"
    }
}

$report = "## Warnings report`n`n"
$report += "| Compiler | Configuration | # Warnings |`n"
$report += "|:---------|:--------------|-----------:|`n"
foreach ($entry in $warningsList) {
    $report += "| $($entry.Compiler) | $($entry.Configuration) | $($entry.NCompilerWarnings)"
    if($env:INCLUDE_CLANG_TIDY_WARNINGS -eq "true") {
        $report += " + $($entry.NClangTidyWarnings)"
    }
    $report += " |`n"
}
$report | Out-File -FilePath warnings.md -Encoding utf8
