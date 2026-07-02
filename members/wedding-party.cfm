<cfinclude template="../includes/auth-check.cfm">
<cfset pageTitle = "Wedding Party | digitalweddings.love">
<cfset activePage = "wedding-party">
<cfset userId = session.user.id>
<cfparam name="form.action"    default="">
<cfparam name="form.memberId"  default="0">
<cfparam name="form.name"      default="">
<cfparam name="form.email"     default="">
<cfparam name="form.partyRole" default="">
<cfparam name="form.partySide" default="">
<cfparam name="url.preview"   default="">
<cfparam name="url.error"     default="">
<cfparam name="url.sent"      default="">
<cfparam name="url.selftest"  default="">


<!--- ── Send test invite to self ── --->
<cfif form.action EQ "send_test" AND isNumeric(form.memberId) AND form.memberId GT 0>
    <cftry>
        <cfquery name="qMember" datasource="#application.config.datasource#">
            SELECT name, party_role, party_side FROM dbo.WeddingPartyMembers
            WHERE wedding_party_member_id = <cfqueryparam value="#form.memberId#" cfsqltype="cf_sql_bigint">
              AND user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
        </cfquery>
        <cfif NOT qMember.recordCount>
            <cfthrow message="Member not found for ID #form.memberId# and userId #userId#">
        </cfif>
        <cfquery name="qSiteForEmail" datasource="#application.config.datasource#">
            SELECT couple_name_1, couple_name_2, wedding_date, slug, template
            FROM dbo.WeddingSites
            WHERE user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
            ORDER BY created_at DESC
        </cfquery>
        <cfif NOT qSiteForEmail.recordCount>
            <cfthrow message="No WeddingSite found for userId #userId#. A wedding site is required to send invites.">
        </cfif>
        <cfinclude template="email-theme-helper.cfm">
        <cfset emailSiteLink = "https://digitalweddings.love/site.cfm?slug=" & URLEncodedFormat(qSiteForEmail.slug)>
        <cfset wpMemberName  = trim(qMember.name)>
        <cfset wpRole        = trim(qMember.party_role)>
        <cfset wpSide        = trim(qMember.party_side)>
        <cfset wpMemberId    = form.memberId>
        <cfif wpSide EQ "Bride's Side">
            <cfset wpSubject = "[TEST] " & qSiteForEmail.couple_name_1 & " wants you in their wedding!">
        <cfelseif wpSide EQ "Groom's Side">
            <cfset wpSubject = "[TEST] " & qSiteForEmail.couple_name_2 & " wants you in their wedding!">
        <cfelse>
            <cfset wpSubject = "[TEST] " & qSiteForEmail.couple_name_1 & " & " & qSiteForEmail.couple_name_2 & " want you in their wedding!">
        </cfif>
        <cfif NOT len(trim(session.user.email))>
            <cfthrow message="session.user.email is empty - cannot send test email.">
        </cfif>
        <cfmail to="#session.user.email#"
                from="#application.config.mailFrom#"
                replyto="#session.user.email#"
                subject="#wpSubject#"
                type="html"><cfinclude template="email-wedding-party-body.cfm"></cfmail>
        <cflocation url="wedding-party.cfm?preview=1" addToken="false">
    <cfcatch type="any">
        <cftry>
        <cfmail to="moniqueboea@gmail.com"
                from="#application.config.mailFrom#"
                subject="wedding-party.cfm send_test ERROR - #cfcatch.type#"
                type="text">
ERROR REPORT - wedding-party.cfm send_test (digitalweddings)
=============================================================
Type:    #cfcatch.type#
Message: #cfcatch.message#
Detail:  #cfcatch.detail#

