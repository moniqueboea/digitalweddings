<cfinclude template="../includes/auth-check.cfm">
<cfset pageTitle = "Seating Chart | digitalweddings.love">
<cfset activePage = "seating">
<cfset userId = session.user.id>

<cfparam name="form.action" default="">

<!--- Count confirmed RSVPs - seating requires at least one RSVP --->
<cfquery name="rsvpCount" datasource="#application.config.datasource#">
    SELECT COUNT(*) AS total FROM dbo.Guests
    WHERE user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
      AND rsvp_status IS NOT NULL
      AND rsvp_status <> ''
      AND rsvp_status <> 'pending'
</cfquery>
<cfset hasRsvps = (rsvpCount.total GT 0)>

<!--- Block table/seat actions if no RSVPs --->
<cfif form.action EQ "add_table" && hasRsvps>
    <cfif len(trim(form.tableLabel))>
        <cfquery name="qMaxTable" datasource="#application.config.datasource#">
            SELECT ISNULL(MAX(table_number), 0) + 1 AS nextNum FROM dbo.ReceptionTables
            WHERE user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
        </cfquery>
        <cfquery datasource="#application.config.datasource#">
            INSERT INTO dbo.ReceptionTables (user_id, table_number, table_name, capacity)
            VALUES (
                <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">,
                <cfqueryparam value="#qMaxTable.nextNum#" cfsqltype="cf_sql_integer">,
                <cfqueryparam value="#trim(form.tableLabel)#" cfsqltype="cf_sql_nvarchar">,
                <cfqueryparam value="#isNumeric(form.capacity) ? val(form.capacity) : 8#" cfsqltype="cf_sql_integer">
            )
        </cfquery>
    </cfif>
    <cflocation url="seating-chart.cfm" addToken="false">
</cfif>

<cfif form.action EQ "assign_table" && hasRsvps && isNumeric(form.guestId) && isNumeric(form.tableNum)>
    <cfquery datasource="#application.config.datasource#">
        UPDATE dbo.Guests SET table_number = <cfqueryparam value="#val(form.tableNum)#" cfsqltype="cf_sql_integer" null="#val(form.tableNum) EQ 0#">, updated_at = SYSUTCDATETIME()
        WHERE guest_id = <cfqueryparam value="#form.guestId#" cfsqltype="cf_sql_bigint"> AND user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
    </cfquery>
    <cflocation url="seating-chart.cfm" addToken="false">
</cfif>

<cfif form.action EQ "rename_table" && isNumeric(form.tableId) && len(trim(form.newTableName))>
    <cfquery datasource="#application.config.datasource#">
        UPDATE dbo.ReceptionTables
        SET table_name = <cfqueryparam value="#trim(form.newTableName)#" cfsqltype="cf_sql_nvarchar">
        WHERE reception_table_id = <cfqueryparam value="#val(form.tableId)#" cfsqltype="cf_sql_bigint">
          AND user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
    </cfquery>
    <cflocation url="seating-chart.cfm" addToken="false">
</cfif>

