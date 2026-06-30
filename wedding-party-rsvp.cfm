<cfcontent type="text/html; charset=utf-8">
<cfset pageTitle = "Wedding Party RSVP | digitalweddings.love">
<cfset emojiParty = chr(55356) & chr(56713)>
<cfset emojiLetter = chr(55357) & chr(56460)>
<cfparam name="url.id"      default="0">
<cfparam name="form.action" default="">
<cfparam name="form.rsvp"   default="">
<cfparam name="form.note"   default="">

<!--- Inline schema migration: add rsvp_note column if missing --->
<cftry>
    <cfquery name="qCheckCol" datasource="#application.config.datasource#">
        SELECT COUNT(*) AS cnt FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_SCHEMA='dbo' AND TABLE_NAME='WeddingPartyMembers' AND COLUMN_NAME='rsvp_note'
    </cfquery>
    <cfif qCheckCol.cnt EQ 0>
        <cfquery datasource="#application.config.datasource#">
            ALTER TABLE dbo.WeddingPartyMembers ADD rsvp_note NVARCHAR(1000) NULL
        </cfquery>
    </cfif>
<cfcatch></cfcatch>
</cftry>

<cfif !isNumeric(url.id) OR url.id LTE 0>
    <cflocation url="/" addToken="false">
</cfif>

<cfquery name="qMember" datasource="#application.config.datasource#">
    SELECT wpm.wedding_party_member_id, wpm.name, wpm.party_role, wpm.party_side,
           wpm.accepted, wpm.rsvp_note,
           ws.couple_name_1, ws.couple_name_2, ws.wedding_date, ws.slug, ws.template
    FROM dbo.WeddingPartyMembers wpm
    JOIN dbo.WeddingSites ws ON ws.user_id = wpm.user_id
    WHERE wpm.wedding_party_member_id = <cfqueryparam value="#url.id#" cfsqltype="cf_sql_bigint">
</cfquery>

<cfif !qMember.recordCount>
    <cflocation url="/" addToken="false">
</cfif>

<cfset justSubmitted = "">
<cfif form.action EQ "rsvp" AND len(trim(form.rsvp))>
    <cfquery datasource="#application.config.datasource#">
        UPDATE dbo.WeddingPartyMembers
        SET accepted   = <cfqueryparam value="#trim(form.rsvp)#" cfsqltype="cf_sql_varchar">,
            rsvp_note  = <cfqueryparam value="#trim(form.note)#" cfsqltype="cf_sql_nvarchar" null="#!len(trim(form.note))#">,
            updated_at = SYSUTCDATETIME()
        WHERE wedding_party_member_id = <cfqueryparam value="#url.id#" cfsqltype="cf_sql_bigint">
    </cfquery>
    <cfset justSubmitted = trim(form.rsvp)>
    <cfquery name="qMember" datasource="#application.config.datasource#">
        SELECT wpm.wedding_party_member_id, wpm.name, wpm.party_role, wpm.party_side,
               wpm.accepted, wpm.rsvp_note,
               ws.couple_name_1, ws.couple_name_2, ws.wedding_date, ws.slug, ws.template
        FROM dbo.WeddingPartyMembers wpm
        JOIN dbo.WeddingSites ws ON ws.user_id = wpm.user_id
        WHERE wpm.wedding_party_member_id = <cfqueryparam value="#url.id#" cfsqltype="cf_sql_bigint">
    </cfquery>
</cfif>

<!--- Load theme colors from the couple's template --->
<cfset qSiteForEmail = qMember>
<cfinclude template="members/email-theme-helper.cfm">

<!--- Format wedding date --->
<cfset weddingDateFormatted = "">
<cfif len(trim(qMember.wedding_date))>
    <cftry>
        <cfset weddingDateFormatted = dateFormat(qMember.wedding_date, "mmmm d, yyyy")>
    <cfcatch><cfset weddingDateFormatted = qMember.wedding_date></cfcatch>
    </cftry>
