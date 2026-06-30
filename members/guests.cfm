<cfinclude template="../includes/auth-check.cfm">
<cfset pageTitle = "Guests & RSVP | digitalweddings.love">
<cfset activePage = "guests">
<cfset userId = session.user.id>

<cfparam name="url.sent"      default="">
<cfparam name="url.resent"    default="">
<cfparam name="url.mailerror" default="">
<cfparam name="url.error"     default="">
<cfparam name="form.action"   default="">

<!--- ============================================================
  ADD GUEST
  Outer cftry catches DB errors and any unexpected failure.
  Inner cftry catches email-only failures so the guest is still
  saved even when the invite email cannot be sent.
  cflocation is deliberately placed OUTSIDE both try blocks because
  ColdFusion's abort exception can be caught by cfcatch type="any".
============================================================ --->
<cfif form.action EQ "add_guest">

    <cfset addGuestMailError = "">
    <cfset addGuestFatalError = false>

    <cftry>

        <cfif len(trim(form.name))>

            <cfquery datasource="#application.config.datasource#">
                INSERT INTO dbo.Guests (user_id, name, email, guest_group, rsvp_status, plus_one, plus_one_name, dietary_restrictions, notes)
                VALUES (
                    <cfqueryparam value="#userId#"                                                                    cfsqltype="cf_sql_bigint">,
                    <cfqueryparam value="#trim(form.name)#"                                                           cfsqltype="cf_sql_nvarchar">,
                    <cfqueryparam value="#lCase(trim(form.email))#"                                                   cfsqltype="cf_sql_varchar"   null="#!len(trim(form.email))#">,
                    <cfqueryparam value="#trim(form.guestGroup)#"                                                     cfsqltype="cf_sql_nvarchar"  null="#!len(trim(form.guestGroup))#">,
                    <cfqueryparam value="#len(trim(form.rsvpStatus)) ? trim(form.rsvpStatus) : 'pending'#"            cfsqltype="cf_sql_varchar">,
                    <cfqueryparam value="#(structKeyExists(form,'plusOne') AND form.plusOne EQ 'on') ? 1 : 0#"       cfsqltype="cf_sql_bit">,
                    <cfqueryparam value="#trim(form.plusOneName)#"                                                    cfsqltype="cf_sql_nvarchar"  null="#!len(trim(form.plusOneName))#">,
                    <cfqueryparam value="#trim(form.dietaryRestrictions)#"                                            cfsqltype="cf_sql_nvarchar"  null="#!len(trim(form.dietaryRestrictions))#">,
                    <cfqueryparam value="#trim(form.notes)#"                                                          cfsqltype="cf_sql_nvarchar"  null="#!len(trim(form.notes))#">
                )
            </cfquery>

            <cfif len(trim(form.email))>

                <cfquery name="qSiteForEmail" datasource="#application.config.datasource#">
                    SELECT couple_name_1, couple_name_2, wedding_date, venue_name, venue_address, slug, template, invite_subject, invite_message
                    FROM dbo.WeddingSites
                    WHERE user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
                      AND published = 1
                    ORDER BY created_at DESC
                </cfquery>

                <cfif qSiteForEmail.recordCount AND len(trim(qSiteForEmail.slug))>

                    <cfset rsvpLink    = "https://digitalweddings.love/rsvp.cfm?slug=" & URLEncodedFormat(qSiteForEmail.slug)>
                    <cfset emailSubject = len(trim(qSiteForEmail.invite_subject))
                                        ? trim(qSiteForEmail.invite_subject)
                                        : "You're Invited! " & qSiteForEmail.couple_name_1 & " & " & qSiteForEmail.couple_name_2 & " are getting married">
                    <cfinclude template="email-theme-helper.cfm">

                    <cftry>
                        <cfset emailGuestName  = trim(form.name)>
                        <cfset emailIsReminder = false>
                        <cfmail to="#trim(form.email)#"
                                from="#application.config.mailFrom#"
                                replyto="#session.user.email#"
                                bcc="#session.user.email#"
                                server="localhost"
                                port="25"
                                subject="#emailSubject#"
                                type="html"
                                timeout="60"><cfinclude template="email-invite-body.cfm"></cfmail>
                    <cfcatch>
                        <cfset addGuestMailError = cfcatch.message>
                    </cfcatch>
                    </cftry>

                </cfif>
            </cfif>

        </cfif>

    <cfcatch>
        <cfset addGuestFatalError = true>
    </cfcatch>
    </cftry>

    <!--- Redirect OUTSIDE the try block so cflocation cannot be caught --->
    <cfif addGuestFatalError>
        <cflocation url="guests.cfm?error=1" addToken="false">
    <cfelseif len(addGuestMailError)>
        <cflocation url="guests.cfm?sent=1&mailerror=#URLEncodedFormat(addGuestMailError)#" addToken="false">
    <cfelse>
        <cflocation url="guests.cfm?sent=1" addToken="false">
    </cfif>

