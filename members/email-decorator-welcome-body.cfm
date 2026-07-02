<!---
  email-decorator-welcome-body.cfm - Initial decorator welcome email

  Required variables:
    emailTheme    - struct from email-theme-helper.cfm
    qSiteForEmail - query row: couple_name_1, couple_name_2, wedding_date,
                    venue_name, venue_address, ceremony_start_time,
                    decorator_name, decorator_company
    decIsTest     - boolean: true adds TEST EMAIL banner
--->
<cfparam name="decIsTest" default="false">
<cfset decCoupleName = HTMLEditFormat(qSiteForEmail.couple_name_1) & " &amp; " & HTMLEditFormat(qSiteForEmail.couple_name_2)>
<cfset decGreeting = len(trim(qSiteForEmail.decorator_name)) ? HTMLEditFormat(trim(qSiteForEmail.decorator_name)) : "there">
<cfoutput>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>You've Been Added as Our Wedding Decorator</title>
</head>
<body style="margin:0;padding:0;background-color:#emailTheme.bodyBg#;font-family:#emailTheme.fontStack#;-webkit-text-size-adjust:100%">
<table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0" style="background:#emailTheme.bodyBg#">
<tr><td align="center" style="padding:40px 12px">
<table role="presentation" width="600" cellpadding="0" cellspacing="0" border="0" style="max-width:600px;width:100%">

  <cfif len(emailTheme.themeImage)>
  <tr><td style="padding:0;line-height:0;font-size:0;background:#emailTheme.headerBg#">
    <img src="https://digitalweddings.love/assets/#emailTheme.themeImage#" width="600" alt="" style="display:block;width:100%;height:auto;border:0">
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
    <p style="margin:0 0 14px 0;color:#emailTheme.accentColor#;font-size:11px;letter-spacing:5px;text-transform:uppercase;font-family:Arial,Helvetica,sans-serif">
      Wedding Decorator Notification
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

  <tr><td style="background:#emailTheme.bodyCardBg#;padding:40px 40px 32px">

    <p style="margin:0 0 20px 0;color:#emailTheme.bodyText#;font-size:16px;line-height:1.6;font-family:#emailTheme.fontStack#">
      Hi #decGreeting#,
    </p>
    <p style="margin:0 0 20px 0;color:#emailTheme.bodyText#;font-size:15px;line-height:1.7;font-family:#emailTheme.fontStack#">
      We are excited to let you know that we've added you as our wedding decorator for our upcoming wedding through <strong>DigitalWeddings.love</strong>.
    </p>
    <p style="margin:0 0 24px 0;color:#emailTheme.bodyText#;font-size:15px;line-height:1.7;font-family:#emailTheme.fontStack#">
      Here are our wedding details:
    </p>

    <table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0" style="background:#emailTheme.bodyBg#;border-radius:8px;margin:0 0 28px 0">
    <tr><td style="padding:24px 28px">
      <table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0">
        <cfif len(trim(qSiteForEmail.wedding_date))>
        <tr>
          <td style="padding:6px 0;font-size:13px;font-weight:700;color:#emailTheme.mutedText#;font-family:Arial,sans-serif;width:40%;vertical-align:top">Wedding Date</td>
          <td style="padding:6px 0;font-size:14px;color:#emailTheme.bodyText#;font-family:#emailTheme.fontStack#">#dateFormat(qSiteForEmail.wedding_date,'mmmm d, yyyy')#</td>
        </tr>
        </cfif>
        <cfif len(trim(qSiteForEmail.ceremony_start_time))>
        <tr>
          <td style="padding:6px 0;font-size:13px;font-weight:700;color:#emailTheme.mutedText#;font-family:Arial,sans-serif;vertical-align:top">Wedding Time</td>
          <td style="padding:6px 0;font-size:14px;color:#emailTheme.bodyText#;font-family:#emailTheme.fontStack#">#HTMLEditFormat(trim(qSiteForEmail.ceremony_start_time))#</td>
        </tr>
        </cfif>
        <cfif len(trim(qSiteForEmail.venue_name))>
        <tr>
          <td style="padding:6px 0;font-size:13px;font-weight:700;color:#emailTheme.mutedText#;font-family:Arial,sans-serif;vertical-align:top">Wedding Location</td>
          <td style="padding:6px 0;font-size:14px;color:#emailTheme.bodyText#;font-family:#emailTheme.fontStack#">
            #HTMLEditFormat(trim(qSiteForEmail.venue_name))#
            <cfif len(trim(qSiteForEmail.venue_address))><br><span style="font-size:13px;color:#emailTheme.mutedText#">#HTMLEditFormat(trim(qSiteForEmail.venue_address))#</span></cfif>
          </td>
        </tr>
        </cfif>
      </table>
    </td></tr>
    </table>

    <p style="margin:0 0 16px 0;color:#emailTheme.bodyText#;font-size:15px;line-height:1.7;font-family:#emailTheme.fontStack#">
      As we continue planning, we'll be sharing additional information with you, including things like our seating chart, ceremony and reception layouts, wedding party information, decor inspiration, floral preferences, timeline, and other planning details.
    </p>
    <p style="margin:0 0 32px 0;color:#emailTheme.bodyText#;font-size:15px;line-height:1.7;font-family:#emailTheme.fontStack#">
      We're looking forward to working with you and helping bring our wedding vision to life!
    </p>

    <hr style="border:0;border-top:1px solid #emailTheme.dividerColor#;margin:0 0 24px 0">

    <p style="margin:0 0 4px 0;color:#emailTheme.bodyText#;font-size:14px;font-family:#emailTheme.fontStack#">Warm regards,</p>
    <p style="margin:0 0 16px 0;color:#emailTheme.bodyText#;font-size:15px;font-weight:700;font-family:#emailTheme.headingFont#">#decCoupleName#</p>
    <p style="margin:0;color:#emailTheme.mutedText#;font-size:12px;font-style:italic;font-family:Arial,sans-serif">Powered by DigitalWeddings.love</p>

  </td></tr>

  <tr><td align="center" style="background:#emailTheme.headerBg#;padding:20px 40px;border-radius:0 0 8px 8px">
    <p style="margin:0;color:#emailTheme.accentColor#;font-size:12px;font-family:Arial,sans-serif">
      <a href="https://digitalweddings.love" style="color:#emailTheme.accentColor#;text-decoration:none">digitalweddings.love</a>
      &nbsp;&#9829;&nbsp; Celebrating love, one wedding at a time.
    </p>
  </td></tr>

  <cfif len(emailTheme.themeImageBottom)>
  <tr><td style="padding:0;line-height:0;font-size:0;background:#emailTheme.headerBg#">
    <img src="https://digitalweddings.love/assets/#emailTheme.themeImageBottom#" width="600" alt="" style="display:block;width:100%;height:auto;border:0">
  </td></tr>
  </cfif>

</table>
</td></tr>
</table>
</body>
</html>
</cfoutput>
