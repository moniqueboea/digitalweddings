<cfsetting showdebugoutput="false">
<cfcontent type="text/html; charset=utf-8">
<cfheader name="X-Robots-Tag" value="noindex, nofollow, noarchive">
<cfheader name="Cache-Control" value="no-store, max-age=0">

<cfinclude template="admin-check.cfm">

<cfparam name="form.sql"        default="">
<cfparam name="form.action"     default="">
<cfparam name="form.csrf_token" default="">

<!--- Init CSRF token --->
<cfif NOT structKeyExists(session, "databaseToolCsrf")>
    <cfset session.databaseToolCsrf = createUUID()>
</cfif>

<cfset pageMessage  = "">
<cfset errorMessage = "">
<cfset queryResult  = "">
<cfset executionMs  = 0>

<!--- CSRF check --->
<cfif len(form.action) AND form.csrf_token NEQ session.databaseToolCsrf>
    <cfset errorMessage = "Form session expired. Refresh the page and try again.">
    <cfset form.action  = "">
</cfif>

<!--- Run SQL --->
<cfif form.action EQ "run_sql">
    <cfset sqlText = trim(form.sql)>
    <cfif NOT len(sqlText)>
        <cfset errorMessage = "Enter a SQL statement.">
    <cfelse>
        <cfset startedAt = getTickCount()>
        <cfset isSelect  = REFindNoCase("^SELECT\s", sqlText) GT 0>
        <cftry>
            <cfif isSelect>
                <cfquery name="queryResult" datasource="#application.config.datasource#" timeout="60">
                    #preserveSingleQuotes(sqlText)#
                </cfquery>
                <cfset pageMessage = "Query returned " & queryResult.recordCount & " row(s).">
            <cfelse>
                <cfquery datasource="#application.config.datasource#" timeout="60">
                    #preserveSingleQuotes(sqlText)#
                </cfquery>
                <cfset pageMessage = "SQL executed successfully.">
            </cfif>
            <cfset executionMs = getTickCount() - startedAt>
        <cfcatch>
            <cfset executionMs  = getTickCount() - startedAt>
            <cfset errorMessage = cfcatch.message>
            <cfif len(trim(cfcatch.detail))>
                <cfset errorMessage = errorMessage & " — " & cfcatch.detail>
            </cfif>
            <cfset queryResult = "">
        </cfcatch>
        </cftry>
    </cfif>
</cfif>

<!--- List tables --->
<cfif form.action EQ "list_tables">
    <cfset startedAt = getTickCount()>
    <cftry>
        <cfquery name="queryResult" datasource="#application.config.datasource#">
            SELECT
                s.name      AS schema_name,
                t.name      AS table_name,
                SUM(p.rows) AS row_count
            FROM sys.tables     t
            INNER JOIN sys.schemas    s ON t.schema_id = s.schema_id
            INNER JOIN sys.partitions p ON t.object_id = p.object_id
            WHERE p.index_id IN (0, 1)
            GROUP BY s.name, t.name
            ORDER BY s.name, t.name
        </cfquery>
        <cfset executionMs = getTickCount() - startedAt>
        <cfset pageMessage = "Table list loaded.">
    <cfcatch>
        <cfset errorMessage = cfcatch.message>
        <cfset queryResult  = "">
    </cfcatch>
    </cftry>
</cfif>

