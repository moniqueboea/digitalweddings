<cfheader name="Content-Type" value="application/json">
<cfparam name="url.email" default="">
<cfset email = lCase(trim(url.email))>
<cfif !isValid("email", email)>
    <cfoutput>{"status":"invalid"}</cfoutput>
    <cfabort>
</cfif>
<cfquery name="q" datasource="#application.config.datasource#">
    SELECT vendor_id, status FROM dbo.Vendors
    WHERE email = <cfqueryparam value="#email#" cfsqltype="cf_sql_varchar">
      AND complimentary = 1
</cfquery>
<cfif q.recordCount>
    <cfif q.status EQ "active">
        <cfoutput>{"status":"already_registered"}</cfoutput>
    <cfelse>
        <cfoutput>{"status":"found"}</cfoutput>
    </cfif>
<cfelse>
    <cfoutput>{"status":"not_found"}</cfoutput>
</cfif>
