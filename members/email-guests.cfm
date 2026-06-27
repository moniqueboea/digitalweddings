<cfinclude template="../includes/auth-check.cfm">
<cfset pageTitle = "Email Guests | digitalweddings.love">
<cfset activePage = "email-guests">
<cfset userId = session.user.id>

<cfparam name="form.action"       default="">
<cfparam name="form.recipientGroup" default="all">
<cfparam name="form.emailSubject"   default="">
<cfparam name="form.emailBody"      default="">

<!--- Load published wedding site --->
<cfquery name="qSite" datasource="#application.config.datasource#">
    SELECT wedding_site_id, couple_name_1, couple_name_2, wedding_date,
           venue_name, venue_address, slug, template, invite_subject
    FROM dbo.WeddingSites
    WHERE user_id  = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
      AND published = 1
    ORDER BY created_at DESC
</cfquery>

<!--- Guest counts for preview (only guests with a valid email, distinct by email) --->
<cfquery name="qCountAll" datasource="#application.config.datasource#">
    SELECT COUNT(DISTINCT email) AS cnt FROM dbo.Guests
    WHERE user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
      AND email IS NOT NULL AND LEN(LTRIM(RTRIM(email))) > 0
</cfquery>
<cfquery name="qCountRsvp" datasource="#application.config.datasource#">
    SELECT COUNT(DISTINCT email) AS cnt FROM dbo.Guests
    WHERE user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
      AND email IS NOT NULL AND LEN(LTRIM(RTRIM(email))) > 0
      AND rsvp_status IN ('attending','declined','maybe')
</cfquery>
<cfquery name="qCountPending" datasource="#application.config.datasource#">
    SELECT COUNT(DISTINCT email) AS cnt FROM dbo.Guests
    WHERE user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
      AND email IS NOT NULL AND LEN(LTRIM(RTRIM(email))) > 0
      AND (rsvp_status IS NULL OR rsvp_status = '' OR rsvp_status = 'pending')
</cfquery>

<cfset countAll     = qCountAll.cnt>
<cfset countRsvp    = qCountRsvp.cnt>
<cfset countPending = qCountPending.cnt>

<!--- ─── PREVIEW ──────────────────────────────────────────────────────────── --->
<cfif form.action EQ "preview_bulk" AND qSite.recordCount>

    <cfif !len(trim(form.emailSubject))>
        <cflocation url="email-guests.cfm?error=nosubject&group=#URLEncodedFormat(form.recipientGroup)#&frompreview=1" addToken="false">
    </cfif>
    <cfif !len(trim(form.emailBody))>
        <cflocation url="email-guests.cfm?error=nobody&group=#URLEncodedFormat(form.recipientGroup)#&frompreview=1" addToken="false">
    </cfif>

    <cfset qSiteForEmail    = qSite>
    <cfinclude template="email-theme-helper.cfm">
    <cfset emailSiteLink    = "https://digitalweddings.love/site.cfm?slug=" & URLEncodedFormat(qSite.slug)>
    <cfset emailMessageBody = trim(form.emailBody)>
    <cfset emailGuestName = len(trim(session.user.full_name)) ? trim(session.user.full_name) : "Guest">

    <cftry>
        <cfmail to="#session.user.email#"
                from="#application.config.mailFrom#"
                replyto="#session.user.email#"
                server="localhost"
                port="25"
                subject="[PREVIEW] #trim(form.emailSubject)#"
                type="html"
                timeout="60"><cfinclude template="email-announcement-body.cfm"></cfmail>
        <cflocation url="email-guests.cfm?preview=1&group=#URLEncodedFormat(form.recipientGroup)#" addToken="false">
    <cfcatch>
        <cflocation url="email-guests.cfm?error=previewfail&group=#URLEncodedFormat(form.recipientGroup)#" addToken="false">
    </cfcatch>
    </cftry>

</cfif>

