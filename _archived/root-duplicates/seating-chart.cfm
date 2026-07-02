<cfinclude template="includes/auth-check.cfm">
<cfset pageTitle = "Seating Chart | digitalweddings.love">
<cfset activePage = "seating">
<cfset userId = session.user.id>

<cfparam name="form.action" default="">

<cfif form.action EQ "add_table">
    <cfif isNumeric(form.tableNumber) && len(trim(form.tableLabel))>
        <cfquery datasource="#application.config.datasource#">
            INSERT INTO dbo.ReceptionTables (user_id, table_number, label, capacity, notes)
            VALUES (
                <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">,
                <cfqueryparam value="#val(form.tableNumber)#" cfsqltype="cf_sql_integer">,
                <cfqueryparam value="#trim(form.tableLabel)#" cfsqltype="cf_sql_nvarchar">,
                <cfqueryparam value="#isNumeric(form.capacity) ? val(form.capacity) : 8#" cfsqltype="cf_sql_integer">,
                <cfqueryparam value="#trim(form.notes)#" cfsqltype="cf_sql_nvarchar" null="#!len(trim(form.notes))#">
            )
        </cfquery>
    </cfif>
    <cflocation url="seating-chart.cfm" addToken="false">
</cfif>

<cfif form.action EQ "assign_table" && isNumeric(form.guestId) && isNumeric(form.tableNum)>
    <cfquery datasource="#application.config.datasource#">
        UPDATE dbo.Guests SET table_number = <cfqueryparam value="#val(form.tableNum)#" cfsqltype="cf_sql_integer" null="#val(form.tableNum) EQ 0#">, updated_at = SYSUTCDATETIME()
        WHERE guest_id = <cfqueryparam value="#form.guestId#" cfsqltype="cf_sql_bigint"> AND user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
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
    SELECT reception_table_id, table_number, label, capacity, notes FROM dbo.ReceptionTables
    WHERE user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint"> ORDER BY table_number
</cfquery>

<cfquery name="guests" datasource="#application.config.datasource#">
    SELECT guest_id, name, rsvp_status, table_number FROM dbo.Guests
    WHERE user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint"> ORDER BY name
</cfquery>

<cfquery name="unassigned" datasource="#application.config.datasource#">
    SELECT guest_id, name FROM dbo.Guests
    WHERE user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint"> AND table_number IS NULL ORDER BY name
</cfquery>

<cfinclude template="includes/layout-start.cfm">
<section style="padding:60px 0">
<div class="container">
    <div class="page-header">
        <p class="eyebrow">Manage Your Day</p>
        <h1>Seating <span class="script">Chart</span></h1>
    </div>

    <div class="grid-2" style="gap:32px;align-items:start">
        <!--- Left: Tables --->
        <div>
            <div class="panel">
                <p class="panel-title">Add a Table</p>
                <form method="post" action="seating-chart.cfm">
                    <input type="hidden" name="action" value="add_table">
                    <div class="field-row">
                        <div class="field"><label>Table #</label><input type="number" name="tableNumber" min="1" required></div>
                        <div class="field"><label>Label</label><input type="text" name="tableLabel" placeholder="e.g. Head Table" required></div>
                    </div>
                    <div class="field-row">
                        <div class="field"><label>Capacity</label><input type="number" name="capacity" min="1" value="8"></div>
                        <div class="field"><label>Notes</label><input type="text" name="notes" placeholder="Optional"></div>
                    </div>
                    <button type="submit" class="btn btn-primary">Add Table</button>
                </form>
            </div>

            <cfif tables.recordCount>
                <cfoutput query="tables">
                <cfset seated = 0>
                <cfloop query="guests"><cfif table_number EQ tables.table_number><cfset seated++></cfif></cfloop>
                <div class="panel" style="margin-bottom:16px">
                    <div style="display:flex;justify-content:space-between;align-items:start;margin-bottom:12px">
                        <div>
                            <strong>Table #table_number# &mdash; #HTMLEditFormat(label)#</strong>
                            <span class="badge badge-gray" style="margin-left:8px">#seated#/#capacity# seats</span>
                        </div>
                        <form method="post" action="seating-chart.cfm" style="display:inline">
                            <input type="hidden" name="action" value="delete_table">
                            <input type="hidden" name="tableId" value="#reception_table_id#">
                            <button type="submit" class="btn btn-danger btn-sm" onclick="return confirm('Remove table?')">&times;</button>
                        </form>
                    </div>
                    <cfloop query="guests">
                        <cfif table_number EQ tables.table_number>
                            <div style="display:flex;justify-content:space-between;align-items:center;padding:6px 0;border-bottom:1px solid var(--border);font-size:13px">
                                <span>#HTMLEditFormat(name)#</span>
                                <form method="post" action="seating-chart.cfm" style="display:inline">
                                    <input type="hidden" name="action" value="assign_table">
                                    <input type="hidden" name="guestId" value="#guest_id#">
                                    <input type="hidden" name="tableNum" value="0">
                                    <button type="submit" class="btn btn-ghost btn-sm" style="padding:2px 8px">Remove</button>
                                </form>
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
            <div class="panel">
                <p class="panel-title">Unassigned Guests (<cfoutput>#unassigned.recordCount#</cfoutput>)</p>
                <cfif unassigned.recordCount && tables.recordCount>
                    <cfoutput query="unassigned">
                    <div style="display:flex;justify-content:space-between;align-items:center;padding:8px 0;border-bottom:1px solid var(--border)">
                        <span style="font-size:14px">#HTMLEditFormat(name)#</span>
                        <form method="post" action="seating-chart.cfm" style="display:flex;gap:8px;align-items:center">
                            <input type="hidden" name="action" value="assign_table">
                            <input type="hidden" name="guestId" value="#guest_id#">
                            <select name="tableNum" style="font-size:12px;padding:4px;border:1px solid var(--border);border-radius:4px">
                                <cfloop query="tables"><option value="#table_number#">Table #table_number# &mdash; #HTMLEditFormat(label)#</option></cfloop>
                            </select>
                            <button type="submit" class="btn btn-primary btn-sm">Assign</button>
                        </form>
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
<cfinclude template="includes/layout-end.cfm">
