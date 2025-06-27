# Function to download a page and save it as an HTML file
function Download-Page {
    param (
        [string]$BaseUrl,
        [int]$PageNumber
    )
    
    # Construct the URL with the given page number
    $PageUrl = "$BaseUrl?page=$PageNumber"
    #Write-Host "Downloading page: $PageUrl"
    
    # Send a GET request to the URL
    $webSession = New-Object Microsoft.PowerShell.Commands.WebRequestSession
    $Response = Invoke-WebRequest -Uri $PageUrl -WebSession $webSession
    
    # Check if the request was successful
    if ($Response.StatusCode -eq 200) {
        # Save the HTML content to a file
        $FilePath = "page_$PageNumber.html"
        $Response.Content | Out-File -FilePath $FilePath -Encoding utf8
        Write-Host "Page $PageNumber downloaded successfully."
    } else {
        Write-Host "Failed to download page $PageNumber. Status code: $($Response.StatusCode)"
    }
}

# Base URL
$BaseUrl = "https://naicslist.com/company-directory/state-va"

# Number of pages to download
$NumPages = 2

# Download each page
for ($Page = 1; $Page -le $NumPages; $Page++) {
    Write-Host "Downloading page $Page of $NumPages..."
    Download-Page -BaseUrl $BaseUrl -PageNumber $Page
}