<!--- ─── SEND ─────────────────────────────────────────────────────────────── --->
<cfif form.action EQ "send_bulk" AND qSite.recordCount>

    <cfif !len(trim(form.emailSubject))>
        <cflocation url="email-guests.cfm?error=nosubject" addToken="false">
    </cfif>
    <cfif !len(trim(form.emailBody))>
        <cflocation url="email-guests.cfm?error=nobody" addToken="false">
    </cfif>

    <!--- Build recipient query based on group --->
    <cfif form.recipientGroup EQ "rsvp">
        <cfquery name="qRecipients" datasource="#application.config.datasource#">
            SELECT MIN(guest_id) AS guest_id, MAX(name) AS name, email
            FROM dbo.Guests
            WHERE user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
              AND email IS NOT NULL AND LEN(LTRIM(RTRIM(email))) > 0
              AND rsvp_status IN ('attending','declined','maybe')
            GROUP BY email
        </cfquery>
    <cfelseif form.recipientGroup EQ "pending">
        <cfquery name="qRecipients" datasource="#application.config.datasource#">
            SELECT MIN(guest_id) AS guest_id, MAX(name) AS name, email
            FROM dbo.Guests
            WHERE user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
              AND email IS NOT NULL AND LEN(LTRIM(RTRIM(email))) > 0
              AND (rsvp_status IS NULL OR rsvp_status = '' OR rsvp_status = 'pending')
            GROUP BY email
        </cfquery>
    <cfelse>
        <cfquery name="qRecipients" datasource="#application.config.datasource#">
            SELECT MIN(guest_id) AS guest_id, MAX(name) AS name, email
            FROM dbo.Guests
            WHERE user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
              AND email IS NOT NULL AND LEN(LTRIM(RTRIM(email))) > 0
            GROUP BY email
        </cfquery>
    </cfif>

    <cfif !qRecipients.recordCount>
        <cflocation url="email-guests.cfm?error=noguests&group=#URLEncodedFormat(form.recipientGroup)#" addToken="false">
    </cfif>

    <!--- Set up theme once --->
    <cfset qSiteForEmail = qSite>
    <cfinclude template="email-theme-helper.cfm">
    <cfset emailSiteLink = "https://digitalweddings.love/site.cfm?slug=" & URLEncodedFormat(qSite.slug)>
    <cfset emailMessageBody = trim(form.emailBody)>
    <cfset emailSubjectLine = trim(form.emailSubject)>

    <cfset sentCount  = 0>
    <cfset failCount  = 0>

    <cfloop query="qRecipients">
        <cfset emailGuestName = trim(name)>
        <cftry>
            <cfmail to="#trim(email)#"
                    from="#application.config.mailFrom#"
                    replyto="#session.user.email#"
                    bcc="#session.user.email#"
                    server="localhost"
                    port="25"
                    subject="#emailSubjectLine#"
                    type="html"
                    timeout="60"><cfinclude template="email-announcement-body.cfm"></cfmail>
            <cfset sentCount++>
        <cfcatch>
            <cfset failCount++>
        </cfcatch>
        </cftry>
    </cfloop>

    <cflocation url="email-guests.cfm?sent=#sentCount#&failed=#failCount#" addToken="false">

</cfif>

<!--- ─── PAGE ────────────────────────────────────────────────────────────── --->
<cfinclude template="../includes/layout-start.cfm">

<cfparam name="url.sent"        default="">
<cfparam name="url.failed"      default="0">
<cfparam name="url.error"       default="">
<cfparam name="url.group"       default="">
<cfparam name="url.preview"     default="">
<cfparam name="url.frompreview" default="">

