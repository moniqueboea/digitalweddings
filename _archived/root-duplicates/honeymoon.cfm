<cfinclude template="includes/auth-check.cfm">
<cfset pageTitle = "Honeymoon Planner | digitalweddings.love">
<cfset activePage = "honeymoon">
<cfset userId = session.user.id>
<cfparam name="form.action" default="">

<cfif form.action EQ "save">
    <cfquery name="existing" datasource="#application.config.datasource#">
        SELECT honeymoon_id FROM dbo.Honeymoons WHERE user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
    </cfquery>
    <cfif existing.recordCount>
        <cfquery datasource="#application.config.datasource#">
            UPDATE dbo.Honeymoons SET
                destination = <cfqueryparam value="#trim(form.destination)#" cfsqltype="cf_sql_nvarchar" null="#!len(trim(form.destination))#">,
                start_date = <cfqueryparam value="#trim(form.startDate)#" cfsqltype="cf_sql_date" null="#!len(trim(form.startDate))#">,
                end_date = <cfqueryparam value="#trim(form.endDate)#" cfsqltype="cf_sql_date" null="#!len(trim(form.endDate))#">,
                estimated_budget = <cfqueryparam value="#isNumeric(form.estimatedBudget) ? val(form.estimatedBudget) : 0#" cfsqltype="cf_sql_decimal">,
                notes = <cfqueryparam value="#trim(form.notes)#" cfsqltype="cf_sql_nvarchar" null="#!len(trim(form.notes))#">,
                updated_at = SYSUTCDATETIME()
            WHERE user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
        </cfquery>
    <cfelse>
        <cfquery datasource="#application.config.datasource#">
            INSERT INTO dbo.Honeymoons (user_id, destination, start_date, end_date, estimated_budget, notes)
            VALUES (
                <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">,
                <cfqueryparam value="#trim(form.destination)#" cfsqltype="cf_sql_nvarchar" null="#!len(trim(form.destination))#">,
                <cfqueryparam value="#trim(form.startDate)#" cfsqltype="cf_sql_date" null="#!len(trim(form.startDate))#">,
                <cfqueryparam value="#trim(form.endDate)#" cfsqltype="cf_sql_date" null="#!len(trim(form.endDate))#">,
                <cfqueryparam value="#isNumeric(form.estimatedBudget) ? val(form.estimatedBudget) : 0#" cfsqltype="cf_sql_decimal">,
                <cfqueryparam value="#trim(form.notes)#" cfsqltype="cf_sql_nvarchar" null="#!len(trim(form.notes))#">
            )
        </cfquery>
    </cfif>
    <cflocation url="honeymoon.cfm?saved=1" addToken="false">
</cfif>

<cfquery name="honeymoon" datasource="#application.config.datasource#">
    SELECT destination, start_date, end_date, estimated_budget, notes
    FROM dbo.Honeymoons WHERE user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
</cfquery>

<cfset saved = structKeyExists(url,"saved") && url.saved EQ "1">

<cfinclude template="includes/layout-start.cfm">
<section style="padding:60px 0">
<div class="container" style="max-width:680px">
    <div class="page-header">
        <p class="eyebrow">After the Wedding</p>
        <h1>Honeymoon <span class="script">Planner</span></h1>
    </div>

    <cfif saved><div class="alert alert-success">Honeymoon details saved!</div></cfif>

    <div class="panel">
        <form method="post" action="honeymoon.cfm">
            <input type="hidden" name="action" value="save">
            <div class="field">
                <label for="destination">Destination</label>
                <input type="text" id="destination" name="destination" placeholder="e.g. Maldives, Jamaica, Paris" value="<cfoutput>#honeymoon.recordCount ? HTMLEditFormat(honeymoon.destination) : ''#</cfoutput>">
            </div>
            <div class="field-row">
                <div class="field">
                    <label for="startDate">Departure Date</label>
                    <input type="date" id="startDate" name="startDate" value="<cfoutput>#honeymoon.recordCount && len(honeymoon.start_date) ? dateFormat(honeymoon.start_date,'yyyy-mm-dd') : ''#</cfoutput>">
                </div>
                <div class="field">
                    <label for="endDate">Return Date</label>
                    <input type="date" id="endDate" name="endDate" value="<cfoutput>#honeymoon.recordCount && len(honeymoon.end_date) ? dateFormat(honeymoon.end_date,'yyyy-mm-dd') : ''#</cfoutput>">
                </div>
            </div>
            <div class="field">
                <label for="estimatedBudget">Estimated Budget ($)</label>
                <input type="number" id="estimatedBudget" name="estimatedBudget" min="0" step="0.01" value="<cfoutput>#honeymoon.recordCount ? honeymoon.estimated_budget : 0#</cfoutput>">
            </div>
            <div class="field">
                <label for="notes">Notes &amp; Ideas</label>
                <textarea id="notes" name="notes" rows="6" placeholder="Hotels, activities, packing lists, flight info..."><cfoutput>#honeymoon.recordCount ? HTMLEditFormat(honeymoon.notes) : ''#</cfoutput></textarea>
            </div>
            <button type="submit" class="btn btn-primary btn-lg">Save Honeymoon Plans</button>
        </form>
    </div>
</div>
</section>
<cfinclude template="includes/layout-end.cfm">
