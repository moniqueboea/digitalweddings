<!---
  email-save-the-date-body.cfm

  Required variables (set before including):
    emailTheme   - struct from email-theme-helper.cfm
    stdName1     - string: first partner first name (HTMLEditFormat already applied)
    stdName2     - string: second partner first name (HTMLEditFormat already applied)
    stdDate      - string: formatted wedding date, or ""
    stdLocation  - string: wedding location, or ""
    stdSiteLink  - string: full URL to wedding website
    stdPhoto     - string: relative path to couple photo, or ""
    stdRecipName - string: recipient first name (raw, not yet escaped)
--->
<cfparam name="stdRecipName" default="">
<cfoutput>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<meta name="x-apple-disable-message-reformatting">
<title>Save the Date &mdash; #stdName1# &amp; #stdName2#</title>
</head>
<body style="margin:0;padding:0;background-color:#emailTheme.bodyBg#;font-family:#emailTheme.fontStack#;-webkit-text-size-adjust:100%;-ms-text-size-adjust:100%">

<table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0" style="background:#emailTheme.bodyBg#">
<tr><td align="center" style="padding:40px 12px">
<table role="presentation" width="600" cellpadding="0" cellspacing="0" border="0" style="max-width:600px;width:100%">

  <!--- Top theme image --->
  <cfif len(emailTheme.themeImage)>
  <tr><td style="padding:0;line-height:0;font-size:0">
    <img src="https://digitalweddings.love/assets/#emailTheme.themeImage#"
         width="600" height="180" alt=""
         style="display:block;width:100%;height:180px;object-fit:cover;border:0;outline:0;text-decoration:none">
  </td></tr>
  </cfif>

  <!--- Header --->
  <tr><td align="center" style="background:#emailTheme.headerBg#;padding:48px 40px 40px">

    <p style="margin:0 0 16px;color:#emailTheme.accentColor#;font-size:11px;letter-spacing:6px;text-transform:uppercase;font-family:Arial,Helvetica,sans-serif">
      #HTMLEditFormat(emailTheme.eyebrow)#
    </p>

    <!--- Couple photo --->
    <cfif len(stdPhoto)>
    <div style="width:180px;height:180px;border-radius:50%;overflow:hidden;border:4px solid #emailTheme.accentColor#;margin:0 auto 28px;line-height:0;font-size:0">
      <img src="https://digitalweddings.love#HTMLEditFormat(stdPhoto)#"
           width="180" height="180" alt="#stdName1# &amp; #stdName2#"
           style="display:block;width:180px;height:180px;object-fit:cover;border:0">
    </div>
    </cfif>

    <h1 style="margin:0 0 8px;color:#emailTheme.headerText#;font-family:#emailTheme.headingFont#;font-size:52px;font-weight:#emailTheme.headingWeight#;line-height:1.1;letter-spacing:0.02em">
      Save the Date
    </h1>
    <p style="margin:0;color:#emailTheme.headerText#;font-size:22px;opacity:0.85;font-family:#emailTheme.fontStack#;letter-spacing:0.05em">
      #stdName1# &amp; #stdName2#
    </p>

    <table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0" style="margin-top:28px">
    <tr>
      <td style="height:1px;background:#emailTheme.accentColor#;opacity:0.3;font-size:0;line-height:0">&nbsp;</td>
      <td width="36" align="center" style="color:#emailTheme.accentColor#;font-size:20px;padding:0 10px;line-height:1;font-family:Georgia,serif">&#10022;</td>
      <td style="height:1px;background:#emailTheme.accentColor#;opacity:0.3;font-size:0;line-height:0">&nbsp;</td>
    </tr>
    </table>
  </td></tr>

  <!--- Body --->
  <tr><td align="center" style="background:#emailTheme.bodyCardBg#;padding:44px 48px 40px">

    <cfif len(trim(stdRecipName))>
    <p style="margin:0 0 28px;color:#emailTheme.bodyText#;font-size:18px;font-family:#emailTheme.fontStack#;text-align:left">
      Dear #HTMLEditFormat(trim(stdRecipName))#,
    </p>
    </cfif>

    <p style="margin:0 0 32px;color:#emailTheme.bodyText#;font-size:16px;line-height:1.8;font-family:#emailTheme.fontStack#;text-align:left">
      We are overjoyed to share our wonderful news &mdash; we&rsquo;re getting married! Please save the date and celebrate this special milestone with us.
    </p>

    <!--- Date & Location card --->
    <table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0" style="margin:0 0 36px">
    <tr><td style="background:#emailTheme.bodyBg#;border:1px solid #emailTheme.dividerColor#;border-radius:8px;padding:28px 32px;text-align:center">
      <p style="margin:0 0 6px;color:#emailTheme.mutedText#;font-size:10px;letter-spacing:5px;text-transform:uppercase;font-family:Arial,Helvetica,sans-serif">The Wedding of</p>
      <p style="margin:0 0 20px;color:#emailTheme.bodyText#;font-size:26px;font-family:#emailTheme.headingFont#;font-weight:#emailTheme.headingWeight#;line-height:1.2">#stdName1# &amp; #stdName2#</p>
      <cfif len(stdDate)>
      <p style="margin:0 0 6px;color:#emailTheme.mutedText#;font-size:10px;letter-spacing:5px;text-transform:uppercase;font-family:Arial,Helvetica,sans-serif">Date</p>
      <p style="margin:0 0 20px;color:#emailTheme.accentColor#;font-size:20px;font-family:#emailTheme.headingFont#;font-weight:#emailTheme.headingWeight#">#HTMLEditFormat(stdDate)#</p>
      </cfif>
      <cfif len(stdLocation)>
      <p style="margin:0 0 6px;color:#emailTheme.mutedText#;font-size:10px;letter-spacing:5px;text-transform:uppercase;font-family:Arial,Helvetica,sans-serif">Location</p>
      <p style="margin:0;color:#emailTheme.bodyText#;font-size:16px;font-family:#emailTheme.fontStack#">#HTMLEditFormat(stdLocation)#</p>
      </cfif>
    </td></tr>
    </table>

    <p style="margin:0 0 28px;color:#emailTheme.mutedText#;font-size:14px;line-height:1.7;font-family:Arial,Helvetica,sans-serif;text-align:center">
      A formal invitation will follow. For more details, visit our wedding website.
    </p>

    <!--- CTA --->
    <table role="presentation" cellpadding="0" cellspacing="0" border="0" style="margin:0 auto 12px">
    <tr><td align="center" style="border-radius:#emailTheme.btnRadius#;background:#emailTheme.btnBg#">
      <a href="#HTMLEditFormat(stdSiteLink)#"
         style="display:inline-block;padding:16px 48px;background:#emailTheme.btnBg#;color:#emailTheme.btnText#;font-family:Arial,Helvetica,sans-serif;font-size:13px;font-weight:700;letter-spacing:2px;text-transform:uppercase;text-decoration:none;border-radius:#emailTheme.btnRadius#">
        Visit Our Wedding Website
      </a>
    </td></tr>
    </table>

    <p style="margin:24px 0 0;color:#emailTheme.bodyText#;font-size:17px;font-family:#emailTheme.fontStack#;text-align:right">
      With love,<br>
      <em style="font-family:#emailTheme.headingFont#;font-size:22px">#stdName1# &amp; #stdName2#</em>
    </p>

  </td></tr>

  <!--- Bottom theme image --->
  <cfif len(emailTheme.themeImageBottom)>
  <tr><td style="padding:0;line-height:0;font-size:0">
    <img src="https://digitalweddings.love/assets/#emailTheme.themeImageBottom#"
         width="600" alt=""
         style="display:block;width:100%;height:auto;border:0;outline:0;text-decoration:none">
  </td></tr>
  </cfif>

  <!--- Footer --->
  <tr><td align="center" style="background:#emailTheme.headerBg#;padding:22px 40px;border-top:1px solid #emailTheme.dividerColor#">
    <p style="margin:0 0 4px;font-family:Arial,Helvetica,sans-serif;font-size:14px;font-weight:600">
      <a href="https://digitalweddings.love" style="color:#emailTheme.headerText#;text-decoration:none">digitalweddings.love</a>
      <span style="color:##cc0022;margin-left:5px">&#9829;</span>
    </p>
    <p style="margin:0;color:#emailTheme.headerText#;font-size:11px;opacity:0.5;font-family:Arial,Helvetica,sans-serif">Celebrating love, one wedding at a time.</p>
  </td></tr>

</table>
</td></tr>
</table>
</body>
</html>
</cfoutput>
