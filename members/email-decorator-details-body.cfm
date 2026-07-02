<!---
  email-decorator-details-body.cfm - Details email wrapper for decorator

  Required variables:
    emailTheme    - struct from email-theme-helper.cfm
    qSiteForEmail - query row with couple/venue/decorator fields
    decBodyHtml   - pre-built HTML string of section content
    decIsTest     - boolean: true adds TEST EMAIL banner
    decSentAt     - formatted date/time string
--->
<cfparam name="decIsTest"  default="false">
<cfparam name="decSentAt"  default="">
<cfset decCoupleName = HTMLEditFormat(qSiteForEmail.couple_name_1) & " &amp; " & HTMLEditFormat(qSiteForEmail.couple_name_2)>
<cfoutput>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>Wedding Details - #decCoupleName#</title>
</head>
<body style="margin:0;padding:0;background-color:#emailTheme.bodyBg#;font-family:#emailTheme.fontStack#;-webkit-text-size-adjust:100%">
<table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0" style="background:#emailTheme.bodyBg#">
<tr><td align="center" style="padding:40px 12px">
<table role="presentation" width="620" cellpadding="0" cellspacing="0" border="0" style="max-width:620px;width:100%">

  <cfif len(emailTheme.themeImage)>
  <tr><td style="padding:0;line-height:0;font-size:0;background:#emailTheme.headerBg#">
    <img src="https://digitalweddings.love/assets/#emailTheme.themeImage#" width="620" alt="" style="display:block;width:100%;height:auto;border:0">
  </td></tr>
  </cfif>

  <cfif decIsTest>
  <tr><td align="center" style="background:##ff6b00;padding:10px 20px">
    <p style="margin:0;color:##ffffff;font-size:13px;font-weight:700;letter-spacing:3px;text-transform:uppercase;font-family:Arial,sans-serif">
      - TEST EMAIL - THIS IS A PREVIEW ONLY -
    </p>
  </td></tr>
  </cfif>

  <tr><td align="center" style="background:#emailTheme.headerBg#;padding:44px 40px 36px">
    <p style="margin:0 0 10px 0;color:#emailTheme.accentColor#;font-size:11px;letter-spacing:5px;text-transform:uppercase;font-family:Arial,Helvetica,sans-serif">
      Wedding Planning Details
    </p>
    <h1 style="margin:0;color:#emailTheme.headerText#;font-family:#emailTheme.headingFont#;font-size:34px;font-weight:#emailTheme.headingWeight#;line-height:1.2">
      #decCoupleName#
    </h1>
    <cfif len(trim(qSiteForEmail.wedding_date))>
    <p style="margin:14px 0 0 0;color:#emailTheme.accentColor#;font-size:12px;letter-spacing:4px;text-transform:uppercase;font-family:Arial,Helvetica,sans-serif">
      #dateFormat(qSiteForEmail.wedding_date,'mmmm d, yyyy')#
    </p>
    </cfif>
  </td></tr>

  <tr><td style="background:#emailTheme.bodyCardBg#;padding:16px 40px 8px">
    <p style="margin:0;color:#emailTheme.mutedText#;font-size:12px;font-family:Arial,sans-serif">
      <strong>Sent to decorator:</strong> #HTMLEditFormat(decSentAt)#
      <cfif len(trim(qSiteForEmail.decorator_name))>
        &nbsp;&bull;&nbsp; <strong>Decorator:</strong> #HTMLEditFormat(trim(qSiteForEmail.decorator_name))#
        <cfif len(trim(qSiteForEmail.decorator_company))> - #HTMLEditFormat(trim(qSiteForEmail.decorator_company))#</cfif>
      </cfif>
    </p>
    <hr style="border:0;border-top:1px solid #emailTheme.dividerColor#;margin:12px 0 0 0">
  </td></tr>

  <tr><td style="background:#emailTheme.bodyCardBg#;padding:8px 40px 36px">
    #decBodyHtml#
  </td></tr>

  <tr><td align="center" style="background:#emailTheme.headerBg#;padding:20px 40px;border-radius:0 0 8px 8px">
    <p style="margin:0;color:#emailTheme.accentColor#;font-size:12px;font-family:Arial,sans-serif">
      <a href="https://digitalweddings.love" style="color:#emailTheme.accentColor#;text-decoration:none">digitalweddings.love</a>
      &nbsp;&#9829;&nbsp; Celebrating love, one wedding at a time.
    </p>
  </td></tr>

  <cfif len(emailTheme.themeImageBottom)>
  <tr><td style="padding:0;line-height:0;font-size:0;background:#emailTheme.headerBg#">
    <img src="https://digitalweddings.love/assets/#emailTheme.themeImageBottom#" width="620" alt="" style="display:block;width:100%;height:auto;border:0">
  </td></tr>
  </cfif>

</table>
</td></tr>
</table>
</body>
</html>
</cfoutput>
