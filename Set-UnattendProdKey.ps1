# Set the path to the unattended.xml file
$unattendedXmlPath = "C:\tools\auto.xml"

# Set the product key
$productKey = "WBYGB-TFMJ2-4DKK7-MYRGK-DYH2G"

# Load the unattended.xml file
$xml = [xml](Get-Content $unattendedXmlPath)

# Find the Microsoft-Windows-Setup node
$setupNode = $xml.SelectSingleNode("//Microsoft-Windows-Setup")

# Add the ProductKey node if it doesn't exist
if ($null -eq $setupNode.ProductKey) {
    $productKeyNode = $xml.CreateElement("ProductKey")
    $setupNode.AppendChild($productKeyNode)
}

# Set the product key value
$setupNode.ProductKey.InnerText = $productKey

# Save the modified unattended.xml file
$xml.Save($unattendedXmlPath)