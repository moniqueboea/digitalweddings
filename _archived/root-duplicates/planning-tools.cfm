<cfinclude template="includes/auth-check.cfm">
<cfset pageTitle = "Planning Tools | digitalweddings.love">
<cfset activePage = "planning-tools">
<cfset userId = session.user.id>

<!--- Handle budget form actions --->
<cfparam name="form.action" default="">

<cfif form.action EQ "add_budget">
    <cfif len(trim(form.category)) && len(trim(form.itemName)) && isNumeric(form.estimatedCost)>
        <cfquery datasource="#application.config.datasource#">
            INSERT INTO dbo.BudgetItems (user_id, category, item_name, estimated_cost, actual_cost, paid, vendor_name, notes)
            VALUES (
                <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">,
                <cfqueryparam value="#trim(form.category)#" cfsqltype="cf_sql_nvarchar">,
                <cfqueryparam value="#trim(form.itemName)#" cfsqltype="cf_sql_nvarchar">,
                <cfqueryparam value="#val(form.estimatedCost)#" cfsqltype="cf_sql_decimal">,
                <cfqueryparam value="#val(form.actualCost)#" cfsqltype="cf_sql_decimal">,
                <cfqueryparam value="#(structKeyExists(form,'paid') && form.paid EQ 'on') ? 1 : 0#" cfsqltype="cf_sql_bit">,
                <cfqueryparam value="#trim(form.vendorName)#" cfsqltype="cf_sql_nvarchar" null="#!len(trim(form.vendorName))#">,
                <cfqueryparam value="#trim(form.notes)#" cfsqltype="cf_sql_nvarchar" null="#!len(trim(form.notes))#">
            )
        </cfquery>
    </cfif>
    <cflocation url="planning-tools.cfm" addToken="false">
</cfif>

<cfif form.action EQ "delete_budget" && isNumeric(form.budgetItemId)>
    <cfquery datasource="#application.config.datasource#">
        DELETE FROM dbo.BudgetItems WHERE budget_item_id = <cfqueryparam value="#form.budgetItemId#" cfsqltype="cf_sql_bigint"> AND user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
    </cfquery>
    <cflocation url="planning-tools.cfm" addToken="false">
</cfif>

<cfif form.action EQ "add_checklist">
    <cfif len(trim(form.title))>
        <cfquery datasource="#application.config.datasource#">
            INSERT INTO dbo.ChecklistItems (user_id, title, description, due_date, priority, category)
            VALUES (
                <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">,
                <cfqueryparam value="#trim(form.title)#" cfsqltype="cf_sql_nvarchar">,
                <cfqueryparam value="#trim(form.description)#" cfsqltype="cf_sql_nvarchar" null="#!len(trim(form.description))#">,
                <cfqueryparam value="#trim(form.dueDate)#" cfsqltype="cf_sql_date" null="#!len(trim(form.dueDate))#">,
                <cfqueryparam value="#len(trim(form.priority)) ? trim(form.priority) : 'medium'#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#len(trim(form.category)) ? trim(form.category) : 'Other'#" cfsqltype="cf_sql_nvarchar">
            )
        </cfquery>
    </cfif>
    <cflocation url="planning-tools.cfm##checklist" addToken="false">
</cfif>

<cfif form.action EQ "toggle_checklist" && isNumeric(form.checklistItemId)>
    <cfquery datasource="#application.config.datasource#">
        UPDATE dbo.ChecklistItems SET completed = ~completed, updated_at = SYSUTCDATETIME()
        WHERE checklist_item_id = <cfqueryparam value="#form.checklistItemId#" cfsqltype="cf_sql_bigint"> AND user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
    </cfquery>
    <cflocation url="planning-tools.cfm##checklist" addToken="false">
</cfif>

<cfif form.action EQ "delete_checklist" && isNumeric(form.checklistItemId)>
    <cfquery datasource="#application.config.datasource#">
        DELETE FROM dbo.ChecklistItems WHERE checklist_item_id = <cfqueryparam value="#form.checklistItemId#" cfsqltype="cf_sql_bigint"> AND user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
    </cfquery>
    <cflocation url="planning-tools.cfm##checklist" addToken="false">
</cfif>

<cfquery name="budgetItems" datasource="#application.config.datasource#">
    SELECT budget_item_id, category, item_name, estimated_cost, actual_cost, paid, vendor_name, notes
    FROM dbo.BudgetItems WHERE user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
    ORDER BY category, item_name
