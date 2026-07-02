<cfinclude template="../includes/auth-check.cfm">
<cfparam name="url.siteId"   default="">
<cfparam name="url.template" default="">

<!--- Validate inputs --->
<cfif NOT isNumeric(url.siteId) OR NOT len(trim(url.template))>
    <cflocation url="/members/wedding-sites.cfm" addToken="false">
</cfif>

<!--- Verify site belongs to user --->
<cfquery name="qSite" datasource="#application.config.datasource#">
    SELECT wedding_site_id, template, couple_name_1, couple_name_2
    FROM dbo.WeddingSites
    WHERE wedding_site_id = <cfqueryparam value="#val(url.siteId)#" cfsqltype="cf_sql_bigint">
      AND user_id = <cfqueryparam value="#session.user.id#" cfsqltype="cf_sql_bigint">
</cfquery>
<cfif NOT qSite.recordCount>
    <cflocation url="/members/wedding-sites.cfm" addToken="false">
</cfif>

<!--- Verify template is actually premium --->
<cfif NOT listFind(application.config.premiumTemplates, trim(url.template))>
    <cflocation url="/members/wedding-site-edit.cfm?siteId=#val(url.siteId)#" addToken="false">
</cfif>

<!--- Check not already unlocked --->
<cfquery name="qUnlock" datasource="#application.config.datasource#">
    SELECT unlock_id FROM dbo.PremiumTemplateUnlocks
    WHERE wedding_site_id = <cfqueryparam value="#val(url.siteId)#" cfsqltype="cf_sql_bigint">
      AND template_name    = <cfqueryparam value="#trim(url.template)#" cfsqltype="cf_sql_nvarchar">
</cfquery>
<cfif qUnlock.recordCount>
    <cflocation url="/members/wedding-site-edit.cfm?siteId=#val(url.siteId)#" addToken="false">
</cfif>

<!--- Create Stripe Checkout Session via HTTP --->
<cfset successUrl = application.config.frontendUrl & "/members/premium-success.cfm?session_id={CHECKOUT_SESSION_ID}&siteId=" & val(url.siteId) & "&template=" & URLEncodedFormat(trim(url.template))>
<cfset cancelUrl  = application.config.frontendUrl & "/members/wedding-sites.cfm?premium_cancel=1">
<cfset coupleName = HTMLEditFormat(trim(qSite.couple_name_1)) & " & " & HTMLEditFormat(trim(qSite.couple_name_2))>
<cfset tplDisplay = replace(trim(url.template), "_", " ", "all")>

<cftry>
    <cfhttp url="https://api.stripe.com/v1/checkout/sessions" method="post" result="stripeResult">
        <cfhttpparam type="header" name="Authorization" value="Bearer #application.config.stripeSecretKey#">
        <cfhttpparam type="formfield" name="mode" value="payment">
        <cfhttpparam type="formfield" name="success_url" value="#successUrl#">
        <cfhttpparam type="formfield" name="cancel_url" value="#cancelUrl#">
        <cfhttpparam type="formfield" name="customer_email" value="#session.user.email#">
        <cfhttpparam type="formfield" name="line_items[0][price_data][currency]" value="usd">
        <cfhttpparam type="formfield" name="line_items[0][price_data][unit_amount]" value="#application.config.premiumTemplatePrice#">
        <cfhttpparam type="formfield" name="line_items[0][price_data][product_data][name]" value="Premium Wedding Design - #tplDisplay#">
        <cfhttpparam type="formfield" name="line_items[0][price_data][product_data][description]" value="Unlock the #tplDisplay# premium design for #coupleName#">
        <cfhttpparam type="formfield" name="line_items[0][quantity]" value="1">
        <cfhttpparam type="formfield" name="metadata[site_id]" value="#val(url.siteId)#">
        <cfhttpparam type="formfield" name="metadata[user_id]" value="#session.user.id#">
        <cfhttpparam type="formfield" name="metadata[template_name]" value="#trim(url.template)#">
        <cfhttpparam type="formfield" name="payment_intent_data[metadata][site_id]" value="#val(url.siteId)#">
        <cfhttpparam type="formfield" name="payment_intent_data[metadata][template_name]" value="#trim(url.template)#">
    </cfhttp>

    <cfset sessionData = deserializeJSON(stripeResult.fileContent)>

    <cfif structKeyExists(sessionData, "url")>
        <cflocation url="#sessionData.url#" addToken="false">
    <cfelse>
        <cflocation url="/members/wedding-sites.cfm?premium_error=1" addToken="false">
    </cfif>
<cfcatch>
    <cflocation url="/members/wedding-sites.cfm?premium_error=1" addToken="false">
</cfcatch>
</cftry>
