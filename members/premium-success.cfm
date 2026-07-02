<cfinclude template="../includes/auth-check.cfm">
<cfparam name="url.session_id" default="">
<cfparam name="url.siteId"     default="">
<cfparam name="url.template"   default="">

<cfif NOT len(trim(url.session_id)) OR NOT isNumeric(url.siteId)>
    <cflocation url="/members/wedding-sites.cfm" addToken="false">
</cfif>

<!--- Verify site belongs to user --->
<cfquery name="qSite" datasource="#application.config.datasource#">
    SELECT wedding_site_id, template FROM dbo.WeddingSites
    WHERE wedding_site_id = <cfqueryparam value="#val(url.siteId)#" cfsqltype="cf_sql_bigint">
      AND user_id = <cfqueryparam value="#session.user.id#" cfsqltype="cf_sql_bigint">
</cfquery>
<cfif NOT qSite.recordCount>
    <cflocation url="/members/wedding-sites.cfm" addToken="false">
</cfif>

<!--- Already unlocked? Just go to edit --->
<cfquery name="qExisting" datasource="#application.config.datasource#">
    SELECT unlock_id FROM dbo.PremiumTemplateUnlocks
    WHERE wedding_site_id = <cfqueryparam value="#val(url.siteId)#" cfsqltype="cf_sql_bigint">
      AND template_name    = <cfqueryparam value="#trim(url.template)#" cfsqltype="cf_sql_nvarchar">
</cfquery>
<cfif qExisting.recordCount>
    <cflocation url="/members/wedding-site-edit.cfm?siteId=#val(url.siteId)#&unlocked=1" addToken="false">
</cfif>

<!--- Verify the Stripe session --->
<cfset verified   = false>
<cfset sessionObj = {}>
<cftry>
    <cfhttp url="https://api.stripe.com/v1/checkout/sessions/#URLEncodedFormat(trim(url.session_id))#" method="get" result="stripeResult">
        <cfhttpparam type="header" name="Authorization" value="Bearer #application.config.stripeSecretKey#">
    </cfhttp>
    <cfset sessionObj = deserializeJSON(stripeResult.fileContent)>
    <cfif structKeyExists(sessionObj,"payment_status") AND sessionObj.payment_status EQ "paid">
        <cfset verified = true>
    </cfif>
<cfcatch>
    <cfset verified = false>
</cfcatch>
</cftry>

<cfif NOT verified>
    <cflocation url="/members/wedding-sites.cfm?premium_error=1" addToken="false">
</cfif>

<!--- Record the unlock --->
<cfset paymentIntent = (structKeyExists(sessionObj,"payment_intent") AND isSimpleValue(sessionObj.payment_intent)) ? sessionObj.payment_intent : "">
<cfset amountTotal   = (structKeyExists(sessionObj,"amount_total") AND isNumeric(sessionObj.amount_total)) ? sessionObj.amount_total / 100 : 14.99>

<cftry>
<cfquery datasource="#application.config.datasource#">
    INSERT INTO dbo.PremiumTemplateUnlocks
        (user_id, wedding_site_id, template_name, stripe_session_id, stripe_payment_intent, amount_paid)
    VALUES (
        <cfqueryparam value="#session.user.id#"         cfsqltype="cf_sql_bigint">,
        <cfqueryparam value="#val(url.siteId)#"         cfsqltype="cf_sql_bigint">,
        <cfqueryparam value="#trim(url.template)#"      cfsqltype="cf_sql_nvarchar">,
        <cfqueryparam value="#trim(url.session_id)#"    cfsqltype="cf_sql_nvarchar">,
        <cfqueryparam value="#paymentIntent#"           cfsqltype="cf_sql_nvarchar" null="#!len(paymentIntent)#">,
        <cfqueryparam value="#amountTotal#"             cfsqltype="cf_sql_decimal">
    )
</cfquery>
<cfcatch><!--- duplicate insert race condition - already unlocked --->
</cfcatch>
</cftry>

<cflocation url="/members/wedding-site-edit.cfm?siteId=#val(url.siteId)#&unlocked=1" addToken="false">
