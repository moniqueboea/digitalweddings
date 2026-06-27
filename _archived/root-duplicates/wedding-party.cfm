<cfinclude template="includes/auth-check.cfm">
<cfset pageTitle = "Wedding Party | digitalweddings.love">
<cfset activePage = "wedding-party">
<cfset userId = session.user.id>
<cfparam name="form.action" default="">

<cfif form.action EQ "add_member">
    <cfif len(trim(form.name)) && len(trim(form.partyRole))>
        <cfquery datasource="#application.config.datasource#">
            INSERT INTO dbo.WeddingPartyMembers (user_id, name, email, party_role, party_side, notes)
            VALUES (
                <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">,
                <cfqueryparam value="#trim(form.name)#" cfsqltype="cf_sql_nvarchar">,
                <cfqueryparam value="#lCase(trim(form.email))#" cfsqltype="cf_sql_varchar" null="#!len(trim(form.email))#">,
                <cfqueryparam value="#trim(form.partyRole)#" cfsqltype="cf_sql_nvarchar">,
                <cfqueryparam value="#trim(form.partySide)#" cfsqltype="cf_sql_nvarchar" null="#!len(trim(form.partySide))#">,
                <cfqueryparam value="#trim(form.notes)#" cfsqltype="cf_sql_nvarchar" null="#!len(trim(form.notes))#">
            )
        </cfquery>
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

<cfquery name="members" datasource="#application.config.datasource#">
    SELECT wedding_party_member_id, name, email, party_role, party_side, accepted, notes
    FROM dbo.WeddingPartyMembers WHERE user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
    ORDER BY party_side, party_role, name
</cfquery>

<cfset roles = ["Maid of Honor","Best Man","Bridesmaid","Groomsman","Flower Girl","Ring Bearer","Junior Bridesmaid","Usher","Officiant","Other"]>
<cfset sides = ["Bride's Side","Groom's Side","Both Sides"]>

<cfinclude template="includes/layout-start.cfm">
<section style="padding:60px 0">
<div class="container">
    <div class="page-header">
        <p class="eyebrow">Your Crew</p>
        <h1>Wedding <span class="script">Party</span></h1>
    </div>

    <div class="panel" style="margin-bottom:24px">
        <p class="panel-title">Add a Member</p>
        <form method="post" action="wedding-party.cfm">
            <input type="hidden" name="action" value="add_member">
            <div style="display:grid;grid-template-columns:2fr 2fr 1fr 1fr auto;gap:12px;align-items:end">
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
    <div class="panel" style="padding:0">
        <div class="table-wrap">
            <table>
                <thead><tr><th>Name</th><th>Role</th><th>Side</th><th>Email</th><th>Status</th><th></th></tr></thead>
                <tbody>
                    <cfoutput query="members">
                    <tr>
                        <td><strong>#HTMLEditFormat(name)#</strong></td>
                        <td><span class="badge badge-gold">#HTMLEditFormat(party_role)#</span></td>
                        <td>#HTMLEditFormat(party_side)#</td>
                        <td><cfif len(email)><a href="mailto:#HTMLEditFormat(email)#">#HTMLEditFormat(email)#</a></cfif></td>
                        <td>
                            <form method="post" action="wedding-party.cfm" style="display:inline">
                                <input type="hidden" name="action" value="update_status">
                                <input type="hidden" name="memberId" value="#wedding_party_member_id#">
                                <select name="accepted" onchange="this.form.submit()" style="font-size:12px;padding:4px 8px;border-radius:20px;border:1.5px solid var(--border)">
                                    <option value="pending" <cfif accepted EQ "pending">selected</cfif>>Pending</option>
                                    <option value="accepted" <cfif accepted EQ "accepted">selected</cfif>>Accepted</option>
                                    <option value="declined" <cfif accepted EQ "declined">selected</cfif>>Declined</option>
                                </select>
                            </form>
                        </td>
                        <td>
                            <form method="post" action="wedding-party.cfm" style="display:inline">
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
    <cfelse>
        <div class="empty-state">
            <div style="font-size:48px;margin-bottom:16px">&#128145;</div>
            <p>No wedding party members yet. Add your first member above!</p>
        </div>
    </cfif>
</div>
</section>
<cfinclude template="includes/layout-end.cfm">
