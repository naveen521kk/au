<#
.SYNOPSIS
  Publishes the package update status to discord.

.PARAMETER WebHookUrl
  This is the webhook url created through discord.

.PARAMETER MessageFormat
  The format of the message that is meant to be published on Discord.
  {0} = The total number of automated packages.
  {1} = The number of updated packages,
  {2} = The number of published packages.
  {3} = The number of failed packages.
  {4} = The url to the github gist.
#>
param(
  $Info,
  [string]$WebHookUrl,
  [string]$MessageFormat = "[Update Status:{0} packages.`n  {1} updated, {2} Published, {3} Failed]({4})"
)

if (!$WebHookUrl) { return } # If we don't have a webhookurl we can't push status messages, so ignore.

$updatedPackages   = @($Info.result.updated).Count
$publishedPackages = @($Info.result.pushed).Count
$failedPackages    = $Info.error_count.total
$gistUrl           = $Info.plugin_results.Gist -split '\n' | select -Last 1
$packageCount      = $Info.result.all.Length

$discordMessage     = ($MessageFormat -f $packageCount, $updatedPackages, $publishedPackages, $failedPackages, $gistUrl)

$embeds            = @{
    "title"        = "AU update Status",
    "color"        = if ($failedPackages -gt 0) { "11111111" } else { "14177041" }
    "description"  = "$discordMessage"
    "url"          = "$gistUrl"
} | ConvertTo-Json

$Body              = @{
    username       = "Choco Bot"
    avatar_url     = "https://avatars2.githubusercontent.com/u/6270979"
    embeds         = "$embeds"
} | ConvertTo-Json

$arguments = @{
  Body             = $Body
  Uri              = $WebHookUrl
  ContentType      = 'application/json'
  Method           = 'Post'
}

"Submitting message to discord"
Invoke-WebRequest @arguments
"Message submitted to discord"