<section style="padding:60px 0">
<div class="container" style="max-width:760px">

    <div class="page-header">
        <p class="eyebrow">Guest Communications</p>
        <h1>Email <span class="script">Your Guests</span></h1>
    </div>

    <!--- No published site warning --->
    <cfif !qSite.recordCount>
    <div class="alert" style="background:#FFF8E1;border:1px solid #FFD54F;color:#5D4037;padding:20px 24px;border-radius:8px;margin-bottom:32px">
        <strong>No published wedding site found.</strong>
        You need a published wedding website before you can email guests.
        <a href="/members/wedding-sites.cfm" style="color:#B8860B;font-weight:600;margin-left:8px">Go to Wedding Sites &rarr;</a>
    </div>
    </cfif>

    <!--- Success banner --->
    <cfif isNumeric(url.sent) AND url.sent GT 0>
    <div class="alert alert-success" style="display:flex;align-items:center;gap:14px;padding:20px 24px;margin-bottom:32px;border-radius:8px">
        <span style="font-size:24px">&#10003;</span>
        <div>
            <strong>Message sent!</strong>
            Your message was delivered to <strong><cfoutput>#url.sent#</cfoutput></strong> guest<cfoutput>#url.sent NEQ 1 ? 's' : ''#</cfoutput>.
            <cfif isNumeric(url.failed) AND url.failed GT 0>
            <span style="color:#c0392b;margin-left:8px">(<cfoutput>#url.failed#</cfoutput> failed to send.)</span>
            </cfif>
        </div>
    </div>
    </cfif>

    <!--- Preview sent banner --->
    <cfif url.preview EQ "1">
    <div class="alert alert-success" style="display:flex;align-items:center;gap:14px;padding:20px 24px;margin-bottom:32px;border-radius:8px">
        <span style="font-size:24px">&#128233;</span>
        <div>
            <strong>Preview sent!</strong>
            Check <cfoutput>#HTMLEditFormat(session.user.email)#</cfoutput> to see exactly how your message will look before sending to guests.
        </div>
    </div>
    </cfif>

    <!--- Error banners --->
    <cfif url.error EQ "nosubject">
    <div class="alert alert-error" style="margin-bottom:24px">Please enter a subject line before sending.</div>
    </cfif>
    <cfif url.error EQ "nobody">
    <div class="alert alert-error" style="margin-bottom:24px">Please enter a message before sending.</div>
    </cfif>
    <cfif url.error EQ "previewfail">
    <div class="alert alert-error" style="margin-bottom:24px">Preview could not be sent. Please try again.</div>
    </cfif>
    <cfif url.error EQ "noguests">
    <cfset groupLabel = url.group EQ "rsvp" ? "guests who have RSVP'd" : (url.group EQ "pending" ? "guests who haven't replied" : "guests")>
    <div class="alert alert-error" style="margin-bottom:24px">No <cfoutput>#groupLabel#</cfoutput> with a valid email address were found.</div>
    </cfif>

    <cfif qSite.recordCount>
    <form method="post" action="email-guests.cfm" id="emailGuestsForm">
    <input type="hidden" name="action" value="send_bulk">

    <!--- ── Recipient Group ── --->
    <div class="panel" style="margin-bottom:24px">
        <p class="panel-title">Who are you emailing?</p>

        <div style="display:flex;flex-direction:column;gap:12px">

            <label style="display:flex;align-items:center;gap:14px;padding:16px 20px;border:2px solid var(--border);border-radius:8px;cursor:pointer;transition:border-color .15s" id="lbl-all">
                <input type="radio" name="recipientGroup" value="all" id="grp-all"
                       style="width:18px;height:18px;accent-color:var(--gold);flex-shrink:0"
                       <cfif form.recipientGroup EQ "all">checked</cfif>>
                <div style="flex:1">
                    <span style="font-weight:600;font-size:15px;color:var(--text)">All Guests</span>
                    <span style="color:var(--text-muted);font-size:13px;margin-left:8px">with an email address</span>
                </div>
                <span class="guest-badge" id="badge-all" style="background:var(--charcoal);color:#fff;font-size:12px;font-weight:700;padding:4px 12px;border-radius:20px">
                    <cfoutput>#countAll#</cfoutput>
                </span>
            </label>

            <label style="display:flex;align-items:center;gap:14px;padding:16px 20px;border:2px solid var(--border);border-radius:8px;cursor:pointer;transition:border-color .15s" id="lbl-rsvp">
                <input type="radio" name="recipientGroup" value="rsvp" id="grp-rsvp"
                       style="width:18px;height:18px;accent-color:var(--gold);flex-shrink:0"
                       <cfif form.recipientGroup EQ "rsvp">checked</cfif>>
                <div style="flex:1">
                    <span style="font-weight:600;font-size:15px;color:var(--text)">RSVP Received</span>
                    <span style="color:var(--text-muted);font-size:13px;margin-left:8px">attending, declined, or maybe</span>
                </div>
                <span class="guest-badge" id="badge-rsvp" style="background:##2e7d32;color:#fff;font-size:12px;font-weight:700;padding:4px 12px;border-radius:20px">
                    <cfoutput>#countRsvp#</cfoutput>
                </span>
            </label>

            <label style="display:flex;align-items:center;gap:14px;padding:16px 20px;border:2px solid var(--border);border-radius:8px;cursor:pointer;transition:border-color .15s" id="lbl-pending">
                <input type="radio" name="recipientGroup" value="pending" id="grp-pending"
                       style="width:18px;height:18px;accent-color:var(--gold);flex-shrink:0"
                       <cfif form.recipientGroup EQ "pending">checked</cfif>>
                <div style="flex:1">
                    <span style="font-weight:600;font-size:15px;color:var(--text)">No RSVP Yet</span>
                    <span style="color:var(--text-muted);font-size:13px;margin-left:8px">still waiting to hear back</span>
                </div>
                <span class="guest-badge" id="badge-pending" style="background:##b05a00;color:#fff;font-size:12px;font-weight:700;padding:4px 12px;border-radius:20px">
                    <cfoutput>#countPending#</cfoutput>
                </span>
            </label>

        </div>
    </div>

    <!--- ── Subject ── --->
    <div class="panel" style="margin-bottom:24px">
        <p class="panel-title">Email Subject</p>
        <div class="field" style="margin-bottom:0">
            <input type="text" name="emailSubject" id="emailSubject" required
                   placeholder="e.g. An update from Aisha &amp; Marcus"
                   value="<cfoutput>#HTMLEditFormat(form.emailSubject)#</cfoutput>"
                   style="font-size:15px">
        </div>
    </div>

    <!--- ── Message ── --->
    <div class="panel" style="margin-bottom:24px">
        <p class="panel-title">Your Message</p>
        <div class="field" style="margin-bottom:0">
            <textarea name="emailBody" id="emailBody" rows="8" required
                      placeholder="Type your message here. Each guest will be addressed by name at the top of the email."
                      style="font-size:15px;line-height:1.7;resize:vertical"><cfoutput>#HTMLEditFormat(form.emailBody)#</cfoutput></textarea>
        </div>
        <p style="margin:8px 0 0;font-size:12px;color:var(--text-muted)">Line breaks are preserved in the email. Each guest is greeted personally by name.</p>
    </div>

    <!--- ── Preview bar ── --->
    <div id="previewBar" style="background:var(--surface);border:1px solid var(--border);border-radius:8px;padding:18px 24px;margin-bottom:28px;display:flex;align-items:center;justify-content:space-between;gap:16px">
        <div style="display:flex;align-items:center;gap:10px">
            <span style="font-size:20px">&#128233;</span>
            <span style="font-size:14px;color:var(--text-muted)">This email will be sent to</span>
            <span id="previewCount" style="font-size:18px;font-weight:700;color:var(--text)"><cfoutput>#countAll#</cfoutput></span>
            <span id="previewLabel" style="font-size:14px;color:var(--text-muted)">guest<cfoutput>#countAll NEQ 1 ? 's' : ''#</cfoutput></span>
        </div>
        <cfoutput>
        <span style="font-size:13px;color:var(--gold);font-weight:600">#HTMLEditFormat(qSite.couple_name_1)# &amp; #HTMLEditFormat(qSite.couple_name_2)#</span>
        </cfoutput>
    </div>

    <!--- ── Buttons ── --->
    <div style="display:flex;gap:12px;align-items:center;flex-wrap:wrap">
        <button type="submit" class="btn btn-primary btn-lg" id="sendBtn"
                onclick="return confirmSend()">
            Send to Guests
        </button>
        <button type="button" class="btn btn-ghost btn-lg" onclick="sendPreview()">
            &#128233; Send Preview to Myself
        </button>
        <a href="guests.cfm" class="btn btn-ghost btn-lg">Back to Guest List</a>
    </div>
    <p style="margin:12px 0 0;font-size:12px;color:var(--text-muted)">
        Preview sends a sample to <cfoutput>#HTMLEditFormat(session.user.email)#</cfoutput> so you can check how it looks before sending to guests.
    </p>

    </form>
    </cfif>

</div>
</section>

<script>
(function(){
  var counts = {
    all:     <cfoutput>#countAll#</cfoutput>,
    rsvp:    <cfoutput>#countRsvp#</cfoutput>,
    pending: <cfoutput>#countPending#</cfoutput>
  };
  var labels = {
    all:     'all guests',
    rsvp:    'guests who have RSVP\'d',
    pending: 'guests who haven\'t replied yet'
  };
  var radios = document.querySelectorAll('input[name="recipientGroup"]');
  var countEl = document.getElementById('previewCount');
  var labelEl = document.getElementById('previewLabel');
  var lblEls  = { all: document.getElementById('lbl-all'), rsvp: document.getElementById('lbl-rsvp'), pending: document.getElementById('lbl-pending') };

  function update(val) {
    var n = counts[val] || 0;
    countEl.textContent = n;
    labelEl.textContent = n === 1 ? 'guest' : 'guests';
    Object.keys(lblEls).forEach(function(k) {
      lblEls[k].style.borderColor = k === val ? 'var(--gold)' : 'var(--border)';
    });
  }

  radios.forEach(function(r) {
    r.addEventListener('change', function(){ update(this.value); });
    if (r.checked) update(r.value);
  });
})();

function sendPreview() {
  var subj = document.getElementById('emailSubject').value.trim();
  var body = document.getElementById('emailBody').value.trim();
  if (!subj) { alert('Please enter a subject line first.'); return; }
  if (!body) { alert('Please enter a message first.'); return; }
  var actionInput = document.querySelector('#emailGuestsForm input[name="action"]');
  var orig = actionInput.value;
  actionInput.value = 'preview_bulk';
  document.getElementById('emailGuestsForm').submit();
  actionInput.value = orig;
}

function confirmSend() {
  var radios = document.querySelectorAll('input[name="recipientGroup"]');
  var group  = 'all';
  radios.forEach(function(r){ if(r.checked) group = r.value; });
  var counts = { all: <cfoutput>#countAll#</cfoutput>, rsvp: <cfoutput>#countRsvp#</cfoutput>, pending: <cfoutput>#countPending#</cfoutput> };
  var n      = counts[group] || 0;
  var subj   = document.getElementById('emailSubject').value.trim();
  var body   = document.getElementById('emailBody').value.trim();
  if (!subj) { alert('Please enter a subject line.'); return false; }
  if (!body) { alert('Please enter a message.'); return false; }
  if (n === 0) { alert('No guests in this group have an email address.'); return false; }
  return confirm('Send "' + subj + '" to ' + n + ' guest' + (n !== 1 ? 's' : '') + '?');
}
</script>

<cfinclude template="../includes/layout-end.cfm">
