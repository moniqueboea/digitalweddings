<cfparam name="url.slug"          default="">
<cfparam name="url.success"       default="">
<cfparam name="url.error"         default="">
<cfparam name="url.alreadyrsvp"   default="">
<cfparam name="url.currentstatus" default="">
<cfparam name="url.email"         default="">

<cfif !len(trim(url.slug))>
    <cflocation url="/index.cfm" addToken="false">
</cfif>

<cfquery name="site" datasource="#application.config.datasource#">
    SELECT wedding_site_id, couple_name_1, couple_name_2, wedding_date, venue_name, venue_address, dress_code, travel_info, template
    FROM dbo.WeddingSites
    WHERE slug = <cfqueryparam value="#trim(url.slug)#" cfsqltype="cf_sql_varchar">
      AND published = 1
</cfquery>

<cfif !site.recordCount>
<!DOCTYPE html>
<html lang="en">
<head><meta charset="UTF-8"><title>Not Found | digitalweddings.love</title></head>
<body style="font-family:Georgia,serif;text-align:center;padding:80px 24px;background:#FDFBF7">
    <h1>Wedding Site Not Found</h1>
    <a href="/index.cfm" style="color:#B8860B">Return Home</a>
</body>
</html>
<cfabort>
</cfif>

<!--- Load template theme --->
<cfset qSiteForEmail = site>
<cfinclude template="members/email-theme-helper.cfm">

<!--- Guest list for plus-one JS detection (name + email) --->
<cfquery name="qGuests" datasource="#application.config.datasource#">
    SELECT name, email, plus_one, guest_id FROM dbo.Guests
    WHERE user_id = (SELECT user_id FROM dbo.WeddingSites WHERE wedding_site_id = <cfqueryparam value="#site.wedding_site_id#" cfsqltype="cf_sql_bigint">)
      AND plus_one = 1
