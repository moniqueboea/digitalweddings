<!---
  email-thank-you-body.cfm - thank you card email.

  Required variables:
    emailTheme      - struct from email-theme-helper.cfm
    qSiteForEmail   - query row: couple_name_1, couple_name_2, wedding_date, slug
    tyRecipientName - string: recipient's name
    tyMessage       - string: personal thank you message
    emailSiteLink   - full URL to the wedding website
--->
<cfparam name="tyRecipientName" default="">
<cfparam name="tyMessage"       default="">
<cfoutput>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<meta name="x-apple-disable-message-reformatting">
<title>A Thank You from #HTMLEditFormat(qSiteForEmail.couple_name_1)# &amp; #HTMLEditFormat(qSiteForEmail.couple_name_2)#</title>
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
  <cfset name1 = HTMLEditFormat(listFirst(trim(qSiteForEmail.couple_name_1)," "))>
  <cfset name2 = HTMLEditFormat(listFirst(trim(qSiteForEmail.couple_name_2)," "))>
  <cfset couplePhoto = len(trim(qSiteForEmail.couple_photo_url)) ? trim(qSiteForEmail.couple_photo_url) : (len(trim(qSiteForEmail.hero_image_url)) ? trim(qSiteForEmail.hero_image_url) : "")>
  <tr><td align="center" style="background:#emailTheme.headerBg#;padding:44px 40px 36px">
    <p style="margin:0 0 14px 0;color:#emailTheme.accentColor#;font-size:11px;letter-spacing:5px;text-transform:uppercase;font-family:Arial,Helvetica,sans-serif">
      With Love &amp; Gratitude
    </p>
    <h1 style="margin:0;color:#emailTheme.headerText#;font-family:#emailTheme.headingFont#;font-size:40px;font-weight:#emailTheme.headingWeight#;line-height:1.2;letter-spacing:0.02em">
      Thank You
    </h1>
    <p style="margin:14px 0 0 0;color:#emailTheme.headerText#;font-size:16px;opacity:0.75;font-family:#emailTheme.fontStack#">
      from #name1# &amp; #name2#
    </p>
    <cfif len(couplePhoto)>
    <div style="margin:28px auto 0;width:160px;height:160px;border-radius:50%;overflow:hidden;border:3px solid #emailTheme.accentColor#;line-height:0;font-size:0">
      <img src="https://digitalweddings.love#HTMLEditFormat(couplePhoto)#"
           width="160" height="160" alt="#name1# &amp; #name2#"
           style="display:block;width:160px;height:160px;object-fit:cover;border:0;outline:0;text-decoration:none">
    </div>
    <cfelse>
    <table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0" style="margin-top:28px">
    <tr>
      <td style="height:1px;background-color:#emailTheme.accentColor#;opacity:0.25;font-size:0;line-height:0">&nbsp;</td>
      <td width="32" align="center" style="color:#emailTheme.accentColor#;font-size:18px;padding:0 10px;line-height:1;font-family:Georgia,serif">&#10022;</td>
      <td style="height:1px;background-color:#emailTheme.accentColor#;opacity:0.25;font-size:0;line-height:0">&nbsp;</td>
    </tr>
    </table>
    </cfif>
  </td></tr>

  <!--- Body --->
  <tr><td align="center" style="background:#emailTheme.bodyCardBg#;padding:44px 48px 40px">

    <!--- Greeting --->
    <cfif len(trim(tyRecipientName))>
    <p style="margin:0 0 6px 0;color:#emailTheme.mutedText#;font-size:12px;letter-spacing:3px;text-transform:uppercase;font-family:Arial,Helvetica,sans-serif">Dear</p>
    <p style="margin:0 0 32px 0;color:#emailTheme.bodyText#;font-size:28px;font-family:#emailTheme.headingFont#;font-weight:#emailTheme.headingWeight#;line-height:1.2">#HTMLEditFormat(trim(tyRecipientName))#,</p>
    </cfif>

    <!--- Message --->
    <cfif len(trim(tyMessage))>
    <p style="margin:0 0 32px 0;color:#emailTheme.bodyText#;font-size:17px;line-height:1.85;font-family:#emailTheme.fontStack#;text-align:left;white-space:pre-line">#HTMLEditFormat(trim(tyMessage))#</p>
    <cfelse>
    <p style="margin:0 0 32px 0;color:#emailTheme.bodyText#;font-size:17px;line-height:1.85;font-family:#emailTheme.fontStack#">
      We are so grateful for your love, support, and presence on our special day.
      Your kindness means more to us than words can express.
      Thank you from the bottom of our hearts.
    </p>
    </cfif>

    <p style="margin:0 0 0 0;color:#emailTheme.bodyText#;font-size:17px;line-height:1.85;font-family:#emailTheme.fontStack#;text-align:right">
      With love,<br>
      <em style="font-family:#emailTheme.headingFont#;font-size:22px">#name1# &amp; #name2#</em>
    </p>

    <cfif len(trim(qSiteForEmail.wedding_date))>
    <p style="margin:28px 0 0 0;color:#emailTheme.mutedText#;font-size:12px;letter-spacing:3px;text-transform:uppercase;font-family:Arial,Helvetica,sans-serif;text-align:center;border-top:1px solid #emailTheme.dividerColor#;padding-top:24px">
      Married on #dateFormat(qSiteForEmail.wedding_date,'mmmm d, yyyy')#
    </p>
    </cfif>

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
