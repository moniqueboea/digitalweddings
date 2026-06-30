<cfinclude template="../includes/auth-check.cfm">
<cfset pageTitle = "Save the Date | digitalweddings.love">
<cfset activePage = "save-the-date">
<cfset userId = session.user.id>

<cfparam name="form.action"         default="">
<cfparam name="form.stdId"          default="0">
<cfparam name="form.recipientName"  default="">
<cfparam name="form.recipientEmail" default="">
<cfparam name="form.rsvpStatus"     default="pending">
<cfparam name="url.sent"            default="">
<cfparam name="url.error"           default="">
<cfparam name="url.msg"             default="">
<cfparam name="url.edit"            default="0">

<!--- Ensure table exists --->
<cftry>
    <cfquery datasource="#application.config.datasource#">
        IF OBJECT_ID('dbo.SaveTheDates','U') IS NULL
        BEGIN
            CREATE TABLE dbo.SaveTheDates (
                save_the_date_id BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
                user_id          BIGINT NOT NULL,
                wedding_site_id  BIGINT NOT NULL,
                recipient_name   NVARCHAR(200) NOT NULL,
                recipient_email  VARCHAR(320)  NOT NULL,
                rsvp_status      VARCHAR(20)   NOT NULL DEFAULT 'pending',
                sent_at          DATETIME2(0)  NULL,
                created_at       DATETIME2(0)  NOT NULL DEFAULT SYSUTCDATETIME(),
                updated_at       DATETIME2(0)  NOT NULL DEFAULT SYSUTCDATETIME(),
                CONSTRAINT FK_STD_Users FOREIGN KEY (user_id) REFERENCES dbo.Users(user_id) ON DELETE CASCADE,
                CONSTRAINT FK_STD_Sites FOREIGN KEY (wedding_site_id) REFERENCES dbo.WeddingSites(wedding_site_id),
                CONSTRAINT CK_STD_Rsvp  CHECK (rsvp_status IN ('pending','attending','declined'))
            );
        END;
        IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='SaveTheDates' AND COLUMN_NAME='sent_at')
            ALTER TABLE dbo.SaveTheDates ADD sent_at DATETIME2(0) NULL;
    </cfquery>
<cfcatch></cfcatch>
</cftry>

<!--- Load the couple's wedding site --->
<cfquery name="qSite" datasource="#application.config.datasource#">
    SELECT wedding_site_id, couple_name_1, couple_name_2, wedding_date,
           venue_name, venue_address, template, slug, hero_image_url, couple_photo_url
    FROM dbo.WeddingSites
    WHERE user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
    ORDER BY created_at DESC
</cfquery>

<cfset hasSite      = qSite.recordCount GT 0>
<cfset hasTemplate  = hasSite AND len(trim(qSite.template))>
<cfset couplePhoto  = "">
<cfif hasSite>
    <cfset couplePhoto = len(trim(qSite.couple_photo_url)) ? trim(qSite.couple_photo_url) : (len(trim(qSite.hero_image_url)) ? trim(qSite.hero_image_url) : "")>
</cfif>
<cfset hasPhoto     = len(couplePhoto)>
<cfset canSend      = hasTemplate AND hasPhoto>

<!--- ── ADD RECIPIENT ── --->
<cfif form.action EQ "add_recipient" AND hasTemplate>
    <cfset rName  = trim(form.recipientName)>
    <cfset rEmail = lCase(trim(form.recipientEmail))>
    <cfif !len(rName) OR !isValid("email", rEmail)>
        <cflocation url="save-the-date.cfm?error=invalid" addToken="false">
    </cfif>
    <!--- Check for duplicate --->
    <cfquery name="qDupe" datasource="#application.config.datasource#">
        SELECT save_the_date_id FROM dbo.SaveTheDates
        WHERE user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
          AND recipient_email = <cfqueryparam value="#rEmail#" cfsqltype="cf_sql_varchar">
    </cfquery>
    <cfif qDupe.recordCount>
        <cflocation url="save-the-date.cfm?error=duplicate" addToken="false">
    </cfif>
    <cfset senderName = trim(qSite.couple_name_1) & " & " & trim(qSite.couple_name_2)>
    <cfset tokenHash = lCase(replace(createUUID(),"-","","all")) & lCase(replace(createUUID(),"-","","all"))>
    <cfquery datasource="#application.config.datasource#">
        INSERT INTO dbo.SaveTheDates (user_id, wedding_site_id, recipient_name, recipient_email, sender_name, rsvp_status, token_hash)
        VALUES (
            <cfqueryparam value="#userId#"                cfsqltype="cf_sql_bigint">,
            <cfqueryparam value="#qSite.wedding_site_id#" cfsqltype="cf_sql_bigint">,
            <cfqueryparam value="#rName#"                 cfsqltype="cf_sql_nvarchar">,
            <cfqueryparam value="#rEmail#"                cfsqltype="cf_sql_varchar">,
            <cfqueryparam value="#senderName#"            cfsqltype="cf_sql_nvarchar">,
            'pending',
            <cfqueryparam value="#tokenHash#"             cfsqltype="cf_sql_varchar">
        )
    </cfquery>
    <cflocation url="save-the-date.cfm" addToken="false">