--- Variables at time of error ---
userId:            #userId#
form.memberId:     #form.memberId#
session.user.email:#IsDefined('session.user.email') ? session.user.email : '[NOT DEFINED]'#
qMember.recordCount:    #IsDefined('qMember') ? qMember.recordCount : '[query not run]'#
qSiteForEmail.recordCount: #IsDefined('qSiteForEmail') ? qSiteForEmail.recordCount : '[query not run]'#
wpMemberName:      #IsDefined('wpMemberName') ? wpMemberName : '[NOT DEFINED]'#
wpRole:            #IsDefined('wpRole') ? wpRole : '[NOT DEFINED]'#
wpSide:            #IsDefined('wpSide') ? wpSide : '[NOT DEFINED]'#
wpSubject:         #IsDefined('wpSubject') ? wpSubject : '[NOT DEFINED]'#
emailSiteLink:     #IsDefined('emailSiteLink') ? emailSiteLink : '[NOT DEFINED]'#
application.config.mailFrom: #IsDefined('application.config.mailFrom') ? application.config.mailFrom : '[NOT DEFINED]'#

--- Stack Trace ---
#cfcatch.stackTrace#
        </cfmail>
        <cfcatch type="any"><!--- ignore errors sending the diagnostic email ---></cfcatch>
        </cftry>
        <cflocation url="wedding-party.cfm?error=testfail" addToken="false">
    </cfcatch>
    </cftry>
    <cflocation url="wedding-party.cfm?error=testfail" addToken="false">
</cfif>

<cfif form.action EQ "add_member">
    <cfif len(trim(form.name)) && len(trim(form.partyRole))>
        <cfquery datasource="#application.config.datasource#">
            INSERT INTO dbo.WeddingPartyMembers (user_id, name, email, party_role, party_side)
            VALUES (
                <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">,
                <cfqueryparam value="#trim(form.name)#" cfsqltype="cf_sql_nvarchar">,
                <cfqueryparam value="#lCase(trim(form.email))#" cfsqltype="cf_sql_varchar" null="#!len(trim(form.email))#">,
                <cfqueryparam value="#trim(form.partyRole)#" cfsqltype="cf_sql_nvarchar">,
                <cfqueryparam value="#trim(form.partySide)#" cfsqltype="cf_sql_nvarchar" null="#!len(trim(form.partySide))#">
            )
        </cfquery>

        <!--- Send wedding party invite email if an email address was provided --->
        <cfif len(trim(form.email))>
            <cftry>
                <cfquery name="qSiteForEmail" datasource="#application.config.datasource#">
                    SELECT couple_name_1, couple_name_2, wedding_date, slug, template
                    FROM dbo.WeddingSites
                    WHERE user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
                    ORDER BY created_at DESC
                </cfquery>
                <cfif qSiteForEmail.recordCount>
                    <cfinclude template="email-theme-helper.cfm">
                    <cfset emailSiteLink = "https://digitalweddings.love/site.cfm?slug=" & URLEncodedFormat(qSiteForEmail.slug)>
                    <cfset wpMemberName  = trim(form.name)>
                    <cfset wpRole        = trim(form.partyRole)>
                    <cfset wpSide        = trim(form.partySide)>
                    <cfset wpEmailTo     = lCase(trim(form.email))>
                    <cfquery name="qNewMember" datasource="#application.config.datasource#">
                        SELECT TOP 1 wedding_party_member_id FROM dbo.WeddingPartyMembers
                        WHERE user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
                          AND email   = <cfqueryparam value="#wpEmailTo#" cfsqltype="cf_sql_varchar">
                        ORDER BY wedding_party_member_id DESC
                    </cfquery>
                    <cfset wpMemberId = qNewMember.recordCount ? qNewMember.wedding_party_member_id : 0>
                    <cfif wpSide EQ "Bride's Side">
                        <cfset wpSubject = HTMLEditFormat(qSiteForEmail.couple_name_1) & " wants you in their wedding!">
                    <cfelseif wpSide EQ "Groom's Side">
                        <cfset wpSubject = HTMLEditFormat(qSiteForEmail.couple_name_2) & " wants you in their wedding!">
                    <cfelse>
                        <cfset wpSubject = HTMLEditFormat(qSiteForEmail.couple_name_1) & " & " & HTMLEditFormat(qSiteForEmail.couple_name_2) & " want you in their wedding!">
                    </cfif>
                    <cfmail to="#wpEmailTo#"
                            from="#application.config.mailFrom#"
                            replyto="#session.user.email#"
                            bcc="#session.user.email#"
                            subject="#wpSubject#"
                            server="localhost"
                            port="25"
                            timeout="60"
                            type="html"><cfinclude template="email-wedding-party-body.cfm"></cfmail>
                </cfif>
            <cfcatch><!--- swallow mail errors silently ---></cfcatch>
            </cftry>
        </cfif>

    </cfif>
    <cflocation url="wedding-party.cfm" addToken="false">