</cfquery>

<cfquery name="checklistItems" datasource="#application.config.datasource#">
    SELECT checklist_item_id, title, description, due_date, completed, priority, category
    FROM dbo.ChecklistItems WHERE user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
    ORDER BY completed, priority DESC, due_date
</cfquery>

<cfset totalEstimated = 0><cfset totalActual = 0><cfset totalPaid = 0>
<cfloop query="budgetItems">
    <cfset totalEstimated += estimated_cost>
    <cfset totalActual += actual_cost>
    <cfif paid><cfset totalPaid += actual_cost></cfif>
</cfloop>
<cfset checklistDone = 0>
<cfloop query="checklistItems"><cfif completed><cfset checklistDone++></cfif></cfloop>

<cfinclude template="includes/layout-start.cfm">
<section style="padding:60px 0">
<div class="container">
    <div class="page-header">
        <p class="eyebrow">Manage Your Day</p>
        <h1>Planning <span class="script">Tools</span></h1>
    </div>

    <!--- Budget Summary --->
    <div class="stats-row" style="margin-bottom:36px">
        <div class="stat-card"><div class="stat-num"><cfoutput>$#numberFormat(totalEstimated,'999,999')#</cfoutput></div><div class="stat-label">Estimated Budget</div></div>
        <div class="stat-card"><div class="stat-num"><cfoutput>$#numberFormat(totalActual,'999,999')#</cfoutput></div><div class="stat-label">Actual Cost</div></div>
        <div class="stat-card"><div class="stat-num"><cfoutput>$#numberFormat(totalPaid,'999,999')#</cfoutput></div><div class="stat-label">Paid</div></div>
        <div class="stat-card"><div class="stat-num"><cfoutput>#checklistDone#/#checklistItems.recordCount#</cfoutput></div><div class="stat-label">Checklist Done</div></div>
    </div>

    <!--- Budget Section --->
    <div class="panel">
        <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:20px;padding-bottom:14px;border-bottom:1px solid var(--border)">
            <h2 style="font-size:20px;font-family:var(--font-heading)">Budget Tracker</h2>
        </div>

        <form method="post" action="planning-tools.cfm" style="margin-bottom:24px;padding:20px;background:var(--bg-card);border-radius:var(--radius)">
            <input type="hidden" name="action" value="add_budget">
            <div style="display:grid;grid-template-columns:1fr 1fr 1fr 1fr 1fr auto;gap:12px;align-items:end;flex-wrap:wrap">
                <div class="field" style="margin-bottom:0">
                    <label>Category</label>
                    <input type="text" name="category" placeholder="e.g. Venue" required>
                </div>
                <div class="field" style="margin-bottom:0">
                    <label>Item Name</label>
                    <input type="text" name="itemName" placeholder="e.g. Reception Hall" required>
                </div>
                <div class="field" style="margin-bottom:0">
                    <label>Estimated ($)</label>
                    <input type="number" name="estimatedCost" min="0" step="0.01" value="0">
                </div>
                <div class="field" style="margin-bottom:0">
                    <label>Actual ($)</label>
                    <input type="number" name="actualCost" min="0" step="0.01" value="0">
                </div>
                <div class="field" style="margin-bottom:0">
                    <label>Vendor</label>
                    <input type="text" name="vendorName" placeholder="Optional">
                </div>
                <button type="submit" class="btn btn-primary">Add</button>
            </div>
        </form>

        <cfif budgetItems.recordCount>
        <div class="table-wrap">
            <table>
                <thead><tr><th>Category</th><th>Item</th><th>Vendor</th><th>Estimated</th><th>Actual</th><th>Paid</th><th></th></tr></thead>
                <tbody>
                    <cfoutput query="budgetItems">
                    <tr>
                        <td>#HTMLEditFormat(category)#</td>
                        <td>#HTMLEditFormat(item_name)#</td>
                        <td>#HTMLEditFormat(vendor_name)#</td>
                        <td>$#numberFormat(estimated_cost,'999,999.99')#</td>
                        <td>$#numberFormat(actual_cost,'999,999.99')#</td>
                        <td><cfif paid><span class="badge badge-green">Paid</span><cfelse><span class="badge badge-amber">Unpaid</span></cfif></td>
                        <td>
                            <form method="post" action="planning-tools.cfm" style="display:inline">
                                <input type="hidden" name="action" value="delete_budget">
                                <input type="hidden" name="budgetItemId" value="#budget_item_id#">
                                <button type="submit" class="btn btn-danger btn-sm" onclick="return confirm('Delete this item?')">Delete</button>
                            </form>
                        </td>
                    </tr>
                    </cfoutput>
                </tbody>
            </table>
        </div>
        <cfelse>
            <div class="empty-state"><p>No budget items yet. Add your first one above.</p></div>
        </cfif>
    </div>

    <!--- Checklist Section --->
    <div class="panel" id="checklist">
        <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:20px;padding-bottom:14px;border-bottom:1px solid var(--border)">
            <h2 style="font-size:20px;font-family:var(--font-heading)">Wedding Checklist</h2>
        </div>

        <form method="post" action="planning-tools.cfm" style="margin-bottom:24px;padding:20px;background:var(--bg-card);border-radius:var(--radius)">
            <input type="hidden" name="action" value="add_checklist">
            <div style="display:grid;grid-template-columns:2fr 1fr 1fr 1fr auto;gap:12px;align-items:end">
                <div class="field" style="margin-bottom:0">
                    <label>Task Title</label>
                    <input type="text" name="title" placeholder="e.g. Book the venue" required>
                </div>
                <div class="field" style="margin-bottom:0">
                    <label>Category</label>
                    <input type="text" name="category" placeholder="e.g. Venue">
                </div>
                <div class="field" style="margin-bottom:0">
                    <label>Due Date</label>
                    <input type="date" name="dueDate">
                </div>
                <div class="field" style="margin-bottom:0">
                    <label>Priority</label>
                    <select name="priority">
                        <option value="medium">Medium</option>
                        <option value="high">High</option>
                        <option value="low">Low</option>
                    </select>
                </div>
                <button type="submit" class="btn btn-primary">Add</button>
            </div>
        </form>

        <cfif checklistItems.recordCount>
            <cfset lastCat = "">
            <cfoutput query="checklistItems">
                <cfif category NEQ lastCat>
                    <cfif lastCat NEQ ""><br></cfif>
                    <p style="font-size:11px;font-weight:700;letter-spacing:0.2em;text-transform:uppercase;color:var(--text-muted);margin-bottom:8px">#HTMLEditFormat(category)#</p>
                    <cfset lastCat = category>
                </cfif>
                <div style="display:flex;align-items:center;gap:12px;padding:12px;border-radius:var(--radius);background:<cfif completed>var(--bg-card)<cfelse>##fff</cfif>;border:1px solid var(--border);margin-bottom:8px">
                    <form method="post" action="planning-tools.cfm" style="flex-shrink:0">
                        <input type="hidden" name="action" value="toggle_checklist">
                        <input type="hidden" name="checklistItemId" value="#checklist_item_id#">
                        <button type="submit" style="width:22px;height:22px;border-radius:4px;border:2px solid <cfif completed>var(--gold)<cfelse>var(--border)</cfif>;background:<cfif completed>var(--gold)<cfelse>##fff</cfif>;cursor:pointer;display:flex;align-items:center;justify-content:center;padding:0">
                            <cfif completed><span style="color:##fff;font-size:14px">&##10003;</span></cfif>
                        </button>
                    </form>
                    <div style="flex:1">
                        <p style="font-size:14px;font-weight:500;<cfif completed>text-decoration:line-through;color:var(--text-muted);</cfif>">#HTMLEditFormat(title)#</p>
                        <cfif len(due_date)><p style="font-size:12px;color:var(--text-muted)">Due: #dateFormat(due_date,'mmmm d, yyyy')#</p></cfif>
                    </div>
                    <cfset priorityColors = {high:'badge-red',medium:'badge-amber',low:'badge-blue'}>
                    <span class="badge #priorityColors[priority]#">#priority#</span>
                    <form method="post" action="planning-tools.cfm" style="flex-shrink:0">
                        <input type="hidden" name="action" value="delete_checklist">
                        <input type="hidden" name="checklistItemId" value="#checklist_item_id#">
                        <button type="submit" class="btn btn-ghost btn-sm" onclick="return confirm('Delete?')" style="padding:4px 10px;font-size:18px;color:var(--text-muted)">&times;</button>
                    </form>
                </div>
            </cfoutput>
        <cfelse>
            <div class="empty-state"><p>No checklist items yet. Add your first task above.</p></div>
        </cfif>
    </div>
</div>
</section>
<cfinclude template="includes/layout-end.cfm">
