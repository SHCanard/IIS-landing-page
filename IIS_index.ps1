# Run with elevated permissions
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
{
  # Relaunch as an elevated process:
  Start-Process powershell.exe "-File",('"{0}"' -f $MyInvocation.MyCommand.Path) -Verb RunAs
  exit
}

import-Module WebAdministration

$Domain="domain.com"

$HTMLfile="C:\inetpub\wwwroot\index.html"
Remove-Item –path $HTMLfile

# Define image to use for app tiles
$App1Imagefile="App1.png"
$App1Imagealt="App1"
$App2Imagefile="App2.svg"
$App2Imagealt="App2"
$App3Imagefile="App3.png"
$App3Imagealt="App3"

$HTML='<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    
    <!-- Website Title -->
    <title>IIS Landing Page</title>
    
    <!-- Styles -->
    <link href="https://fonts.googleapis.com/css?family=Raleway:400,400i,600,700,700i&amp;subset=latin-ext" rel="stylesheet">
    <link href="css/bootstrap.css" rel="stylesheet">
	<link href="css/styles.css" rel="stylesheet">
	
	<!-- Favicon  -->
    <link rel="icon" href="images/myorg.png">
</head>
<body data-spy="scroll" data-target=".fixed-top">
    
    <!-- Preloader -->
	<div class="spinner-wrapper">
        <div class="spinner">
            <div class="bounce1"></div>
            <div class="bounce2"></div>
            <div class="bounce3"></div>
        </div>
    </div>
    <!-- end of preloader -->
    

    <!-- Navigation -->
    <nav class="navbar navbar-expand-lg navbar-dark navbar-custom fixed-top">

        <!-- Image Logo -->
        <a class="navbar-brand logo-image" href="index.html"><img src="images/myorg.png" alt="myorg"></a><h1>MyOrg</h1>
        </div>
    </nav> <!-- end of navbar -->
    <!-- end of navigation -->


    <!-- Header -->
    <header id="header" class="header">
        <div class="header-content">
            <div class="container">
                <div class="row">
                    <div class="col-lg-6">
                        <div class="text-container">
                            <h1><span class="turquoise">IIS Landing Page</span></h1>
                            <p class="p-large">This is an index of sites available on this server.</br>Please scroll down.</p>
                           <!--  <a class="btn-solid-lg page-scroll" href="#services">DISCOVER</a> -->
                        </div> <!-- end of text-container -->
                    </div> <!-- end of col -->
                    <div class="col-lg-6">
                        <div class="image-container">
                            <img class="img-fluid" src="images/header-teamwork.svg" alt="alternative">
                        </div> <!-- end of image-container -->
                    </div> <!-- end of col -->
                </div> <!-- end of row -->
            </div> <!-- end of container -->
        </div> <!-- end of header-content -->
    </header> <!-- end of header -->
    <!-- end of header -->

    <!-- Services -->
    <div id="services" class="cards-1">
        <div class="container">
            <div class="row">
                <div class="col-lg-12">
                    <h2>List of sites available</h2>
                    <p class="p-heading p-large"></p>
                </div> <!-- end of col -->
            </div> <!-- end of row -->
            <div class="row">
                <div class="col-lg-12">
                
                '

$Websites = Get-ChildItem IIS:\Sites

foreach($Site in $Websites) {
    $Sitenames = Get-WebApplication -Site $Site.name | select @{e={$_.Path.Trim('/')};l="Name"} | Sort-Object -Property Name
    foreach($Rawname in $Sitenames) {
        $Name=$Rawname | ft -hide | out-string
        $Name=$Name.Trim()
		switch ( $Name ) {
			{$_ -match "App1"} {
				if ($Name -notmatch "\d{3,}-\d+") { # Exclude app names containing version
					$Spacedname=$Name.Replace("_"," ")
					$HTML +="<a href=""https://" + $env:computername + "." + $Domain + "/" + $Name + "/"">
					<div class=""card"">
					<img class=""card-image"" src=""images/" + $App1Imagefile + """ alt=" + $App1Imagealt + ">
					<div class=""card-body"">
					<h4 class=""card-title"">" + $Spacedname + "</h4>
					</div>
					</div>
					</a>"
				}
			}
			{$_ -match "App2"} {
				$Spacedname=$Name.Replace("_"," ")
				$HTML +="<a href=""https://" + $env:computername + "." + $Domain + "/" + $Name + "/"">
				<div class=""card"">
				<img class=""card-image"" src=""images/" + $App2Imagefile + """ alt=" + $App2Imagealt + ">
				<div class=""card-body"">
				<h4 class=""card-title"">" + $Spacedname + "</h4>
				</div>
				</div>
				</a>"
			}
			{$_ -match "App3"} {
				if ($Name -match "\d{3,}-\d+") { # Exclude app names not containing version
					$Spacedname=$Name.Replace("_"," ")
					$HTML +="<a href=""https://" + $env:computername + "." + $Domain + "/" + $Name + "/"">
					<div class=""card"">
					<img class=""card-image"" src=""images/" + $App3Imagefile + """ alt=" + $App3Imagealt + ">
					<div class=""card-body"">
					<h4 class=""card-title"">" + $Spacedname + "</h4>
					</div>
					</div>
					</a>"
				}
			}
		}
        
    }
      
}

$HTML += '</div> <!-- end of col -->
            </div> <!-- end of row -->
        </div> <!-- end of container -->
    </div> <!-- end of cards-1 -->
    <!-- end of services -->

    <!-- Copyright -->
    <div class="copyright">
        <div class="container">
            <div class="row">
                <div class="col-lg-12">
                    <p class="p-small">Copyright &#169; MyOrg - IIS HTML Landing Page</p>
                </div> <!-- end of col -->
            </div> <!-- enf of row -->
        </div> <!-- end of container -->
    </div> <!-- end of copyright --> 
    <!-- end of copyright -->
    
    	
    <!-- Scripts -->
    <script src="js/jquery.min.js"></script> <!-- jQuery for Bootstraps JavaScript plugins -->
    <script src="js/scripts.js"></script> <!-- Custom scripts -->
</body>
</html>'

$HTML | Add-Content -Path $HTMLfile