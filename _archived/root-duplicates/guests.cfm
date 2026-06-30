<cfinclude template="includes/auth-check.cfm">
<cfset pageTitle = "Guests & RSVP | digitalweddings.love">
<cfset activePage = "guests">
<cfset userId = session.user.id>

<cfparam name="form.action" default="">

<cfif form.action EQ "add_guest">
    <cfif len(trim(form.name))>
        <cfquery datasource="#application.config.datasource#">
            INSERT INTO dbo.Guests (user_id, name, email, phone, guest_group, rsvp_status, plus_one, plus_one_name, dietary_restrictions, notes)
            VALUES (
                <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">,
                <cfqueryparam value="#trim(form.name)#" cfsqltype="cf_sql_nvarchar">,
                <cfqueryparam value="#lCase(trim(form.email))#" cfsqltype="cf_sql_varchar" null="#!len(trim(form.email))#">,
                <cfqueryparam value="#trim(form.phone)#" cfsqltype="cf_sql_varchar" null="#!len(trim(form.phone))#">,
                <cfqueryparam value="#trim(form.guestGroup)#" cfsqltype="cf_sql_nvarchar" null="#!len(trim(form.guestGroup))#">,
                <cfqueryparam value="#len(trim(form.rsvpStatus)) ? trim(form.rsvpStatus) : 'pending'#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#(structKeyExists(form,'plusOne') && form.plusOne EQ 'on') ? 1 : 0#" cfsqltype="cf_sql_bit">,
                <cfqueryparam value="#trim(form.plusOneName)#" cfsqltype="cf_sql_nvarchar" null="#!len(trim(form.plusOneName))#">,
                <cfqueryparam value="#trim(form.dietaryRestrictions)#" cfsqltype="cf_sql_nvarchar" null="#!len(trim(form.dietaryRestrictions))#">,
                <cfqueryparam value="#trim(form.notes)#" cfsqltype="cf_sql_nvarchar" null="#!len(trim(form.notes))#">
            )
        </cfquery>
    </cfif>
    <cflocation url="guests.cfm" addToken="false">
</cfif>

<cfif form.action EQ "update_rsvp" && isNumeric(form.guestId)>
    <cfquery datasource="#application.config.datasource#">
        UPDATE dbo.Guests SET rsvp_status = <cfqueryparam value="#trim(form.rsvpStatus)#" cfsqltype="cf_sql_varchar">, updated_at = SYSUTCDATETIME()
        WHERE guest_id = <cfqueryparam value="#form.guestId#" cfsqltype="cf_sql_bigint"> AND user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
    </cfquery>
    <cflocation url="guests.cfm" addToken="false">
</cfif>

<cfif form.action EQ "delete_guest" && isNumeric(form.guestId)>
    <cfquery datasource="#application.config.datasource#">
        DELETE FROM dbo.Guests WHERE guest_id = <cfqueryparam value="#form.guestId#" cfsqltype="cf_sql_bigint"> AND user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
    </cfquery>
    <cflocation url="guests.cfm" addToken="false">
</cfif>

<cfquery name="guests" datasource="#application.config.datasource#">
    SELECT guest_id, name, email, phone, guest_group, rsvp_status, plus_one, plus_one_name, dietary_restrictions, table_number, notes
    FROM dbo.Guests WHERE user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
    ORDER BY name
</cfquery>

<cfset attending = 0><cfset declined = 0><cfset pending = 0><cfset maybe = 0>
<cfloop query="guests">
    <cfif rsvp_status EQ "attending"><cfset attending++>
    <cfelseif rsvp_status EQ "declined"><cfset declined++>
    <cfelseif rsvp_status EQ "maybe"><cfset maybe++>
    <cfelse><cfset pending++>
    </cfif>
</cfloop>

<cfset groups = ["Bride's Family","Groom's Family","Bride's Friends","Groom's Friends","Mutual Friends","Colleagues","Other"]>

