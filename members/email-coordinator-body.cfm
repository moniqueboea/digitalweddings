<!---
  email-coordinator-body.cfm - coordinator email HTML

  Required variables set before cfinclude:
    coordSite       - query row: couple_name_1, couple_name_2, wedding_date, slug, coord_name
    coordSection    - string: section label or "Complete Wedding Planning Package"
    coordSentAt     - string: formatted date/time sent
    coordSiteUrl    - full URL to wedding website (or "")
    coordBodyHtml   - pre-built HTML string of the section content
--->
<cfparam name="coordSiteUrl"  default="">
<cfoutput>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>Wedding Coordinator Package</title>
</head>
<body style="margin:0;padding:0;background-color:##f4f4f4;font-family:Arial,Helvetica,sans-serif">
<table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0" style="background:##f4f4f4">
<tr><td align="center" style="padding:40px 12px">
<table role="presentation" width="600" cellpadding="0" cellspacing="0" border="0" style="max-width:600px;width:100%">

  <!--- Header --->
  <tr><td align="center" style="background:##2c3e2e;padding:40px 40px 32px;border-radius:8px 8px 0 0">
    <p style="margin:0 0 8px 0;color:##a8c5a0;font-size:11px;letter-spacing:5px;text-transform:uppercase;font-family:Arial,Helvetica,sans-serif">
      Wedding Coordinator Package
    </p>
    <h1 style="margin:0;color:##ffffff;font-family:Georgia,serif;font-size:30px;font-weight:normal;line-height:1.2">
      #HTMLEditFormat(coordSite.couple_name_1)# &amp; #HTMLEditFormat(coordSite.couple_name_2)#
    </h1>
    <cfif len(trim(coordSite.wedding_date))>
    <p style="margin:12px 0 0 0;color:##a8c5a0;font-size:12px;letter-spacing:3px;text-transform:uppercase;font-family:Arial,Helvetica,sans-serif">
      #dateFormat(coordSite.wedding_date,'mmmm d, yyyy')#
    </p>
    </cfif>
  </td></tr>

  <!--- Section label + meta --->
  <tr><td style="background:##7A9E7E;padding:14px 40px">
    <p style="margin:0;color:##ffffff;font-size:13px;font-weight:700;letter-spacing:1px;text-transform:uppercase;font-family:Arial,Helvetica,sans-serif">
      #HTMLEditFormat(coordSection)#
    </p>
  </td></tr>

  <!--- Body --->
  <tr><td style="background:##ffffff;padding:36px 40px">

    <p style="margin:0 0 20px 0;color:##555;font-size:13px;font-family:Arial,Helvetica,sans-serif">
      <strong>Sent to coordinator:</strong> #HTMLEditFormat(coordSentAt)#
      <cfif len(trim(coordSite.coord_name))> &nbsp;&bull;&nbsp; <strong>Coordinator:</strong> #HTMLEditFormat(coordSite.coord_name)#</cfif>
    </p>
    <cfif len(trim(coordSiteUrl))>
    <p style="margin:0 0 24px 0;color:##555;font-size:13px;font-family:Arial,Helvetica,sans-serif">
      <strong>Wedding website:</strong> <a href="#coordSiteUrl#" style="color:##7A9E7E">#coordSiteUrl#</a>
    </p>
    </cfif>

    <hr style="border:0;border-top:1px solid ##e8e8e8;margin:0 0 28px 0">

    #coordBodyHtml#

  </td></tr>

  <!--- Footer --->
  <tr><td align="center" style="background:##2c3e2e;padding:20px 40px;border-radius:0 0 8px 8px">
    <p style="margin:0;color:##a8c5a0;font-size:12px;font-family:Arial,Helvetica,sans-serif">
      <a href="https://digitalweddings.love" style="color:##a8c5a0;text-decoration:none">digitalweddings.love</a>
      &nbsp;&#9829;&nbsp; Celebrating love, one wedding at a time.
    </p>
  </td></tr>

</table>
</td></tr>
</table>
</body>
</html>
</cfoutput>