<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Database Tool | Admin</title>
    <style>
        :root { --green: #7A9E7E; --green-dark: #4a6b4e; --panel: #f9fafb; --line: #e2e8e3; }
        * { box-sizing: border-box; }
        body { margin: 0; background: #ffffff; color: #2c3e2e; font: 15px/1.5 Arial, sans-serif; }
        main { width: min(1180px, calc(100% - 32px)); margin: 40px auto; }
        .card { background: var(--panel); border: 1px solid var(--line); border-radius: 12px; padding: 24px; margin-bottom: 20px; }
        h1, h2 { margin-top: 0; }
        h1 { color: var(--green-dark); }
        label { display: block; font-weight: 700; margin-bottom: 8px; }
        input, textarea { width: 100%; border: 1px solid #b2cbb5; border-radius: 8px; background: #ffffff; color: #2c3e2e; padding: 12px; }
        textarea { min-height: 300px; resize: vertical; font: 14px/1.45 ui-monospace, SFMono-Regular, Menlo, monospace; }
        button, .btn-tool { display: inline-block; border: 0; border-radius: 8px; background: var(--green); color: #ffffff; padding: 11px 18px; font-weight: 700; cursor: pointer; text-decoration: none; }
        .secondary { background: #e2e8e3; color: #2c3e2e; }
        .danger  { color: #7c1c1c; background: #fde8e8; border: 1px solid #f0b4b4; padding: 12px; border-radius: 8px; }
        .success { color: #1a4d2e; background: #e8f5ec; border: 1px solid #a8d5b5; padding: 12px; border-radius: 8px; }
        .actions { display: flex; gap: 10px; flex-wrap: wrap; margin-top: 14px; }
        .topbar  { display: flex; align-items: center; justify-content: space-between; gap: 16px; }
        .muted   { color: #5f8464; }
        .table-wrap { overflow: auto; max-height: 580px; border: 1px solid var(--line); border-radius: 8px; }
        table { border-collapse: collapse; width: 100%; background: #ffffff; }
        th, td { border-bottom: 1px solid #e2e8e3; padding: 9px 11px; text-align: left; white-space: nowrap; vertical-align: top; }
        th { position: sticky; top: 0; background: #e8f0e9; color: #3a5e3e; }
        code { color: #4a6b4e; }
    </style>
</head>
<body>
<main>

    <div class="topbar">
        <div>
            <h1>Digitial Weddings Database Tool</h1>
            <p class="muted">Datasource: <code><cfoutput>#HTMLEditFormat(application.config.datasource)#</cfoutput></code> &mdash; <a href="/members/admin/index.cfm" style="color:var(--green)">Admin Home</a></p>
        </div>
    </div>

    <cfif len(errorMessage)>
        <p class="danger"><cfoutput>#HTMLEditFormat(errorMessage)#</cfoutput></p>
    </cfif>
    <cfif len(pageMessage)>
        <p class="success">
            <cfoutput>#HTMLEditFormat(pageMessage)#</cfoutput>
            <cfif executionMs GT 0> (<cfoutput>#executionMs#</cfoutput> ms)</cfif>
        </p>
    </cfif>

    <section class="card">
        <h2>Run SQL</h2>
        <p class="muted">Executes against the production datasource. Review destructive statements carefully.</p>
        <form method="post" action="/members/admin/db.cfm">
            <input type="hidden" name="csrf_token" value="<cfoutput>#HTMLEditFormat(session.databaseToolCsrf)#</cfoutput>">
            <input type="hidden" name="action"     value="run_sql">
            <label for="sql">SQL Statement</label>
            <textarea id="sql" name="sql" spellcheck="false"><cfoutput>#HTMLEditFormat(form.sql)#</cfoutput></textarea>
            <div class="actions">
                <button type="submit">Run SQL</button>
            </div>
        </form>
        <form method="post" action="/members/admin/db.cfm" style="margin-top:10px">
            <input type="hidden" name="csrf_token" value="<cfoutput>#HTMLEditFormat(session.databaseToolCsrf)#</cfoutput>">
            <input type="hidden" name="action"     value="list_tables">
            <button class="secondary" type="submit">List Tables</button>
        </form>
    </section>

    <cfif isQuery(queryResult) AND queryResult.recordCount GT 0>
    <section class="card">
        <h2>Results</h2>
        <p class="muted"><cfoutput>#queryResult.recordCount#</cfoutput> row(s)</p>
        <div class="table-wrap">
            <table>
                <thead>
                    <tr>
                        <cfloop list="#queryResult.columnList#" index="colName">
                            <th><cfoutput>#HTMLEditFormat(colName)#</cfoutput></th>
                        </cfloop>
                    </tr>
                </thead>
                <tbody>
                    <cfoutput query="queryResult">
                    <tr>
                        <cfloop list="#queryResult.columnList#" index="colName">
                            <td>#HTMLEditFormat(queryResult[colName][currentRow])#</td>
                        </cfloop>
                    </tr>
                    </cfoutput>
                </tbody>
            </table>
        </div>
    </section>
    </cfif>

</main>
</body>
</html>
