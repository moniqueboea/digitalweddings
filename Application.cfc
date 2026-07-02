<cfcomponent>
    <cfset this.name = "DigitalWeddingsFull">
    <cfset this.applicationTimeout = createTimeSpan(1,0,0,0)>
    <cfset this.sessionManagement = true>
    <cfset this.sessionTimeout = createTimeSpan(0,2,0,0)>
    <cfset this.setClientCookies = true>
    <cfset this.datasource = "digitalweddings">
    <cfset this.sessionCookie = {httpOnly:true, secure:false, sameSite:"Lax"}>



<cffunction name="onApplicationStart" returntype="boolean">
    <cfinclude template="database-config.cfm">

    <cfset application.config = {
        datasource: application.database.datasource,
        environment: "production",
        frontendUrl: "https://digitalweddings.love",
        passwordHashIterations: 120000,
        verificationTokenHours: 24,
        passwordResetTokenHours: 1,

        mailFrom: "no-reply@digitalweddings.love",
        mailFromName: "DigitalWeddings.Love",

        mail: {
            server: "localhost",
            port: 25
        },

        <!--- Stripe keys - replace with your actual keys --->
        stripeSecretKey:      "sk_live_REPLACE_WITH_YOUR_SECRET_KEY",
        stripePublishableKey: "pk_live_REPLACE_WITH_YOUR_PUBLISHABLE_KEY",
        stripeWebhookSecret:  "whsec_REPLACE_WITH_YOUR_WEBHOOK_SECRET",
        premiumTemplatePrice: 1499,  <!--- $14.99 in cents --->

        premiumTemplates: ""
    }>

    <!--- Load premium templates from DB (empty string = none) --->
    <cftry>
        <cfquery name="local.qPremium" datasource="#application.config.datasource#">
            IF OBJECT_ID('dbo.AppSettings','U') IS NULL
            BEGIN
                CREATE TABLE dbo.AppSettings (
                    setting_key   NVARCHAR(100) NOT NULL PRIMARY KEY,
                    setting_value NVARCHAR(MAX) NULL,
                    updated_at    DATETIME2(0)  NOT NULL DEFAULT SYSUTCDATETIME()
                );
                INSERT INTO dbo.AppSettings (setting_key, setting_value) VALUES ('premiumTemplates', '');
            END
            SELECT setting_value FROM dbo.AppSettings WHERE setting_key = 'premiumTemplates'
        </cfquery>
        <cfif local.qPremium.recordCount>
            <cfset application.config.premiumTemplates = trim(local.qPremium.setting_value)>
        </cfif>
    <cfcatch type="any"></cfcatch>
    </cftry>

    <cfreturn true>
</cffunction>

    <cffunction name="onSessionStart" returntype="void">
        <cfset session.user = {}>
    </cffunction>

    <cffunction name="onRequestStart" returntype="boolean">
        <cfargument name="targetPage" type="string" required="true">
        <cfif structKeyExists(url,"reload") AND url.reload EQ "1">
            <cfset onApplicationStart()>
        </cfif>
        <cfheader name="X-Content-Type-Options" value="nosniff">
        <cfheader name="X-Frame-Options" value="SAMEORIGIN">
        <cfheader name="Referrer-Policy" value="strict-origin-when-cross-origin">
        <cfreturn true>
    </cffunction>

    <cffunction name="onRequest" returntype="void">
        <cfargument name="targetPage" type="string" required="true">
        <cfset var isAjax = (CGI.HTTP_X_REQUESTED_WITH EQ "XMLHttpRequest")>
        <cftry>
            <cfinclude template="#arguments.targetPage#">
        <cfcatch type="any">
            <cftry>
                <cfset var notifier = new services.ErrorNotifier()>
                <cfset notifier.notify(cfcatch, "onRequest", arguments.targetPage)>
            <cfcatch type="any"></cfcatch>
            </cftry>
            <cfif isAjax>
                <cfheader name="Content-Type" value="application/json">
                <cfset writeOutput('{"success":false,"message":"An error occurred. Please try again."}')>
            <cfelse>
                <cflocation url="/error.cfm" addToken="false">
            </cfif>
        </cfcatch>
        </cftry>
    </cffunction>

    <cffunction name="onMissingTemplate" returntype="boolean">
        <cfargument name="targetPage" type="string" required="true">
        <cfheader statuscode="404" statustext="Not Found">
        <cfset var homeUrl = (structKeyExists(session,"user") AND structKeyExists(session.user,"id") AND len(session.user.id)) ? "/members/planning-tools.cfm" : "/">
        <cfinclude template="error.cfm">
        <cfreturn true>
    </cffunction>

    <cffunction name="onError" returntype="void">
        <cfargument name="exception" required="true">
        <cfargument name="eventName" type="string" required="true">

        <cfset var isAjax = (CGI.HTTP_X_REQUESTED_WITH EQ "XMLHttpRequest")>

        <!--- Log via ErrorNotifier with 3-tier fallback (email -> plain email -> cflog) --->
        <cftry>
            <cfset var notifier = new services.ErrorNotifier()>
            <cfset notifier.notify(arguments.exception, "onError - event: " & arguments.eventName, CGI.SCRIPT_NAME)>
        <cfcatch type="any">
            <cftry>
                <cflog file="digitalweddings_errors" type="error"
                       text="[ON ERROR] PAGE=#CGI.SCRIPT_NAME# ERR=#arguments.exception.message# NOTIFIER_ERR=#cfcatch.message#">
            <cfcatch type="any"></cfcatch>
            </cftry>
        </cfcatch>
        </cftry>

        <!--- Never expose error details to users --->
        <cfif isAjax>
            <cfheader name="Content-Type" value="application/json">
            <cfset writeOutput('{"success":false,"message":"An error occurred. Please try again."}')>
        <cfelse>
            <cftry>
                <cflocation url="/error.cfm" addToken="false">
            <cfcatch type="any">
                <!--- cflocation failed (headers already sent) - output minimal safe page --->
                <cfheader statuscode="500" statustext="Internal Server Error">
                <cfset writeOutput('<!DOCTYPE html><html><head><meta charset="UTF-8"><meta http-equiv="refresh" content="0;url=/error.cfm"><title>Error</title></head><body></body></html>')>
            </cfcatch>
            </cftry>
        </cfif>
    </cffunction>

</cfcomponent>
