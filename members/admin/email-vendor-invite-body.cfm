<!---
  email-vendor-invite-body.cfm - complimentary vendor registration invite.

  Required variables:
    vendorName      - string: vendor/business name
    vendorCategory  - string: vendor category
    personalMessage - string: optional personal note
    registerLink    - full URL to register-vendor.cfm
--->
<cfparam name="vendorName"      default="">
<cfparam name="vendorCategory"  default="">
<cfparam name="personalMessage" default="">
<cfoutput>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<meta name="x-apple-disable-message-reformatting">
<title>Complimentary Vendor Registration | digitalweddings.love</title>
</head>
<body style="margin:0;padding:0;background-color:##F5F0E8;font-family:Georgia,serif;-webkit-text-size-adjust:100%;-ms-text-size-adjust:100%">

<table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0" style="background:##F5F0E8">
<tr><td align="center" style="padding:40px 12px">
<table role="presentation" width="600" cellpadding="0" cellspacing="0" border="0" style="max-width:600px;width:100%">

  <!--- Header --->
  <tr><td align="center" style="background:##2C2C2C;padding:0 0 0 0;line-height:0;font-size:0">
    <img src="https://digitalweddings.love/assets/photos/bride-groom-planning.jpg"
         width="600" height="220" alt=""
         style="display:block;width:100%;height:220px;object-fit:cover;border:0;outline:0;text-decoration:none">
  </td></tr>

  <tr><td align="center" style="background:##2C2C2C;padding:44px 40px 40px">
    <p style="margin:0 0 14px 0;color:##B8860B;font-size:11px;letter-spacing:5px;text-transform:uppercase;font-family:Arial,Helvetica,sans-serif">
      You&rsquo;re Invited
    </p>
    <h1 style="margin:0;color:##FDFBF7;font-family:Georgia,'Times New Roman',serif;font-size:38px;font-weight:400;line-height:1.2;letter-spacing:0.02em">
      Join digitalweddings<span style="color:##C9A96A">.love</span>
    </h1>
    <p style="margin:16px 0 0;color:##B8860B;font-size:13px;letter-spacing:3px;text-transform:uppercase;font-family:Arial,Helvetica,sans-serif">
      Complimentary Vendor Registration
    </p>
    <table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0" style="margin-top:28px">
    <tr>
      <td style="height:1px;background-color:##B8860B;opacity:0.35;font-size:0;line-height:0">&nbsp;</td>
      <td width="32" align="center" style="color:##B8860B;font-size:18px;padding:0 10px;line-height:1;font-family:Georgia,serif">&##10022;</td>
      <td style="height:1px;background-color:##B8860B;opacity:0.35;font-size:0;line-height:0">&nbsp;</td>
    </tr>
    </table>
  </td></tr>

  <!--- Body --->
  <tr><td align="center" style="background:##FDFBF7;padding:44px 48px 40px">

    <cfif len(trim(vendorName))>
    <p style="margin:0 0 6px 0;color:##888888;font-size:12px;letter-spacing:3px;text-transform:uppercase;font-family:Arial,Helvetica,sans-serif">Dear</p>
    <p style="margin:0 0 32px 0;color:##2C2C2C;font-size:26px;font-family:Georgia,serif;line-height:1.2">#HTMLEditFormat(trim(vendorName))#,</p>
    </cfif>

    <cfif len(trim(personalMessage))>
    <p style="margin:0 0 28px 0;color:##2C2C2C;font-size:16px;line-height:1.85;font-family:Georgia,serif;text-align:left;white-space:pre-line">#HTMLEditFormat(trim(personalMessage))#</p>
    <cfelse>
    <p style="margin:0 0 28px 0;color:##2C2C2C;font-size:16px;line-height:1.85;font-family:Georgia,serif;text-align:left">
      We&rsquo;d love to have you as part of the <strong>digitalweddings.love</strong> vendor community &mdash; a platform built to connect couples and wedding professionals.
    </p>
    <p style="margin:0 0 28px 0;color:##2C2C2C;font-size:16px;line-height:1.85;font-family:Georgia,serif;text-align:left">
      As our guest, you&rsquo;re receiving a <strong>complimentary listing</strong> &mdash; completely free, no fees, no credit card required. Listings are reviewed within 2 business days.
    </p>
    <table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0" style="margin:0 0 28px 0">
    <tr><td style="background:##FFF8E6;border:1px solid ##F0D080;border-radius:6px;padding:16px 20px">
      <p style="margin:0;color:##7A5A00;font-size:14px;line-height:1.6;font-family:Arial,Helvetica,sans-serif">
        <strong>Important:</strong> You must register using the exact email address this invitation was sent to. Using a different email address will not work.
      </p>
    </td></tr>
    </table>
    </cfif>

    <!--- Category card --->
    <cfif len(trim(vendorCategory))>
    <table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0" style="margin:0 0 36px 0">
    <tr><td style="background:##F5F0E8;border:1px solid ##E8E0D0;border-radius:6px;padding:20px 28px;text-align:center">
      <p style="margin:0 0 6px 0;color:##888888;font-size:10px;letter-spacing:4px;text-transform:uppercase;font-family:Arial,Helvetica,sans-serif">Listed As</p>
      <p style="margin:0;color:##2C2C2C;font-size:20px;font-weight:bold;font-family:Georgia,serif">#HTMLEditFormat(trim(vendorCategory))#</p>
    </td></tr>
    </table>
    </cfif>

    <!--- CTA button --->
    <table role="presentation" cellpadding="0" cellspacing="0" border="0" style="margin:0 auto 20px">
    <tr><td align="center" style="border-radius:2px;background:##B8860B">
      <a href="#HTMLEditFormat(registerLink)#"
         style="display:inline-block;padding:18px 52px;background:##B8860B;color:##FDFBF7;font-family:Arial,Helvetica,sans-serif;font-size:14px;font-weight:700;letter-spacing:2px;text-transform:uppercase;text-decoration:none;border-radius:2px">
        Claim Your Free Listing
      </a>
    </td></tr>
    </table>

    <p style="margin:0 0 32px 0;font-family:Arial,Helvetica,sans-serif;font-size:12px;text-align:center;color:##888888">
      Or copy this link: <a href="#HTMLEditFormat(registerLink)#" style="color:##B8860B;word-break:break-all">#HTMLEditFormat(registerLink)#</a>
    </p>

    <p style="margin:0;color:##888888;font-size:13px;line-height:1.7;font-family:Arial,Helvetica,sans-serif;text-align:center;border-top:1px solid ##E8E0D0;padding-top:24px">
      Questions? Reply to this email and we&rsquo;ll be happy to help.
    </p>

  </td></tr>

  <!--- Footer --->
  <tr><td align="center" style="background:##2C2C2C;padding:22px 40px;border-top:1px solid ##3a3a3a">
    <p style="margin:0 0 4px 0;font-family:Arial,Helvetica,sans-serif;font-size:14px;font-weight:600">
      <a href="https://digitalweddings.love" style="color:##FDFBF7;text-decoration:none">digitalweddings.love</a>
      <span style="color:##cc0022;margin-left:5px">&##9829;</span>
    </p>
    <p style="margin:0;color:##FDFBF7;font-size:11px;opacity:0.5;font-family:Arial,Helvetica,sans-serif">Celebrating love, one wedding at a time.</p>
  </td></tr>

</table>
</td></tr>
</table>
</body>
</html>
</cfoutput>
