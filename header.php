<?php
session_start();

$timeout_duration = 3600;

if (isset($_SESSION['last_activity'])) {
    $elapsed_time = time() - $_SESSION['last_activity'];
    if ($elapsed_time >= $timeout_duration) {
        session_unset();
        session_destroy();
        header("Location: /Merchant-Tool/");
        exit();
    }
}

$_SESSION['last_activity'] = time();

if (!isset($_SESSION['user_id'])) {
    header("Location: /Merchant-Tool/");
    exit();
}

$name = $_SESSION['name'] ?? '';

include_once($_SERVER['DOCUMENT_ROOT'] . '/Merchant-Tool/inc/config.php');

$user_id = $_SESSION['user_id'];

$escaped_user_id = mysqli_real_escape_string($conn, $user_id);

$sql = "SELECT * FROM user WHERE user_id = '$escaped_user_id'";
$result = mysqli_query($conn, $sql);

if ($result && mysqli_num_rows($result) > 0) {
    $user_data = mysqli_fetch_assoc($result);
    $type = $user_data['type'];
    $name = $user_data['name'];
    $user_id = $user_data['user_id'];
} else {
    $type = 'unknown';
}

$initial = strtoupper($name[0]);

if (preg_match('/^[Ñ0-9\W]/u', $initial)) {
    $image = 'unknown.png';
} else {
    $image_map = [
        'A' => 'A.png',
        'B' => 'B.png',
        'C' => 'C.png',
        'D' => 'D.png',
        'E' => 'E.png',
        'F' => 'F.png',
        'G' => 'G.png',
        'H' => 'H.png',
        'I' => 'I.png',
        'J' => 'J.png',
        'K' => 'K.png',
        'L' => 'L.png',
        'M' => 'M.png',
        'N' => 'N.png',
        'Ñ' => 'Ñ.png',
        'O' => 'O.png',
        'P' => 'P.png',
        'Q' => 'Q.png',
        'R' => 'R.png',
        'S' => 'S.png',
        'T' => 'T.png',
        'U' => 'U.png',
        'V' => 'V.png',
        'W' => 'W.png',
        'X' => 'X.png',
        'Y' => 'Y.png',
        'Z' => 'Z.png',
    ];
    $image = isset($image_map[$initial]) ? $image_map[$initial] : 'unknown.png';
}

if ($type === 'User' && strpos($_SERVER['REQUEST_URI'], '/users') !== false) {
    header("Location: /Merchant-Tool/access_denied.php");
    exit();
}

if ($type === 'User' && strpos($_SERVER['REQUEST_URI'], '/activity_history') !== false) {
    header("Location: /Merchant-Tool/access_denied.php");
    exit();
}
?>

<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="icon" href="/Merchant-Tool/images/booky1.png" type="image/x-icon" />
    <link href='https://fonts.googleapis.com/css?family=Open+Sans' rel='stylesheet'>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-rbsA2VBKQhggwzxH7pPCaAqO46MgnOM80zW1RWuH61DGLwZJEdK2Kadq2F9CUG65" crossorigin="anonymous">
    <script src="https://kit.fontawesome.com/d36de8f7e2.js" crossorigin="anonymous"></script>
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Nanum+Gothic&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200" />
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Nunito:ital,wght@0,200..1000;1,200..1000&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="style.css">
    <style>
        .nav-link {
            font-weight: 700;
            font-style: normal;
            font-size: 12px;
        }

        .active_nav {
            color: #fff !important;
            border: solid #4BB0B8 2px !important;
            border-radius: 30px !important;
            background-color: #4BB0B8 !important;
            box-shadow: 0px 2px 5px 0px rgba(0, 0, 0, 0.27) inset !important;
            -webkit-box-shadow: 0px 2px 5px 0px rgba(0, 0, 0, 0.27) inset !important;
            -moz-box-shadow: 0px 2px 5px 0px rgba(0, 0, 0, 0.27) inset !important;
        }

        .dropdown-toggle::after {
            display: none;
        }

        a#navbarDropdownMenuLink.nav-link.mx-2.dropdown-toggle::after {
            display: none;
        }

        .profile-initial {
            background-color: #fff;
            color: #4BB0B8;
            display: flex;
            justify-content: center;
            align-items: center;
            font-size: 21px;
            font-weight: 800;
            border-radius: 50%;
            height: 30px;
            width: 30px;
            border: solid #fff 2px;
            box-shadow: 0px 1px 5px 0px rgba(0, 0, 0, 0.27) inset;
            -webkit-box-shadow: 0px 1px 5px 0px rgba(0, 0, 0, 0.27) inset;
            -moz-box-shadow: 0px 1px 5px 0px rgba(0, 0, 0, 0.27) inset;
            background-image: url('<?php echo '/Merchant-Tool/images/Initials/' . $image; ?>');
            background-size: cover;
            background-position: center;
        }

        #booky{
            font-weight:1000 !important;
            color:#fff;
            font-size:23px !important;
            padding-top:1px;
        }

        #leadgen{
            font-size:13px;
            padding-top:4px;
            font-family: Nanum Gothic;
        }
        #lead{
            display: none;
        }
        @media only screen and (max-width: 767px) {
        #booky{
            font-size:18px !important;
        }
        #leadgen{
            display: none;
        }
        #lead{
            display:inline;
            padding-left: 8px;
            margin-bottom:15px;
        }
        }
    </style>
