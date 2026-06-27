<!---
  email-wedding-party-body.cfm — invite email sent when a wedding party member is added.

  Required variables set before cfinclude:
    emailTheme      — struct from email-theme-helper.cfm
    qSiteForEmail   — query row: couple_name_1, couple_name_2, wedding_date, slug
    wpMemberName    — string: member's full name
    wpRole          — string: party role (e.g. "Maid of Honor")
    emailSiteLink   — full URL to the wedding website
--->
<cfparam name="wpMemberName" default="">
<cfparam name="wpRole"       default="">
<cfoutput>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<meta name="x-apple-disable-message-reformatting">
<title>You're invited to be in the wedding!</title>
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
  <tr><td align="center" style="background:#emailTheme.headerBg#;padding:44px 40px 36px">
    <p style="margin:0 0 14px 0;color:#emailTheme.accentColor#;font-size:11px;letter-spacing:5px;text-transform:uppercase;font-family:Arial,Helvetica,sans-serif">
      You're Invited to Be In the Wedding
    </p>
    <h1 style="margin:0;color:#emailTheme.headerText#;font-family:#emailTheme.headingFont#;font-size:40px;font-weight:#emailTheme.headingWeight#;line-height:1.2;letter-spacing:0.02em">
      #HTMLEditFormat(qSiteForEmail.couple_name_1)#
      <span style="font-size:32px;opacity:0.7">&amp;</span>
      #HTMLEditFormat(qSiteForEmail.couple_name_2)#
    </h1>
    <cfif len(trim(qSiteForEmail.wedding_date))>
    <p style="margin:18px 0 0 0;color:#emailTheme.accentColor#;font-size:13px;letter-spacing:4px;text-transform:uppercase;font-family:Arial,Helvetica,sans-serif">
      #dateFormat(qSiteForEmail.wedding_date,'mmmm d, yyyy')#
    </p>
    </cfif>
    <table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0" style="margin-top:28px">
    <tr>
      <td style="height:1px;background-color:#emailTheme.accentColor#;opacity:0.25;font-size:0;line-height:0">&nbsp;</td>
      <td width="32" align="center" style="color:#emailTheme.accentColor#;font-size:18px;padding:0 10px;line-height:1;font-family:Georgia,serif">&##10022;</td>
      <td style="height:1px;background-color:#emailTheme.accentColor#;opacity:0.25;font-size:0;line-height:0">&nbsp;</td>
    </tr>
    </table>
  </td></tr>

  <!--- Body --->
  <tr><td align="center" style="background:#emailTheme.bodyCardBg#;padding:44px 48px 40px">

    <!--- Greeting --->
    <cfif len(trim(wpMemberName))>
    <p style="margin:0 0 6px 0;color:#emailTheme.mutedText#;font-size:12px;letter-spacing:3px;text-transform:uppercase;font-family:Arial,Helvetica,sans-serif">Dear</p>
    <p style="margin:0 0 32px 0;color:#emailTheme.bodyText#;font-size:28px;font-family:#emailTheme.headingFont#;font-weight:#emailTheme.headingWeight#;line-height:1.2">#HTMLEditFormat(trim(wpMemberName))#,</p>
    </cfif>

    <!--- Message --->
    <p style="margin:0 0 28px 0;color:#emailTheme.bodyText#;font-size:17px;line-height:1.85;font-family:#emailTheme.fontStack#">
      We have something very special to ask you.
      <strong>#HTMLEditFormat(qSiteForEmail.couple_name_1)#</strong> and
      <strong>#HTMLEditFormat(qSiteForEmail.couple_name_2)#</strong> would be
      deeply honored to have you join their wedding party as
      <strong>#HTMLEditFormat(wpRole)#</strong>.
    </p>
    <p style="margin:0 0 36px 0;color:#emailTheme.bodyText#;font-size:17px;line-height:1.85;font-family:#emailTheme.fontStack#">
      Your love and support means the world to them. They hope you'll say yes!
    </p>

    <!--- Role card --->
    <table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0" style="margin:0 0 36px 0">
    <tr><td style="background:#emailTheme.bodyBg#;border:1px solid #emailTheme.dividerColor#;border-radius:6px;padding:24px 28px;text-align:center">
      <p style="margin:0 0 8px 0;color:#emailTheme.mutedText#;font-size:10px;letter-spacing:4px;text-transform:uppercase;font-family:Arial,Helvetica,sans-serif">Your Role</p>
      <p style="margin:0;color:#emailTheme.bodyText#;font-size:22px;font-weight:bold;font-family:#emailTheme.headingFont#">#HTMLEditFormat(wpRole)#</p>
      <cfif len(trim(qSiteForEmail.wedding_date))>
      <p style="margin:10px 0 0 0;color:#emailTheme.mutedText#;font-size:13px;font-family:Arial,Helvetica,sans-serif">
        #dateFormat(qSiteForEmail.wedding_date,'dddd, mmmm d, yyyy')#
      </p>
      </cfif>
    </td></tr>
    </table>

    <!--- Website button --->
    <table role="presentation" cellpadding="0" cellspacing="0" border="0" style="margin:0 auto 16px">
    <tr><td align="center" style="border-radius:#emailTheme.btnRadius#;background:#emailTheme.btnBg#">
      <a href="#emailSiteLink#"
         style="display:inline-block;padding:18px 48px;background:#emailTheme.btnBg#;color:#emailTheme.btnText#;font-family:Arial,Helvetica,sans-serif;font-size:14px;font-weight:700;letter-spacing:2px;text-transform:uppercase;text-decoration:none;border-radius:#emailTheme.btnRadius#">
        View Our Wedding Website
      </a>
    </td></tr>
    </table>

    <p style="margin:0 0 32px 0;font-family:Arial,Helvetica,sans-serif;font-size:13px;text-align:center">
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
      <span style="color:##cc0022;margin-left:5px">&##9829;</span>
    </p>
    <p style="margin:0;color:#emailTheme.headerText#;font-size:11px;opacity:0.5;font-family:Arial,Helvetica,sans-serif">Celebrating love, one wedding at a time.</p>
  </td></tr>

</table>
</td></tr>
</table>
</body>
</html>
</cfoutput>
