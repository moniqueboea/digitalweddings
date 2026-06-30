<cfsilent>
<!---
    ONE-TIME ADMIN SEED SCRIPT
    Run once in a browser: https://digitalweddings.love/db/seed-admin.cfm
    DELETE THIS FILE after the user is created.
--->

<cfset targetUsername  = "moniqueboea">
<cfset targetEmail     = "moniqueboea@gmail.com">
<cfset targetFirstName = "Monique">
<cfset targetLastName  = "Boea">
<cfset targetPassword  = "wedding@2026">
<cfset targetRole      = "admin">

<!--- Check if user already exists --->
<cfquery name="existing" datasource="#application.config.datasource#">
    SELECT user_id FROM dbo.Users
    WHERE username = <cfqueryparam value="#targetUsername#" cfsqltype="cf_sql_varchar">
       OR email    = <cfqueryparam value="#targetEmail#"    cfsqltype="cf_sql_varchar">
</cfquery>

<cfif existing.recordCount GT 0>
    <!--- User exists - just make sure they are admin + active --->
    <cfquery datasource="#application.config.datasource#">
        UPDATE dbo.Users
        SET is_admin = 1,
            is_active = 1,
            role = <cfqueryparam value="#targetRole#" cfsqltype="cf_sql_varchar">,
            email_verified_at = ISNULL(email_verified_at, SYSUTCDATETIME())
        WHERE username = <cfqueryparam value="#targetUsername#" cfsqltype="cf_sql_varchar">
           OR email    = <cfqueryparam value="#targetEmail#"    cfsqltype="cf_sql_varchar">
    </cfquery>
    <cfset resultMsg = "User already existed - updated to admin + active.">
    <cfset resultOk  = true>
<cfelse>
    <!--- Hash password using the real PasswordService --->
    <cfset pwSvc = createObject("component", "services.PasswordService")>
    <cfset pw    = pwSvc.createHash(targetPassword)>

    <cftry>
        <cfquery name="inserted" datasource="#application.config.datasource#">
            INSERT INTO dbo.Users
                (username, first_name, last_name, email,
                 password_hash, password_salt, password_iterations, password_algorithm,
                 role, is_active, is_admin, email_verified_at)
            OUTPUT INSERTED.user_id
            VALUES (
                <cfqueryparam value="#targetUsername#"      cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#targetFirstName#"     cfsqltype="cf_sql_nvarchar">,
                <cfqueryparam value="#targetLastName#"      cfsqltype="cf_sql_nvarchar">,
                <cfqueryparam value="#targetEmail#"         cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#pw.hash#"             cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#pw.salt#"             cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#pw.iterations#"       cfsqltype="cf_sql_integer">,
                <cfqueryparam value="#pw.algorithm#"        cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#targetRole#"          cfsqltype="cf_sql_varchar">,
                1,
                1,
                SYSUTCDATETIME()
            )
        </cfquery>
        <cfset resultMsg = "Admin user created! user_id = #inserted.user_id#">
        <cfset resultOk  = true>
    <cfcatch type="any">
        <cfset resultMsg = "Error: #cfcatch.message# - #cfcatch.detail#">
        <cfset resultOk  = false>
    </cfcatch>
    </cftry>
</cfif>
</cfsilent>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Admin Seed</title>
    <style>
        body { font-family: sans-serif; max-width: 600px; margin: 80px auto; padding: 0 24px; }
        .ok  { background: #f0fdf4; border: 1px solid #bbf7d0; color: #166534; padding: 20px; border-radius: 10px; }
        .err { background: #fef2f2; border: 1px solid #fecaca; color: #991b1b; padding: 20px; border-radius: 10px; }
        h2   { margin-bottom: 12px; }
        .warn { font-size: 13px; margin-top: 16px; color: #92400e; background: #fef3c7; padding: 12px 16px; border-radius: 8px; }
    </style>
</head>
<body>
<cfoutput>
<div class="#resultOk ? 'ok' : 'err'#">
    <h2>#resultOk ? 'Done' : 'Failed'#</h2>
    <p>#encodeForHTML(resultMsg)#</p>
</div>
<cfif resultOk>
<p class="warn">
    <strong>Security:</strong> delete <code>/db/seed-admin.cfm</code> from the server now that it has run.
</p>
</cfif>
</cfoutput>
</body>
</html>
