<?php include ("header.php") ?>
<?php

?>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Homepage</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet"
        integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH" crossorigin="anonymous">
    <link href='https://fonts.googleapis.com/css?family=Open Sans' rel='stylesheet'>
    <script src="https://kit.fontawesome.com/d36de8f7e2.js" crossorigin="anonymous"></script>
    <link rel='stylesheet' href='https://cdn.datatables.net/1.13.5/css/dataTables.bootstrap5.min.css'>
    <link rel='stylesheet' href='https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.6.3/css/font-awesome.min.css'>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/papaparse@5.3.0/papaparse.min.js"></script>
    <link rel="stylesheet" href="style.css">
    <style>
        body {
            background-image: url("images/bg_booky.png");
            background-position: center;
            background-repeat: no-repeat;
            background-size: cover;
            background-attachment: fixed;
        }

        .title {
            font-size: 30px;
            font-weight: bold;
            margin-right: auto;
            padding-left: 5vh;
            color: #E96529;
        }

        .back {
            font-size: 20px;
            font-weight: bold;
            margin-right: auto;
            padding-left: 5vh;
            color: #E96529;
        }
    </style>
</head>

<body>

    <div class="cont-box">
        <div class="custom-box pt-4">
                <div class="upload pt-4" style="text-align:left;">
                <div class="add-btns">
                    <p class="title">Profile</p>
                </div>

                <div class="content" style="width:95%;margin-left:auto;margin-right:auto;margin-bottom:40px; background-color:#fff;border-left: 5px solid #E96529;border-radius:10px;padding:5px;">
                <div class="container mt-3">
        <h2 class="mb-4">BUNCAG, JERICO ANGOLLUAN (2020-06784-MN-0)</h2>
        <hr style="border: 1px solid #3b3b3b !important;">
        <div class="row">
            <div class="col-md-6">
                <div class="form-group">
                    <label for="studentNumber">Student Number</label>
                    <input type="text" class="form-control" id="studentNumber" value="2020-06784-MN-0" readonly>
                </div>
                <div class="form-group">
                    <label for="name">Name</label>
                    <input type="text" class="form-control" id="name" value="BUNCAG, JERICO ANGOLLUAN" readonly>
                </div>
                <div class="form-group">
                    <label for="gender">Gender</label>
                    <input type="text" class="form-control" id="gender" value="Male" readonly>
                </div>
                <div class="form-group">
                    <label for="dateOfBirth">Date of Birth</label>
                    <input type="text" class="form-control" id="dateOfBirth" value="March 01, 2003" readonly>
                </div>
                <div class="form-group">
                    <label for="placeOfBirth">Place of Birth</label>
                    <input type="text" class="form-control" id="placeOfBirth" value="SAN JOSE DEL MONTE, BULACAN" readonly>
                </div>
                <div class="form-group">
                    <label for="mobileNumber">Mobile No.</label>
                    <input type="text" class="form-control" id="mobileNumber" value="09054153618" readonly>
                </div>
                <div class="form-group">
                    <label for="emailAddress">Email Address</label>
                    <input type="email" class="form-control" id="emailAddress" value="jericobuncag0@gmail.com" readonly>
                </div>
            </div>
            <div class="col-md-6">
                <div class="form-group">
                    <label for="residentialAddress">Residential Address</label>
                    <textarea class="form-control" id="residentialAddress" rows="3" readonly>34 C SALALILLA ST., PROJECT 4 QUEZON CITY MANILA, CITY OF, METROPOLITAN MANILA</textarea>
                </div>
                <div class="form-group">
                    <label for="permanentAddress">Permanent Address</label>
                    <textarea class="form-control" id="permanentAddress" rows="3"></textarea>
                </div>
                <div class="form-group">
                    <label for="provincialAddress">Provincial Address</label>
                    <textarea class="form-control" id="provincialAddress" rows="3"></textarea>
                </div>
                <div class="form-group">
                    <label for="spouseName">Name of Spouse (if married)</label>
                    <input type="text" class="form-control" id="spouseName">
                </div>
            </div>
        </div>
        <div class="form-group mt-4">
            <textarea class="form-control" rows="3" readonly>I hereby certify that all the information provided are true and correct to the best of my knowledge.</textarea>
        </div>
        <div class="text-center mt-4">
            <button type="button" class="btn btn-primary">Save</button>
        </div>
    </div>
                </div>
        </div>
    </div>


   
</body>

</html>