</cfif>

<cfif form.action EQ "update_status" && isNumeric(form.memberId)>
    <cfquery datasource="#application.config.datasource#">
        UPDATE dbo.WeddingPartyMembers SET accepted = <cfqueryparam value="#trim(form.accepted)#" cfsqltype="cf_sql_varchar">, updated_at = SYSUTCDATETIME()
        WHERE wedding_party_member_id = <cfqueryparam value="#form.memberId#" cfsqltype="cf_sql_bigint"> AND user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
    </cfquery>
    <cflocation url="wedding-party.cfm" addToken="false">
</cfif>

<cfif form.action EQ "delete_member" && isNumeric(form.memberId)>
    <cfquery datasource="#application.config.datasource#">
        DELETE FROM dbo.WeddingPartyMembers WHERE wedding_party_member_id = <cfqueryparam value="#form.memberId#" cfsqltype="cf_sql_bigint"> AND user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
    </cfquery>
    <cflocation url="wedding-party.cfm" addToken="false">
</cfif>

<!--- ── Send to myself (preview) ── --->
<cfif form.action EQ "send_self">
    <cfquery name="qSelfSite" datasource="#application.config.datasource#">
        SELECT couple_name_1, couple_name_2, wedding_date, slug, coord_name, coord_email
        FROM dbo.WeddingSites
        WHERE user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
        ORDER BY created_at DESC
    </cfquery>
    <cfif NOT qSelfSite.recordCount>
        <cflocation url="wedding-party.cfm?error=sendfail" addToken="false">
    </cfif>
    <cfquery name="qPartyForSelf" datasource="#application.config.datasource#">
        SELECT name, party_role, party_side, email, phone
        FROM dbo.WeddingPartyMembers
        WHERE user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
        ORDER BY party_side, party_role, name
    </cfquery>
    <cfset coordSite    = qSelfSite>
    <cfset coordSection = "Wedding Party">
    <cfset coordSentAt  = dateTimeFormat(now(), "mmmm d, yyyy h:mm tt")>
    <cfset coordSiteUrl = len(trim(qSelfSite.slug)) ? "https://digitalweddings.love/site.cfm?slug=#URLEncodedFormat(trim(qSelfSite.slug))#" : "">
    <cfsavecontent variable="coordBodyHtml">
        <cfoutput>
        <cfif qPartyForSelf.recordCount>
        <table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0" style="border-collapse:collapse">
            <tr style="background:##e8f0e9">
                <th style="padding:8px 10px;text-align:left;font-size:12px;color:##3a5e3e;font-family:Arial,sans-serif;border-bottom:1px solid ##b2cbb5">Name</th>
                <th style="padding:8px 10px;text-align:left;font-size:12px;color:##3a5e3e;font-family:Arial,sans-serif;border-bottom:1px solid ##b2cbb5">Role</th>
                <th style="padding:8px 10px;text-align:left;font-size:12px;color:##3a5e3e;font-family:Arial,sans-serif;border-bottom:1px solid ##b2cbb5">Side</th>
                <th style="padding:8px 10px;text-align:left;font-size:12px;color:##3a5e3e;font-family:Arial,sans-serif;border-bottom:1px solid ##b2cbb5">Email</th>
                <th style="padding:8px 10px;text-align:left;font-size:12px;color:##3a5e3e;font-family:Arial,sans-serif;border-bottom:1px solid ##b2cbb5">Phone</th>
            </tr>
            <cfloop query="qPartyForSelf">
            <tr>
                <td style="padding:8px 10px;font-size:13px;color:##333;font-family:Arial,sans-serif;border-bottom:1px solid ##eee">#HTMLEditFormat(name)#</td>
                <td style="padding:8px 10px;font-size:13px;color:##333;font-family:Arial,sans-serif;border-bottom:1px solid ##eee">#HTMLEditFormat(party_role)#</td>
                <td style="padding:8px 10px;font-size:13px;color:##333;font-family:Arial,sans-serif;border-bottom:1px solid ##eee">#HTMLEditFormat(party_side)#</td>
                <td style="padding:8px 10px;font-size:13px;color:##333;font-family:Arial,sans-serif;border-bottom:1px solid ##eee">#HTMLEditFormat(email)#</td>
                <td style="padding:8px 10px;font-size:13px;color:##333;font-family:Arial,sans-serif;border-bottom:1px solid ##eee">#HTMLEditFormat(phone)#</td>
            </tr>
            </cfloop>
        </table>
        <cfelse>
        <p style="color:##888;font-size:13px;font-family:Arial,sans-serif;font-style:italic">No information added yet.</p>
        </cfif>
        </cfoutput>
    </cfsavecontent>
    <cftry>
        <cfset coordSubject = "Wedding Party - " & trim(qSelfSite.couple_name_1) & " & " & trim(qSelfSite.couple_name_2)>
        <cfmail to="#session.user.email#"
                from="#application.config.mailFrom#"
                server="localhost" port="25"
                subject="#coordSubject#"
                type="html" timeout="60"><cfinclude template="email-coordinator-body.cfm"></cfmail>
        <cflocation url="wedding-party.cfm?selftest=1" addToken="false">
    <cfcatch>
        <cflocation url="wedding-party.cfm?error=selfsendfail" addToken="false">
    </cfcatch>
    </cftry>
