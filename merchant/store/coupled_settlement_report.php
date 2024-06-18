<?php
$merchant_id = isset($_GET['merchant_id']) ? $_GET['merchant_id'] : '';
$merchant_name = isset($_GET['merchant_name']) ? $_GET['merchant_name'] : '';
$store_name = isset($_GET['store_name']) ? $_GET['store_name'] : '';
$legal_entity_name = isset($_GET['legal_entity_name']) ? $_GET['legal_entity_name'] : '';
$store_address = isset($_GET['store_address']) ? $_GET['store_address'] : '';
?>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Merchant Settlement Tool</title>
  <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/5.0.0-alpha1/css/bootstrap.min.css">
  <link rel="icon" href="/Merchant-Tool/images/booky1.png" type="image/x-icon" />
  <script src="https://cdnjs.cloudflare.com/ajax/libs/pdfmake/0.1.68/pdfmake.min.js"></script>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/pdfmake/0.1.68/vfs_fonts.js"></script>
  <script src="https://kit.fontawesome.com/d36de8f7e2.js" crossorigin="anonymous"></script>
  <link href="https://fonts.googleapis.com/css2?family=Nunito:ital,wght@0,500;1,500&family=Poppins:ital,wght@0,100;0,200;0,300;0,400;0,500;0,600;0,700;0,800;0,900;1,100;1,200;1,300;1,400;1,500;1,600;1,700;1,800;1,900&display=swap" rel="stylesheet">
  <link href="https://fonts.googleapis.com/css2?family=Nanum+Gothic&display=swap" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-rbsA2VBKQhggwzxH7pPCaAqO46MgnOM80zW1RWuH61DGLwZJEdK2Kadq2F9CUG65" crossorigin="anonymous">
  <style>
    *{
  font-family: "Nunito", sans-serif;
  font-size: 10px;
  margin:0;
  padding:0;
}
    body{
      background-color:	#636363;
    }
    .container {
      background-color:	#fff;
      box-shadow: 1px 2px 6px 2px rgba(0,0,0,0.50);
      -webkit-box-shadow: 1px 2px 6px 2px rgba(0,0,0,0.50);
      -moz-box-shadow: 1px 2px 6px 2px rgba(0,0,0,0.50);
      height:1100px;
      width:850px;
      margin-top:120px;
      margin-bottom:50px;
    }

    #downloadBtn {
      padding: 8px 20px;
      background-color: #4BB0B8;
      color: #fff;
      border: none;
      border-radius: 20px;
      cursor: pointer;
      font-size: 13px;
      transition: background-color 0.3s ease;
    }

    nav{
      box-shadow: 1px 2px 6px 2px rgba(0,0,0,0.25);
      -webkit-box-shadow: 1px 2px 6px 2px rgba(0,0,0,0.25);
      -moz-box-shadow: 1px 2px 6px 2px rgba(0,0,0,0.25);
    }

    p { 
   padding:0px; 
   margin:4px; 
} 
  </style>
</head>
<body>
<nav class="navbar navbar-expand-lg navbar-dark bg-dark pt-3 pb-3 pl-3 pr-3 fixed-top">
  <div class="container-fluid">
  <a class="navbar-brand" href="/Merchant-tool/merchant/">
        <table style="border:10px;">
        <tr>
        <th style="font-weight:900 !important;font-size:23px !important;padding-top:1px;">booky <span style="font-size:25px;font-weight:normal;">|</span></th>
        <th style="font-size:13px;padding-top:4px;font-family: Nanum Gothic">&nbsp; LEADGEN <i class="fa-solid fa-egg animated-egg"></i><t/h>
        </tr>
        </table>
        </a>
    <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav" aria-controls="navbarNav" aria-expanded="false" aria-label="Toggle navigation">
      <span class="navbar-toggler-icon"></span>
    </button>
    <div class="collapse navbar-collapse justify-content-end" id="navbarNav">
      <ul class="navbar-nav">
        <!-- Add your navigation items here if needed -->
      </ul>
      <a class="btn btn-primary" id="downloadBtn"  href="#"><i class="fa-solid fa-download"></i> Download</a>
    </div>
  </div>