</cfif>

<!--- ── EDIT RECIPIENT ── --->
<cfif form.action EQ "edit_recipient" AND isNumeric(form.stdId) AND form.stdId GT 0>
    <cfset rName   = trim(form.recipientName)>
    <cfset rEmail  = lCase(trim(form.recipientEmail))>
    <cfset rStatus = listFindNoCase("pending,attending,declined", trim(form.rsvpStatus)) ? trim(form.rsvpStatus) : "pending">
    <cfif !len(rName) OR !isValid("email", rEmail)>
        <cflocation url="save-the-date.cfm?error=invalid" addToken="false">
    </cfif>
    <cfquery datasource="#application.config.datasource#">
        UPDATE dbo.SaveTheDates SET
            recipient_name  = <cfqueryparam value="#rName#"   cfsqltype="cf_sql_nvarchar">,
            recipient_email = <cfqueryparam value="#rEmail#"  cfsqltype="cf_sql_varchar">,
            rsvp_status     = <cfqueryparam value="#rStatus#" cfsqltype="cf_sql_varchar">,
            updated_at      = SYSUTCDATETIME()
        WHERE save_the_date_id = <cfqueryparam value="#val(form.stdId)#" cfsqltype="cf_sql_bigint">
          AND user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
    </cfquery>
    <cflocation url="save-the-date.cfm" addToken="false">
</cfif>

<!--- ── DELETE RECIPIENT ── --->
<cfif form.action EQ "delete_recipient" AND isNumeric(form.stdId) AND form.stdId GT 0>
    <cfquery datasource="#application.config.datasource#">
        DELETE FROM dbo.SaveTheDates
        WHERE save_the_date_id = <cfqueryparam value="#val(form.stdId)#" cfsqltype="cf_sql_bigint">
          AND user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
    </cfquery>
    <cflocation url="save-the-date.cfm" addToken="false">
</cfif>