</head>
<body>
<nav class="navbar navbar-expand-lg navbar-dark p-3">
    <div class="container-fluid">
        <a class="navbar-brand" href="/Merchant-tool/merchant/">
            <table style="border:10px;">
                <tr>
                    <th id="booky">booky <span id="div" style="font-size:25px;font-weight:normal;">|<span id="lead">LEADGEN</span></span></th>
                    <th id="leadgen">&nbsp; LEADGEN</th>
                </tr>
            </table>
        </a>
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNavDropdown" aria-controls="navbarNavDropdown" aria-expanded="false" aria-label="Toggle navigation">
            <span class="navbar-toggler-icon"></span>
        </button>

        <div class="collapse navbar-collapse" id="navbarNavDropdown">
            <ul class="navbar-nav ms-auto">
                <li class="nav-item">
                    <a id="merchant-link" class="nav-link mx-2" aria-current="page" href="/Merchant-Tool/merchants/" style="padding-right:10px;padding-left:10px;">Merchants</a>
                </li>
                <li class="nav-item">
                    <a id="store-link" class="nav-link mx-2" aria-current="page" href="/Merchant-Tool/stores/" style="padding-right:10px;padding-left:10px;">Stores</a>
                </li>
                <li class="nav-item">
                    <a id="promo-link" class="nav-link mx-2" aria-current="page" href="/Merchant-Tool/promos/" style="padding-right:10px;padding-left:10px;">Promos</a>
                </li>
                <li class="nav-item">
                    <a id="pg-link" class="nav-link mx-2" aria-current="page" href="/Merchant-Tool/fees/" style="padding-right:10px;padding-left:10px;">Fees</a>
                </li>
                <li class="nav-item">
                    <a id="transaction-link" class="nav-link mx-2" aria-current="page" href="/Merchant-Tool/transactions/" style="padding-right:10px;padding-left:10px;">Transactions</a>
                </li>
            </ul>
            <ul class="navbar-nav ms-auto d-lg-inline-flex">
                <li class="nav-item dropdown">
                    <a class="nav-link mx-2 dropdown-toggle d-flex align-items-center" href="#" id="navbarDropdownMenuLink" role="button" data-bs-toggle="dropdown" aria-expanded="false">
                        <div class="d-flex align-items-center">
                            <div class="profile-initial">
                               
                            </div>
                            <span style="color:#fff;padding-left:5px;font-weight:700;"><?php echo ' ' . htmlspecialchars($name); ?></span>
                        </div>
                    </a>
                    <ul class="dropdown-menu dropdown-menu-end" aria-labelledby="navbarDropdownMenuLink">
                        <li><a class="dropdown-item" href="/Merchant-Tool/profile"><i class="fa-solid fa-pen-to-square"></i> Edit Profile</a></li>
                        <?php if ($type !== 'User') : ?>
                            <li><a class="dropdown-item" href="/Merchant-Tool/users/"><i class="fa-solid fa-users"></i> Manage Users</a></li>
                            <li><a class="dropdown-item" href="/Merchant-Tool/activity_history/"><i class="fa-solid fa-user-clock"></i> Activity History</a></li>
                        <?php endif; ?>
                        <li><a class="dropdown-item" href="/Merchant-Tool/logout.php"><i class="fa-solid fa-right-from-bracket"></i> Logout</a></li>
                    </ul>
                </li>
            </ul>
        </div>
    </div>
</nav>
<script>
    document.addEventListener('DOMContentLoaded', function() {
        var currentPage = window.location.href;
        var merchantLink = document.getElementById('merchant-link');
        var transactionLink = document.getElementById('transaction-link');
        var pgLink = document.getElementById('pg-link');
        var storeLink = document.getElementById('store-link');
        var promoLink = document.getElementById('promo-link');

        if (currentPage.includes('merchants/'))  {
            merchantLink.classList.add('active_nav');
        } else if (currentPage.includes('transactions/')) {
            transactionLink.classList.add('active_nav');
        } else if (currentPage.includes('fees/')) {
            pgLink.classList.add('active_nav');
        } else if (currentPage.includes('stores/')) {
            storeLink.classList.add('active_nav');
        } else if (currentPage.includes('promos/')) {
            promoLink.classList.add('active_nav');
        }

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

        var timeout;
        var timeoutDuration = 10000000;
                              
        function resetTimeout() {
            clearTimeout(timeout);
            timeout = setTimeout(logout, timeoutDuration);
        }

        function logout() {
            window.location.href = '/Merchant-Tool/logout.php';
        }

        document.addEventListener('mousemove', resetTimeout);
        document.addEventListener('keydown', resetTimeout);
        document.addEventListener('scroll', resetTimeout);
        document.addEventListener('click', resetTimeout);

        resetTimeout();
    });
</script>
<script src="https://cdn.jsdelivr.net/npm/@popperjs/core@2.11.6/dist/umd/popper.min.js" integrity="sha384-oBqDVmMz9ATKxIep9tiCxS/Z9fNfEXiDAYTujMAeBAsjFuCZSmKbSSUnQlmh/jp3" crossorigin="anonymous"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/js/bootstrap.min.js" integrity="sha384-cuYeSxntonz0PPNlHhBs68uyIAVpIIOZZ5JqeqvYYIcEL727kskC66kF92t6Xl2V" crossorigin="anonymous"></script>
</body>
</html>