</cfquery>
<cfset guestJson = "[">
<cfoutput query="qGuests">
<cfset guestJson = guestJson & '{"name":"' & JSStringFormat(name) & '","email":"' & JSStringFormat(lCase(trim(email))) & '","id":#guest_id#},'>
</cfoutput>
<cfset guestJson = guestJson & "]">

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title><cfoutput>#HTMLEditFormat(site.couple_name_1)# &amp; #HTMLEditFormat(site.couple_name_2)# | RSVP</cfoutput></title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Cormorant+Garamond:ital,wght@0,300;0,400;0,600;1,400&family=Great+Vibes&family=Jost:wght@300;400;500&family=Montserrat:wght@300;400;600&display=swap" rel="stylesheet">
<cfoutput>
<style>
*{box-sizing:border-box;margin:0;padding:0}
body{background:#emailTheme.bodyBg#;font-family:#emailTheme.fontStack#;color:#emailTheme.bodyText#;min-height:100vh}
input,select,textarea{width:100%;padding:12px 14px;border:1.5px solid #emailTheme.dividerColor#;border-radius:4px;font-size:15px;font-family:#emailTheme.fontStack#;color:#emailTheme.bodyText#;background:#emailTheme.bodyCardBg#;outline:none;transition:border-color .2s}
input:focus,select:focus,textarea:focus{border-color:#emailTheme.accentColor#}
label{display:block;font-size:11px;letter-spacing:.1em;text-transform:uppercase;color:#emailTheme.mutedText#;margin-bottom:6px;font-family:Arial,Helvetica,sans-serif}
.field{margin-bottom:20px}
</style>
</cfoutput>
</head>
<body>

<!--- Hero header --->
<cfoutput>
<div style="background:#emailTheme.headerBg#;padding:72px 24px 60px;text-align:center">
    <p style="font-size:11px;letter-spacing:5px;text-transform:uppercase;color:#emailTheme.accentColor#;margin-bottom:16px;font-family:Arial,Helvetica,sans-serif">#HTMLEditFormat(emailTheme.eyebrow)#</p>
    <h1 style="font-size:clamp(36px,7vw,76px);color:#emailTheme.headerText#;font-family:#emailTheme.headingFont#;font-weight:#emailTheme.headingWeight#;line-height:1.15;letter-spacing:.02em">
        #HTMLEditFormat(site.couple_name_1)# &amp; #HTMLEditFormat(site.couple_name_2)#
    </h1>
    <cfif len(site.wedding_date)>
    <p style="margin-top:18px;font-size:14px;letter-spacing:.15em;text-transform:uppercase;color:#emailTheme.accentColor#;font-family:Arial,Helvetica,sans-serif">
        #dateFormat(site.wedding_date,'mmmm d, yyyy')#
    </p>
    </cfif>
    <cfif len(site.venue_name)>
    <p style="margin-top:10px;color:#emailTheme.headerText#;opacity:.7;font-size:15px">
        #HTMLEditFormat(site.venue_name)#<cfif len(site.venue_address)> &bull; #HTMLEditFormat(site.venue_address)#</cfif>
    </p>
    </cfif>
    <!--- Decorative divider --->
    <div style="display:flex;align-items:center;max-width:400px;margin:32px auto 0">
        <div style="flex:1;height:1px;background:#emailTheme.accentColor#;opacity:.3"></div>
        <span style="padding:0 14px;color:#emailTheme.accentColor#;font-size:18px;font-family:Georgia,serif">&##10022;</span>
        <div style="flex:1;height:1px;background:#emailTheme.accentColor#;opacity:.3"></div>
    </div>
</div>
</cfoutput>

<!--- RSVP form section --->
<cfoutput>
<div style="background:#emailTheme.bodyBg#;padding:72px 24px;min-height:60vh">
<div style="max-width:520px;margin:0 auto">

    <div style="text-align:center;margin-bottom:40px">
        <p style="font-size:11px;letter-spacing:5px;text-transform:uppercase;color:#emailTheme.accentColor#;margin-bottom:12px;font-family:Arial,Helvetica,sans-serif">RSVP</p>
        <h2 style="font-size:clamp(28px,5vw,44px);color:#emailTheme.bodyText#;font-family:#emailTheme.headingFont#;font-weight:#emailTheme.headingWeight#">Will You Join Us?</h2>
        <p style="margin-top:12px;color:#emailTheme.mutedText#;font-size:14px;line-height:1.7;font-family:Arial,Helvetica,sans-serif">
            Enter the email address your invitation was sent to.
        </p>
    </div>

    <!--- Already RSVPd notice --->
    <cfif url.alreadyrsvp EQ "1">
    <cfset statusLabels = {attending:"Yes, I'll be there!", declined:"Sorry, I can't make it", maybe:"I'm not sure yet", pending:"Pending"}>
    <cfset currentLabel = structKeyExists(statusLabels, url.currentstatus) ? statusLabels[url.currentstatus] : url.currentstatus>
    <div style="background:#emailTheme.bodyCardBg#;border:2px solid #emailTheme.accentColor#;border-radius:8px;padding:24px 28px;margin-bottom:28px;text-align:center">
        <p style="font-size:22px;margin:0 0 10px">&##128204;</p>
        <p style="font-weight:700;color:#emailTheme.bodyText#;margin:0 0 8px;font-size:16px">You've already RSVP'd!</p>
        <p style="color:#emailTheme.mutedText#;margin:0 0 16px;font-size:14px;line-height:1.6">
            Your current response is <strong>#HTMLEditFormat(currentLabel)#</strong>.<br>
            Would you like to update your RSVP?
        </p>
        <form method="post" action="/rsvp-submit.cfm" style="display:inline">
            <input type="hidden" name="slug"          value="#HTMLEditFormat(url.slug)#">
            <input type="hidden" name="guestEmail"    value="#HTMLEditFormat(url.email)#">
            <input type="hidden" name="confirmUpdate" value="1">
            <input type="hidden" name="rsvpStatus"    value="">
            <input type="hidden" name="plusOneName"   value="">
            <input type="hidden" name="dietaryRestrictions" value="">
            <button type="button" onclick="showUpdateForm()" style="background:#emailTheme.btnBg#;color:#emailTheme.btnText#;border:none;border-radius:#emailTheme.btnRadius#;padding:12px 28px;font-size:14px;font-weight:700;letter-spacing:1px;text-transform:uppercase;cursor:pointer">
                Yes, Update My RSVP
            </button>
        </form>
    </div>
    </cfif>

    <!--- Errors --->
    <cfif url.error EQ "notfound">
    <div style="background:##fff8f0;border:1px solid ##f5c6a0;border-radius:8px;padding:24px 28px;margin-bottom:28px;text-align:center">
        <p style="font-size:22px;margin:0 0 10px">&##9888;</p>
        <p style="font-weight:700;color:##2C2C2C;margin:0 0 8px;font-size:16px">We couldn't find you on the guest list.</p>
        <p style="color:##666;margin:0;font-size:14px;line-height:1.6">
            Please double-check your name or email address as it appears on your invitation.<br>
            If you believe this is a mistake, please contact the wedding couple directly.
        </p>
    </div>
    <cfelseif len(url.error)>
    <div style="background:##fff0f0;border:1px solid ##fca5a5;border-radius:8px;padding:16px 20px;margin-bottom:28px;color:##b91c1c;font-size:14px">
        #HTMLEditFormat(url.error)#
    </div>
    </cfif>

    <!--- Success --->
    <cfif url.success EQ "1">
    <div style="text-align:center;padding:48px 32px;background:#emailTheme.bodyCardBg#;border-radius:8px;border:1px solid #emailTheme.dividerColor#">
        <p style="font-size:2.5rem;margin-bottom:16px;color:#emailTheme.accentColor#">&##10003;</p>
        <h3 style="color:#emailTheme.accentColor#;margin-bottom:12px;font-family:#emailTheme.headingFont#;font-size:28px;font-weight:#emailTheme.headingWeight#">Thank You!</h3>
        <p style="color:#emailTheme.bodyText#;opacity:.8;font-size:15px;line-height:1.7">
            Your RSVP has been submitted.<br>
            #HTMLEditFormat(site.couple_name_1)# and #HTMLEditFormat(site.couple_name_2)# have been notified.
        </p>
    </div>

    <cfelse>
    <!--- Form card --->
    <div id="rsvpFormCard" style="background:#emailTheme.bodyCardBg#;border:1px solid #emailTheme.dividerColor#;border-radius:8px;padding:36px 32px<cfif url.alreadyrsvp EQ '1'>;display:none</cfif>">
        <form method="post" action="/rsvp-submit.cfm" id="rsvpForm">
            <input type="hidden" name="slug"          value="#HTMLEditFormat(url.slug)#">
            <input type="hidden" name="guestId"       id="guestIdField" value="">
            <input type="hidden" name="confirmUpdate" value="<cfif url.alreadyrsvp EQ '1'>1<cfelse>0</cfif>">

            <div class="field">
                <label style="color:#emailTheme.mutedText#">Email Address</label>
                <input type="email" name="guestEmail" id="guestEmailInput" placeholder="your@email.com" autocomplete="email" required value="#HTMLEditFormat(url.email)#">
            </div>

            <div class="field">
                <label style="color:#emailTheme.mutedText#">Will you attend?</label>
                <select name="rsvpStatus" required style="background:#emailTheme.bodyCardBg#">
                    <option value="">Please select...</option>
                    <option value="attending">Yes, I'll be there!</option>
                    <option value="declined">Sorry, I can't make it</option>
                    <option value="maybe">I'm not sure yet</option>
                </select>
            </div>

            <div class="field" id="plusOneField" style="display:none">
                <label style="color:#emailTheme.mutedText#">Plus One Name <span style="color:red">*</span></label>
                <input type="text" name="plusOneName" id="plusOneNameInput" placeholder="Guest's full name">
            </div>

            <div class="field">
                <label style="color:#emailTheme.mutedText#">Dietary Restrictions</label>
                <input type="text" name="dietaryRestrictions" placeholder="e.g. vegetarian, gluten-free, nut allergy">
            </div>

            <button type="submit" style="display:block;width:100%;padding:18px;background:#emailTheme.btnBg#;color:#emailTheme.btnText#;border:none;border-radius:#emailTheme.btnRadius#;font-size:14px;font-weight:700;letter-spacing:2px;text-transform:uppercase;cursor:pointer;font-family:Arial,Helvetica,sans-serif">
                Send RSVP
            </button>
        </form>
    </div>
    </cfif>

</div>
</div>
</cfoutput>


<!--- Footer --->
<cfoutput>
<div style="background:#emailTheme.headerBg#;padding:24px;text-align:center;border-top:1px solid #emailTheme.dividerColor#">
    <p style="font-size:13px;color:#emailTheme.headerText#;opacity:.6;font-family:Arial,Helvetica,sans-serif">
        Powered by <a href="https://digitalweddings.love" style="color:#emailTheme.accentColor#;text-decoration:none">digitalweddings.love</a>
    </p>
</div>
</cfoutput>

<script>
var plusOneGuests    = <cfoutput>#guestJson#</cfoutput>;
var plusOneField     = document.getElementById('plusOneField');
var plusOneNameInput = document.getElementById('plusOneNameInput');

function checkPlusOne() {
    var email = document.getElementById('guestEmailInput').value.toLowerCase().trim();
    var found = false;
    for (var i = 0; i < plusOneGuests.length; i++) {
        var g = plusOneGuests[i];
        if (email && g.email && g.email === email) {
            found = true;
            document.getElementById('guestIdField').value = g.id;
            break;
        }
    }
    plusOneField.style.display = found ? 'block' : 'none';
    plusOneNameInput.required  = found;
}

document.getElementById('guestEmailInput').addEventListener('blur', checkPlusOne);

document.getElementById('rsvpForm').addEventListener('submit', function(e) {
    if (plusOneField.style.display !== 'none' && !plusOneNameInput.value.trim()) {
        e.preventDefault();
        plusOneNameInput.focus();
        plusOneNameInput.style.borderColor = 'red';
        var msg = plusOneField.querySelector('.plus-one-error');
        if (!msg) {
            msg = document.createElement('p');
            msg.className = 'plus-one-error';
            msg.style.cssText = 'color:red;font-size:13px;margin:4px 0 0';
            msg.textContent = 'Please enter your plus one\'s name.';
            plusOneField.appendChild(msg);
        }
    }
});

function showUpdateForm() {
    var card = document.getElementById('rsvpFormCard');
    if (card) {
        card.style.display = 'block';
        card.scrollIntoView({behavior:'smooth', block:'start'});
    }
}
</script>

</body>
</html>
