<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Something Went Wrong | DigitalWeddings.Love</title>
<link href="https://fonts.googleapis.com/css2?family=Cormorant+Garamond:ital,wght@0,400;1,400&family=Montserrat:wght@400;600&family=Playfair+Display:ital,wght@1,400&display=swap" rel="stylesheet">
<style>
*{margin:0;padding:0;box-sizing:border-box}
body{background:#FFFFFF;color:#1e2022;font-family:'Montserrat',sans-serif;min-height:100vh;display:flex;flex-direction:column;align-items:center;justify-content:center;text-align:center;padding:48px 24px}
.icon{font-size:2.5rem;margin-bottom:24px}
h1{font-family:'Playfair Display',serif;font-size:clamp(1.6rem,3vw,2.2rem);font-weight:400;font-style:italic;color:#1e2022;margin-bottom:16px}
.divider{width:48px;height:2px;background:#7A9E7E;margin:0 auto 24px;border-radius:2px}
p{font-size:15px;font-weight:300;color:#6b7280;max-width:420px;line-height:1.8;margin-bottom:36px}
.btn{display:inline-block;padding:12px 36px;background:#7A9E7E;color:#fff;text-decoration:none;font-family:'Montserrat',sans-serif;font-size:13px;font-weight:600;letter-spacing:.08em;text-transform:uppercase;border-radius:4px;transition:background .2s}
.btn:hover{background:#5f8464}
.brand{margin-top:48px;font-size:13px;color:#6b7280}
.brand span{color:#7A9E7E;font-weight:600}
</style>
</head>
<body>
  <div class="icon">&#128149;</div>
  <h1>Something Went Wrong</h1>
  <div class="divider"></div>
  <p>We apologize for the inconvenience. Our team has been notified and is working to resolve the issue. Please try again in a moment.</p>
  <cfset homeUrl = (structKeyExists(session,"user") AND structKeyExists(session.user,"id") AND len(session.user.id)) ? "/members/planning-tools.cfm" : "/">
  <a href="<cfoutput>#homeUrl#</cfoutput>" class="btn">Return Home</a>
  <div class="brand">digitalweddings<span>.love</span></div>
</body>
</html>
