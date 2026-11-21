$ErrorActionPreference = 'Stop'
$resourceRoot = Join-Path $PSScriptRoot '../android/app/src/main/res'
$androidNamespace = 'http://schemas.android.com/apk/res/android'

foreach ($layoutName in @('usage_widget')) {
    $document = [xml][System.IO.File]::ReadAllText((Join-Path $resourceRoot "layout/$layoutName.xml"))
    $namespaces = New-Object System.Xml.XmlNamespaceManager($document.NameTable)
    $namespaces.AddNamespace('android', $androidNamespace)
    $score = $document.SelectSingleNode('//*[@android:id="@+id/widget_score_text"]', $namespaces)
    if ($null -ne $score) {
        throw "$layoutName must not display a score."
    }
    $quote = $document.SelectSingleNode('//*[@android:id="@+id/widget_mood_quote"]', $namespaces)
    if ($null -eq $quote) { throw "$layoutName has no mood quote." }
    if ($quote.ParentNode -ne $document.DocumentElement) {
        throw 'The caption must sit below the icon and use the full card width.'
    }
    if ($document.SelectNodes('//ProgressBar').Count -ne 0) { throw 'The old progress bar is back.' }
}
foreach ($localeName in @('values', 'values-vi')) {
    $strings = [xml][System.IO.File]::ReadAllText((Join-Path $resourceRoot "$localeName/strings.xml"))
    foreach ($quote in ($strings.resources.string | Where-Object { $_.name -like 'widget_quote_*' })) {
        if (($quote.InnerText.Trim() -split '\s+').Count -gt 2) {
            throw "Mood captions must stay within two words: $($quote.name)"
        }
    }
}
$info = [xml][System.IO.File]::ReadAllText((Join-Path $resourceRoot 'xml/usage_widget_info.xml'))
if ($info.DocumentElement.GetAttribute('targetCellWidth', $androidNamespace) -ne
    $info.DocumentElement.GetAttribute('targetCellHeight', $androidNamespace)) {
    throw 'The default widget must occupy a square grid.'
}
Write-Output 'Widget passed: square grid, icon above caption, two-word captions, no score or progress bar.'