</cfif>


<!--- ============================================================
  RESEND INVITE
============================================================ --->
<cfif form.action EQ "resend_invite" AND isNumeric(form.guestId)>

    <cfset resendMailError = "">
    <cfset resendFatalError = false>

    <cftry>

        <cfquery name="qGuest" datasource="#application.config.datasource#">
            SELECT name, email FROM dbo.Guests
            WHERE guest_id = <cfqueryparam value="#form.guestId#" cfsqltype="cf_sql_bigint">
              AND user_id   = <cfqueryparam value="#userId#"       cfsqltype="cf_sql_bigint">
        </cfquery>

        <cfif qGuest.recordCount AND len(trim(qGuest.email))>

            <cfquery name="qSiteResend" datasource="#application.config.datasource#">
                SELECT couple_name_1, couple_name_2, wedding_date, venue_name, venue_address, slug, template, invite_subject, invite_message
                FROM dbo.WeddingSites
                WHERE user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
                  AND published = 1
                ORDER BY created_at DESC
            </cfquery>

            <cfif qSiteResend.recordCount AND len(trim(qSiteResend.slug))>

                <cfset rsvpLink     = "https://digitalweddings.love/rsvp.cfm?slug=" & URLEncodedFormat(qSiteResend.slug)>
                <cfset qSiteForEmail = qSiteResend>
                <cfset emailSubject  = len(trim(qSiteResend.invite_subject))
                                     ? trim(qSiteResend.invite_subject)
                                     : "Reminder! Please RSVP - " & qSiteResend.couple_name_1 & " & " & qSiteResend.couple_name_2>
                <cfinclude template="email-theme-helper.cfm">

                <cftry>
                    <cfset emailGuestName  = trim(qGuest.name)>
                    <cfset emailIsReminder = true>
                    <cfmail to="#trim(qGuest.email)#"
                            from="#application.config.mailFrom#"
                            replyto="#session.user.email#"
                            bcc="#session.user.email#"
                            server="localhost"
                            port="25"
                            subject="#emailSubject#"
                            type="html"
                            timeout="60"><cfinclude template="email-invite-body.cfm"></cfmail>
                <cfcatch>
                    <cfset resendMailError = cfcatch.message>
                </cfcatch>
                </cftry>

            </cfif>
        </cfif>

    <cfcatch>
        <cfset resendFatalError = true>
    </cfcatch>
    </cftry>

    <cfif resendFatalError>
        <cflocation url="guests.cfm?error=1" addToken="false">
    <cfelseif len(resendMailError)>
        <cflocation url="guests.cfm?resent=1&mailerror=#URLEncodedFormat(resendMailError)#" addToken="false">
    <cfelse>
        <cflocation url="guests.cfm?resent=1" addToken="false">
    </cfif>

</cfif>


<!--- ============================================================
  UPDATE RSVP STATUS
============================================================ --->
<cfif form.action EQ "update_rsvp" AND isNumeric(form.guestId)>
    <cftry>
        <cfquery datasource="#application.config.datasource#">
            UPDATE dbo.Guests
            SET rsvp_status = <cfqueryparam value="#trim(form.rsvpStatus)#" cfsqltype="cf_sql_varchar">,
                updated_at  = SYSUTCDATETIME()
            WHERE guest_id = <cfqueryparam value="#form.guestId#" cfsqltype="cf_sql_bigint">
              AND user_id   = <cfqueryparam value="#userId#"       cfsqltype="cf_sql_bigint">
        </cfquery>
    <cfcatch></cfcatch>
    </cftry>
    <cflocation url="guests.cfm" addToken="false">
</cfif>


<!--- ============================================================
  EDIT GUEST