</cfif>

<!--- ── Send to coordinator ── --->
<cfif form.action EQ "send_coordinator">
    <cfquery name="qCoordSite" datasource="#application.config.datasource#">
        SELECT couple_name_1, couple_name_2, wedding_date, slug, coord_name, coord_email
        FROM dbo.WeddingSites
        WHERE user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
        ORDER BY created_at DESC
    </cfquery>
    <cfif NOT qCoordSite.recordCount OR NOT len(trim(qCoordSite.coord_email))>
        <cflocation url="wedding-party.cfm?error=noemail" addToken="false">
    </cfif>
    <cfquery name="qPartyForCoord" datasource="#application.config.datasource#">
        SELECT name, party_role, party_side, email, phone
        FROM dbo.WeddingPartyMembers
        WHERE user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
        ORDER BY party_side, party_role, name
    </cfquery>
    <cfset coordSite    = qCoordSite>
    <cfset coordSection = "Wedding Party">
    <cfset coordSentAt  = dateTimeFormat(now(), "mmmm d, yyyy h:mm tt")>
    <cfset coordSiteUrl = len(trim(qCoordSite.slug)) ? "https://digitalweddings.love/site.cfm?slug=#URLEncodedFormat(trim(qCoordSite.slug))#" : "">
    <cfsavecontent variable="coordBodyHtml">
        <cfoutput>
        <cfif qPartyForCoord.recordCount>
        <table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0" style="border-collapse:collapse">
            <tr style="background:##e8f0e9">
                <th style="padding:8px 10px;text-align:left;font-size:12px;color:##3a5e3e;font-family:Arial,sans-serif;border-bottom:1px solid ##b2cbb5">Name</th>
                <th style="padding:8px 10px;text-align:left;font-size:12px;color:##3a5e3e;font-family:Arial,sans-serif;border-bottom:1px solid ##b2cbb5">Role</th>
                <th style="padding:8px 10px;text-align:left;font-size:12px;color:##3a5e3e;font-family:Arial,sans-serif;border-bottom:1px solid ##b2cbb5">Side</th>
                <th style="padding:8px 10px;text-align:left;font-size:12px;color:##3a5e3e;font-family:Arial,sans-serif;border-bottom:1px solid ##b2cbb5">Email</th>
                <th style="padding:8px 10px;text-align:left;font-size:12px;color:##3a5e3e;font-family:Arial,sans-serif;border-bottom:1px solid ##b2cbb5">Phone</th>
            </tr>
            <cfloop query="qPartyForCoord">
            <tr>
                <td style="padding:8px 10px;font-size:13px;color:##333;font-family:Arial,sans-serif;border-bottom:1px solid ##eee">#HTMLEditFormat(name)#</td>
                <td style="padding:8px 10px;font-size:13px;color:##333;font-family:Arial,sans-serif;border-bottom:1px solid ##eee">#HTMLEditFormat(party_role)#</td>
                <td style="padding:8px 10px;font-size:13px;color:##333;font-family:Arial,sans-serif;border-bottom:1px solid ##eee">#HTMLEditFormat(party_side)#</td>
                <td style="padding:8px 10px;font-size:13px;color:##333;font-family:Arial,sans-serif;border-bottom:1px solid ##eee">#HTMLEditFormat(email)#</td>
                <td style="padding:8px 10px;font-size:13px;color:##333;font-family:Arial,sans-serif;border-bottom:1px solid ##eee">#HTMLEditFormat(phone)#</td>
            </tr>
            </cfloop>
        </table>
        <cfelse>
        <p style="color:##888;font-size:13px;font-family:Arial,sans-serif;font-style:italic">No information added yet.</p>
        </cfif>
        </cfoutput>
    </cfsavecontent>
    <cftry>
        <cfset coordSubject = "Wedding Party - " & trim(qCoordSite.couple_name_1) & " & " & trim(qCoordSite.couple_name_2)>
        <cfmail to="#trim(qCoordSite.coord_email)#"
                from="#application.config.mailFrom#"
                replyto="#session.user.email#"
                server="localhost" port="25"
                subject="#coordSubject#"
                type="html" timeout="60"><cfinclude template="email-coordinator-body.cfm"></cfmail>
        <cflocation url="wedding-party.cfm?sent=1" addToken="false">
    <cfcatch>
        <cflocation url="wedding-party.cfm?error=sendfail" addToken="false">
    </cfcatch>
    </cftry>