<!--- ── SEND TO ONE ── --->
<cfif form.action EQ "send_one" AND isNumeric(form.stdId) AND form.stdId GT 0 AND canSend>
    <cfset sendRedirect = "save-the-date.cfm?error=sendfail">
    <cftry>
        <cfquery name="qRecip" datasource="#application.config.datasource#">
            SELECT save_the_date_id, recipient_name, recipient_email
            FROM dbo.SaveTheDates
            WHERE save_the_date_id = <cfqueryparam value="#val(form.stdId)#" cfsqltype="cf_sql_bigint">
              AND user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
        </cfquery>
        <cfif qRecip.recordCount>
            <cfset qSiteForEmail = qSite>
            <cfinclude template="email-theme-helper.cfm">
            <cfset stdName1     = HTMLEditFormat(listFirst(trim(qSite.couple_name_1)," "))>
            <cfset stdName2     = HTMLEditFormat(listFirst(trim(qSite.couple_name_2)," "))>
            <cfset stdDate      = len(trim(qSite.wedding_date)) ? dateFormat(qSite.wedding_date,"mmmm d, yyyy") : "">
            <cfset stdLocation  = len(trim(qSite.venue_name)) ? trim(qSite.venue_name) & (len(trim(qSite.venue_address)) ? ", " & trim(qSite.venue_address) : "") : "">
            <cfset stdSiteLink  = "https://digitalweddings.love/site.cfm?slug=" & URLEncodedFormat(qSite.slug)>
            <cfset stdPhoto     = couplePhoto>
            <cfset stdRecipName = trim(qRecip.recipient_name)>
            <cfquery name="qUser" datasource="#application.config.datasource#">
                SELECT email FROM dbo.Users WHERE user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
            </cfquery>
            <cfmail to="#trim(qRecip.recipient_email)#"
                    from="#application.config.mailFrom#"
                    replyto="#trim(qUser.email)#"
                    bcc="#trim(qUser.email)#"
                    subject="Save the Date - #HTMLEditFormat(qSite.couple_name_1)# and #HTMLEditFormat(qSite.couple_name_2)#"
                    server="localhost" port="25" timeout="60" type="html">
                <cfinclude template="email-save-the-date-body.cfm">
            </cfmail>
            <cfquery datasource="#application.config.datasource#">
                UPDATE dbo.SaveTheDates SET sent_at = SYSUTCDATETIME(), updated_at = SYSUTCDATETIME()
                WHERE save_the_date_id = <cfqueryparam value="#val(form.stdId)#" cfsqltype="cf_sql_bigint">
                  AND user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
            </cfquery>
            <cfset sendRedirect = "save-the-date.cfm?sent=1">
        </cfif>
    <cfcatch>
        <cftry><cfset notifier = new services.ErrorNotifier()><cfset notifier.notify(cfcatch, "Save the Date send", CGI.SCRIPT_NAME)><cfcatch></cfcatch></cftry>
        <cfset sendRedirect = "save-the-date.cfm?error=sendfail">
    </cfcatch>
    </cftry>
    <cflocation url="#sendRedirect#" addToken="false">
</cfif>

<!--- ── SEND TO ALL UNSENT ── --->
<cfif form.action EQ "send_all" AND canSend>
    <cfset sendRedirect = "save-the-date.cfm?error=sendfail">
    <cftry>
        <cfquery name="qUnsent" datasource="#application.config.datasource#">
            SELECT save_the_date_id, recipient_name, recipient_email
            FROM dbo.SaveTheDates
            WHERE user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
              AND sent_at IS NULL
        </cfquery>
        <cfif qUnsent.recordCount>
            <cfset qSiteForEmail = qSite>
            <cfinclude template="email-theme-helper.cfm">
            <cfset stdName1    = HTMLEditFormat(listFirst(trim(qSite.couple_name_1)," "))>
            <cfset stdName2    = HTMLEditFormat(listFirst(trim(qSite.couple_name_2)," "))>
            <cfset stdDate     = len(trim(qSite.wedding_date)) ? dateFormat(qSite.wedding_date,"mmmm d, yyyy") : "">
            <cfset stdLocation = len(trim(qSite.venue_name)) ? trim(qSite.venue_name) & (len(trim(qSite.venue_address)) ? ", " & trim(qSite.venue_address) : "") : "">
            <cfset stdSiteLink = "https://digitalweddings.love/site.cfm?slug=" & URLEncodedFormat(qSite.slug)>
            <cfset stdPhoto    = couplePhoto>
            <cfquery name="qUser" datasource="#application.config.datasource#">
                SELECT email FROM dbo.Users WHERE user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
            </cfquery>
            <cfloop query="qUnsent">
                <cfset stdRecipName = trim(qUnsent.recipient_name)>
                <cfmail to="#trim(qUnsent.recipient_email)#"
                        from="#application.config.mailFrom#"
                        replyto="#trim(qUser.email)#"
                        subject="Save the Date - #HTMLEditFormat(qSite.couple_name_1)# and #HTMLEditFormat(qSite.couple_name_2)#"
                        server="localhost" port="25" timeout="60" type="html">
                    <cfinclude template="email-save-the-date-body.cfm">
                </cfmail>
                <cfquery datasource="#application.config.datasource#">
                    UPDATE dbo.SaveTheDates SET sent_at = SYSUTCDATETIME(), updated_at = SYSUTCDATETIME()
                    WHERE save_the_date_id = <cfqueryparam value="#qUnsent.save_the_date_id#" cfsqltype="cf_sql_bigint">
                </cfquery>
            </cfloop>
            <cfset sendRedirect = "save-the-date.cfm?sent=#qUnsent.recordCount#">
        <cfelse>
            <cfset sendRedirect = "save-the-date.cfm?error=noneunsent">
        </cfif>
    <cfcatch>
        <cftry><cfset notifier = new services.ErrorNotifier()><cfset notifier.notify(cfcatch, "Save the Date send_all", CGI.SCRIPT_NAME)><cfcatch></cfcatch></cftry>
        <cfset sendRedirect = "save-the-date.cfm?error=sendfail">
    </cfcatch>
    </cftry>
    <cflocation url="#sendRedirect#" addToken="false">
