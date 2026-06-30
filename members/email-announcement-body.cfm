<!---
  email-announcement-body.cfm - shared email HTML for bulk guest messages.

  Required variables set before cfinclude:
    emailTheme       - struct from email-theme-helper.cfm
    qSiteForEmail    - query row with couple_name_1, couple_name_2, wedding_date,
                       venue_name, venue_address, slug
    emailGuestName   - recipient's name string
    emailMessageBody - the message the couple typed
    emailSiteLink    - full URL to the wedding website
--->
<cfparam name="emailGuestName"   default="">
<cfparam name="emailMessageBody" default="">
<cfoutput>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<meta name="x-apple-disable-message-reformatting">
<title>#HTMLEditFormat(qSiteForEmail.couple_name_1)# &amp; #HTMLEditFormat(qSiteForEmail.couple_name_2)#</title>
</head>
<body style="margin:0;padding:0;background-color:#emailTheme.bodyBg#;font-family:#emailTheme.fontStack#;-webkit-text-size-adjust:100%;-ms-text-size-adjust:100%">

<table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0" style="background:#emailTheme.bodyBg#">
<tr><td align="center" style="padding:40px 12px">
<table role="presentation" width="600" cellpadding="0" cellspacing="0" border="0" style="max-width:600px;width:100%">

  <!--- Top theme image --->
  <cfif len(emailTheme.themeImage)>
  <tr><td style="padding:0;line-height:0;font-size:0;background:#emailTheme.headerBg#">
    <img src="https://digitalweddings.love/assets/#emailTheme.themeImage#"
         width="600" alt=""
         style="display:block;width:100%;height:auto;border:0;outline:0;text-decoration:none">
  </td></tr>
  </cfif>

  <!--- Header --->
  <tr><td align="center" style="background:#emailTheme.headerBg#;padding:40px 40px 32px">
    <p style="margin:0 0 12px 0;color:#emailTheme.accentColor#;font-size:11px;letter-spacing:5px;text-transform:uppercase;font-family:Arial,Helvetica,sans-serif">
      A Message From
    </p>
    <h1 style="margin:0;color:#emailTheme.headerText#;font-family:#emailTheme.headingFont#;font-size:36px;font-weight:#emailTheme.headingWeight#;line-height:1.2">
      #HTMLEditFormat(qSiteForEmail.couple_name_1)#
      <span style="font-size:28px;opacity:0.7">&amp;</span>
      #HTMLEditFormat(qSiteForEmail.couple_name_2)#
    </h1>
    <cfif len(trim(qSiteForEmail.wedding_date))>
    <p style="margin:14px 0 0 0;color:#emailTheme.accentColor#;font-size:12px;letter-spacing:3px;text-transform:uppercase;font-family:Arial,Helvetica,sans-serif">
      #dateFormat(qSiteForEmail.wedding_date,'mmmm d, yyyy')#
    </p>
    </cfif>
    <table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0" style="margin-top:24px">
    <tr>
      <td style="height:1px;background-color:#emailTheme.accentColor#;opacity:0.25;font-size:0;line-height:0">&nbsp;</td>
      <td width="32" align="center" style="color:#emailTheme.accentColor#;font-size:16px;padding:0 10px;line-height:1;font-family:Georgia,serif">&#10022;</td>
      <td style="height:1px;background-color:#emailTheme.accentColor#;opacity:0.25;font-size:0;line-height:0">&nbsp;</td>
    </tr>
    </table>
  </td></tr>

  <!--- Body --->
  <tr><td align="center" style="background:#emailTheme.bodyCardBg#;padding:44px 48px 40px">

    <!--- Guest greeting --->
    <cfif len(trim(emailGuestName))>
    <p style="margin:0 0 28px 0;color:#emailTheme.bodyText#;font-size:17px;font-family:#emailTheme.fontStack#;text-align:left">
      Dear #HTMLEditFormat(trim(emailGuestName))#,
    </p>
    </cfif>

    <!--- Message body --->
    <p style="margin:0 0 36px 0;color:#emailTheme.bodyText#;font-size:17px;line-height:1.85;font-family:#emailTheme.fontStack#;text-align:left;white-space:pre-line">#HTMLEditFormat(trim(emailMessageBody))#</p>

    <!--- Wedding website button --->
    <table role="presentation" cellpadding="0" cellspacing="0" border="0" style="margin:0 auto 28px">
    <tr><td align="center" style="border-radius:#emailTheme.btnRadius#;background:#emailTheme.btnBg#">
      <a href="#emailSiteLink#"
         style="display:inline-block;padding:16px 48px;background:#emailTheme.btnBg#;color:#emailTheme.btnText#;font-family:Arial,Helvetica,sans-serif;font-size:14px;font-weight:700;letter-spacing:2px;text-transform:uppercase;text-decoration:none;border-radius:#emailTheme.btnRadius#">
        Visit Our Wedding Website
      </a>
    </td></tr>
    </table>

    <!--- Plain URL --->
    <p style="margin:0;color:#emailTheme.mutedText#;font-size:12px;font-family:Arial,Helvetica,sans-serif;border-top:1px solid #emailTheme.dividerColor#;padding-top:24px;text-align:center">
      <a href="#emailSiteLink#" style="color:#emailTheme.accentColor#;word-break:break-all">#emailSiteLink#</a>
    </p>

  </td></tr>

  <!--- Bottom theme image --->
  <cfif len(emailTheme.themeImageBottom)>
  <tr><td style="padding:0;line-height:0;font-size:0;background:#emailTheme.bodyBg#">
    <img src="https://digitalweddings.love/assets/#emailTheme.themeImageBottom#"
         width="600" alt=""
         style="display:block;width:100%;height:auto;border:0;outline:0;text-decoration:none">
  </td></tr>
  </cfif>

  <!--- Footer --->
  <tr><td align="center" style="background:#emailTheme.headerBg#;padding:22px 40px;border-top:1px solid #emailTheme.dividerColor#">
    <p style="margin:0 0 4px 0;font-family:Arial,Helvetica,sans-serif;font-size:14px;font-weight:600">
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
