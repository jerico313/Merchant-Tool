<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Animated Rolling Egg</title>
    <link rel="stylesheet" href="styles.css">
    <style>
        body {
            margin: 0;
            padding: 0;

        }

        .egg-container {
            position: fixed;
            bottom: 0;
            left: 0;
            width: 100%;
            display: flex;

            align-items: flex-end;
            overflow: hidden;
        }

        .egg {
            position: relative;
            width: 50px;
            height: 70px;
            background-color: #FFFACD;
            /* Light yellow */
            border-radius: 50% 50% 50% 50% / 60% 60% 40% 40%;
            /* Egg shape */
            animation: rollEgg 6s infinite ease-in-out;
        }

        @keyframes rollEgg {

            0%,
            100% {
                transform: translateX(0) rotate(0deg);
            }

            25% {
                transform: translateX(calc(100vw - 50px)) rotate(360deg);
            }

            50% {
                transform: translateX(calc(100vw - 50px)) rotate(360deg);
            }

            75% {
                transform: translateX(0) rotate(720deg);
            }
        }
    </style>
</head>

<body>
    <div class="egg-container">
        <div class="egg"></div>
    </div>
</body>

</html>