</cfif>

<!--- ── SEND TEST TO SELF ── --->
<cfif form.action EQ "send_test" AND canSend>
    <cfset testRedirect = "save-the-date.cfm?error=sendfail">
    <cftry>
        <cfset qSiteForEmail = qSite>
        <cfinclude template="email-theme-helper.cfm">
        <cfset stdName1     = HTMLEditFormat(listFirst(trim(qSite.couple_name_1)," "))>
        <cfset stdName2     = HTMLEditFormat(listFirst(trim(qSite.couple_name_2)," "))>
        <cfset stdDate      = len(trim(qSite.wedding_date)) ? dateFormat(qSite.wedding_date,"mmmm d, yyyy") : "">
        <cfset stdLocation  = len(trim(qSite.venue_name)) ? trim(qSite.venue_name) & (len(trim(qSite.venue_address)) ? ", " & trim(qSite.venue_address) : "") : "">
        <cfset stdSiteLink  = "https://digitalweddings.love/site.cfm?slug=" & URLEncodedFormat(qSite.slug)>
        <cfset stdPhoto     = couplePhoto>
        <cfset stdRecipName = "You">
        <cfmail to="#session.user.email#"
                from="#application.config.mailFrom#"
                replyto="#session.user.email#"
                subject="[TEST] Save the Date Preview"
                server="localhost" port="25" timeout="60" type="html">
            <cfinclude template="email-save-the-date-body.cfm">
        </cfmail>
        <cfset testRedirect = "save-the-date.cfm?sent=test">
    <cfcatch>
        <cftry><cfset notifier = new services.ErrorNotifier()><cfset notifier.notify(cfcatch, "Save the Date test send", CGI.SCRIPT_NAME)><cfcatch></cfcatch></cftry>
        <cfset testRedirect = "save-the-date.cfm?error=sendfail">
    </cfcatch>
    </cftry>
    <cflocation url="#testRedirect#" addToken="false">
</cfif>

<!--- ── LOAD LIST ── --->
<cfquery name="qList" datasource="#application.config.datasource#">
    SELECT save_the_date_id, recipient_name, recipient_email, rsvp_status, sent_at, created_at
    FROM dbo.SaveTheDates
    WHERE user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
    ORDER BY recipient_name
</cfquery>

<!--- Load edit row if editing --->
<cfset editRow = {}>
<cfif isNumeric(url.edit) AND val(url.edit) GT 0>
    <cfquery name="qEdit" datasource="#application.config.datasource#">
        SELECT save_the_date_id, recipient_name, recipient_email, rsvp_status
        FROM dbo.SaveTheDates
        WHERE save_the_date_id = <cfqueryparam value="#val(url.edit)#" cfsqltype="cf_sql_bigint">
          AND user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
    </cfquery>
    <cfif qEdit.recordCount>
        <cfset editRow = {id:qEdit.save_the_date_id, name:qEdit.recipient_name, email:qEdit.recipient_email, status:qEdit.rsvp_status}>
    </cfif>
</cfif>

<cfset sentCount    = 0>
<cfset pendingCount = 0>
<cfloop query="qList">
    <cfif len(sent_at)><cfset sentCount++><cfelse><cfset pendingCount++></cfif>
</cfloop>

