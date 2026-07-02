<!---
  email-dj-playlist-body.cfm - Full wedding playlist email for DJ

  Required variables:
    emailTheme      - struct from email-theme-helper.cfm
    qSiteForEmail   - query row with couple/venue/dj fields
    qCeremony       - query: playlist_type='ceremony', all columns, ordered by category/sort_order
    qReception      - query: playlist_type='reception', all columns, ordered by category/sort_order
    djIsTest        - boolean: true adds TEST EMAIL banner
--->
<cfparam name="djIsTest" default="false">
<cfset djCoupleName = HTMLEditFormat(qSiteForEmail.couple_name_1) & " &amp; " & HTMLEditFormat(qSiteForEmail.couple_name_2)>

<!--- Build ceremony sections --->
<cfset ceremonyCats = "Pre-Ceremony Music,Wedding Party Processional,Bride's Processional,Ceremony Moments,Recessional">
<!--- Build reception sections (Do Not Play last) --->
<cfset receptionCats = "Cocktail Hour,Wedding Party Entrance,Couple's Grand Entrance,First Dance,Parent Dances,Dinner Music,Cake Cutting,Bouquet Toss,Garter Toss,Open Dance Floor,Last Dance,Do Not Play">

<cfoutput>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>Wedding Music Playlist - #djCoupleName#</title>
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
    <p style="margin:0 0 10px 0;color:#emailTheme.accentColor#;font-size:11px;letter-spacing:5px;text-transform:uppercase;font-family:Arial,Helvetica,sans-serif">
      Wedding Music Worksheet
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

  <!--- Wedding Information --->
  <tr><td style="background:#emailTheme.bodyCardBg#;padding:32px 40px 0">
    <p style="margin:0 0 16px 0;color:#emailTheme.accentColor#;font-size:11px;font-weight:700;letter-spacing:4px;text-transform:uppercase;font-family:Arial,sans-serif;border-bottom:2px solid #emailTheme.accentColor#;padding-bottom:8px">
      Wedding Information
    </p>
    <table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0" style="margin-bottom:8px">
      <cfif len(trim(qSiteForEmail.couple_name_1))>
      <tr>
        <td style="padding:4px 0;font-size:13px;font-weight:700;color:#emailTheme.mutedText#;font-family:Arial,sans-serif;width:38%;vertical-align:top">Couple</td>
        <td style="padding:4px 0;font-size:13px;color:#emailTheme.bodyText#;font-family:Arial,sans-serif">#HTMLEditFormat(qSiteForEmail.couple_name_1)# &amp; #HTMLEditFormat(qSiteForEmail.couple_name_2)#</td>
      </tr>
      </cfif>
      <cfif len(trim(qSiteForEmail.wedding_date))>
      <tr>
        <td style="padding:4px 0;font-size:13px;font-weight:700;color:#emailTheme.mutedText#;font-family:Arial,sans-serif;vertical-align:top">Wedding Date</td>
        <td style="padding:4px 0;font-size:13px;color:#emailTheme.bodyText#;font-family:Arial,sans-serif">#dateFormat(qSiteForEmail.wedding_date,'mmmm d, yyyy')#</td>
      </tr>
      </cfif>
      <cfif len(trim(qSiteForEmail.ceremony_start_time))>
      <tr>
        <td style="padding:4px 0;font-size:13px;font-weight:700;color:#emailTheme.mutedText#;font-family:Arial,sans-serif;vertical-align:top">Ceremony Time</td>
        <td style="padding:4px 0;font-size:13px;color:#emailTheme.bodyText#;font-family:Arial,sans-serif">#HTMLEditFormat(trim(qSiteForEmail.ceremony_start_time))#</td>
      </tr>
      </cfif>
      <cfif len(trim(qSiteForEmail.reception_start_time))>
      <tr>
        <td style="padding:4px 0;font-size:13px;font-weight:700;color:#emailTheme.mutedText#;font-family:Arial,sans-serif;vertical-align:top">Reception Time</td>
        <td style="padding:4px 0;font-size:13px;color:#emailTheme.bodyText#;font-family:Arial,sans-serif">#HTMLEditFormat(trim(qSiteForEmail.reception_start_time))#</td>
      </tr>
      </cfif>
      <cfif len(trim(qSiteForEmail.venue_name))>
      <tr>
        <td style="padding:4px 0;font-size:13px;font-weight:700;color:#emailTheme.mutedText#;font-family:Arial,sans-serif;vertical-align:top">Venue</td>
        <td style="padding:4px 0;font-size:13px;color:#emailTheme.bodyText#;font-family:Arial,sans-serif">
          #HTMLEditFormat(trim(qSiteForEmail.venue_name))#
          <cfif len(trim(qSiteForEmail.venue_address))><br>#HTMLEditFormat(trim(qSiteForEmail.venue_address))#</cfif>
        </td>
      </tr>
      </cfif>
      <cfif len(trim(qSiteForEmail.dj_name))>
      <tr>
        <td style="padding:4px 0;font-size:13px;font-weight:700;color:#emailTheme.mutedText#;font-family:Arial,sans-serif;vertical-align:top">DJ / Company</td>
        <td style="padding:4px 0;font-size:13px;color:#emailTheme.bodyText#;font-family:Arial,sans-serif">#HTMLEditFormat(trim(qSiteForEmail.dj_name))#</td>
      </tr>
      </cfif>
    </table>
    <hr style="border:0;border-top:1px solid #emailTheme.dividerColor#;margin:16px 0 0 0">
  </td></tr>

  <!--- Ceremony Music --->
  <tr><td style="background:#emailTheme.bodyCardBg#;padding:28px 40px 0">
    <p style="margin:0 0 16px 0;color:#emailTheme.accentColor#;font-size:11px;font-weight:700;letter-spacing:4px;text-transform:uppercase;font-family:Arial,sans-serif;border-bottom:2px solid #emailTheme.accentColor#;padding-bottom:8px">
      Ceremony Music
    </p>
    <cfset anyInCeremony = false>
    <cfloop list="#ceremonyCats#" index="cat">
      <cfquery name="qCatSongs" dbtype="query">
        SELECT * FROM qCeremony WHERE category = '#cat#' ORDER BY sort_order
      </cfquery>
      <cfif qCatSongs.recordCount>
        <cfset anyInCeremony = true>
        <p style="margin:0 0 6px 0;font-size:12px;font-weight:700;color:#emailTheme.headerBg#;font-family:Arial,sans-serif;text-transform:uppercase;letter-spacing:1px">#HTMLEditFormat(cat)#</p>
        <table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0" style="border-collapse:collapse;margin-bottom:18px">
          <tr style="background:#emailTheme.bodyBg#">
            <th style="padding:6px 8px;text-align:left;font-size:11px;color:#emailTheme.mutedText#;font-family:Arial,sans-serif;border-bottom:1px solid #emailTheme.dividerColor#;width:34%">Song</th>
            <th style="padding:6px 8px;text-align:left;font-size:11px;color:#emailTheme.mutedText#;font-family:Arial,sans-serif;border-bottom:1px solid #emailTheme.dividerColor#;width:26%">Artist</th>
            <th style="padding:6px 8px;text-align:left;font-size:11px;color:#emailTheme.mutedText#;font-family:Arial,sans-serif;border-bottom:1px solid #emailTheme.dividerColor#">Notes</th>
          </tr>
          <cfloop query="qCatSongs">
          <tr>
            <td style="padding:7px 8px;font-size:13px;color:#emailTheme.bodyText#;font-family:Arial,sans-serif;border-bottom:1px solid #emailTheme.dividerColor#;vertical-align:top">
              #HTMLEditFormat(song_title)#
              <cfif len(trim(music_link))><br><a href="#HTMLEditFormat(trim(music_link))#" style="font-size:11px;color:#emailTheme.accentColor#;text-decoration:none">&#9654; Listen</a></cfif>
            </td>
            <td style="padding:7px 8px;font-size:13px;color:#emailTheme.bodyText#;font-family:Arial,sans-serif;border-bottom:1px solid #emailTheme.dividerColor#;vertical-align:top">#HTMLEditFormat(artist)#</td>
            <td style="padding:7px 8px;font-size:12px;color:#emailTheme.mutedText#;font-family:Arial,sans-serif;border-bottom:1px solid #emailTheme.dividerColor#;vertical-align:top">#HTMLEditFormat(notes)#</td>
          </tr>
          </cfloop>
        </table>
      </cfif>
    </cfloop>

    <!--- Any ceremony songs with uncategorized or custom categories --->
    <cfquery name="qCeremonyOther" dbtype="query">
      SELECT * FROM qCeremony
      WHERE category NOT IN ('Pre-Ceremony Music','Wedding Party Processional','Bride''s Processional','Ceremony Moments','Recessional')
      ORDER BY category, sort_order
    </cfquery>
    <cfif qCeremonyOther.recordCount>
      <cfset prevCat = "">
      <cfloop query="qCeremonyOther">
        <cfif category NEQ prevCat>
          <cfif prevCat NEQ ""></table></cfif>
          <p style="margin:0 0 6px 0;font-size:12px;font-weight:700;color:#emailTheme.headerBg#;font-family:Arial,sans-serif;text-transform:uppercase;letter-spacing:1px">#HTMLEditFormat(category)#</p>
          <table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0" style="border-collapse:collapse;margin-bottom:18px">
            <tr style="background:#emailTheme.bodyBg#">
              <th style="padding:6px 8px;text-align:left;font-size:11px;color:#emailTheme.mutedText#;font-family:Arial,sans-serif;border-bottom:1px solid #emailTheme.dividerColor#;width:34%">Song</th>
              <th style="padding:6px 8px;text-align:left;font-size:11px;color:#emailTheme.mutedText#;font-family:Arial,sans-serif;border-bottom:1px solid #emailTheme.dividerColor#;width:26%">Artist</th>
              <th style="padding:6px 8px;text-align:left;font-size:11px;color:#emailTheme.mutedText#;font-family:Arial,sans-serif;border-bottom:1px solid #emailTheme.dividerColor#">Notes</th>
            </tr>
          <cfset anyInCeremony = true>
          <cfset prevCat = category>
        </cfif>
        <tr>
          <td style="padding:7px 8px;font-size:13px;color:#emailTheme.bodyText#;font-family:Arial,sans-serif;border-bottom:1px solid #emailTheme.dividerColor#;vertical-align:top">
            #HTMLEditFormat(song_title)#
            <cfif len(trim(music_link))><br><a href="#HTMLEditFormat(trim(music_link))#" style="font-size:11px;color:#emailTheme.accentColor#;text-decoration:none">&#9654; Listen</a></cfif>
          </td>
          <td style="padding:7px 8px;font-size:13px;color:#emailTheme.bodyText#;font-family:Arial,sans-serif;border-bottom:1px solid #emailTheme.dividerColor#;vertical-align:top">#HTMLEditFormat(artist)#</td>
          <td style="padding:7px 8px;font-size:12px;color:#emailTheme.mutedText#;font-family:Arial,sans-serif;border-bottom:1px solid #emailTheme.dividerColor#;vertical-align:top">#HTMLEditFormat(notes)#</td>
        </tr>
      </cfloop>
      </table>
    </cfif>
    <cfif NOT anyInCeremony>
      <p style="color:#emailTheme.mutedText#;font-size:13px;font-style:italic;font-family:Arial,sans-serif;margin:0 0 16px 0">No ceremony songs added yet.</p>
    </cfif>
    <hr style="border:0;border-top:1px solid #emailTheme.dividerColor#;margin:8px 0 0 0">
  </td></tr>

  <!--- Reception Music (excluding Do Not Play) --->
  <tr><td style="background:#emailTheme.bodyCardBg#;padding:28px 40px 0">
    <p style="margin:0 0 16px 0;color:#emailTheme.accentColor#;font-size:11px;font-weight:700;letter-spacing:4px;text-transform:uppercase;font-family:Arial,sans-serif;border-bottom:2px solid #emailTheme.accentColor#;padding-bottom:8px">
      Reception Music
    </p>
    <cfset anyInReception = false>
    <cfloop list="Cocktail Hour,Wedding Party Entrance,Couple's Grand Entrance,First Dance,Parent Dances,Dinner Music,Cake Cutting,Bouquet Toss,Garter Toss,Open Dance Floor,Last Dance" index="cat">
      <cfquery name="qRCatSongs" dbtype="query">
        SELECT * FROM qReception WHERE category = '#cat#' ORDER BY sort_order
      </cfquery>
      <cfif qRCatSongs.recordCount>
        <cfset anyInReception = true>
        <p style="margin:0 0 6px 0;font-size:12px;font-weight:700;color:#emailTheme.headerBg#;font-family:Arial,sans-serif;text-transform:uppercase;letter-spacing:1px">#HTMLEditFormat(cat)#</p>
        <table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0" style="border-collapse:collapse;margin-bottom:18px">
          <tr style="background:#emailTheme.bodyBg#">
            <th style="padding:6px 8px;text-align:left;font-size:11px;color:#emailTheme.mutedText#;font-family:Arial,sans-serif;border-bottom:1px solid #emailTheme.dividerColor#;width:34%">Song</th>
            <th style="padding:6px 8px;text-align:left;font-size:11px;color:#emailTheme.mutedText#;font-family:Arial,sans-serif;border-bottom:1px solid #emailTheme.dividerColor#;width:26%">Artist</th>
            <th style="padding:6px 8px;text-align:left;font-size:11px;color:#emailTheme.mutedText#;font-family:Arial,sans-serif;border-bottom:1px solid #emailTheme.dividerColor#">Notes / DJ Instructions</th>
          </tr>
          <cfloop query="qRCatSongs">
          <tr>
            <td style="padding:7px 8px;font-size:13px;color:#emailTheme.bodyText#;font-family:Arial,sans-serif;border-bottom:1px solid #emailTheme.dividerColor#;vertical-align:top">
              #HTMLEditFormat(song_title)#
              <cfif len(trim(music_link))><br><a href="#HTMLEditFormat(trim(music_link))#" style="font-size:11px;color:#emailTheme.accentColor#;text-decoration:none">&#9654; Listen</a></cfif>
            </td>
            <td style="padding:7px 8px;font-size:13px;color:#emailTheme.bodyText#;font-family:Arial,sans-serif;border-bottom:1px solid #emailTheme.dividerColor#;vertical-align:top">#HTMLEditFormat(artist)#</td>
            <td style="padding:7px 8px;font-size:12px;color:#emailTheme.mutedText#;font-family:Arial,sans-serif;border-bottom:1px solid #emailTheme.dividerColor#;vertical-align:top">#HTMLEditFormat(notes)#</td>
          </tr>
          </cfloop>
        </table>
      </cfif>
    </cfloop>
    <cfif NOT anyInReception>
      <p style="color:#emailTheme.mutedText#;font-size:13px;font-style:italic;font-family:Arial,sans-serif;margin:0 0 16px 0">No reception songs added yet.</p>
    </cfif>
    <hr style="border:0;border-top:1px solid #emailTheme.dividerColor#;margin:8px 0 0 0">
  </td></tr>

  <!--- Do Not Play --->
  <cfquery name="qDNP" dbtype="query">
    SELECT * FROM qReception WHERE category = 'Do Not Play' ORDER BY sort_order
  </cfquery>
  <cfif qDNP.recordCount>
  <tr><td style="background:##fff8f8;padding:28px 40px 0;border-left:4px solid ##e53e3e">
    <p style="margin:0 0 16px 0;color:##e53e3e;font-size:11px;font-weight:700;letter-spacing:4px;text-transform:uppercase;font-family:Arial,sans-serif;border-bottom:2px solid ##e53e3e;padding-bottom:8px">
      DO NOT PLAY LIST
    </p>
    <table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0" style="border-collapse:collapse;margin-bottom:18px">
      <tr style="background:##fee2e2">
        <th style="padding:6px 8px;text-align:left;font-size:11px;color:##9b1c1c;font-family:Arial,sans-serif;border-bottom:1px solid ##fca5a5;width:34%">Song</th>
        <th style="padding:6px 8px;text-align:left;font-size:11px;color:##9b1c1c;font-family:Arial,sans-serif;border-bottom:1px solid ##fca5a5;width:26%">Artist</th>
        <th style="padding:6px 8px;text-align:left;font-size:11px;color:##9b1c1c;font-family:Arial,sans-serif;border-bottom:1px solid ##fca5a5">Reason / Notes</th>
      </tr>
      <cfloop query="qDNP">
      <tr>
        <td style="padding:7px 8px;font-size:13px;color:##7b1d1d;font-family:Arial,sans-serif;border-bottom:1px solid ##fca5a5;font-weight:700;vertical-align:top">#HTMLEditFormat(song_title)#</td>
        <td style="padding:7px 8px;font-size:13px;color:##7b1d1d;font-family:Arial,sans-serif;border-bottom:1px solid ##fca5a5;vertical-align:top">#HTMLEditFormat(artist)#</td>
        <td style="padding:7px 8px;font-size:12px;color:##9b1c1c;font-family:Arial,sans-serif;border-bottom:1px solid ##fca5a5;vertical-align:top">#HTMLEditFormat(notes)#</td>
      </tr>
      </cfloop>
    </table>
    <hr style="border:0;border-top:1px solid #emailTheme.dividerColor#;margin:8px 0 0 0">
  </td></tr>
  </cfif>

  <!--- DJ Notes --->
  <cfif len(trim(qSiteForEmail.dj_notes))>
  <tr><td style="background:#emailTheme.bodyCardBg#;padding:28px 40px 0">
    <p style="margin:0 0 12px 0;color:#emailTheme.accentColor#;font-size:11px;font-weight:700;letter-spacing:4px;text-transform:uppercase;font-family:Arial,sans-serif;border-bottom:2px solid #emailTheme.accentColor#;padding-bottom:8px">
      Special DJ Notes
    </p>
    <p style="margin:0 0 16px 0;color:#emailTheme.bodyText#;font-size:14px;line-height:1.7;font-family:#emailTheme.fontStack#;white-space:pre-wrap">#HTMLEditFormat(trim(qSiteForEmail.dj_notes))#</p>
    <hr style="border:0;border-top:1px solid #emailTheme.dividerColor#;margin:8px 0 0 0">
  </td></tr>
  </cfif>

  <!--- Footer --->
  <tr><td align="center" style="background:#emailTheme.headerBg#;padding:20px 40px">
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