============================================================ --->
<cfif form.action EQ "update_guest" AND isNumeric(form.guestId)>
    <cftry>
        <cfquery datasource="#application.config.datasource#">
            UPDATE dbo.Guests SET
                name                 = <cfqueryparam value="#trim(form.name)#"                cfsqltype="cf_sql_nvarchar">,
                email                = <cfqueryparam value="#lCase(trim(form.email))#"        cfsqltype="cf_sql_varchar"  null="#!len(trim(form.email))#">,
                guest_group          = <cfqueryparam value="#trim(form.guestGroup)#"          cfsqltype="cf_sql_nvarchar" null="#!len(trim(form.guestGroup))#">,
                rsvp_status          = <cfqueryparam value="#trim(form.rsvpStatus)#"          cfsqltype="cf_sql_varchar">,
                plus_one             = <cfqueryparam value="#(structKeyExists(form,'plusOne') AND form.plusOne EQ 'on') ? 1 : 0#" cfsqltype="cf_sql_bit">,
                plus_one_name        = <cfqueryparam value="#trim(form.plusOneName)#"         cfsqltype="cf_sql_nvarchar" null="#!len(trim(form.plusOneName))#">,
                dietary_restrictions = <cfqueryparam value="#trim(form.dietaryRestrictions)#" cfsqltype="cf_sql_nvarchar" null="#!len(trim(form.dietaryRestrictions))#">,
                notes                = <cfqueryparam value="#trim(form.notes)#"               cfsqltype="cf_sql_nvarchar" null="#!len(trim(form.notes))#">,
                updated_at           = SYSUTCDATETIME()
            WHERE guest_id = <cfqueryparam value="#form.guestId#" cfsqltype="cf_sql_bigint">
              AND user_id   = <cfqueryparam value="#userId#"       cfsqltype="cf_sql_bigint">
        </cfquery>
    <cfcatch></cfcatch>
    </cftry>
    <cflocation url="guests.cfm" addToken="false">
</cfif>


<!--- ============================================================
  DELETE GUEST
============================================================ --->
<cfif form.action EQ "remove_plus_one" AND isNumeric(form.guestId)>
    <cftry>
        <cfquery datasource="#application.config.datasource#">
            UPDATE dbo.Guests
            SET plus_one = 0, plus_one_name = NULL, updated_at = SYSUTCDATETIME()
            WHERE guest_id = <cfqueryparam value="#form.guestId#" cfsqltype="cf_sql_bigint">
              AND user_id   = <cfqueryparam value="#userId#"       cfsqltype="cf_sql_bigint">
        </cfquery>
    <cfcatch></cfcatch>
    </cftry>
    <cflocation url="guests.cfm" addToken="false">
</cfif>

<cfif form.action EQ "delete_guest" AND isNumeric(form.guestId)>
    <cftry>
        <cfquery datasource="#application.config.datasource#">
            DELETE FROM dbo.Guests
            WHERE guest_id = <cfqueryparam value="#form.guestId#" cfsqltype="cf_sql_bigint">
              AND user_id   = <cfqueryparam value="#userId#"       cfsqltype="cf_sql_bigint">
        </cfquery>
    <cfcatch></cfcatch>
    </cftry>
    <cflocation url="guests.cfm" addToken="false">
</cfif>


<!--- ============================================================
  LOAD GUEST LIST
============================================================ --->
<cfquery name="qActiveSite" datasource="#application.config.datasource#">
    SELECT TOP 1 wedding_site_id, couple_name_1, couple_name_2, slug, template
    FROM dbo.WeddingSites
    WHERE user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
      AND published = 1
      AND slug IS NOT NULL
    ORDER BY updated_at DESC
</cfquery>
<cfset hasSite = qActiveSite.recordCount GT 0>

<cfquery name="guests" datasource="#application.config.datasource#">
    SELECT guest_id, name, email, phone, guest_group, rsvp_status, plus_one, plus_one_name, dietary_restrictions, table_number, notes,
        CASE
            WHEN guest_group LIKE 'Bride%' THEN 1
            WHEN guest_group LIKE 'Groom%' THEN 2
            ELSE 3
        END AS side_order
    FROM dbo.Guests
    WHERE user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
    ORDER BY side_order, name
</cfquery>

<cfset attending = 0><cfset declined = 0><cfset pending = 0><cfset maybe = 0><cfset totalHeadcount = 0>
<cfloop query="guests">
    <cfif rsvp_status EQ "attending">
        <cfset attending++>
        <cfif plus_one AND len(trim(plus_one_name))>
            <cfset attending++>
        </cfif>
    <cfelseif rsvp_status EQ "declined"><cfset declined++>
    <cfelseif rsvp_status EQ "maybe"><cfset maybe++>
    <cfelse><cfset pending++>
    </cfif>
    <!--- Total headcount includes confirmed plus ones --->
    <cfset totalHeadcount++>
    <cfif plus_one AND len(trim(plus_one_name))>
        <cfset totalHeadcount++>
    </cfif>
</cfloop>

<cfset groups = ["Bride's Family","Groom's Family","Bride's Friends","Groom's Friends","Mutual Friends","Colleagues","Other"]>