<cfif form.action EQ "delete_table" && isNumeric(form.tableId)>
    <cfquery datasource="#application.config.datasource#">
        UPDATE dbo.Guests SET table_number = NULL WHERE table_number = (SELECT table_number FROM dbo.ReceptionTables WHERE reception_table_id = <cfqueryparam value="#form.tableId#" cfsqltype="cf_sql_bigint"> AND user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">) AND user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
    </cfquery>
    <cfquery datasource="#application.config.datasource#">
        DELETE FROM dbo.ReceptionTables WHERE reception_table_id = <cfqueryparam value="#form.tableId#" cfsqltype="cf_sql_bigint"> AND user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
    </cfquery>
    <cflocation url="seating-chart.cfm" addToken="false">
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
        <cflocation url="seating-chart.cfm?error=selfsendfail" addToken="false">
    </cfif>
    <cfquery name="qTablesForSelf" datasource="#application.config.datasource#">
        SELECT t.reception_table_id, t.table_number, t.table_name, t.capacity,
               g.name AS guest_name, g.plus_one, g.plus_one_name
        FROM dbo.ReceptionTables t
        LEFT JOIN dbo.Guests g ON g.user_id = t.user_id AND g.table_number = t.table_number
        WHERE t.user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
        ORDER BY t.table_number, g.name
    </cfquery>
    <cfset coordSite    = qSelfSite>
    <cfset coordSection = "Seating Chart">
    <cfset coordSentAt  = dateTimeFormat(now(), "mmmm d, yyyy h:mm tt")>
    <cfset coordSiteUrl = len(trim(qSelfSite.slug)) ? "https://digitalweddings.love/site.cfm?slug=#URLEncodedFormat(trim(qSelfSite.slug))#" : "">
    <cfsavecontent variable="coordBodyHtml">
        <cfoutput>
        <cfif qTablesForSelf.recordCount>
            <cfset lastTable = 0>
            <cfloop query="qTablesForSelf">
                <cfif reception_table_id NEQ lastTable>
                    <cfif lastTable NEQ 0></table><br></cfif>
                    <p style="margin:0 0 6px 0;font-size:13px;font-weight:700;color:##2c3e2e;font-family:Arial,sans-serif">Table #table_number# - #HTMLEditFormat(table_name)# (capacity: #capacity#)</p>
                    <table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0" style="border-collapse:collapse">
                    <tr style="background:##e8f0e9">
                        <th style="padding:6px 10px;text-align:left;font-size:12px;color:##3a5e3e;font-family:Arial,sans-serif;border-bottom:1px solid ##b2cbb5">Guest</th>
                        <th style="padding:6px 10px;text-align:left;font-size:12px;color:##3a5e3e;font-family:Arial,sans-serif;border-bottom:1px solid ##b2cbb5">Plus One</th>
                    </tr>
                    <cfset lastTable = reception_table_id>
                </cfif>
                <cfif len(trim(guest_name))>
                <tr>
                    <td style="padding:6px 10px;font-size:13px;color:##333;font-family:Arial,sans-serif;border-bottom:1px solid ##eee">#HTMLEditFormat(guest_name)#</td>
                    <td style="padding:6px 10px;font-size:13px;color:##333;font-family:Arial,sans-serif;border-bottom:1px solid ##eee"><cfif plus_one>Yes<cfif len(trim(plus_one_name))> - #HTMLEditFormat(plus_one_name)#</cfif><cfelse>-</cfif></td>
                </tr>
                <cfelse>
                <tr><td colspan="2" style="padding:6px 10px;font-size:13px;color:##aaa;font-family:Arial,sans-serif;font-style:italic;border-bottom:1px solid ##eee">No guests assigned yet</td></tr>
                </cfif>
            </cfloop>
            </table>
        <cfelse>
        <p style="color:##888;font-size:13px;font-family:Arial,sans-serif;font-style:italic">No information added yet.</p>
        </cfif>
        </cfoutput>
    </cfsavecontent>
    <cftry>
        <cfset coordSubject = "Seating Chart - " & trim(qSelfSite.couple_name_1) & " & " & trim(qSelfSite.couple_name_2)>
        <cfmail to="#session.user.email#"
                from="#application.config.mailFrom#"
                server="localhost" port="25"
                subject="#coordSubject#"
                type="html" timeout="60"><cfinclude template="email-coordinator-body.cfm"></cfmail>
        <cflocation url="seating-chart.cfm?selftest=1" addToken="false">
    <cfcatch>
        <cflocation url="seating-chart.cfm?error=selfsendfail" addToken="false">
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
        <cflocation url="seating-chart.cfm?error=noemail" addToken="false">
    </cfif>
    <cfquery name="qTablesForCoord" datasource="#application.config.datasource#">
        SELECT t.reception_table_id, t.table_number, t.table_name, t.capacity,
               g.name AS guest_name, g.plus_one, g.plus_one_name
        FROM dbo.ReceptionTables t
        LEFT JOIN dbo.Guests g ON g.user_id = t.user_id AND g.table_number = t.table_number
        WHERE t.user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
        ORDER BY t.table_number, g.name
    </cfquery>
    <cfset coordSite    = qCoordSite>
    <cfset coordSection = "Seating Chart">
    <cfset coordSentAt  = dateTimeFormat(now(), "mmmm d, yyyy h:mm tt")>
    <cfset coordSiteUrl = len(trim(qCoordSite.slug)) ? "https://digitalweddings.love/site.cfm?slug=#URLEncodedFormat(trim(qCoordSite.slug))#" : "">
    <cfsavecontent variable="coordBodyHtml">
        <cfoutput>
        <cfif qTablesForCoord.recordCount>
            <cfset lastTable = 0>
            <cfloop query="qTablesForCoord">
                <cfif reception_table_id NEQ lastTable>
                    <cfif lastTable NEQ 0></table><br></cfif>
                    <p style="margin:0 0 6px 0;font-size:13px;font-weight:700;color:##2c3e2e;font-family:Arial,sans-serif">Table #table_number# - #HTMLEditFormat(table_name)# (capacity: #capacity#)</p>
                    <table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0" style="border-collapse:collapse">
                    <tr style="background:##e8f0e9">
                        <th style="padding:6px 10px;text-align:left;font-size:12px;color:##3a5e3e;font-family:Arial,sans-serif;border-bottom:1px solid ##b2cbb5">Guest</th>
                        <th style="padding:6px 10px;text-align:left;font-size:12px;color:##3a5e3e;font-family:Arial,sans-serif;border-bottom:1px solid ##b2cbb5">Plus One</th>
                    </tr>
                    <cfset lastTable = reception_table_id>
                </cfif>
                <cfif len(trim(guest_name))>
                <tr>
                    <td style="padding:6px 10px;font-size:13px;color:##333;font-family:Arial,sans-serif;border-bottom:1px solid ##eee">#HTMLEditFormat(guest_name)#</td>
                    <td style="padding:6px 10px;font-size:13px;color:##333;font-family:Arial,sans-serif;border-bottom:1px solid ##eee"><cfif plus_one>Yes<cfif len(trim(plus_one_name))> - #HTMLEditFormat(plus_one_name)#</cfif><cfelse>-</cfif></td>
                </tr>
                <cfelse>
                <tr><td colspan="2" style="padding:6px 10px;font-size:13px;color:##aaa;font-family:Arial,sans-serif;font-style:italic;border-bottom:1px solid ##eee">No guests assigned yet</td></tr>
                </cfif>
            </cfloop>
            </table>
        <cfelse>
        <p style="color:##888;font-size:13px;font-family:Arial,sans-serif;font-style:italic">No information added yet.</p>
        </cfif>
        </cfoutput>
    </cfsavecontent>
    <cftry>
        <cfset coordSubject = "Seating Chart - " & trim(qCoordSite.couple_name_1) & " & " & trim(qCoordSite.couple_name_2)>
        <cfmail to="#trim(qCoordSite.coord_email)#"
                from="#application.config.mailFrom#"
                replyto="#session.user.email#"
                server="localhost" port="25"
                subject="#coordSubject#"
                type="html" timeout="60"><cfinclude template="email-coordinator-body.cfm"></cfmail>
        <cflocation url="seating-chart.cfm?coordsent=1" addToken="false">
    <cfcatch>
        <cflocation url="seating-chart.cfm?error=sendfail" addToken="false">
    </cfcatch>
    </cftry>
</cfif>

<cfquery name="tables" datasource="#application.config.datasource#">
    SELECT reception_table_id, table_number, table_name, capacity FROM dbo.ReceptionTables
    WHERE user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint"> ORDER BY table_number
</cfquery>

<cfquery name="guests" datasource="#application.config.datasource#">
    SELECT guest_id, name, rsvp_status, table_number, plus_one, plus_one_name FROM dbo.Guests
    WHERE user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
      AND (rsvp_status IS NULL OR rsvp_status <> 'declined')
    ORDER BY name
</cfquery>

<cfquery name="unassigned" datasource="#application.config.datasource#">
    SELECT guest_id, name, plus_one, plus_one_name FROM dbo.Guests
    WHERE user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
      AND (rsvp_status IS NULL OR rsvp_status <> 'declined')
      AND table_number IS NULL
    ORDER BY name
</cfquery>

<cfinclude template="../includes/layout-start.cfm">
<style>
@media (max-width:768px) {
    .unassigned-row { flex-direction:column !important; align-items:stretch !important; gap:10px !important; }
    .unassigned-form { flex-direction:column !important; width:100% !important; }
    .unassigned-form select, .unassigned-form button { width:100% !important; box-sizing:border-box !important; }
}
</style>
<section style="padding:60px 0">
<div class="container">
    <div class="page-header" style="display:flex;justify-content:space-between;align-items:flex-start;flex-wrap:wrap;gap:16px">
        <div>
            <p class="eyebrow">Manage Your Day</p>
            <h1>Seating <span class="script">Chart</span></h1>
        </div>
        <div style="display:flex;gap:8px;margin-top:8px;flex-wrap:wrap">
            <form method="post" action="/members/seating-chart.cfm">
                <input type="hidden" name="action" value="send_self">
                <button type="submit" class="btn btn-ghost btn-sm">&#128140; Send to Myself</button>
            </form>
            <form method="post" action="/members/seating-chart.cfm">
                <input type="hidden" name="action" value="send_coordinator">
                <button type="submit" class="btn btn-ghost btn-sm">&#128140; Send to Coordinator</button>
            </form>
        </div>
    </div>

    <cfparam name="url.coordsent" default="">
    <cfparam name="url.selftest"  default="">
    <cfparam name="url.error"     default="">
    <cfif url.coordsent EQ "1">
    <div class="alert alert-success" style="margin-bottom:24px">Seating chart sent to your coordinator!</div>
    </cfif>
    <cfif url.selftest EQ "1">
    <div class="alert alert-success" style="margin-bottom:24px">Seating chart preview sent to <cfoutput>#HTMLEditFormat(session.user.email)#</cfoutput> - check your inbox!</div>
    </cfif>
    <cfif url.error EQ "noemail">
    <div class="alert alert-error" style="margin-bottom:24px">Please add your wedding coordinator&rsquo;s email address before sending information. <a href="/members/coordinator.cfm">Add coordinator &rarr;</a></div>
    </cfif>
    <cfif url.error EQ "sendfail" OR url.error EQ "selfsendfail">
    <div class="alert alert-error" style="margin-bottom:24px">There was a problem sending the email. Please try again.</div>
    </cfif>

    <cfif !hasRsvps>
    <div style="background:#e8f0e9;border:1px solid #b2cbb5;border-radius:10px;padding:20px 24px;margin-bottom:32px;display:flex;align-items:center;gap:14px">
        <span style="font-size:1.6rem">&#128274;</span>
        <div>
            <strong style="display:block;margin-bottom:4px;color:#3a5e3e">No RSVPs yet</strong>
            <span style="font-size:14px;color:#5f8464">Seating assignments are only available once guests have RSVP&rsquo;d. Share your wedding site so guests can respond, then come back here to arrange seating.</span>
            <div style="margin-top:10px"><a href="/members/guests.cfm" class="btn btn-sm" style="background:#7A9E7E;color:#fff;border:none">View Guest List &rarr;</a></div>
        </div>
    </div>
    </cfif>

    <div class="grid-2" style="gap:32px;align-items:start">
        <!--- Left: Tables --->
        <div>
            <div class="panel" style="<cfif !hasRsvps>opacity:.5;pointer-events:none;</cfif>">
                <p class="panel-title">Add a Table</p>
                <form method="post" action="/members/seating-chart.cfm">
                    <input type="hidden" name="action" value="add_table">
                    <div class="field-row">
                        <div class="field"><label>Label</label><input type="text" name="tableLabel" placeholder="e.g. Head Table" required <cfif !hasRsvps>disabled</cfif>></div>
                        <div class="field"><label>Capacity</label><input type="number" name="capacity" min="1" value="8" <cfif !hasRsvps>disabled</cfif>></div>
                    </div>
                    <button type="submit" class="btn btn-primary" <cfif !hasRsvps>disabled</cfif>>Add Table</button>
                </form>
            </div>

            <cfif tables.recordCount>
                <cfoutput query="tables">
                <cfset seated = 0>
                <cfloop query="guests">
                    <cfif table_number EQ tables.table_number>
                        <cfset seated++>
                        <cfif plus_one><cfset seated++></cfif>
                    </cfif>
                </cfloop>
                <div class="panel" style="margin-bottom:16px">
                    <div style="display:flex;justify-content:space-between;align-items:start;margin-bottom:12px">
                        <div style="flex:1;min-width:0">
                            <div id="label-view-#reception_table_id#" style="display:flex;align-items:center;gap:8px;flex-wrap:wrap">
                                <strong>Table #table_number# &mdash; #HTMLEditFormat(table_name)#</strong>
                                <span class="badge badge-gray">#seated#/#capacity# seats</span>
                                <button type="button" data-tid="#reception_table_id#" data-tname="#HTMLEditFormat(table_name)#" onclick="showRename(this.dataset.tid,this.dataset.tname)" class="btn btn-ghost btn-sm" style="padding:2px 8px;font-size:11px">&##9998; Rename</button>
                            </div>
                            <form id="rename-form-#reception_table_id#" method="post" action="/members/seating-chart.cfm" style="display:none;margin-top:6px">
                                <input type="hidden" name="action" value="rename_table">
                                <input type="hidden" name="tableId" value="#reception_table_id#">
                                <div style="display:flex;gap:6px;align-items:center">
                                    <input type="text" id="rename-input-#reception_table_id#" name="newTableName" maxlength="80" required style="font-size:13px;padding:4px 8px;border:1px solid var(--border);border-radius:4px;flex:1">
                                    <button type="submit" class="btn btn-primary btn-sm">Save</button>
                                    <button type="button" onclick="hideRename('#reception_table_id#')" class="btn btn-ghost btn-sm">Cancel</button>
                                </div>
                            </form>
                        </div>
                        <form method="post" action="/members/seating-chart.cfm" style="display:inline;margin-left:8px;flex-shrink:0">
                            <input type="hidden" name="action" value="delete_table">
                            <input type="hidden" name="tableId" value="#reception_table_id#">
                            <button type="submit" class="btn btn-danger btn-sm" onclick="return confirm('Remove table?')">&times;</button>
                        </form>
                    </div>
                    <cfloop query="guests">
                        <cfif table_number EQ tables.table_number>
                            <div style="padding:6px 0;border-bottom:1px solid var(--border);font-size:13px">
                                <div style="display:flex;justify-content:space-between;align-items:center">
                                    <span><strong>#HTMLEditFormat(name)#</strong></span>
                                    <form method="post" action="/members/seating-chart.cfm" style="display:inline">
                                        <input type="hidden" name="action" value="assign_table">
                                        <input type="hidden" name="guestId" value="#guest_id#">
                                        <input type="hidden" name="tableNum" value="0">
                                        <button type="submit" class="btn btn-ghost btn-sm" style="padding:2px 8px">Remove</button>
                                    </form>
                                </div>
                                <cfif plus_one>
                                <div style="font-size:12px;color:var(--text-muted);padding-left:10px;margin-top:2px">
                                    &plus; #len(trim(plus_one_name)) ? HTMLEditFormat(plus_one_name) : 'Guest'#
                                </div>
                                </cfif>
                            </div>
                        </cfif>
                    </cfloop>
                </div>
                </cfoutput>
            <cfelse>
                <div class="empty-state"><p>No tables yet. Add your first table above.</p></div>
            </cfif>
        </div>

        <!--- Right: Unassigned Guests --->
        <div>
            <div class="panel" style="<cfif !hasRsvps>opacity:.5;pointer-events:none;</cfif>">
                <p class="panel-title">Unassigned Guests (<cfoutput>#unassigned.recordCount#</cfoutput>)</p>
                <cfif !hasRsvps>
                    <p style="color:var(--text-muted);font-size:14px">&#128274; Awaiting RSVPs before guests can be seated.</p>
                <cfelseif unassigned.recordCount && tables.recordCount>
                    <cfoutput query="unassigned">
                    <div style="padding:10px 0;border-bottom:1px solid var(--border)">
                        <div class="unassigned-row" style="display:flex;justify-content:space-between;align-items:center;gap:10px">
                            <div style="flex-shrink:0">
                                <span style="font-size:14px;font-weight:600">#HTMLEditFormat(name)#</span>
                                <cfif plus_one>
                                <span style="font-size:12px;color:var(--text-muted);margin-left:6px">&plus; #len(trim(plus_one_name)) ? HTMLEditFormat(plus_one_name) : 'Guest'#</span>
                                </cfif>
                            </div>
                            <form method="post" action="/members/seating-chart.cfm" class="unassigned-form" style="display:flex;gap:8px;align-items:center">
                                <input type="hidden" name="action" value="assign_table">
                                <input type="hidden" name="guestId" value="#guest_id#">
                                <select name="tableNum" style="font-size:12px;padding:4px;border:1px solid var(--border);border-radius:4px">
                                    <cfloop query="tables"><option value="#table_number#">Table #table_number# &mdash; #HTMLEditFormat(table_name)#</option></cfloop>
                                </select>
                                <button type="submit" class="btn btn-primary btn-sm">Assign</button>
                            </form>
                        </div>
                    </div>
                    </cfoutput>
                <cfelseif !unassigned.recordCount>
                    <p style="color:var(--text-muted);font-size:14px">All guests have been assigned to tables!</p>
                <cfelse>
                    <p style="color:var(--text-muted);font-size:14px">Add tables first, then assign guests.</p>
                </cfif>
            </div>
        </div>
    </div>
</div>
</section>
<script>
function showRename(id, currentName) {
    document.getElementById('label-view-' + id).style.display = 'none';
    document.getElementById('rename-form-' + id).style.display = 'block';
    var input = document.getElementById('rename-input-' + id);
    input.value = currentName;
    input.focus();
    input.select();
}
function hideRename(id) {
    document.getElementById('rename-form-' + id).style.display = 'none';
    document.getElementById('label-view-' + id).style.display = 'flex';
}
</script>
<cfinclude template="../includes/layout-end.cfm">
