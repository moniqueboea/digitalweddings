<cfinclude template="../includes/auth-check.cfm">
<cfset pageTitle = "Thank You Cards | digitalweddings.love">
<cfset activePage = "thank-you">
<cfset userId = session.user.id>
<cfparam name="form.action"    default="">
<cfparam name="form.cardId"    default="0">
<cfparam name="form.template"  default="classic">
<cfparam name="url.preview"  default="">
<cfparam name="url.sent"     default="">
<cfparam name="url.error"    default="">

<!--- ── Send test preview to self ── --->
<cfif form.action EQ "send_test" AND isNumeric(form.cardId) AND form.cardId GT 0>
    <cfset testRedirect = "thank-you-cards.cfm?error=testfail">
    <cftry>
        <cfquery name="qCard" datasource="#application.config.datasource#">
            SELECT recipient_name, custom_message FROM dbo.ThankYouCards
            WHERE thank_you_card_id = <cfqueryparam value="#form.cardId#" cfsqltype="cf_sql_bigint">
              AND user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
        </cfquery>
        <cfquery name="qSiteForEmail" datasource="#application.config.datasource#">
            SELECT couple_name_1, couple_name_2, wedding_date, slug, template, hero_image_url, couple_photo_url
            FROM dbo.WeddingSites
            WHERE user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
            ORDER BY created_at DESC
        </cfquery>
        <cfif qCard.recordCount AND qSiteForEmail.recordCount>
            <cfinclude template="email-theme-helper.cfm">
            <cfset emailSiteLink   = "https://digitalweddings.love/site.cfm?slug=" & URLEncodedFormat(qSiteForEmail.slug)>
            <cfset tyRecipientName = trim(qCard.recipient_name)>
            <cfset tyMessage       = trim(qCard.custom_message)>
            <cfmail to="#session.user.email#"
                    from="#application.config.mailFrom#"
                    replyto="#session.user.email#"
                    subject="[TEST] Thank You Card Preview"
                    server="localhost"
                    port="25"
                    timeout="60"
                    type="html"><cfinclude template="email-thank-you-body.cfm"></cfmail>
            <cfset testRedirect = "thank-you-cards.cfm?preview=1">
        </cfif>
    <cfcatch>
        <cftry><cfset notifier = new services.ErrorNotifier()><cfset notifier.notify(cfcatch, "Thank You Card test send", CGI.SCRIPT_NAME)><cfcatch></cfcatch></cftry>
        <cfset testRedirect = "thank-you-cards.cfm?error=testfail">
    </cfcatch>
    </cftry>
    <cflocation url="#testRedirect#" addToken="false">
</cfif>

<cfif form.action EQ "add_card">
    <cfif len(trim(form.recipientName)) && isValid("email", trim(form.recipientEmail))>
        <cfquery datasource="#application.config.datasource#">
            INSERT INTO dbo.ThankYouCards (user_id, recipient_name, recipient_email, template, custom_message, status)
            VALUES (
                <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">,
                <cfqueryparam value="#trim(form.recipientName)#" cfsqltype="cf_sql_nvarchar">,
                <cfqueryparam value="#lCase(trim(form.recipientEmail))#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="classic" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#trim(form.customMessage)#" cfsqltype="cf_sql_nvarchar" null="#!len(trim(form.customMessage))#">,
                'draft'
            )
        </cfquery>
    </cfif>
    <cflocation url="thank-you-cards.cfm" addToken="false">
</cfif>

