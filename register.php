<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <link rel="icon" href="/Merchant-Tool/images/booky1.png" type="image/x-icon" />
  <meta http-equiv="X-UA-Compatible" content="IE-edge">
  <meta name="viewport" content="width=device-width,initial-scale=1.0 ">
  <title> Login Form Merchant Tool</title>
  <link rel="stylesheet" href="style.css">
</head>
<style>
  *{
    margin: 0;
    padding: 0;
    box-sizing: border-box;
    font-family: "Nunito", sans-serif;
  }
  body {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 100vh;
  background: url('images/registerbg.png') no-repeat;
  background-size: cover;
  background-position: center;
    

}
.wrapper{
  width: 420px;
  background: transparent;
  
  color: #fff;
  border-radius: 10px;
  padding: 30px 40px;
}

.wrapper h1{
  font-size: 18px;
  font-weight: normal;
  text-align: center;
  margin:0 0 12px;
}
.wrapper h2{
  font-size: 15px;
  font-weight: medium;
  text-align: center;

}
.wrapper h3{
  font-size: 15px;
  text-align: center;
}

.wrapper .input-box {
  position: relative;
  width: 100%;
  height: 50px;
  margin: 28px 0;
  margin-top: 18px;
}

.input-box input {
  width: 100%;
  height: 100%;
  background: #fff;
  border: none;
  outline: none;
  border: 2px solid rgba(255, 255, 255, .2);
  border-radius: 40px;
  font-size: 16px;
  color: #2A3240;
  padding: 20px 45px 20px 20px;

}

.option {
  width: 100%;
  height: 100%;
  border: 2px solid rgba(255, 255, 255, .2);
  border-radius: 40px;
  border: none;
  outline: none;
  font-size: 16px;
  color: #2A3240;
  padding: 12px 55px 12px 18px;

}

.input-box input::placeholder{
color: #2A3240;

}

.input-box i {
  position: absolute;
  right: 20px;
  top: 50%;
  transform: translateY(-50%);
  font-size: 20px;
  }


.wrapper .remember-forgot{
  display: flex;
  justify-content: space-between;
  font-size: 14.5px;
  margin: -15px 0 15px;
  margin-top: 15px;
}

.remember-forgot label input{
  accent-color: #fff;
  margin-right: 3px;
}

.remember-forgot a{
  color: #fff;
  text-decoration: none;
}

.remember-forgot a:hover{
  text-decoration: underline;
}

.wrapper .btn{
  width: 100%;
  height: 45px;
  background: #4BB0B8;
  border: none;
  outline: none;
  border-radius: 40px;
  box-shadow: 0 0 10px rgba(0, 0, 0, .1);
  cursor: pointer;
  font-size: 16px;
  color: #fff;
  font-weight: 600;
  margin-top: 20px;
}

.wrapper .btn:hover{
  background-color: #E96529;
  color:#fff;
  border: 2px solid rgba(255, 255, 255, .2);
}

.wrapper .btn:active{
  background: #fff;
  color:#4BB0B8;
  border:solid #fff 2px;
}

.wrapper .register-link {
  font-size: 14.5px;
  text-align: center;
  margin: 20px 0 15px;

}

.register-link p a{
  color: #fff;
  text-decoration: none;
  font-weight: 600;
}

.register-link p a:hover {
  text-decoration: underline;
}

</style>



<body>
  <div class="wrapper">
    <form action="">
      <h3 class="text-center mb-4"><img src="images/bookylog.png" alt="booky" height="98" width="180"></h3>
      <h1>Merchant Settlement Tool</h1>
      <h2>Register Account</h2>
      <div class="input-box">
        <input type="text" placeholder="Username" required>
      </div>
      <div class="input-box">
        <input type="text" placeholder="Position" value="User" required>
      </div>
      <div class="input-box">
        <input type="text" placeholder="Create new password" required>
        <i class= 'bx bxs-lock-alt'></i>  
      </div>
      <div class="input-box">
        <input type="text" placeholder="Confirm new password" required>
        <i class= 'bx bxs-lock-alt'></i>  
      </div>
        <button type="submit" class="btn">Submit</button>

        <div class="register-link">
         <p>Already have an account? <a href="index.php"> Login</a></p> 
      </div>
    </form>
</div>
</body>

</html>