<cfinclude template="includes/layout-start.cfm">
<section style="padding:60px 0">
<div class="container">
    <div class="page-header">
        <p class="eyebrow">Manage Your Day</p>
        <h1>Guests &amp; <span class="script">RSVP</span></h1>
    </div>

    <div class="stats-row" style="margin-bottom:36px">
        <div class="stat-card"><i data-lucide="users" style="width:20px;height:20px;color:var(--gold);margin-bottom:8px"></i><div class="stat-num"><cfoutput>#guests.recordCount#</cfoutput></div><div class="stat-label">Total Guests</div></div>
        <div class="stat-card"><i data-lucide="user-check" style="width:20px;height:20px;color:#059669;margin-bottom:8px"></i><div class="stat-num" style="color:#059669"><cfoutput>#attending#</cfoutput></div><div class="stat-label">Attending</div></div>
        <div class="stat-card"><i data-lucide="user-x" style="width:20px;height:20px;color:#dc2626;margin-bottom:8px"></i><div class="stat-num" style="color:#dc2626"><cfoutput>#declined#</cfoutput></div><div class="stat-label">Declined</div></div>
        <div class="stat-card"><i data-lucide="clock" style="width:20px;height:20px;color:#d97706;margin-bottom:8px"></i><div class="stat-num" style="color:#d97706"><cfoutput>#pending#</cfoutput></div><div class="stat-label">Pending</div></div>
    </div>

    <!--- Add Guest Form --->
    <div class="panel" style="margin-bottom:24px">
        <p class="panel-title">Add a Guest</p>
        <form method="post" action="guests.cfm">
            <input type="hidden" name="action" value="add_guest">
            <div style="display:grid;grid-template-columns:2fr 2fr 1fr 1fr 1fr auto;gap:12px;align-items:end;flex-wrap:wrap">
                <div class="field" style="margin-bottom:0">
                    <label>Full Name *</label>
                    <input type="text" name="name" required placeholder="e.g. Aisha Johnson">
                </div>
                <div class="field" style="margin-bottom:0">
                    <label>Email</label>
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
        </form>
    </div>

    <!--- Guest List --->
    <cfif guests.recordCount>
    <div class="panel" style="padding:0">
        <div class="table-wrap">
            <table>
                <thead>
                    <tr><th>Name</th><th>Email</th><th>Group</th><th>Dietary</th><th>RSVP Status</th><th>Table</th><th></th></tr>
                </thead>
                <tbody>
                    <cfoutput query="guests">
                    <tr>
                        <td>
                            <strong>#HTMLEditFormat(name)#</strong>
                            <cfif plus_one><span class="badge badge-blue" style="margin-left:6px">+1<cfif len(plus_one_name)>: #HTMLEditFormat(plus_one_name)#</cfif></span></cfif>
                        </td>
                        <td><cfif len(email)><a href="mailto:#HTMLEditFormat(email)#">#HTMLEditFormat(email)#</a></cfif></td>
                        <td>#HTMLEditFormat(guest_group)#</td>
                        <td>#HTMLEditFormat(dietary_restrictions)#</td>
                        <td>
                            <form method="post" action="guests.cfm" style="display:inline">
                                <input type="hidden" name="action" value="update_rsvp">
                                <input type="hidden" name="guestId" value="#guest_id#">
                                <select name="rsvpStatus" onchange="this.form.submit()" style="font-size:12px;padding:4px 8px;border-radius:20px;border:1.5px solid var(--border)">
                                    <option value="pending" <cfif rsvp_status EQ "pending">selected</cfif>>Pending</option>
                                    <option value="attending" <cfif rsvp_status EQ "attending">selected</cfif>>Attending</option>
                                    <option value="declined" <cfif rsvp_status EQ "declined">selected</cfif>>Declined</option>
                                    <option value="maybe" <cfif rsvp_status EQ "maybe">selected</cfif>>Maybe</option>
                                </select>
                            </form>
                        </td>
                        <td><cfif table_number>Table #table_number#</cfif></td>
                        <td>
                            <form method="post" action="guests.cfm" style="display:inline">
                                <input type="hidden" name="action" value="delete_guest">
                                <input type="hidden" name="guestId" value="#guest_id#">
                                <button type="submit" class="btn btn-danger btn-sm" onclick="return confirm('Remove this guest?')">&times;</button>
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
            <div style="font-size:48px;margin-bottom:16px">&##128101;</div>
            <p>No guests yet. Start building your guest list above!</p>
        </div>
    </cfif>
</div>
</section>
<cfinclude template="includes/layout-end.cfm">
