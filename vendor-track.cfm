<cfparam name="url.id"       default="0">
<cfparam name="url.type"     default="">
<cfparam name="url.redirect" default="">

<!--- Auto-create analytics table if missing --->
<cftry>
<cfquery datasource="#application.config.datasource#">
    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME='VendorAnalytics')
    CREATE TABLE dbo.VendorAnalytics (
        analytics_id bigint IDENTITY(1,1) PRIMARY KEY,
        vendor_id    bigint NOT NULL,
        event_type   varchar(30) NOT NULL,
        event_date   date NOT NULL,
        created_at   datetime2 NOT NULL DEFAULT SYSUTCDATETIME()
    )
</cfquery>
<cfcatch></cfcatch>
</cftry>

<cfset validTypes = "view,website_click,email_click,phone_click">

<cfif isNumeric(url.id) AND url.id GT 0 AND listFind(validTypes, url.type)>
    <cftry>
    <cfquery datasource="#application.config.datasource#">
        INSERT INTO dbo.VendorAnalytics (vendor_id, event_type, event_date)
        VALUES (
            <cfqueryparam value="#url.id#" cfsqltype="cf_sql_bigint">,
            <cfqueryparam value="#url.type#" cfsqltype="cf_sql_varchar">,
            CAST(SYSUTCDATETIME() AS date)
        )
    </cfquery>
    <cfcatch></cfcatch>
    </cftry>
</cfif>

<cfif len(trim(url.redirect))>
    <cflocation url="#url.redirect#" addToken="false">
<cfelse>
    <cfcontent type="text/plain">ok
</cfif>