<!--- ── Send card to recipient ── --->
<cfif form.action EQ "send_card" AND isNumeric(form.cardId) AND form.cardId GT 0>
    <cfset sendRedirect = "thank-you-cards.cfm?error=sendfail">
    <cftry>
        <cfquery name="qCard" datasource="#application.config.datasource#">
            SELECT recipient_name, recipient_email, custom_message FROM dbo.ThankYouCards
            WHERE thank_you_card_id = <cfqueryparam value="#form.cardId#" cfsqltype="cf_sql_bigint">
              AND user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
        </cfquery>
        <cfquery name="qSiteForEmail" datasource="#application.config.datasource#">
            SELECT couple_name_1, couple_name_2, wedding_date, slug, template, hero_image_url, couple_photo_url
            FROM dbo.WeddingSites
            WHERE user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
            ORDER BY created_at DESC
        </cfquery>
        <cfquery name="qUser" datasource="#application.config.datasource#">
            SELECT email FROM dbo.Users WHERE user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
        </cfquery>
        <cfif qCard.recordCount AND qSiteForEmail.recordCount>
            <cfinclude template="email-theme-helper.cfm">
            <cfset emailSiteLink   = "https://digitalweddings.love/site.cfm?slug=" & URLEncodedFormat(qSiteForEmail.slug)>
            <cfset tyRecipientName = trim(qCard.recipient_name)>
            <cfset tyMessage       = trim(qCard.custom_message)>
            <cfmail to="#trim(qCard.recipient_email)#"
                    from="#application.config.mailFrom#"
                    replyto="#trim(qUser.email)#"
                    bcc="#trim(qUser.email)#"
                    subject="A Thank You from #HTMLEditFormat(qSiteForEmail.couple_name_1)# and #HTMLEditFormat(qSiteForEmail.couple_name_2)#"
                    server="localhost"
                    port="25"
                    timeout="60"
                    type="html"><cfinclude template="email-thank-you-body.cfm"></cfmail>
            <cfquery datasource="#application.config.datasource#">
                UPDATE dbo.ThankYouCards SET status = 'sent', sent_date = CAST(SYSUTCDATETIME() AS DATE), updated_at = SYSUTCDATETIME()
                WHERE thank_you_card_id = <cfqueryparam value="#form.cardId#" cfsqltype="cf_sql_bigint"> AND user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
            </cfquery>
            <cfset sendRedirect = "thank-you-cards.cfm?sent=1">
        </cfif>
    <cfcatch>
        <cftry><cfset notifier = new services.ErrorNotifier()><cfset notifier.notify(cfcatch, "Thank You Card send", CGI.SCRIPT_NAME)><cfcatch></cfcatch></cftry>
        <cfset sendRedirect = "thank-you-cards.cfm?error=sendfail">
    </cfcatch>
    </cftry>
    <cflocation url="#sendRedirect#" addToken="false">
</cfif>

<cfif form.action EQ "mark_sent" && isNumeric(form.cardId)>
    <cfquery datasource="#application.config.datasource#">
        UPDATE dbo.ThankYouCards SET status = 'sent', sent_date = CAST(SYSUTCDATETIME() AS DATE), updated_at = SYSUTCDATETIME()
        WHERE thank_you_card_id = <cfqueryparam value="#form.cardId#" cfsqltype="cf_sql_bigint"> AND user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
    </cfquery>
    <cflocation url="thank-you-cards.cfm" addToken="false">
</cfif>

<cfif form.action EQ "delete_card" && isNumeric(form.cardId)>
    <cfquery datasource="#application.config.datasource#">
        DELETE FROM dbo.ThankYouCards WHERE thank_you_card_id = <cfqueryparam value="#form.cardId#" cfsqltype="cf_sql_bigint"> AND user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
    </cfquery>
    <cflocation url="thank-you-cards.cfm" addToken="false">
</cfif>

<cfquery name="cards" datasource="#application.config.datasource#">
    SELECT thank_you_card_id, recipient_name, recipient_email, template, custom_message, status, sent_date
    FROM dbo.ThankYouCards WHERE user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
    ORDER BY status, recipient_name
</cfquery>

<cfset sentCount = 0><cfset draftCount = 0>
<cfloop query="cards"><cfif status EQ "sent"><cfset sentCount++><cfelse><cfset draftCount++></cfif></cfloop>