</cfif>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title><cfoutput>#HTMLEditFormat(qMember.couple_name_1)# &amp; #HTMLEditFormat(qMember.couple_name_2)# | Wedding Party</cfoutput></title>
<cfoutput>
<style>
*{margin:0;padding:0;box-sizing:border-box}
body{background:#emailTheme.bodyBg#;color:#emailTheme.bodyText#;font-family:#emailTheme.fontStack#;min-height:100vh;padding:40px 16px}
.card{background:#emailTheme.bodyCardBg#;border-radius:12px;max-width:560px;margin:0 auto;overflow:hidden;box-shadow:0 2px 24px rgba(0,0,0,.08)}
.card-header{background:#emailTheme.headerBg#;color:#emailTheme.headerText#;text-align:center;padding:36px 32px 28px}
.eyebrow{font-size:11px;letter-spacing:.2em;text-transform:uppercase;opacity:.7;margin-bottom:10px}
.couple-names{font-family:#emailTheme.headingFont#;font-size:clamp(1.6rem,5vw,2.2rem);font-weight:#emailTheme.headingWeight#;line-height:1.2;margin-bottom:8px}
.wedding-date{font-size:13px;opacity:.65;letter-spacing:.1em}
.card-body{padding:36px 32px}
.salutation{font-size:12px;letter-spacing:.18em;text-transform:uppercase;color:#emailTheme.accentColor#;margin-bottom:8px}
.role-heading{font-family:#emailTheme.headingFont#;font-size:1.5rem;font-weight:#emailTheme.headingWeight#;margin-bottom:8px}
.subtitle{color:#emailTheme.mutedText#;font-size:14px;margin-bottom:28px}
.divider{height:1px;background:#emailTheme.dividerColor#;margin:24px 0}
.confirm-box-yes{background:##f0fdf4;border:1.5px solid ##86efac;border-radius:10px;padding:24px;text-align:center;margin-bottom:8px}
.confirm-box-no{background:##fff7ed;border:1.5px solid ##fdba74;border-radius:10px;padding:24px;text-align:center;margin-bottom:8px}
.confirm-icon{font-size:36px;margin-bottom:8px}
.confirm-yes-title{font-weight:700;color:##059669;font-size:18px;margin-bottom:6px}
.confirm-no-title{font-weight:700;color:##d97706;font-size:18px;margin-bottom:6px}
.confirm-body{color:#emailTheme.mutedText#;font-size:14px}
.confirm-note{margin-top:14px;font-size:13px;color:#emailTheme.mutedText#;font-style:italic}
.field label{display:block;font-size:12px;letter-spacing:.12em;text-transform:uppercase;font-weight:600;margin-bottom:6px;color:#emailTheme.bodyText#}
.field textarea{width:100%;border:1.5px solid #emailTheme.dividerColor#;border-radius:6px;padding:10px 12px;font-family:#emailTheme.fontStack#;font-size:14px;resize:vertical;background:#emailTheme.bodyBg#;color:#emailTheme.bodyText#;outline:none}
.field textarea:focus{border-color:#emailTheme.accentColor#}
.btn-row{display:flex;gap:12px;justify-content:center;margin-top:20px;flex-wrap:wrap}
.btn-accept{background:#emailTheme.btnBg#;color:#emailTheme.btnText#;border:none;border-radius:#emailTheme.btnRadius#;padding:14px 32px;font-size:15px;font-family:#emailTheme.fontStack#;cursor:pointer;letter-spacing:.08em;text-transform:uppercase;font-weight:600}
.btn-accept:hover{opacity:.88}
.btn-decline{background:transparent;color:#emailTheme.bodyText#;border:1.5px solid #emailTheme.dividerColor#;border-radius:#emailTheme.btnRadius#;padding:14px 32px;font-size:15px;font-family:#emailTheme.fontStack#;cursor:pointer;letter-spacing:.08em;text-transform:uppercase}
.btn-decline:hover{border-color:#emailTheme.accentColor#;color:#emailTheme.accentColor#}
.view-site{text-align:center;margin-top:20px;font-size:13px}
.view-site a{color:#emailTheme.accentColor#;text-decoration:none}
.view-site a:hover{text-decoration:underline}
</style>
</cfoutput>
</head>
<body>
<cfoutput>
<div class="card">
    <div class="card-header">
        <p class="eyebrow">Wedding Party</p>
        <p class="couple-names">#HTMLEditFormat(qMember.couple_name_1)# &amp; #HTMLEditFormat(qMember.couple_name_2)#</p>
        <cfif len(weddingDateFormatted)>
        <p class="wedding-date">#weddingDateFormatted#</p>
        </cfif>
    </div>
    <div class="card-body">
        <p class="salutation">Dear #HTMLEditFormat(qMember.name)#,</p>
        <h1 class="role-heading">You've been asked to be a #HTMLEditFormat(qMember.party_role)#</h1>

        <cfif len(justSubmitted)>
            <!--- Just submitted - show confirmation only --->
            <cfif justSubmitted EQ "accepted">
            <div class="confirm-box-yes">
                <p class="confirm-icon">#emojiParty#</p>
                <p class="confirm-yes-title">You said YES!</p>
                <p class="confirm-body">#HTMLEditFormat(qMember.couple_name_1)# &amp; #HTMLEditFormat(qMember.couple_name_2)# are so excited to have you in their wedding party.</p>
                <cfif len(trim(qMember.rsvp_note))>
                <p class="confirm-note">&ldquo;#HTMLEditFormat(qMember.rsvp_note)#&rdquo;</p>
                </cfif>
            </div>
            <cfelse>
            <div class="confirm-box-no">
                <p class="confirm-icon">#emojiLetter#</p>
                <p class="confirm-no-title">You declined</p>
                <p class="confirm-body">We understand. Thank you for letting them know.</p>
                <cfif len(trim(qMember.rsvp_note))>
                <p class="confirm-note">&ldquo;#HTMLEditFormat(qMember.rsvp_note)#&rdquo;</p>
                </cfif>
            </div>
            </cfif>
        <cfelse>
            <!--- Not yet submitted (or previously responded) --->
            <p class="subtitle">Please let them know if you can make it.</p>

            <cfif qMember.accepted EQ "accepted" OR qMember.accepted EQ "declined">
                <cfif qMember.accepted EQ "accepted">
                <div class="confirm-box-yes" style="margin-bottom:20px">
                    <p class="confirm-icon">#emojiParty#</p>
                    <p class="confirm-yes-title">You said YES!</p>
                    <p class="confirm-body">#HTMLEditFormat(qMember.couple_name_1)# &amp; #HTMLEditFormat(qMember.couple_name_2)# are so excited to have you in their wedding party.</p>
                    <cfif len(trim(qMember.rsvp_note))>
                    <p class="confirm-note">&ldquo;#HTMLEditFormat(qMember.rsvp_note)#&rdquo;</p>
                    </cfif>
                </div>
                <cfelse>
                <div class="confirm-box-no" style="margin-bottom:20px">
                    <p class="confirm-icon">#emojiLetter#</p>
                    <p class="confirm-no-title">You declined</p>
                    <p class="confirm-body">We understand. Thank you for letting them know.</p>
                    <cfif len(trim(qMember.rsvp_note))>
                    <p class="confirm-note">&ldquo;#HTMLEditFormat(qMember.rsvp_note)#&rdquo;</p>
                    </cfif>
                </div>
                </cfif>
                <p style="text-align:center;font-size:13px;color:#emailTheme.mutedText#;margin-bottom:20px">Changed your mind? You can update your response below.</p>
            </cfif>

            <div class="divider"></div>
            <form method="post" action="/wedding-party-rsvp.cfm?id=#url.id#">
                <input type="hidden" name="action" value="rsvp">
                <div class="field" style="margin-bottom:20px">
                    <label>Leave a note (optional)</label>
                    <textarea name="note" rows="3" placeholder="I'm so honored! Can't wait...">#HTMLEditFormat(form.note)#</textarea>
                </div>
                <div class="btn-row">
                    <button type="submit" name="rsvp" value="accepted" class="btn-accept">Accept</button>
                    <button type="submit" name="rsvp" value="declined" class="btn-decline">Decline</button>
                </div>
            </form>
        </cfif>
    </div>
</div>
<div class="view-site">
    <a href="https://digitalweddings.love/site.cfm?slug=#URLEncodedFormat(qMember.slug)#">View the wedding website &rarr;</a>
</div>
</cfoutput>
</body>
</html>