<cfinclude template="../includes/layout-start.cfm">
<section style="padding:60px 0">
<div class="container">
    <div class="page-header" style="display:flex;justify-content:space-between;align-items:flex-start;flex-wrap:wrap;gap:16px">
        <div>
            <p class="eyebrow">Manage Your Day</p>
            <h1>Guests &amp; <span class="script">RSVP</span></h1>
        </div>
        <a href="/members/edit-invite.cfm" class="btn btn-secondary" style="margin-top:8px">Edit Invite Email</a>
    </div>

    <div class="stats-row" style="margin-bottom:36px">
        <div class="stat-card"><i data-lucide="users" style="width:20px;height:20px;color:var(--gold);margin-bottom:8px"></i><div class="stat-num"><cfoutput>#totalHeadcount#</cfoutput></div><div class="stat-label">Total Guests</div></div>
        <div class="stat-card"><i data-lucide="user-check" style="width:20px;height:20px;color:#059669;margin-bottom:8px"></i><div class="stat-num" style="color:#059669"><cfoutput>#attending#</cfoutput></div><div class="stat-label">Attending</div></div>
        <div class="stat-card"><i data-lucide="user-x" style="width:20px;height:20px;color:#dc2626;margin-bottom:8px"></i><div class="stat-num" style="color:#dc2626"><cfoutput>#declined#</cfoutput></div><div class="stat-label">Declined</div></div>
        <div class="stat-card"><i data-lucide="clock" style="width:20px;height:20px;color:#d97706;margin-bottom:8px"></i><div class="stat-num" style="color:#d97706"><cfoutput>#pending#</cfoutput></div><div class="stat-label">Pending</div></div>
    </div>

    <!--- Flash messages --->
    <cfif url.error EQ "1">
        <div class="alert alert-error" style="margin-bottom:24px">An unexpected error occurred. The administrator has been notified.</div>
    </cfif>
    <cfif url.sent EQ "1">
        <cfif len(url.mailerror)>
            <div class="alert alert-success" style="margin-bottom:24px">Guest added, but the invitation email could not be sent. The administrator has been notified. <small>(<cfoutput>#HTMLEditFormat(url.mailerror)#</cfoutput>)</small></div>
        <cfelse>
            <div class="alert alert-success" style="margin-bottom:24px">Guest added and invitation email sent.</div>
        </cfif>
    </cfif>
    <cfif url.resent EQ "1">
        <cfif len(url.mailerror)>
            <div class="alert alert-error" style="margin-bottom:24px">Could not resend invitation email. The administrator has been notified. <small>(<cfoutput>#HTMLEditFormat(url.mailerror)#</cfoutput>)</small></div>
        <cfelse>
            <div class="alert alert-success" style="margin-bottom:24px">Invitation email resent.</div>
        </cfif>
    </cfif>

    <!--- No published site notice --->
    <cfif NOT hasSite>
    <div class="panel" style="margin-bottom:24px;border-left:3px solid var(--gold);background:var(--surface-alt,##faf8f4)">
        <p style="margin:0 0 8px;font-weight:600;font-size:15px">Set Up Your Wedding Website First</p>
        <p style="margin:0 0 16px;color:var(--text-muted)">Before you can send invitations, you need to publish a wedding website. Your guests' invitation emails will be themed to match your site and will include a link for them to RSVP.</p>
        <a href="/members/wedding-sites.cfm" class="btn btn-primary">Create Your Wedding Website</a>
    </div>
    </cfif>

    <!--- Add Guest Form --->
    <cfif hasSite>
    <div class="panel" style="margin-bottom:24px">
        <p class="panel-title">Add a Guest</p>
        <form method="post" action="/members/guests.cfm">
            <input type="hidden" name="action" value="add_guest">
            <div class="add-guest-row1" style="display:grid;grid-template-columns:2fr 2fr 1fr 1fr 1fr auto;gap:12px;align-items:end;flex-wrap:wrap">
                <div class="field" style="margin-bottom:0">
                    <label>Full Name *</label>
                    <input type="text" name="name" required placeholder="e.g. Aisha Johnson">
                </div>
                <div class="field" style="margin-bottom:0">
                    <label>Email <span style="font-weight:400;text-transform:none;letter-spacing:0">(invite will be sent)</span></label>
                    <input type="email" name="email" placeholder="guest@email.com">
                </div>
                <div class="field" style="margin-bottom:0">
                    <label>Group</label>
                    <select name="guestGroup">
                        <option value="">Select</option>
                        <cfoutput><cfloop array="#groups#" index="g"><option value="#HTMLEditFormat(g)#">#HTMLEditFormat(g)#</option></cfloop></cfoutput>
                    </select>
                </div>
                <div class="field" style="margin-bottom:0">
                    <label>RSVP Status</label>
                    <select name="rsvpStatus">
                        <option value="pending">Pending</option>
                        <option value="attending">Attending</option>
                        <option value="declined">Declined</option>
                        <option value="maybe">Maybe</option>
                    </select>
                </div>
                <div class="field" style="margin-bottom:0">
                    <label>Dietary Notes</label>
                    <input type="text" name="dietaryRestrictions" placeholder="Optional">
                </div>
                <button type="submit" class="btn btn-primary">Add</button>
            </div>
            <div class="add-guest-row2" style="display:grid;grid-template-columns:auto 2fr 3fr;gap:12px;align-items:center;margin-top:12px">
                <div class="field" style="margin-bottom:0;display:flex;align-items:center;gap:8px">
                    <input type="checkbox" name="plusOne" id="plusOneCheck" value="on" onchange="document.getElementById('plusOneNameWrap').style.display=this.checked?'block':'none'" style="width:16px;height:16px;cursor:pointer">
                    <label for="plusOneCheck" style="margin-bottom:0;cursor:pointer">Allow Plus One</label>
                </div>
                <div class="field" id="plusOneNameWrap" style="margin-bottom:0;display:none">
                    <label>Plus One Name</label>
                    <input type="text" name="plusOneName" placeholder="e.g. James Johnson">
                </div>
                <div class="field" style="margin-bottom:0">
                    <label>Notes <span style="font-weight:400;text-transform:none;letter-spacing:0">(internal, guests won't see this)</span></label>
                    <input type="text" name="notes" placeholder="e.g. VIP, needs wheelchair access">
                </div>
            </div>
        </form>
    </div>
    <cfelse>
    <div class="panel" style="margin-bottom:24px;opacity:0.5;pointer-events:none;user-select:none">
        <p class="panel-title">Add a Guest</p>
        <p style="color:var(--text-muted)">Publish your wedding website to enable guest invitations.</p>
    </div>
    </cfif>

    <!--- Guest List --->
    <cfif guests.recordCount>

    <!--- Pre-sort guests into three buckets --->
    <cfset brideGuests   = []>
    <cfset groomGuests   = []>
    <cfset sharedGuests  = []>
    <cfloop query="guests">
        <cfif guest_group CONTAINS "Bride">
            <cfset arrayAppend(brideGuests,  guests.currentRow)>
        <cfelseif guest_group CONTAINS "Groom">
            <cfset arrayAppend(groomGuests,  guests.currentRow)>
        <cfelse>
            <cfset arrayAppend(sharedGuests, guests.currentRow)>
        </cfif>
    </cfloop>

    <!--- Bride's name for section header --->
    <cfset brideName = hasSite AND qActiveSite.recordCount ? trim(qActiveSite.couple_name_1) : "Bride">
    <cfset groomName = hasSite AND qActiveSite.recordCount ? trim(qActiveSite.couple_name_2) : "Groom">

    <cfset guestSections = [
        {label: brideName & "'s Guests", rows: brideGuests},
        {label: groomName & "'s Guests", rows: groomGuests},
        {label: "Mutual / Other",        rows: sharedGuests}
    ]>

    <cfoutput>
    <cfloop array="#guestSections#" index="sec">
        <cfif arrayLen(sec.rows)>
        <div class="panel" style="padding:0;margin-bottom:28px">

            <!--- Section header --->
            <div style="display:flex;align-items:center;justify-content:space-between;padding:16px 24px;border-bottom:1px solid var(--border);background:var(--surface)">
                <p style="margin:0;font-weight:700;font-size:15px;color:var(--text)">#HTMLEditFormat(sec.label)#</p>
                <span style="font-size:13px;color:var(--text-muted);font-weight:600">#arrayLen(sec.rows)# guest#arrayLen(sec.rows) NEQ 1 ? 's' : ''#</span>
            </div>

            <!--- Desktop table --->
            <div class="guest-desktop-table">
            <div class="table-wrap">
            <table>
                <thead>
                    <tr><th style="width:36px;text-align:center">##</th><th>Name</th><th>Email</th><th>Group</th><th>Dietary</th><th>RSVP</th><th>Table</th><th></th></tr>
                </thead>
                <tbody>
                <cfloop array="#sec.rows#" index="rowNum">
                    <cfset guestId_       = guests["guest_id"][rowNum]>
                    <cfset name_          = guests["name"][rowNum]>
                    <cfset email_         = guests["email"][rowNum]>
                    <cfset guest_group_   = guests["guest_group"][rowNum]>
                    <cfset dietary_       = guests["dietary_restrictions"][rowNum]>
                    <cfset rsvp_status_   = guests["rsvp_status"][rowNum]>
                    <cfset plus_one_      = guests["plus_one"][rowNum]>
                    <cfset plus_one_name_ = guests["plus_one_name"][rowNum]>
                    <cfset table_number_  = guests["table_number"][rowNum]>
                    <cfset rowIndex       = arrayFind(sec.rows, rowNum)>
                    <tr>
                        <td style="text-align:center;color:var(--text-muted);font-size:12px;font-weight:600">#rowIndex#</td>
                        <td>
                            <strong>#HTMLEditFormat(name_)#</strong>
                            <cfif plus_one_>
                                <span class="badge badge-blue" style="margin-left:6px">+1<cfif len(plus_one_name_)>: #HTMLEditFormat(plus_one_name_)#</cfif></span>
                                <form method="post" action="/members/guests.cfm" style="display:inline;margin-left:4px">
                                    <input type="hidden" name="action" value="remove_plus_one">
                                    <input type="hidden" name="guestId" value="#guestId_#">
                                    <button type="submit" class="btn btn-ghost btn-sm" style="font-size:10px;padding:2px 7px" onclick="return confirm('Remove plus one for #JSStringFormat(name_)#?')">&##10005; Plus One</button>
                                </form>
                            </cfif>
                        </td>
                        <td><cfif len(email_)><a href="mailto:#HTMLEditFormat(email_)#">#HTMLEditFormat(email_)#</a></cfif></td>
                        <td>#HTMLEditFormat(guest_group_)#</td>
                        <td>#HTMLEditFormat(dietary_)#</td>
                        <td>
                            <form method="post" action="/members/guests.cfm" style="display:inline">
                                <input type="hidden" name="action" value="update_rsvp">
                                <input type="hidden" name="guestId" value="#guestId_#">
                                <select name="rsvpStatus" onchange="this.form.submit()" style="font-size:12px;padding:4px 8px;border-radius:20px;border:1.5px solid var(--border)">
                                    <option value="pending"   <cfif rsvp_status_ EQ "pending">selected</cfif>>Pending</option>
                                    <option value="attending" <cfif rsvp_status_ EQ "attending">selected</cfif>>Attending</option>
                                    <option value="declined"  <cfif rsvp_status_ EQ "declined">selected</cfif>>Declined</option>
                                    <option value="maybe"     <cfif rsvp_status_ EQ "maybe">selected</cfif>>Maybe</option>
                                </select>
                            </form>
                        </td>
                        <td><cfif isNumeric(table_number_)>Table #table_number_#</cfif></td>
                        <td style="white-space:nowrap">
                            <button type="button" class="btn btn-ghost btn-sm" style="margin-right:4px"
                                onclick="openEditModal(#guestId_#,'#JSStringFormat(name_)#','#JSStringFormat(email_)#','#JSStringFormat(guest_group_)#','#JSStringFormat(rsvp_status_)#',#plus_one_#,'#JSStringFormat(plus_one_name_)#','#JSStringFormat(dietary_)#','#JSStringFormat(guests["notes"][rowNum])#')">Edit</button>
                            <cfif hasSite AND len(trim(email_))>
                            <form method="post" action="/members/guests.cfm" style="display:inline">
                                <input type="hidden" name="action" value="resend_invite">
                                <input type="hidden" name="guestId" value="#guestId_#">
                                <button type="submit" class="btn btn-sm" style="margin-right:4px">Resend</button>
                            </form>
                            </cfif>
                            <form method="post" action="/members/guests.cfm" style="display:inline">
                                <input type="hidden" name="action" value="delete_guest">
                                <input type="hidden" name="guestId" value="#guestId_#">
                                <button type="submit" class="btn btn-danger btn-sm" onclick="return confirm('Remove this guest?')">&times;</button>
                            </form>
                        </td>
                    </tr>
                </cfloop>
                </tbody>
                <tfoot>
                    <tr>
                        <td colspan="8" style="padding:12px 24px;text-align:right;font-size:13px;color:var(--text-muted);font-weight:600;background:var(--surface)">
                            Total: #arrayLen(sec.rows)# guest#arrayLen(sec.rows) NEQ 1 ? 's' : ''#
                        </td>
                    </tr>
                </tfoot>
            </table>
            </div>
            </div><!--- /guest-desktop-table --->

            <!--- Mobile cards --->
            <div class="guest-mobile-cards">
            <cfloop array="#sec.rows#" index="rowNum">
                <cfset guestId_       = guests["guest_id"][rowNum]>
                <cfset name_          = guests["name"][rowNum]>
                <cfset email_         = guests["email"][rowNum]>
                <cfset guest_group_   = guests["guest_group"][rowNum]>
                <cfset dietary_       = guests["dietary_restrictions"][rowNum]>
                <cfset rsvp_status_   = guests["rsvp_status"][rowNum]>
                <cfset plus_one_      = guests["plus_one"][rowNum]>
                <cfset plus_one_name_ = guests["plus_one_name"][rowNum]>
                <cfset table_number_  = guests["table_number"][rowNum]>
                <cfset rowIndex       = arrayFind(sec.rows, rowNum)>
                <div style="border-bottom:1px solid var(--border);padding:16px 20px">
                    <div style="display:flex;justify-content:space-between;align-items:flex-start;margin-bottom:12px">
                        <div>
                            <p style="font-weight:700;font-size:15px;margin-bottom:4px">#HTMLEditFormat(name_)#</p>
                            <cfif plus_one_>
                                <span class="badge badge-blue">+1<cfif len(plus_one_name_)>: #HTMLEditFormat(plus_one_name_)#</cfif></span>
                                <form method="post" action="/members/guests.cfm" style="display:inline;margin-left:4px">
                                    <input type="hidden" name="action" value="remove_plus_one">
                                    <input type="hidden" name="guestId" value="#guestId_#">
                                    <button type="submit" class="btn btn-ghost btn-sm" style="font-size:10px;padding:2px 7px" onclick="return confirm('Remove plus one for #JSStringFormat(name_)#?')">&##10005; Plus One</button>
                                </form>
                            </cfif>
                        </div>
                        <div style="display:flex;gap:6px;flex-shrink:0;margin-left:10px">
                            <button type="button" class="btn btn-ghost btn-sm"
                                onclick="openEditModal(#guestId_#,'#JSStringFormat(name_)#','#JSStringFormat(email_)#','#JSStringFormat(guest_group_)#','#JSStringFormat(rsvp_status_)#',#plus_one_#,'#JSStringFormat(plus_one_name_)#','#JSStringFormat(dietary_)#','#JSStringFormat(guests["notes"][rowNum])#')">Edit</button>
                            <cfif hasSite AND len(trim(email_))>
                            <form method="post" action="/members/guests.cfm" style="display:inline">
                                <input type="hidden" name="action" value="resend_invite">
                                <input type="hidden" name="guestId" value="#guestId_#">
                                <button type="submit" class="btn btn-sm">Resend</button>
                            </form>
                            </cfif>
                            <form method="post" action="/members/guests.cfm" style="display:inline">
                                <input type="hidden" name="action" value="delete_guest">
                                <input type="hidden" name="guestId" value="#guestId_#">
                                <button type="submit" class="btn btn-danger btn-sm" onclick="return confirm('Remove this guest?')">&times;</button>
                            </form>
                        </div>
                    </div>
                    <div style="display:grid;grid-template-columns:1fr 1fr;gap:10px 16px;font-size:13px">
                        <div>
                            <p style="font-size:10px;font-weight:700;letter-spacing:0.1em;text-transform:uppercase;color:var(--text-muted);margin-bottom:3px">RSVP</p>
                            <form method="post" action="/members/guests.cfm">
                                <input type="hidden" name="action" value="update_rsvp">
                                <input type="hidden" name="guestId" value="#guestId_#">
                                <select name="rsvpStatus" onchange="this.form.submit()" style="font-size:12px;padding:4px 8px;border-radius:20px;border:1.5px solid var(--border);width:100%">
                                    <option value="pending"   <cfif rsvp_status_ EQ "pending">selected</cfif>>Pending</option>
                                    <option value="attending" <cfif rsvp_status_ EQ "attending">selected</cfif>>Attending</option>
                                    <option value="declined"  <cfif rsvp_status_ EQ "declined">selected</cfif>>Declined</option>
                                    <option value="maybe"     <cfif rsvp_status_ EQ "maybe">selected</cfif>>Maybe</option>
                                </select>
                            </form>
                        </div>
                        <cfif len(trim(guest_group_))>
                        <div>
                            <p style="font-size:10px;font-weight:700;letter-spacing:0.1em;text-transform:uppercase;color:var(--text-muted);margin-bottom:3px">Group</p>
                            <p>#HTMLEditFormat(guest_group_)#</p>
                        </div>
                        </cfif>
                        <cfif len(trim(email_))>
                        <div style="grid-column:1/-1">
                            <p style="font-size:10px;font-weight:700;letter-spacing:0.1em;text-transform:uppercase;color:var(--text-muted);margin-bottom:3px">Email</p>
                            <a href="mailto:#HTMLEditFormat(email_)#" style="color:var(--gold);word-break:break-all">#HTMLEditFormat(email_)#</a>
                        </div>
                        </cfif>
                        <cfif len(trim(dietary_))>
                        <div style="grid-column:1/-1">
                            <p style="font-size:10px;font-weight:700;letter-spacing:0.1em;text-transform:uppercase;color:var(--text-muted);margin-bottom:3px">Dietary</p>
                            <p>#HTMLEditFormat(dietary_)#</p>
                        </div>
                        </cfif>
                        <cfif isNumeric(table_number_)>
                        <div>
                            <p style="font-size:10px;font-weight:700;letter-spacing:0.1em;text-transform:uppercase;color:var(--text-muted);margin-bottom:3px">Table</p>
                            <p>Table #table_number_#</p>
                        </div>
                        </cfif>
                    </div>
                </div>
            </cfloop>
            </div><!--- /guest-mobile-cards --->

        </div>
        </cfif>
    </cfloop>
    </cfoutput>

    <cfelse>
        <div class="empty-state">
            <div style="font-size:48px;margin-bottom:16px">&#128101;</div>
            <p>No guests yet. <cfif hasSite>Start building your guest list above!<cfelse>Publish your wedding website first, then start adding guests.</cfif></p>
        </div>
    </cfif>
</div>
</section>
<!--- Edit Guest Modal --->
<cfoutput>
<div id="editGuestModal" style="display:none;position:fixed;inset:0;z-index:1000;background:rgba(0,0,0,.5);overflow-y:auto;padding:40px 16px">
<div style="background:##fff;border-radius:12px;max-width:560px;margin:0 auto;padding:32px">
    <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:24px">
        <h2 style="margin:0;font-size:20px">Edit Guest</h2>
        <button type="button" onclick="closeEditModal()" style="background:none;border:none;font-size:22px;cursor:pointer;color:var(--text-muted)">&times;</button>
    </div>
    <form method="post" action="/members/guests.cfm">
        <input type="hidden" name="action"  value="update_guest">
        <input type="hidden" name="guestId" id="editGuestId">
        <div class="field">
            <label>Full Name *</label>
            <input type="text" name="name" id="editName" required>
        </div>
        <div class="field">
            <label>Email</label>
            <input type="email" name="email" id="editEmail" placeholder="guest@email.com">
        </div>
        <div style="display:grid;grid-template-columns:1fr 1fr;gap:12px">
            <div class="field">
                <label>Group</label>
                <select name="guestGroup" id="editGroup">
                    <option value="">Select</option>
                    <cfloop array="#groups#" index="g"><option value="#HTMLEditFormat(g)#">#HTMLEditFormat(g)#</option></cfloop>
                </select>
            </div>
            <div class="field">
                <label>RSVP Status</label>
                <select name="rsvpStatus" id="editRsvp">
                    <option value="pending">Pending</option>
                    <option value="attending">Attending</option>
                    <option value="declined">Declined</option>
                    <option value="maybe">Maybe</option>
                </select>
            </div>
        </div>
        <div class="field">
            <div style="display:flex;align-items:center;gap:8px;margin-bottom:8px">
                <input type="checkbox" name="plusOne" id="editPlusOneCheck" value="on"
                    onchange="document.getElementById('editPlusOneNameWrap').style.display=this.checked?'block':'none'"
                    style="width:16px;height:16px;cursor:pointer">
                <label for="editPlusOneCheck" style="margin-bottom:0;cursor:pointer">Plus One</label>
            </div>
            <div id="editPlusOneNameWrap" style="display:none">
                <input type="text" name="plusOneName" id="editPlusOneName" placeholder="Plus one's full name">
            </div>
        </div>
        <div class="field">
            <label>Dietary Restrictions</label>
            <input type="text" name="dietaryRestrictions" id="editDietary" placeholder="e.g. vegetarian, gluten-free">
        </div>
        <div class="field">
            <label>Notes <span style="font-weight:400;text-transform:none;letter-spacing:0">(internal)</span></label>
            <input type="text" name="notes" id="editNotes" placeholder="e.g. VIP, needs wheelchair access">
        </div>
        <div style="display:flex;gap:12px;margin-top:8px">
            <button type="submit" class="btn btn-primary" style="flex:1">Save Changes</button>
            <button type="button" onclick="closeEditModal()" class="btn btn-ghost" style="flex:1">Cancel</button>
        </div>
    </form>
</div>
</div>
</cfoutput>

<script>
function openEditModal(id, name, email, group, rsvp, plusOne, plusOneName, dietary, notes) {
    document.getElementById('editGuestId').value   = id;
    document.getElementById('editName').value      = name;
    document.getElementById('editEmail').value     = email;
    document.getElementById('editDietary').value   = dietary;
    document.getElementById('editNotes').value     = notes;

    var groupSel = document.getElementById('editGroup');
    for (var i = 0; i < groupSel.options.length; i++) {
        groupSel.options[i].selected = (groupSel.options[i].value === group);
    }
    var rsvpSel = document.getElementById('editRsvp');
    for (var i = 0; i < rsvpSel.options.length; i++) {
        rsvpSel.options[i].selected = (rsvpSel.options[i].value === rsvp);
    }

    var hasPlusOne = (plusOne == 1);
    document.getElementById('editPlusOneCheck').checked              = hasPlusOne;
    document.getElementById('editPlusOneNameWrap').style.display     = hasPlusOne ? 'block' : 'none';
    document.getElementById('editPlusOneName').value                 = plusOneName;

    document.getElementById('editGuestModal').style.display = 'block';
    document.body.style.overflow = 'hidden';
}

function closeEditModal() {
    document.getElementById('editGuestModal').style.display = 'none';
    document.body.style.overflow = '';
}

document.getElementById('editGuestModal').addEventListener('click', function(e) {
    if (e.target === this) closeEditModal();
});
</script>

<cfinclude template="../includes/layout-end.cfm">
