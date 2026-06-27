<cfinclude template="../includes/auth-check.cfm">

<cfparam name="url.slug" default="">
<cfparam name="url.siteId" default="0">

<cfset slug = lCase(reReplace(trim(url.slug),"[^a-z0-9\-]","","all"))>
<cfset available = false>

<cfif len(slug) GTE 2>
    <cfquery name="chk" datasource="#application.config.datasource#">
        SELECT wedding_site_id FROM dbo.WeddingSites
        WHERE slug = <cfqueryparam value="#slug#" cfsqltype="cf_sql_varchar">
        <cfif isNumeric(url.siteId) && url.siteId GT 0>
            AND wedding_site_id <> <cfqueryparam value="#url.siteId#" cfsqltype="cf_sql_bigint">
        </cfif>
    </cfquery>
    <cfset available = (chk.recordCount EQ 0)>
</cfif>

<cfcontent type="application/json"><cfoutput>{"available":#available ? 'true' : 'false'#,"slug":"#JSStringFormat(slug)#"}</cfoutput>