</nav>

  
  <div class="container" style="padding:70px;" id="content">
  <p style="text-align:center;font-size:20px;font-weight:900;">SETTLEMENT REPORT</p>
    <p class="text-right" style="font-weight:bold;font-size:40px;">
      <img src="../../images/booky2.png" alt="booky" width="150" height="50">
    </p>
    <div class="row">
      <div class="col-8">
        <p>Business Name: <span style="margin-left:5px;font-weight:bold;"><?php echo htmlspecialchars($legal_entity_name); ?></span></p>
        <p>Brand Name: <span style="margin-left:20px;font-weight:bold;"><?php echo htmlspecialchars($store_name); ?></span></p>
        <p>Address: <span style="margin-left:40px;font-weight:bold;"><?php echo htmlspecialchars($store_address); ?></span></p>
      </div>
      <div class="col-4">
        <p>Settlement Date: <span style="margin-left:25px;font-weight:bold;">June 30, 2023</span></p>
        <p>Settlement Number: <span style="margin-left:5px;font-weight:bold;">2023-06-30-1</span></p>
        <p>Settlement Period: <span style="margin-left:15px;font-weight:bold;">June 29, 2023</span></p>
      </div>
    </div>
    <hr style="border: 1px solid #3b3b3b;">
    <div class="row">
      <div class="col">
        <p>Total Number of Successful Orders</p>
        <br>
        <p>Total Gross Sales</p>
        <p>Total Discount</p>
        <p style="font-weight:bold;">Totals Outstanding Amount</p>
      </div>
      <div class="col text-right">
        <p style="font-weight:bold;padding-right:80px;">34 order/s</p>
        <br>
        <p style="padding-right:80px;">70,591.00 PHP</p>
        <p style="padding-right:80px;">31,196.00 PHP</p>
        <p style="font-weight:bold;padding-right:80px;">39,395.00 PHP</p>
      </div>
    </div>
    <hr style="border: 1px solid #3b3b3b;">
    <div class="row">
      <div class="col">
        <p>Commission Fees</p>
        <p style="padding-left:80px;">Leadgen Commission rate base</p>
        <p style="padding-left:80px;">Commission fee rate</p>
        <p style="padding-left:80px;font-weight:bold;">Total</p>
      </div>
      <div class="col text-right" style="padding-right:90px;">
        <p>.</p>
        <p>800.00</p>
        <p>10%</p>
        <p style="font-weight:bold;">39,395.00 PHP</p>
      </div>
    </div>
    <div class="row">
      <div class="col">
        <p style="font-weight:bold;">Total Commision Fees</p>
        <p style="padding-left:80px;">Payment Gateway Fees:</p>
        <br>
        <p style="padding-left:80px;">Paymaya</p>
        <p style="padding-left:80px;">Paymaya_credit_card</p>
        <p style="padding-left:80px;">Maya</p>
        <p style="padding-left:80px;">Maya_checkout</p>
        <p style="padding-left:80px;">Gcash_miniapp</p>
        <p style="padding-left:80px;">GCash</p>
        <p style="padding-left:80px;font-weight:bold;">Total Payment Gateway Fees</p>
      </div>
      <div class="col text-right" style="padding-right:90px;">
        <p style="font-weight:bold;">89.60 PHP</p>
        <p>.</p>
        <br>
        <p>24.00</p>
        <p>0.00</p>
        <p>0.00</p>
        <p>0.00</p>
        <p style="font-weight:bold;">24.00 PHP</p>
      </div>
    </div>
    <hr style="border: 1px solid #3b3b3b !important;">
    <div class="row">
      <div class="col">
        <p>Total Outstanding Amount</p>
        <p>Less:<span style="padding-left:50px;">Total Commission Fees</span></p>
        <p style="padding-left:75px;">Total Payment Gateway Fees</p>
        <p style="padding-left:75px;">Bank Fees</p>
        <p style="padding-left:75px;">CWT from Gross Sales</p>
        <p>Add:<span style="padding-left:54px;">CWT from Transaction Fees</span></p>
        <p style="padding-left:75px;">CWT from PG Fees</p>
        <br>
        <p style="font-weight:bold;">Total Amount Paid Out</p>
      </div>
      <div class="col text-right" style="padding-right:90px;">
        <p>800.00 PHP</p>
        <p>89.60 PHP</p>
        <p>24.00 PHP</p>
        <p>10 PHP</p>
        <p>0.88 PHP</p>
        <p>1.60</p>
        <p>0.43</p>
        <br>
        <p style="font-weight:bold;">677.55 PHP</p>
      </div>
    </div>
    <hr style="border: 1px solid #3b3b3b;">
    <p>This is a system generated report and doesn't require a signature. If you have questions feel free to contact us at 632-34917659 loc. 7663 or email us at accounting@phonebooky.com</p>
    <br>
    <p>Scrambled Eggs Software Inc.	</p>
    <p>Unit D1 2/F 603 REY-D BUILDING	</p>
    <p>San Rafael St. cor. Boni Avenue Bgy. Plainview Mandaluyong City 1550 Philippines</p>			
    <p>T: (632) 34917659	</p>	
  </div>
  <script src=
"https://cdnjs.cloudflare.com/ajax/libs/html2pdf.js/0.9.2/html2pdf.bundle.min.js">
    </script>

<script>
  const download_button = document.getElementById('downloadBtn');
  const content = document.getElementById('content');

  download_button.addEventListener('click', async function () {
    // Set the filename dynamically based on the store name
    const filename = '<?php echo htmlspecialchars($store_name) ?>.pdf';

    try {
      const opt = {
        margin: [-1.5, -0.2, 0, 0], // Top, left, bottom, right margins
        filename: filename,
        image: { type: 'jpeg', quality: 0.98 },
        html2canvas: { scale: 2 },
        jsPDF: { unit: 'in', format: 'letter', orientation: 'portrait' }
      };
      await html2pdf().set(opt).from(content).save();
    } catch (error) {
      console.error('Error:', error.message);
    }
  });
</script>


</body>
</html>
