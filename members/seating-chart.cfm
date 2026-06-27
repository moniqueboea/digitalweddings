<cfinclude template="../includes/auth-check.cfm">
<cfset pageTitle = "Seating Chart | digitalweddings.love">
<cfset activePage = "seating">
<cfset userId = session.user.id>

<cfparam name="form.action" default="">

<!--- Count confirmed RSVPs — seating requires at least one RSVP --->
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
    <cfif isNumeric(form.tableNumber) && len(trim(form.tableLabel))>
        <cfquery datasource="#application.config.datasource#">
            INSERT INTO dbo.ReceptionTables (user_id, table_number, table_name, capacity)
            VALUES (
                <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">,
                <cfqueryparam value="#val(form.tableNumber)#" cfsqltype="cf_sql_integer">,
                <cfqueryparam value="#trim(form.tableLabel)#" cfsqltype="cf_sql_nvarchar" null="#!len(trim(form.tableLabel))#">,
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

<cfquery name="tables" datasource="#application.config.datasource#">
    SELECT reception_table_id, table_number, table_name, capacity FROM dbo.ReceptionTables
    WHERE user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint"> ORDER BY table_number
</cfquery>

<cfquery name="guests" datasource="#application.config.datasource#">
    SELECT guest_id, name, rsvp_status, table_number, plus_one, plus_one_name FROM dbo.Guests
    WHERE user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint"> ORDER BY name
</cfquery>

<cfquery name="unassigned" datasource="#application.config.datasource#">
    SELECT guest_id, name, plus_one, plus_one_name FROM dbo.Guests
    WHERE user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint"> AND table_number IS NULL ORDER BY name
</cfquery>

<cfinclude template="../includes/layout-start.cfm">
<section style="padding:60px 0">
<div class="container">
    <div class="page-header">
        <p class="eyebrow">Manage Your Day</p>
        <h1>Seating <span class="script">Chart</span></h1>
    </div>

    <cfif !hasRsvps>
    <div style="background:#FFF8E6;border:1px solid #F0D080;border-radius:10px;padding:20px 24px;margin-bottom:32px;display:flex;align-items:center;gap:14px">
        <span style="font-size:1.6rem">&#128274;</span>
        <div>
            <strong style="display:block;margin-bottom:4px;color:#7A5A00">No RSVPs yet</strong>
            <span style="font-size:14px;color:#9A7A20">Seating assignments are only available once guests have RSVP&rsquo;d. Share your wedding site so guests can respond, then come back here to arrange seating.</span>
            <div style="margin-top:10px"><a href="/members/guests.cfm" class="btn btn-sm" style="background:#B8922A;color:#fff;border:none">View Guest List &rarr;</a></div>
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
                        <div class="field"><label>Table #</label><input type="number" name="tableNumber" min="1" required <cfif !hasRsvps>disabled</cfif>></div>
                        <div class="field"><label>Label</label><input type="text" name="tableLabel" placeholder="e.g. Head Table" required <cfif !hasRsvps>disabled</cfif>></div>
                    </div>
                    <div class="field-row">
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
                        <cfif plus_one AND len(trim(plus_one_name))><cfset seated++></cfif>
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
                                <cfif plus_one AND len(trim(plus_one_name))>
                                <div style="font-size:12px;color:var(--text-muted);padding-left:10px;margin-top:2px">
                                    &plus; #HTMLEditFormat(plus_one_name)#
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
                    <div style="padding:8px 0;border-bottom:1px solid var(--border)">
                        <div style="display:flex;justify-content:space-between;align-items:center">
                            <div>
                                <span style="font-size:14px;font-weight:600">#HTMLEditFormat(name)#</span>
                                <cfif plus_one AND len(trim(plus_one_name))>
                                <span style="font-size:12px;color:var(--text-muted);margin-left:8px">&plus; #HTMLEditFormat(plus_one_name)#</span>
                                </cfif>
                            </div>
                            <form method="post" action="/members/seating-chart.cfm" style="display:flex;gap:8px;align-items:center">
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
