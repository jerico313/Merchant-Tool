<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="icon" href="/Merchant-Tool/images/booky1.png" type="image/x-icon" />
    <title>Merchant Settlement Tool</title>
    <link href='https://fonts.googleapis.com/css?family=Open Sans' rel='stylesheet'>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-rbsA2VBKQhggwzxH7pPCaAqO46MgnOM80zW1RWuH61DGLwZJEdK2Kadq2F9CUG65" crossorigin="anonymous">
    <script src="https://kit.fontawesome.com/d36de8f7e2.js" crossorigin="anonymous"></script>
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Nanum+Gothic&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200" />

    <link rel="stylesheet" href="style.css">
    <style>      
      .navbar a {
        font-size: 13px !important;
      }

      .active_nav{
        color:#fff !important;
        border:solid #4BB0B8 2px !important ;
        border-radius: 30px !important;
      } 
      

@keyframes roll {
    0% { transform: translateX(0) rotate(0deg); }
    20% { transform: translateX(50px) rotate(90deg); }
    40% { transform: translateX(100px) rotate(180deg); }
    60% { transform: translateX(150px) rotate(270deg); }
    80% { transform: translateX(200px) rotate(360deg); }
    100% { transform: translateX(0px) rotate(450deg); }
}

.animated-egg {
    font-size: 15px;
    color: #fff;
    display: inline-block;
    animation: roll 8s linear infinite;
}
    </style>
</head>
<body>
<nav class="navbar navbar-expand-lg navbar-dark p-3">
    <div class="container-fluid">
        <a class="navbar-brand" href="/Merchant-tool/merchant/">
        <table style="border:10px;">
        <tr>
        <th style="font-weight:900 !important;color:#fff;font-size:23px !important;padding-top:1px;">booky <span style="font-size:25px;font-weight:normal;">|</span></th>
        <th style="font-size:13px;padding-top:4px;font-family: Nanum Gothic">&nbsp; LEADGEN <i class="fa-solid fa-egg animated-egg"></i><t/h>
        </tr>
        </table>
        </a>
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNavDropdown" aria-controls="navbarNavDropdown" aria-expanded="false" aria-label="Toggle navigation">
            <span class="navbar-toggler-icon"></span>
        </button>

        <div class=" collapse navbar-collapse" id="navbarNavDropdown">
            <ul class="navbar-nav ms-auto ">
                <li class="nav-item">
                    <a id="orders-link" class="nav-link mx-2" aria-current="page" href="/Merchant-Tool/merchant/"  style="padding-right:10px;padding-left:10px;">Merchant</a>
                </li>
                <li class="nav-item">
                    <a id="merchants-link" class="nav-link mx-2" aria-current="page" href="/Merchant-Tool/transaction/" style="padding-right:10px;padding-left:10px;">Transactions</a>
                </li>
                <li class="nav-item">
                    <a id="pg-link" class="nav-link mx-2" aria-current="page" href="/Merchant-Tool/fee/" style="padding-right:10px;padding-left:10px;">Payment Gateway</a>
                </li>
            </ul>
            <ul class="navbar-nav ms-auto d-none d-lg-inline-flex">
                <li class="nav-item dropdown">
                    <a class="nav-link mx-2 dropdown-toggle" href="#" id="navbarDropdownMenuLink" role="button" data-bs-toggle="dropdown" aria-expanded="false">
                        <i class="fa-solid fa-user fa-lg"></i>
                    </a>
                    <ul class="dropdown-menu dropdown-menu-end" aria-labelledby="navbarDropdownMenuLink">
                        <li><a class="dropdown-item" href="#"><i class="fa-solid fa-pen-to-square"></i> Edit Profile</a></li>
                        <li><a class="dropdown-item" href="logout.php"><i class="fa-solid fa-right-from-bracket"></i> Logout</a></li>
                        <li><a class="dropdown-item" href="/Merchant-Tool/activity_history/"><i class="fa-solid fa-user-clock"></i>  Activity History</a></li>
                    </ul>
                </li>
            </ul>
        </div>
    </div>
</nav>

<script>
    document.addEventListener('DOMContentLoaded', function() {
        // Get the current page URL
        var currentPage = window.location.href;

        // Get the navbar links
        var ordersLink = document.getElementById('orders-link');
        var merchantsLink = document.getElementById('merchants-link');
        var pgLink = document.getElementById('pg-link');

        // Set the active class based on the current page
        if (currentPage.includes('merchant/') || currentPage.includes('merchant/index.php') || currentPage.includes('store/index.php') || currentPage.includes('merchant/upload.php') || currentPage.includes('merchant/upload_process.php') || currentPage.includes('order/index.php') || currentPage.includes('promo/index.php') || currentPage.includes('category.php') || currentPage.includes('order/index.php')) {
            ordersLink.classList.add('active_nav');
        } else if (currentPage.includes('transaction/') || currentPage.includes('transaction/upload_transaction.php') || currentPage.includes('upload_transaction_process.php')) {
            merchantsLink.classList.add('active_nav');
        } else if (currentPage.includes('fee/')) {
            pgLink.classList.add('active_nav');
        }

        // Prevent default behavior of anchor tags
        var navbarLinks = document.querySelectorAll('.navbar-nav a');
        navbarLinks.forEach(function(link) {
            link.addEventListener('click', function(event) {
                event.preventDefault();
                var href = this.getAttribute('href');
                if (href) {
                    window.location.href = href;
                }
            });
        });
    });
</script>



<script src="https://cdn.jsdelivr.net/npm/@popperjs/core@2.11.6/dist/umd/popper.min.js" integrity="sha384-oBqDVmMz9ATKxIep9tiCxS/Z9fNfEXiDAYTujMAeBAsjFuCZSmKbSSUnQlmh/jp3" crossorigin="anonymous"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/js/bootstrap.min.js" integrity="sha384-cuYeSxntonz0PPNlHhBs68uyIAVpIIOZZ5JqeqvYYIcEL727kskC66kF92t6Xl2V" crossorigin="anonymous"></script>
</body>
</html>
