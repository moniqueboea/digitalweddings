<cfinclude template="includes/auth-check.cfm">
<cfset pageTitle = "Thank You Cards | digitalweddings.love">
<cfset activePage = "thank-you">
<cfset userId = session.user.id>
<cfparam name="form.action" default="">

<cfif form.action EQ "add_card">
    <cfif len(trim(form.recipientName)) && isValid("email", trim(form.recipientEmail))>
        <cfquery datasource="#application.config.datasource#">
            INSERT INTO dbo.ThankYouCards (user_id, recipient_name, recipient_email, template, custom_message, status)
            VALUES (
                <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">,
                <cfqueryparam value="#trim(form.recipientName)#" cfsqltype="cf_sql_nvarchar">,
                <cfqueryparam value="#lCase(trim(form.recipientEmail))#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#len(trim(form.template)) ? trim(form.template) : 'classic'#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#trim(form.customMessage)#" cfsqltype="cf_sql_nvarchar" null="#!len(trim(form.customMessage))#">,
                'draft'
            )
        </cfquery>
    </cfif>
    <cflocation url="thank-you-cards.cfm" addToken="false">
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

<cfinclude template="includes/layout-start.cfm">
<section style="padding:60px 0">
<div class="container">
    <div class="page-header">
        <p class="eyebrow">Show Your Gratitude</p>
        <h1>Thank You <span class="script">Cards</span></h1>
    </div>

    <div class="stats-row" style="margin-bottom:32px">
        <div class="stat-card"><div class="stat-num"><cfoutput>#cards.recordCount#</cfoutput></div><div class="stat-label">Total Cards</div></div>
        <div class="stat-card"><div class="stat-num" style="color:#059669"><cfoutput>#sentCount#</cfoutput></div><div class="stat-label">Sent</div></div>
        <div class="stat-card"><div class="stat-num" style="color:#d97706"><cfoutput>#draftCount#</cfoutput></div><div class="stat-label">Drafts</div></div>
        <div class="stat-card"><div class="stat-num"><cfoutput>#cards.recordCount GT 0 ? numberFormat(sentCount/cards.recordCount*100,'0') : 0#%</cfoutput></div><div class="stat-label">Complete</div></div>
    </div>

    <div class="panel" style="margin-bottom:24px">
        <p class="panel-title">Add a Thank You Card</p>
        <form method="post" action="thank-you-cards.cfm">
            <input type="hidden" name="action" value="add_card">
            <div style="display:grid;grid-template-columns:2fr 2fr 1fr auto;gap:12px;align-items:end">
                <div class="field" style="margin-bottom:0">
                    <label>Recipient Name</label>
                    <input type="text" name="recipientName" required placeholder="e.g. Aunt Gloria">
                </div>
                <div class="field" style="margin-bottom:0">
                    <label>Email Address</label>
                    <input type="email" name="recipientEmail" required placeholder="gloria@email.com">
                </div>
                <div class="field" style="margin-bottom:0">
                    <label>Template</label>
                    <select name="template">
                        <option value="classic">Classic</option>
                        <option value="elegant">Elegant</option>
                        <option value="floral">Floral</option>
                        <option value="modern">Modern</option>
                    </select>
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
                <thead><tr><th>Recipient</th><th>Email</th><th>Template</th><th>Status</th><th>Sent Date</th><th></th></tr></thead>
                <tbody>
                    <cfoutput query="cards">
                    <tr>
                        <td><strong>#HTMLEditFormat(recipient_name)#</strong></td>
                        <td>#HTMLEditFormat(recipient_email)#</td>
                        <td><span class="badge badge-gray">#HTMLEditFormat(template)#</span></td>
                        <td><cfif status EQ "sent"><span class="badge badge-green">Sent</span><cfelse><span class="badge badge-amber">Draft</span></cfif></td>
                        <td><cfif len(sent_date)>#dateFormat(sent_date,'mmm d, yyyy')#</cfif></td>
                        <td style="display:flex;gap:6px;flex-wrap:wrap">
                            <cfif status NEQ "sent">
                            <form method="post" action="thank-you-cards.cfm" style="display:inline">
                                <input type="hidden" name="action" value="mark_sent">
                                <input type="hidden" name="cardId" value="#thank_you_card_id#">
                                <button type="submit" class="btn btn-primary btn-sm">Mark Sent</button>
                            </form>
                            </cfif>
                            <form method="post" action="thank-you-cards.cfm" style="display:inline">
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
<cfinclude template="includes/layout-end.cfm">