<cfinclude template="../includes/layout-start.cfm">
<section style="padding:60px 0">
<div class="container">
    <div class="page-header">
        <p class="eyebrow">Show Your Gratitude</p>
        <h1>Thank You <span class="script">Cards</span></h1>
    </div>

    <cfif url.preview EQ "1">
    <div class="alert alert-success" style="margin-bottom:24px">
        Test card sent to <cfoutput>#HTMLEditFormat(session.user.email)#</cfoutput> &mdash; check your inbox!
    </div>
    </cfif>
    <cfif url.sent EQ "1">
    <div class="alert alert-success" style="margin-bottom:24px">
        Thank you card sent! You&rsquo;ve been BCC&rsquo;d on a copy.
    </div>
    </cfif>
    <cfparam name="url.msg" default="">
    <cfif url.error EQ "testfail">
    <div class="alert alert-error" style="margin-bottom:24px">We&rsquo;re sorry, the test email could not be sent. Please try again or contact us if the issue continues.</div>
    </cfif>
    <cfif url.error EQ "sendfail">
    <div class="alert alert-error" style="margin-bottom:24px">We&rsquo;re sorry, the thank you card could not be sent. Please try again or contact us if the issue continues.</div>
    </cfif>

    <div class="stats-row" style="margin-bottom:32px">
        <div class="stat-card"><div class="stat-num"><cfoutput>#cards.recordCount#</cfoutput></div><div class="stat-label">Total Cards</div></div>
        <div class="stat-card"><div class="stat-num" style="color:##059669"><cfoutput>#sentCount#</cfoutput></div><div class="stat-label">Sent</div></div>
        <div class="stat-card"><div class="stat-num" style="color:##d97706"><cfoutput>#draftCount#</cfoutput></div><div class="stat-label">Drafts</div></div>
        <div class="stat-card"><div class="stat-num"><cfoutput>#cards.recordCount GT 0 ? numberFormat(sentCount/cards.recordCount*100,'0') : 0#%</cfoutput></div><div class="stat-label">Complete</div></div>
    </div>

    <div style="background:#F0F7FF;border:1px solid #C8DDF5;border-radius:10px;padding:20px 24px;margin-bottom:24px">
        <p style="font-weight:700;margin:0 0 12px;color:#1a1a1a">How it works</p>
        <div style="display:flex;flex-direction:column;gap:8px;font-size:14px;color:#444;line-height:1.6">
            <div><strong>1. Add</strong> &mdash; Enter a recipient&rsquo;s name, email, and personal message, then click Add. They&rsquo;re saved as a Draft.</div>
            <div><strong>2. Test</strong> &mdash; Sends a preview of the card email to <em>you</em> so you can see how it looks before it goes to the guest.</div>
            <div><strong>3. Send</strong> &mdash; Emails the thank you card to the recipient, BCCs you on a copy, and marks it Sent automatically.</div>
        </div>
    </div>

    <div class="panel" style="margin-bottom:24px">
        <p class="panel-title">Add a Thank You Card</p>
        <form method="post" action="/members/thank-you-cards.cfm">
            <input type="hidden" name="action" value="add_card">
            <div style="display:grid;grid-template-columns:2fr 2fr auto;gap:12px;align-items:end">
                <div class="field" style="margin-bottom:0">
                    <label>Recipient Name</label>
                    <input type="text" name="recipientName" required placeholder="e.g. Aunt Gloria">
                </div>
                <div class="field" style="margin-bottom:0">
                    <label>Email Address</label>
                    <input type="email" name="recipientEmail" required placeholder="gloria@email.com">
                </div>
                <button type="submit" class="btn btn-primary">Add</button>
            </div>
            <div class="field" style="margin-top:12px">
                <label>Personal Message</label>
                <textarea name="customMessage" rows="2" placeholder="Thank you so much for your generous gift and for celebrating with us!"></textarea>
            </div>
        </form>
    </div>

    <cfif cards.recordCount>
    <div class="panel" style="padding:0">
        <div class="table-wrap">
            <table>
                <thead><tr><th>Recipient</th><th>Email</th><th>Status</th><th>Sent Date</th><th></th></tr></thead>
                <tbody>
                    <cfoutput query="cards">
                    <tr>
                        <td><strong>#HTMLEditFormat(recipient_name)#</strong></td>
                        <td>#HTMLEditFormat(recipient_email)#</td>
                        <td><cfif status EQ "sent"><span class="badge badge-green">Sent</span><cfelse><span class="badge badge-amber">Draft</span></cfif></td>
                        <td><cfif len(sent_date)>#dateFormat(sent_date,'mmm d, yyyy')#</cfif></td>
                        <td style="display:flex;gap:6px;flex-wrap:wrap">
                            <form method="post" action="/members/thank-you-cards.cfm" style="display:inline">
                                <input type="hidden" name="action" value="send_test">
                                <input type="hidden" name="cardId" value="#thank_you_card_id#">
                                <button type="submit" class="btn btn-ghost btn-sm" title="Send a test to yourself">Test</button>
                            </form>
                            <cfif status NEQ "sent">
                            <form method="post" action="/members/thank-you-cards.cfm" style="display:inline">
                                <input type="hidden" name="action" value="send_card">
                                <input type="hidden" name="cardId" value="#thank_you_card_id#">
                                <button type="submit" class="btn btn-primary btn-sm" data-name="#HTMLEditFormat(recipient_name)#" onclick="return confirm('Send this thank you card to ' + this.dataset.name + '?')">Send</button>
                            </form>
                            </cfif>
                            <form method="post" action="/members/thank-you-cards.cfm" style="display:inline">
                                <input type="hidden" name="action" value="delete_card">
                                <input type="hidden" name="cardId" value="#thank_you_card_id#">
                                <button type="submit" class="btn btn-danger btn-sm" onclick="return confirm('Delete this card?')">&times;</button>
                            </form>
                        </td>
                    </tr>
                    </cfoutput>
                </tbody>
            </table>
        </div>
    </div>
    <cfelse>
        <div class="empty-state">
            <div style="font-size:48px;margin-bottom:16px">&#128140;</div>
            <p>No thank you cards yet. Add recipients above to get started.</p>
        </div>
    </cfif>
</div>
</section>
<cfinclude template="../includes/layout-end.cfm">
