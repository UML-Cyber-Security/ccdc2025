# Define the output CSV file
$outputFile = "C:\validTaskSchedulerXREF.csv"

# Fetch scheduled tasks using Get-ScheduledTask cmdlet
$tasks = Get-ScheduledTask | ForEach-Object {
    $task = $_
    $actions = $task.Actions | ForEach-Object {
        $_ | Select-Object -Property Command, Arguments
    }

    [PSCustomObject]@{
        TaskName    = $task.TaskName
        TaskPath    = $task.TaskPath
        Description = ($task.Settings.Description -join "`n")  # Handle multi-line descriptions
        Actions     = $actions.Command -join "; "
        Arguments   = $actions.Arguments -join "; "
    }
}

# Export to CSV
$tasks | Export-Csv -Path $outputFile -NoTypeInformation -Force

Write-Host "Autoruns have been exported to $outputFile"
