<!---
  email-dj-notify-body.cfm - Initial DJ notification email

  Required variables:
    emailTheme   - struct from email-theme-helper.cfm
    qSiteForEmail - query row: couple_name_1, couple_name_2, wedding_date,
                    venue_name, venue_address, ceremony_start_time, reception_start_time,
                    dj_name, dj_contact_person, dj_email
    djIsTest     - boolean: true adds TEST EMAIL banner
--->
<cfparam name="djIsTest" default="false">
<cfset djCoupleName = HTMLEditFormat(qSiteForEmail.couple_name_1) & " &amp; " & HTMLEditFormat(qSiteForEmail.couple_name_2)>
<cfset djGreeting = len(trim(qSiteForEmail.dj_contact_person)) ? HTMLEditFormat(trim(qSiteForEmail.dj_contact_person)) : (len(trim(qSiteForEmail.dj_name)) ? HTMLEditFormat(trim(qSiteForEmail.dj_name)) : "there")>
<cfoutput>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>You've Been Selected as the DJ</title>
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

  <!--- TEST BANNER --->
  <cfif djIsTest>
  <tr><td align="center" style="background:##ff6b00;padding:10px 20px">
    <p style="margin:0;color:##ffffff;font-size:13px;font-weight:700;letter-spacing:3px;text-transform:uppercase;font-family:Arial,sans-serif">
      - TEST EMAIL - THIS IS A PREVIEW ONLY -
    </p>
  </td></tr>
  </cfif>

  <!--- Header --->
  <tr><td align="center" style="background:#emailTheme.headerBg#;padding:44px 40px 36px">
    <p style="margin:0 0 14px 0;color:#emailTheme.accentColor#;font-size:11px;letter-spacing:5px;text-transform:uppercase;font-family:Arial,Helvetica,sans-serif">
      Wedding DJ Notification
    </p>
    <h1 style="margin:0;color:#emailTheme.headerText#;font-family:#emailTheme.headingFont#;font-size:34px;font-weight:#emailTheme.headingWeight#;line-height:1.2">
      #djCoupleName#
    </h1>
    <cfif len(trim(qSiteForEmail.wedding_date))>
    <p style="margin:14px 0 0 0;color:#emailTheme.accentColor#;font-size:12px;letter-spacing:4px;text-transform:uppercase;font-family:Arial,Helvetica,sans-serif">
      #dateFormat(qSiteForEmail.wedding_date,'mmmm d, yyyy')#
    </p>
    </cfif>
  </td></tr>

  <!--- Body --->
  <tr><td style="background:#emailTheme.bodyCardBg#;padding:40px 40px 32px">

    <p style="margin:0 0 20px 0;color:#emailTheme.bodyText#;font-size:16px;line-height:1.6;font-family:#emailTheme.fontStack#">
      Hello #djGreeting#,
    </p>
    <p style="margin:0 0 20px 0;color:#emailTheme.bodyText#;font-size:15px;line-height:1.7;font-family:#emailTheme.fontStack#">
      We're excited to let you know that <strong>#djCoupleName#</strong> have selected you as the DJ for their upcoming wedding and have added your information to their planning account on <strong>DigitalWeddings.love</strong>.
    </p>

    <!--- Wedding Details box --->
    <table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0" style="background:#emailTheme.bodyBg#;border-radius:8px;margin:24px 0">
    <tr><td style="padding:24px 28px">
      <p style="margin:0 0 16px 0;color:#emailTheme.accentColor#;font-size:11px;font-weight:700;letter-spacing:4px;text-transform:uppercase;font-family:Arial,sans-serif">Wedding Details</p>
      <table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0">
        <cfif len(trim(qSiteForEmail.wedding_date))>
        <tr>
          <td style="padding:5px 0;font-size:13px;font-weight:700;color:#emailTheme.mutedText#;font-family:Arial,sans-serif;width:40%;vertical-align:top">Wedding Date</td>
          <td style="padding:5px 0;font-size:13px;color:#emailTheme.bodyText#;font-family:Arial,sans-serif">#dateFormat(qSiteForEmail.wedding_date,'mmmm d, yyyy')#</td>
        </tr>
        </cfif>
        <cfif len(trim(qSiteForEmail.ceremony_start_time))>
        <tr>
          <td style="padding:5px 0;font-size:13px;font-weight:700;color:#emailTheme.mutedText#;font-family:Arial,sans-serif;vertical-align:top">Ceremony Time</td>
          <td style="padding:5px 0;font-size:13px;color:#emailTheme.bodyText#;font-family:Arial,sans-serif">#trim(qSiteForEmail.ceremony_start_time)#</td>
        </tr>
        </cfif>
        <cfif len(trim(qSiteForEmail.reception_start_time))>
        <tr>
          <td style="padding:5px 0;font-size:13px;font-weight:700;color:#emailTheme.mutedText#;font-family:Arial,sans-serif;vertical-align:top">Reception Time</td>
          <td style="padding:5px 0;font-size:13px;color:#emailTheme.bodyText#;font-family:Arial,sans-serif">#trim(qSiteForEmail.reception_start_time)#</td>
        </tr>
        </cfif>
        <cfif len(trim(qSiteForEmail.venue_name))>
        <tr>
          <td style="padding:5px 0;font-size:13px;font-weight:700;color:#emailTheme.mutedText#;font-family:Arial,sans-serif;vertical-align:top">Venue</td>
          <td style="padding:5px 0;font-size:13px;color:#emailTheme.bodyText#;font-family:Arial,sans-serif">
            #HTMLEditFormat(trim(qSiteForEmail.venue_name))#
            <cfif len(trim(qSiteForEmail.venue_address))><br>#HTMLEditFormat(trim(qSiteForEmail.venue_address))#</cfif>
          </td>
        </tr>
        </cfif>
      </table>
    </td></tr>
    </table>

    <p style="margin:0 0 16px 0;color:#emailTheme.bodyText#;font-size:15px;line-height:1.7;font-family:#emailTheme.fontStack#">
      This email is simply to let you know that you've been selected as the couple's DJ.
    </p>
    <p style="margin:0 0 16px 0;color:#emailTheme.bodyText#;font-size:15px;line-height:1.7;font-family:#emailTheme.fontStack#">
      As they continue planning their wedding, they'll be creating a detailed music worksheet that will include:
    </p>

    <table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0" style="margin:0 0 24px 0">
    <cfloop list="Ceremony music,Wedding party processional songs,Bride's processional song,Recessional music,Reception music,Grand entrance songs,First dance and parent dances,Dinner music,Cake cutting and bouquet toss and other special moments,Dance floor playlist,Do Not Play list,Special requests and notes" index="djBullet">
    <tr><td style="padding:4px 0 4px 16px;font-size:14px;color:#emailTheme.bodyText#;font-family:#emailTheme.fontStack#;line-height:1.5">
      <span style="color:#emailTheme.accentColor#;margin-right:8px">&##9829;</span> #HTMLEditFormat(djBullet)#
    </td></tr>
    </cfloop>
    </table>

    <p style="margin:0 0 16px 0;color:#emailTheme.bodyText#;font-size:15px;line-height:1.7;font-family:#emailTheme.fontStack#">
      Once the couple has finalized their selections, you'll receive a professionally organized playlist with everything you need to help make their wedding day unforgettable.
    </p>
    <p style="margin:0 0 32px 0;color:#emailTheme.bodyText#;font-size:15px;line-height:1.7;font-family:#emailTheme.fontStack#">
      Thank you for being part of their celebration. We look forward to helping make the day a success!
    </p>

    <hr style="border:0;border-top:1px solid #emailTheme.dividerColor#;margin:0 0 24px 0">

    <p style="margin:0 0 4px 0;color:#emailTheme.bodyText#;font-size:14px;font-family:#emailTheme.fontStack#">Warm regards,</p>
    <p style="margin:0 0 4px 0;color:#emailTheme.bodyText#;font-size:14px;font-weight:700;font-family:#emailTheme.fontStack#">The DigitalWeddings.love Team</p>
    <p style="margin:0;color:#emailTheme.mutedText#;font-size:13px;font-style:italic;font-family:#emailTheme.fontStack#">Making wedding planning simple, organized, and stress-free.</p>

  </td></tr>

  <!--- Footer --->
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