</cfif>

<cfquery name="userSite" datasource="#application.config.datasource#">
    SELECT TOP 1 wedding_site_id FROM dbo.WeddingSites
    WHERE user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
</cfquery>
<cfset hasSite = userSite.recordCount GT 0>

<cfquery name="members" datasource="#application.config.datasource#">
    SELECT wedding_party_member_id, name, email, party_role, party_side, accepted, notes
    FROM dbo.WeddingPartyMembers WHERE user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
    ORDER BY party_side, party_role, name
</cfquery>

<cfset roles = ["Maid of Honor","Best Man","Bridesmaid","Groomsman","Flower Girl","Ring Bearer","Junior Bridesmaid","Usher","Officiant","Other"]>
<cfset sides = ["Bride's Side","Groom's Side","Both Sides"]>

<cfinclude template="../includes/layout-start.cfm">
<style>
.wp-desktop { display: block; }
.wp-mobile  { display: none; }
@media (max-width:768px) {
    .mfr { grid-template-columns: 1fr !important; }
    .mfr input, .mfr select, .mfr button[type=submit] {
        display: block !important; width: 100% !important;
        min-width: 0 !important; max-width: 100% !important;
        box-sizing: border-box !important;
    }
    div.wp-desktop { display: none !important; }
    div.wp-mobile  { display: block !important; }
}
</style>
<script>
(function(){
    function applyLayout(){
        var isM = window.innerWidth <= 768;
        document.querySelectorAll('.wp-desktop').forEach(function(el){ el.style.display = isM ? 'none' : ''; });
        document.querySelectorAll('.wp-mobile').forEach(function(el){ el.style.display = isM ? 'block' : 'none'; });
    }
    applyLayout();
    window.addEventListener('resize', applyLayout);
})();
</script>
<section style="padding:60px 0">
<div class="container">
    <div class="page-header">
        <p class="eyebrow">Your Crew</p>
        <h1>Wedding <span class="script">Party</span></h1>
    </div>

    <cfif url.preview EQ "1">
    <div class="alert alert-success" style="margin-bottom:24px">
        Test invite sent to <cfoutput>#HTMLEditFormat(session.user.email)#</cfoutput> &mdash; check your inbox!
    </div>
    </cfif>
    <cfif url.sent EQ "1">
    <div class="alert alert-success" style="margin-bottom:24px">Wedding Party information sent to your coordinator!</div>
    </cfif>
    <cfif url.selftest EQ "1">
    <div class="alert alert-success" style="margin-bottom:24px">Wedding Party preview sent to <cfoutput>#HTMLEditFormat(session.user.email)#</cfoutput> - check your inbox!</div>
    </cfif>
    <cfif url.error EQ "testfail">
    <div class="alert alert-error" style="margin-bottom:24px">Could not send test invite. Please try again.</div>
    </cfif>
    <cfif url.error EQ "noemail">
    <div class="alert alert-error" style="margin-bottom:24px">Please add your wedding coordinator&rsquo;s email address before sending information. <a href="/members/coordinator.cfm">Add coordinator &rarr;</a></div>
    </cfif>
    <cfif url.error EQ "sendfail" OR url.error EQ "selfsendfail">
    <div class="alert alert-error" style="margin-bottom:24px">There was a problem sending the email. Please try again.</div>
    </cfif>

    <div style="display:flex;justify-content:flex-end;gap:8px;margin-bottom:20px">
        <form method="post" action="/members/wedding-party.cfm">
            <input type="hidden" name="action" value="send_self">
            <button type="submit" class="btn btn-ghost btn-sm">&#128140; Send to Myself</button>
        </form>
        <form method="post" action="/members/wedding-party.cfm">
            <input type="hidden" name="action" value="send_coordinator">
            <button type="submit" class="btn btn-ghost btn-sm">&#128140; Send to Coordinator</button>
        </form>
    </div>

    <div class="panel" style="margin-bottom:24px">
        <p class="panel-title">Add a Member</p>
        <cfif NOT hasSite>
        <div class="alert alert-error" style="margin-bottom:16px">
            You need to <a href="/members/wedding-sites.cfm">create a wedding site</a> before adding wedding party members &mdash; the invitation email uses your site&rsquo;s style and details.
        </div>
        </cfif>
        <form method="post" action="/members/wedding-party.cfm" <cfif NOT hasSite>style="opacity:.4;pointer-events:none"</cfif>>
            <input type="hidden" name="action" value="add_member">
            <div class="mfr" style="display:grid;grid-template-columns:2fr 2fr 1fr 1fr auto;gap:12px;align-items:end">
                <div class="field" style="margin-bottom:0">
                    <label>Full Name *</label>
                    <input type="text" name="name" required placeholder="e.g. Maya Johnson">
                </div>
                <div class="field" style="margin-bottom:0">
                    <label>Email</label>
                    <input type="email" name="email" placeholder="maya@email.com">
                </div>
                <div class="field" style="margin-bottom:0">
                    <label>Role *</label>
                    <select name="partyRole" required>
                        <option value="">Select</option>
                        <cfoutput><cfloop array="#roles#" index="r"><option value="#HTMLEditFormat(r)#">#HTMLEditFormat(r)#</option></cfloop></cfoutput>
                    </select>
                </div>
                <div class="field" style="margin-bottom:0">
                    <label>Side</label>
                    <select name="partySide">
                        <option value="">Select</option>
                        <cfoutput><cfloop array="#sides#" index="s"><option value="#HTMLEditFormat(s)#">#HTMLEditFormat(s)#</option></cfloop></cfoutput>
                    </select>
                </div>
                <button type="submit" class="btn btn-primary">Add</button>
            </div>
        </form>
    </div>

    <cfif members.recordCount>
    <!--- Desktop table --->
    <div class="panel wp-desktop" style="padding:0">
        <div class="table-wrap">
            <table>
                <thead><tr><th>Name</th><th>Role</th><th>Side</th><th>Email</th><th>Status</th><th>Note</th><th></th></tr></thead>
                <tbody>
                    <cfoutput query="members">
                    <tr>
                        <td><strong>#HTMLEditFormat(name)#</strong></td>
                        <td><span class="badge badge-gold">#HTMLEditFormat(party_role)#</span></td>
                        <td>#HTMLEditFormat(party_side)#</td>
                        <td><cfif len(email)><a href="mailto:#HTMLEditFormat(email)#">#HTMLEditFormat(email)#</a></cfif></td>
                        <td>
                            <form method="post" action="/members/wedding-party.cfm" style="display:inline">
                                <input type="hidden" name="action" value="update_status">
                                <input type="hidden" name="memberId" value="#wedding_party_member_id#">
                                <select name="accepted" onchange="this.form.submit()" style="font-size:12px;padding:4px 8px;border-radius:20px;border:1.5px solid var(--border)">
                                    <option value="pending" <cfif accepted EQ "pending">selected</cfif>>Pending</option>
                                    <option value="accepted" <cfif accepted EQ "accepted">selected</cfif>>Accepted</option>
                                    <option value="declined" <cfif accepted EQ "declined">selected</cfif>>Declined</option>
                                </select>
                            </form>
                        </td>
                        <td style="font-size:13px;color:var(--text-muted);font-style:italic">#HTMLEditFormat(notes)#</td>
                        <td style="display:flex;gap:6px;flex-wrap:wrap">
                            <form method="post" action="/members/wedding-party.cfm" style="display:inline">
                                <input type="hidden" name="action" value="send_test">
                                <input type="hidden" name="memberId" value="#wedding_party_member_id#">
                                <button type="submit" class="btn btn-ghost btn-sm" title="Send a test invite to yourself">Test</button>
                            </form>
                            <form method="post" action="/members/wedding-party.cfm" style="display:inline">
                                <input type="hidden" name="action" value="delete_member">
                                <input type="hidden" name="memberId" value="#wedding_party_member_id#">
                                <button type="submit" class="btn btn-danger btn-sm" onclick="return confirm('Remove this member?')">&times;</button>
                            </form>
                        </td>
                    </tr>
                    </cfoutput>
                </tbody>
            </table>
        </div>
    </div>
    <!--- Mobile cards --->
    <div class="wp-mobile">
        <cfoutput query="members">
        <div class="panel" style="margin-bottom:12px;padding:16px">
            <div style="display:flex;justify-content:space-between;align-items:start;margin-bottom:10px">
                <div>
                    <p style="font-weight:700;font-size:15px;margin-bottom:2px">#HTMLEditFormat(name)#</p>
                    <cfif len(email)><p style="font-size:13px;color:var(--text-muted)">#HTMLEditFormat(email)#</p></cfif>
                </div>
                <span class="badge badge-gold" style="flex-shrink:0;margin-left:8px">#HTMLEditFormat(party_role)#</span>
            </div>
            <cfif len(party_side)>
            <p style="font-size:13px;color:var(--text-muted);margin-bottom:8px">#HTMLEditFormat(party_side)#</p>
            </cfif>
            <cfif len(notes)>
            <p style="font-size:13px;color:var(--text-muted);font-style:italic;margin-bottom:8px">&ldquo;#HTMLEditFormat(notes)#&rdquo;</p>
            </cfif>
            <form method="post" action="/members/wedding-party.cfm" style="margin-bottom:8px">
                <input type="hidden" name="action" value="update_status">
                <input type="hidden" name="memberId" value="#wedding_party_member_id#">
                <select name="accepted" onchange="this.form.submit()" style="width:100%;font-size:13px;padding:8px 10px;border-radius:8px;border:1.5px solid var(--border);box-sizing:border-box">
                    <option value="pending"  <cfif accepted EQ "pending">selected</cfif>>Pending</option>
                    <option value="accepted" <cfif accepted EQ "accepted">selected</cfif>>Accepted</option>
                    <option value="declined" <cfif accepted EQ "declined">selected</cfif>>Declined</option>
                </select>
            </form>
            <div style="display:flex;flex-direction:column;gap:8px">
                <form method="post" action="/members/wedding-party.cfm">
                    <input type="hidden" name="action" value="send_test">
                    <input type="hidden" name="memberId" value="#wedding_party_member_id#">
                    <button type="submit" class="btn btn-ghost btn-sm" style="width:100%">Send Test Invite</button>
                </form>
                <form method="post" action="/members/wedding-party.cfm">
                    <input type="hidden" name="action" value="delete_member">
                    <input type="hidden" name="memberId" value="#wedding_party_member_id#">
                    <button type="submit" class="btn btn-danger btn-sm" style="width:100%" onclick="return confirm('Remove this member?')">Remove</button>
                </form>
            </div>
        </div>
        </cfoutput>
    </div>
    <cfelse>
        <div class="empty-state">
            <p>No wedding party members yet. Add your first member above!</p>
        </div>
    </cfif>
</div>
</section>
<cfinclude template="../includes/layout-end.cfm">