<cfinclude template="../includes/layout-start.cfm">
<style>
.std-desktop { display: block; }
.std-mobile  { display: none; }
@media (max-width:768px) {
    .std-form-grid { grid-template-columns: 1fr !important; }
    .std-form-grid input, .std-form-grid select, .std-form-grid textarea,
    .std-form-grid button, .std-form-grid .btn {
        display: block !important;
        width: 100% !important;
        min-width: 0 !important;
        max-width: 100% !important;
        box-sizing: border-box !important;
        -webkit-appearance: none !important;
        appearance: none !important;
    }
    .std-form-grid > div[style*="display:flex"] { flex-direction: column !important; }
    div.std-desktop { display: none !important; }
    div.std-mobile  { display: block !important; }
}
</style>
<script>
(function(){
    function applyLayout(){
        var isM = window.innerWidth <= 768;
        document.querySelectorAll('.std-desktop').forEach(function(el){ el.style.display = isM ? 'none' : ''; });
        document.querySelectorAll('.std-mobile').forEach(function(el){ el.style.display = isM ? 'block' : 'none'; });
    }
    applyLayout();
    window.addEventListener('resize', applyLayout);
})();
</script>
<section style="padding:60px 0">
<div class="container">
    <div class="page-header">
        <p class="eyebrow">Spread the News</p>
        <h1>Save the <span class="script">Date</span></h1>
    </div>

    <!--- Banners --->
    <cfif url.sent EQ "test">
    <div class="alert alert-success" style="margin-bottom:24px">Test Save the Date sent to <cfoutput>#HTMLEditFormat(session.user.email)#</cfoutput> &mdash; check your inbox!</div>
    </cfif>
    <cfif isNumeric(url.sent) AND val(url.sent) GT 0>
    <div class="alert alert-success" style="margin-bottom:24px"><cfoutput>#val(url.sent)#</cfoutput> Save the Date(s) sent successfully!</div>
    </cfif>
    <cfif url.sent EQ "1">
    <div class="alert alert-success" style="margin-bottom:24px">Save the Date sent! You&rsquo;ve been BCC&rsquo;d on a copy.</div>
    </cfif>
    <cfif url.error EQ "duplicate">
    <div class="alert alert-error" style="margin-bottom:24px">That email address is already on your list.</div>
    </cfif>
    <cfif url.error EQ "invalid">
    <div class="alert alert-error" style="margin-bottom:24px">Please enter a valid name and email address.</div>
    </cfif>
    <cfif url.error EQ "noneunsent">
    <div class="alert alert-error" style="margin-bottom:24px">All recipients have already been sent a Save the Date.</div>
    </cfif>
    <cfif url.error EQ "sendfail">
    <div class="alert alert-error" style="margin-bottom:24px">We&rsquo;re sorry, something went wrong while sending. Please try again or contact us if the issue continues.</div>
    </cfif>

    <!--- How it works --->
    <div style="background:#F0F7FF;border:1px solid #C8DDF5;border-radius:10px;padding:20px 24px;margin-bottom:32px">
        <p style="font-weight:700;margin:0 0 12px;color:#1a1a1a">How it works</p>
        <div style="display:flex;flex-direction:column;gap:8px;font-size:14px;color:#444;line-height:1.6">
            <div><strong>1. Choose your template</strong> &mdash; Your Save the Date is automatically styled to match your wedding website design.</div>
            <div><strong>2. Upload a couple photo</strong> &mdash; Your photo appears on the Save the Date. Go to Upload Photos to add one.</div>
            <div><strong>3. Add recipients</strong> &mdash; Enter each guest&rsquo;s name and email address. Duplicate emails are not allowed.</div>
            <div><strong>4. Test</strong> &mdash; Send a preview to yourself first so you can see exactly what your guests will receive.</div>
            <div><strong>5. Send</strong> &mdash; Send to individual guests using the Send button on each row, or use <em>Send to All Unsent</em> to send to everyone at once. You&rsquo;ll be BCC&rsquo;d on every email.</div>
        </div>
        <div style="margin-top:20px;padding-top:16px;border-top:1px solid #C8DDF5">
            <p style="font-weight:700;margin:0 0 10px;color:#1a1a1a;font-size:14px">&#128197; When should you send your Save the Dates?</p>
            <table style="width:100%;border-collapse:collapse;font-size:13px;color:#444">
                <thead>
                    <tr style="background:#deeaf7">
                        <th style="text-align:left;padding:8px 12px;border-radius:4px 0 0 4px;font-weight:600">Wedding Type</th>
                        <th style="text-align:left;padding:8px 12px;border-radius:0 4px 4px 0;font-weight:600">When to Send</th>
                    </tr>
                </thead>
                <tbody>
                    <tr style="border-bottom:1px solid #C8DDF5">
                        <td style="padding:8px 12px">Local wedding</td>
                        <td style="padding:8px 12px">6&ndash;8 months before</td>
                    </tr>
                    <tr style="border-bottom:1px solid #C8DDF5">
                        <td style="padding:8px 12px">Destination wedding</td>
                        <td style="padding:8px 12px">8&ndash;12 months before</td>
                    </tr>
                    <tr style="border-bottom:1px solid #C8DDF5">
                        <td style="padding:8px 12px">Holiday weekend wedding</td>
                        <td style="padding:8px 12px">8&ndash;12 months before</td>
                    </tr>
                    <tr>
                        <td style="padding:8px 12px">International wedding</td>
                        <td style="padding:8px 12px">9&ndash;12 months before</td>
                    </tr>
                </tbody>
            </table>
        </div>
    </div>

    <!--- Gate: no template --->
    <cfif !hasTemplate>
    <div style="background:#f8f8f8;border:2px dashed #d0d0d0;border-radius:12px;padding:48px 32px;text-align:center;margin-bottom:32px">
        <div style="font-size:56px;margin-bottom:16px">&#128274;</div>
        <h3 style="margin:0 0 10px;font-size:22px">Set Up Your Wedding Website First</h3>
        <p style="color:var(--text-muted);margin:0 0 8px;max-width:460px;margin-left:auto;margin-right:auto">
            Save the Dates are styled to match your wedding website design. Please choose a template before managing recipients or sending emails.
        </p>
        <p style="color:var(--text-muted);font-size:13px;margin:0 0 24px">This entire section will unlock once a template is selected.</p>
        <a href="/members/wedding-sites.cfm" class="btn btn-primary">Choose a Template</a>
    </div>
    <!--- Greyed-out preview of what will be available --->
    <div style="opacity:0.3;pointer-events:none;user-select:none">
        <div class="stats-row" style="margin-bottom:32px">
            <div class="stat-card"><div class="stat-num">0</div><div class="stat-label">Total Recipients</div></div>
            <div class="stat-card"><div class="stat-num">0</div><div class="stat-label">Sent</div></div>
            <div class="stat-card"><div class="stat-num">0</div><div class="stat-label">Pending</div></div>
        </div>
        <div class="panel" style="margin-bottom:24px">
            <p class="panel-title">Add a Recipient</p>
            <div style="display:grid;grid-template-columns:2fr 2fr auto;gap:12px;align-items:end" class="std-form-grid">
                <div class="field" style="margin-bottom:0"><label>Guest Name *</label><input type="text" disabled placeholder="e.g. Aunt Gloria"></div>
                <div class="field" style="margin-bottom:0"><label>Email Address *</label><input type="email" disabled placeholder="gloria@email.com"></div>
                <button type="button" class="btn btn-primary" disabled>Add</button>
            </div>
        </div>
    </div>
    <cfelse>

    <!--- Gate: no couple photo --->
    <cfif !hasPhoto>
    <div style="background:#FFF0F0;border:1px solid #FFB3B3;border-radius:12px;padding:32px;text-align:center;margin-bottom:32px">
        <div style="font-size:48px;margin-bottom:16px">&#128247;</div>
        <h3 style="margin:0 0 8px">Add Your Couple Photo</h3>
        <p style="color:var(--text-muted);margin:0 0 20px">A couple photo is required for Save the Dates. Upload one to get started.</p>
        <a href="/members/upload-photos.cfm" class="btn btn-primary">Upload Photo</a>
    </div>
    </cfif>

    <!--- Stats --->
    <div class="stats-row" style="margin-bottom:32px">
        <div class="stat-card"><div class="stat-num"><cfoutput>#qList.recordCount#</cfoutput></div><div class="stat-label">Total Recipients</div></div>
        <div class="stat-card"><div class="stat-num" style="color:##059669"><cfoutput>#sentCount#</cfoutput></div><div class="stat-label">Sent</div></div>
        <div class="stat-card"><div class="stat-num" style="color:##d97706"><cfoutput>#pendingCount#</cfoutput></div><div class="stat-label">Pending</div></div>
    </div>

    <!--- Test button - always visible once canSend --->
    <cfif canSend>
    <div style="display:flex;gap:12px;margin-bottom:24px;flex-wrap:wrap;align-items:center">
        <form method="post" action="/members/save-the-date.cfm" style="display:inline">
            <input type="hidden" name="action" value="send_test">
            <button type="submit" class="btn btn-ghost">&#128233; Send Test to Myself</button>
        </form>
        <cfif qList.recordCount AND pendingCount GT 0>
        <form method="post" action="/members/save-the-date.cfm" style="display:inline">
            <input type="hidden" name="action" value="send_all">
            <button type="submit" class="btn btn-primary" onclick="return confirm('Send to all unsent recipients?')">Send to All Unsent (<cfoutput>#pendingCount#</cfoutput>)</button>
        </form>
        </cfif>
    </div>
    </cfif>

    <!--- Add / Edit form --->
    <div class="panel" style="margin-bottom:24px">
        <cfif structKeyExists(editRow,"id")>
        <p class="panel-title">Edit Recipient</p>
        <form method="post" action="/members/save-the-date.cfm">
            <input type="hidden" name="action" value="edit_recipient">
            <cfoutput><input type="hidden" name="stdId" value="#editRow.id#"></cfoutput>
            <div class="std-form-grid" style="display:grid;grid-template-columns:2fr 2fr 1fr auto;gap:12px;align-items:end">
                <div class="field" style="margin-bottom:0">
                    <label>Guest Name *</label>
                    <cfoutput><input type="text" name="recipientName" required value="#HTMLEditFormat(editRow.name)#"></cfoutput>
                </div>
                <div class="field" style="margin-bottom:0">
                    <label>Email Address *</label>
                    <cfoutput><input type="email" name="recipientEmail" required value="#HTMLEditFormat(editRow.email)#"></cfoutput>
                </div>
                <div class="field" style="margin-bottom:0">
                    <label>Attending</label>
                    <select name="rsvpStatus">
                        <cfoutput>
                        <option value="pending"   <cfif editRow.status EQ "pending">selected</cfif>>Pending</option>
                        <option value="attending" <cfif editRow.status EQ "attending">selected</cfif>>Yes</option>
                        <option value="declined"  <cfif editRow.status EQ "declined">selected</cfif>>No</option>
                        </cfoutput>
                    </select>
                </div>
                <div style="display:flex;gap:6px">
                    <button type="submit" class="btn btn-primary">Save</button>
                    <a href="/members/save-the-date.cfm" class="btn btn-ghost">Cancel</a>
                </div>
            </div>
        </form>
        <cfelse>
        <p class="panel-title">Add a Recipient</p>
        <form method="post" action="/members/save-the-date.cfm">
            <input type="hidden" name="action" value="add_recipient">
            <div style="display:grid;grid-template-columns:2fr 2fr auto;gap:12px;align-items:end" class="std-form-grid">
                <div class="field" style="margin-bottom:0">
                    <label>Guest Name *</label>
                    <input type="text" name="recipientName" required placeholder="e.g. Aunt Gloria">
                </div>
                <div class="field" style="margin-bottom:0">
                    <label>Email Address *</label>
                    <input type="email" name="recipientEmail" required placeholder="gloria@email.com">
                </div>
                <button type="submit" class="btn btn-primary">Add</button>
            </div>
        </form>
        </cfif>
    </div>

    <!--- Recipient table --->
    <cfif qList.recordCount>
    <!--- Desktop --->
    <div class="panel std-desktop" style="padding:0">
        <div class="table-wrap">
            <table>
                <thead>
                    <tr><th>Guest</th><th>Email</th><th>Attending</th><th>Sent</th><th></th></tr>
                </thead>
                <tbody>
                    <cfoutput query="qList">
                    <tr>
                        <td><strong>#HTMLEditFormat(recipient_name)#</strong></td>
                        <td>#HTMLEditFormat(recipient_email)#</td>
                        <td>
                            <cfif rsvp_status EQ "attending"><span class="badge badge-green">Yes</span>
                            <cfelseif rsvp_status EQ "declined"><span class="badge badge-gray">No</span>
                            <cfelse><span class="badge badge-amber">Pending</span>
                            </cfif>
                        </td>
                        <td>
                            <cfif len(sent_at)><span class="badge badge-green">Sent</span>
                            <cfelse><span class="badge badge-amber">Not sent</span>
                            </cfif>
                        </td>
                        <td style="display:flex;gap:6px;flex-wrap:wrap">
                            <cfif canSend AND !len(sent_at)>
                            <form method="post" action="/members/save-the-date.cfm" style="display:inline">
                                <input type="hidden" name="action" value="send_one">
                                <input type="hidden" name="stdId" value="#save_the_date_id#">
                                <button type="submit" class="btn btn-primary btn-sm"
                                        data-name="#HTMLEditFormat(recipient_name)#"
                                        onclick="return confirm('Send Save the Date to ' + this.dataset.name + '?')">Send</button>
                            </form>
                            </cfif>
                            <a href="/members/save-the-date.cfm?edit=#save_the_date_id#" class="btn btn-ghost btn-sm">Edit</a>
                            <form method="post" action="/members/save-the-date.cfm" style="display:inline">
                                <input type="hidden" name="action" value="delete_recipient">
                                <input type="hidden" name="stdId" value="#save_the_date_id#">
                                <button type="submit" class="btn btn-danger btn-sm" onclick="return confirm('Remove this recipient?')">&times;</button>
                            </form>
                        </td>
                    </tr>
                    </cfoutput>
                </tbody>
            </table>
        </div>
    </div>
    <!--- Mobile cards --->
    <div class="std-mobile">
        <cfoutput query="qList">
        <div class="panel" style="margin-bottom:12px;padding:16px">
            <div style="display:flex;justify-content:space-between;align-items:start;margin-bottom:8px">
                <div>
                    <p style="font-weight:700;font-size:15px;margin-bottom:2px">#HTMLEditFormat(recipient_name)#</p>
                    <p style="font-size:13px;color:var(--text-muted)">#HTMLEditFormat(recipient_email)#</p>
                </div>
                <div style="display:flex;flex-direction:column;align-items:flex-end;gap:4px">
                    <cfif rsvp_status EQ "attending"><span class="badge badge-green">Yes</span>
                    <cfelseif rsvp_status EQ "declined"><span class="badge badge-gray">No</span>
                    <cfelse><span class="badge badge-amber">Pending</span>
                    </cfif>
                    <cfif len(sent_at)><span class="badge badge-green">Sent</span>
                    <cfelse><span class="badge badge-amber">Not sent</span>
                    </cfif>
                </div>
            </div>
            <div style="display:flex;flex-direction:column;gap:8px;margin-top:10px">
                <cfif canSend AND !len(sent_at)>
                <form method="post" action="/members/save-the-date.cfm">
                    <input type="hidden" name="action" value="send_one">
                    <input type="hidden" name="stdId" value="#save_the_date_id#">
                    <button type="submit" class="btn btn-primary btn-sm" style="width:100%"
                            data-name="#HTMLEditFormat(recipient_name)#"
                            onclick="return confirm('Send Save the Date to ' + this.dataset.name + '?')">Send</button>
                </form>
                </cfif>
                <a href="/members/save-the-date.cfm?edit=#save_the_date_id#" class="btn btn-ghost btn-sm" style="width:100%;text-align:center;box-sizing:border-box">Edit</a>
                <form method="post" action="/members/save-the-date.cfm">
                    <input type="hidden" name="action" value="delete_recipient">
                    <input type="hidden" name="stdId" value="#save_the_date_id#">
                    <button type="submit" class="btn btn-danger btn-sm" style="width:100%" onclick="return confirm('Remove this recipient?')">Remove</button>
                </form>
            </div>
        </div>
        </cfoutput>
    </div>
    <cfelse>
    <div class="empty-state">
        <div style="font-size:48px;margin-bottom:16px">&#128140;</div>
        <p>No recipients yet. Add guests above to get started.</p>
    </div>
    </cfif>

    </cfif><!--- end hasTemplate --->
</div>
</section>
<cfinclude template="../includes/layout-end.cfm">
