<cfinclude template="../includes/auth-check.cfm">
<cfset pageTitle = "Edit Invite Email | digitalweddings.love">
<cfset activePage = "guests">
<cfset userId = session.user.id>

<cfparam name="url.saved" default="">
<cfparam name="form.action" default="">

<!--- Load site --->
<cftry>
    <cfquery name="qSite" datasource="#application.config.datasource#">
        SELECT wedding_site_id, couple_name_1, couple_name_2, wedding_date, template, invite_subject, invite_message
        FROM dbo.WeddingSites
        WHERE user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
        ORDER BY created_at DESC
    </cfquery>
<cfcatch>
    <cflocation url="wedding-sites.cfm" addToken="false">
</cfcatch>
</cftry>

<cfif !qSite.recordCount>
    <cflocation url="wedding-sites.cfm" addToken="false">
</cfif>


<!--- ============================================================
  SAVE INVITE SETTINGS
============================================================ --->
<cfif form.action EQ "save_invite">

    <cfset saveFatalError = false>

    <cftry>
        <cfquery datasource="#application.config.datasource#">
            UPDATE dbo.WeddingSites SET
                invite_subject = <cfqueryparam value="#trim(form.inviteSubject)#" cfsqltype="cf_sql_nvarchar" null="#!len(trim(form.inviteSubject))#">,
                invite_message = <cfqueryparam value="#trim(form.inviteMessage)#" cfsqltype="cf_sql_nvarchar" null="#!len(trim(form.inviteMessage))#">,
                updated_at     = SYSUTCDATETIME()
            WHERE user_id         = <cfqueryparam value="#userId#"                cfsqltype="cf_sql_bigint">
              AND wedding_site_id  = <cfqueryparam value="#qSite.wedding_site_id#" cfsqltype="cf_sql_bigint">
        </cfquery>
    <cfcatch>
        <cfset saveFatalError = true>
    </cfcatch>
    </cftry>

    <cfif saveFatalError>
        <cflocation url="edit-invite.cfm?saved=error" addToken="false">
    <cfelse>
        <cflocation url="edit-invite.cfm?saved=1" addToken="false">
    </cfif>

</cfif>


<!--- ============================================================
  SEND PREVIEW EMAIL
============================================================ --->
<cfif form.action EQ "send_preview">

    <cfset previewMailError = "">
    <cfset previewFatalError = false>

    <cftry>

        <cfquery name="qSitePreview" datasource="#application.config.datasource#">
            SELECT couple_name_1, couple_name_2, wedding_date, venue_name, venue_address, slug, template, invite_subject, invite_message
            FROM dbo.WeddingSites
            WHERE user_id          = <cfqueryparam value="#userId#"                cfsqltype="cf_sql_bigint">
              AND wedding_site_id   = <cfqueryparam value="#qSite.wedding_site_id#" cfsqltype="cf_sql_bigint">
        </cfquery>

        <cfif qSitePreview.recordCount AND len(trim(qSitePreview.slug))>

            <cfset qSiteForEmail  = qSitePreview>
            <cfset rsvpLink       = "https://digitalweddings.love/rsvp.cfm?slug=" & URLEncodedFormat(qSitePreview.slug)>
            <cfset previewSubject = len(trim(qSitePreview.invite_subject))
                                  ? trim(qSitePreview.invite_subject)
                                  : "You're Invited! " & qSitePreview.couple_name_1 & " & " & qSitePreview.couple_name_2 & " are getting married">

            <cfinclude template="email-theme-helper.cfm">

            <cftry>
                <cfset emailGuestName  = "Guest">
                <cfset emailIsReminder = false>
                <cfmail to="#session.user.email#"
                        from="#application.config.mailFrom#"
                        replyto="#session.user.email#"
                        server="localhost"
                        port="25"
                        subject="[PREVIEW] #previewSubject#"
                        type="html"
                        timeout="60"><cfinclude template="email-invite-body.cfm"></cfmail>
            <cfcatch>
                <cfset previewMailError = cfcatch.message>
            </cfcatch>
            </cftry>

        </cfif>

    <cfcatch>
        <cfset previewFatalError = true>
    </cfcatch>
    </cftry>

    <cfif previewFatalError>
        <cflocation url="edit-invite.cfm?saved=previewerror" addToken="false">
    <cfelseif len(previewMailError)>
        <cflocation url="edit-invite.cfm?saved=previewfail" addToken="false">
    <cfelse>
        <cflocation url="edit-invite.cfm?saved=preview" addToken="false">
    </cfif>

