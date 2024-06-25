<?php
// Include the configuration file
include('../../inc/config.php');

$decoupled_report_id = isset($_GET['decoupled_report_id']) ? $_GET['decoupled_report_id'] : '';

// Fetch data from the database
$sql = "SELECT * FROM report_history_decoupled WHERE decoupled_report_id = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("s", $decoupled_report_id);
$stmt->execute();
$result = $stmt->get_result();
$data = $result->fetch_assoc();
$stmt->close();
$conn->close();

$totalGrossSales = number_format($data['total_gross_sales'], 2);
$totalDiscount = number_format($data['total_discount'], 2);
$totalNetSales = number_format($data['total_net_sales'], 2);
$leadgenCommissionRateBasePretrial = number_format($data['leadgen_commission_rate_base_pretrial'], 2); 
$leadgenCommissionRateBaseBillable = number_format($data['leadgen_commission_rate_base_billable'], 2); 
$totalPretrial = number_format($data['total_pretrial'], 2);
$totalBillable = number_format($data['total_billable'], 2);
$totalCommissionFees = number_format($data['total_commission_fees'], 2);
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
  font-size: 11px;
  margin:0;
  padding:0;
}
    body{
      background-color:	#636363;
    }

    td{
      padding-top:2px;
      padding-bottom:2px;
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
    <table style="width:100% !important;">
    <tr >
          <td>Business Name: <span style="margin-left:15px;font-weight:bold;"><?php echo htmlspecialchars($data['merchant_business_name']); ?></span></td>
          <td style="width:40%;">Settlement Date: <span style="margin-left:21px;font-weight:bold;"><?php echo htmlspecialchars($data['settlement_date']); ?></span></td>
      </tr>
      <tr>
          <td>Brand Name: <span style="margin-left:29px;font-weight:bold;"><?php echo htmlspecialchars($data['merchant_brand_name']); ?></span></td>
          <td>Settlement Number: <span style="margin-left:5px;font-weight:bold;"><?php echo htmlspecialchars($data['settlement_number']); ?></span></td>
      </tr>
      <tr>
          <td>Business Address: <span style="margin-left:2px;font-weight:bold;"><?php echo htmlspecialchars($data['business_address']); ?></span></td>
          <td>Settlement Period: <span style="margin-left:15px;font-weight:bold;"><?php echo htmlspecialchars($data['settlement_period']); ?></span></td>
      </tr>
    </table>
    <hr style="border: 1px solid #3b3b3b;">
    <table style="width:100% !important;">
      <tr>
          <td>Total Number of Successful Orders</td>
          <td id="total_successful_orders" style="width:30%;text-align:center;"><?php echo htmlspecialchars($data['total_successful_orders']); ?> order/s</td>
      </tr>
    </table>
    <br>
    <table style="width:100% !important;">
      <tr>
          <td>Total Gross Sales</td>
          <td id="total_gross_sales" style="width:30%;text-align:center;"><?php  echo $totalGrossSales; ?> PHP</td>
      </tr>
      <tr>
          <td>Total Discount</td>
          <td id="total_discount" style="width:30%;text-align:center;"><?php  echo $totalDiscount; ?> PHP</td>
      </tr>
      <tr>
          <td style="font-weight:bold;">Total Net Sales:</td>
          <td id="total_net_sales" style="font-weight:bold;text-align:center;"><?php  echo $totalNetSales; ?> PHP</td>
      </tr>
    </table>
    <hr style="border: 1px solid #3b3b3b;">

    <table style="width:100% !important;">
      <tr>
          <td>Commission Fees</td>
          <td></td>
      </tr>
    </table>

    <table style="width:100% !important;">
      <tr>
          <td style="padding-left:85px;">Leadgen  Commission rate base(Pre-Trial)</td>
          <td id="leadgen_commission_rate_base_pretrial" style="width:30%;text-align:right;padding-right:85px;"><?php echo $leadgenCommissionRateBasePretrial; ?></td>
      </tr>
      <tr>
          <td style="padding-left:85px;">Commission fee rate</td>
          <td id="commission_rate_pretrial" style="text-align:right;padding-right:85px;"><?php echo htmlspecialchars($data['commission_rate_pretrial']); ?></td>
      </tr>
      <tr>
          <td style="font-weight:bold;padding-left:85px;">Total</td>
          <td id="total_pretrial" style="font-weight:bold;text-align:right;padding-right:85px;"><?php echo $totalPretrial; ?> PHP</td>
      </tr>
    </table>
    <br>      
  
<table style="width:100% !important;">
      <tr>
          <td style="padding-left:85px;">Leadgen  Commission rate base(Billable)</td>
          <td id="leadgen_commission_rate_base_billable" style="text-align:right;padding-right:85px;"><?php echo $leadgenCommissionRateBaseBillable; ?></td>
      </tr>
      <tr>
          <td style="padding-left:85px;">Commission fee rate</td>
          <td id="commission_rate_billable" style="text-align:right;padding-right:85px;"><?php echo htmlspecialchars($data['commission_rate_billable']); ?></td>
      </tr>
      <tr>
          <td style="font-weight:bold;padding-left:85px;">Total</td>
          <td id="total_billable" style="text-align:right;padding-right:85px;font-weight:bold;"><?php echo $totalBillable; ?></td>
      </tr>
    </table>
    <br>
    <table style="width:100% !important;">
      <tr>
          <td style="font-weight:bold;">Total Commision Fees:</td>
          <td id="total_commission_fees" style="font-weight:bold;text-align:right;padding-right:85px;"><?php echo $totalCommissionFees; ?> PHP</td>
      </tr>
</table>  
  

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
    const filename = '<?php echo htmlspecialchars($data['merchant_business_name']); ?>_<?php echo htmlspecialchars($data['settlement_number']); ?>.pdf';

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
