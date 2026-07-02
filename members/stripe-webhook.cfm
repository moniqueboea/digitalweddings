<cfset requestBody = toString(getHttpRequestData().content)>
<cfset sigHeader  = CGI.HTTP_STRIPE_SIGNATURE>

<!--- Verify Stripe signature --->
<cfset verified = false>
<cftry>
    <cfset parts     = listToArray(sigHeader, ",")>
    <cfset timestamp = "">
    <cfset sigHash   = "">
    <cfloop array="#parts#" index="part">
        <cfif left(trim(part),2) EQ "t=">  <cfset timestamp = listLast(trim(part),"=")></cfif>
        <cfif left(trim(part),3) EQ "v1="> <cfset sigHash   = mid(trim(part),4,len(trim(part))-3)></cfif>
    </cfloop>
    <cfset signedPayload = timestamp & "." & requestBody>
    <cfset expected = lCase(hmac(signedPayload, application.config.stripeWebhookSecret, "HmacSHA256"))>
    <cfif expected EQ lCase(sigHash)>
        <cfset verified = true>
    </cfif>
<cfcatch>
    <cfset verified = false>
</cfcatch>
</cftry>

<cfif NOT verified>
    <cfheader statuscode="400" statustext="Bad Request">
    <cfoutput>Signature verification failed</cfoutput>
    <cfabort>
</cfif>

<!--- Parse event --->
<cftry>
    <cfset event = deserializeJSON(requestBody)>
    <cfif event.type EQ "checkout.session.completed">
        <cfset session = event.data.object>
        <cfif session.payment_status EQ "paid" AND structKeyExists(session,"metadata")>
            <cfset meta = session.metadata>
            <cfif structKeyExists(meta,"site_id") AND structKeyExists(meta,"user_id") AND structKeyExists(meta,"template_name")>
                <!--- Check not already recorded --->
                <cfquery name="qChk" datasource="#application.config.datasource#">
                    SELECT unlock_id FROM dbo.PremiumTemplateUnlocks
                    WHERE stripe_session_id = <cfqueryparam value="#session.id#" cfsqltype="cf_sql_nvarchar">
                </cfquery>
                <cfif NOT qChk.recordCount>
                    <cfset pi = (structKeyExists(session,"payment_intent") AND isSimpleValue(session.payment_intent)) ? session.payment_intent : "">
                    <cftry>
                    <cfquery datasource="#application.config.datasource#">
                        INSERT INTO dbo.PremiumTemplateUnlocks
                            (user_id, wedding_site_id, template_name, stripe_session_id, stripe_payment_intent, amount_paid)
                        VALUES (
                            <cfqueryparam value="#val(meta.user_id)#"       cfsqltype="cf_sql_bigint">,
                            <cfqueryparam value="#val(meta.site_id)#"       cfsqltype="cf_sql_bigint">,
                            <cfqueryparam value="#meta.template_name#"      cfsqltype="cf_sql_nvarchar">,
                            <cfqueryparam value="#session.id#"              cfsqltype="cf_sql_nvarchar">,
                            <cfqueryparam value="#pi#"                      cfsqltype="cf_sql_nvarchar" null="#!len(pi)#">,
                            <cfqueryparam value="#val(session.amount_total) / 100#" cfsqltype="cf_sql_decimal">
                        )
                    </cfquery>
                    <cfcatch></cfcatch>
                    </cftry>
                </cfif>
            </cfif>
        </cfif>
    </cfif>
<cfcatch>
    <cfheader statuscode="500" statustext="Error">
    <cfoutput>Error processing webhook</cfoutput>
    <cfabort>
</cfcatch>
</cftry>

<cfheader statuscode="200" statustext="OK">
<cfoutput>ok</cfoutput>