</cfif>


<cfinclude template="../includes/layout-start.cfm">
<section style="padding:60px 0">
<div class="container" style="max-width:760px">

    <div class="page-header">
        <p class="eyebrow">Guest Management</p>
        <h1>Edit <span class="script">Invite Email</span></h1>
        <p style="color:var(--text-muted);margin-top:8px">This email is sent when you add a guest or click Resend Invite. Leave fields blank to use the default.</p>
    </div>

    <cfif url.saved EQ "1">
        <div class="alert alert-success" style="margin-bottom:24px">Invite email saved.</div>
    </cfif>
    <cfif url.saved EQ "error">
        <div class="alert alert-error" style="margin-bottom:24px">Could not save invite settings. The administrator has been notified.</div>
    </cfif>
    <cfif url.saved EQ "preview">
        <div class="alert alert-success" style="margin-bottom:24px">Preview sent to <cfoutput>#HTMLEditFormat(session.user.email)#</cfoutput>.</div>
    </cfif>
    <cfif url.saved EQ "previewfail">
        <div class="alert alert-error" style="margin-bottom:24px">Preview email could not be sent. The administrator has been notified.</div>
    </cfif>
    <cfif url.saved EQ "previewerror">
        <div class="alert alert-error" style="margin-bottom:24px">An unexpected error occurred sending the preview. The administrator has been notified.</div>
    </cfif>

    <div class="panel">
        <form method="post" action="/members/edit-invite.cfm">
            <input type="hidden" name="action" value="save_invite">

            <div class="field">
                <label>Email Subject</label>
                <input type="text" name="inviteSubject" value="<cfoutput>#HTMLEditFormat(qSite.invite_subject)#</cfoutput>"
                    placeholder="You're Invited! [Name1] & [Name2] are getting married">
                <p class="field-hint">Default: "You're Invited! [Name1] &amp; [Name2] are getting married"</p>
            </div>

            <div class="field">
                <label>Message Body</label>
                <textarea name="inviteMessage" rows="6" placeholder="You have been invited to celebrate the wedding of [Couple Names]. Please click below to RSVP." style="width:100%;resize:vertical"><cfoutput>#HTMLEditFormat(qSite.invite_message)#</cfoutput></textarea>
                <p class="field-hint">This appears in the body of the email above the RSVP button. The couple names, wedding date, themed header and RSVP button are always included automatically.</p>
            </div>

            <div style="display:flex;gap:12px;align-items:center;flex-wrap:wrap">
                <button type="submit" class="btn btn-primary">Save</button>
                <a href="/members/guests.cfm" class="btn btn-secondary">Back to Guests</a>
            </div>
        </form>
    </div>

    <div class="panel" style="margin-top:24px">
        <p class="panel-title">Send Preview to Yourself</p>
        <p style="color:var(--text-muted);margin-bottom:20px">See exactly what your guests will receive before sending. Sent to <strong><cfoutput>#HTMLEditFormat(session.user.email)#</cfoutput></strong>.</p>
        <form method="post" action="/members/edit-invite.cfm">
            <input type="hidden" name="action" value="send_preview">
            <button type="submit" class="btn btn-secondary">Send Preview Email</button>
        </form>
    </div>

</div>
</section>
<cfinclude template="../includes/layout-end.cfm">
