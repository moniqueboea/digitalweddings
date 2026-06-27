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
        }
    }>

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

    <cffunction name="onError" returntype="void">
        <cfargument name="exception" required="true">
        <cfargument name="eventName" type="string" required="true">

        <cfset var isAjax = (CGI.HTTP_X_REQUESTED_WITH EQ "XMLHttpRequest")>

        <!--- Delegate to ErrorNotifier for full diagnostic email with 3-tier fallback --->
        <cftry>
            <cfset var notifier = new services.ErrorNotifier()>
            <cfset notifier.notify(arguments.exception, "Application.cfc onError - event: " & arguments.eventName, CGI.SCRIPT_NAME)>
        <cfcatch>
            <!--- ErrorNotifier itself failed — last-resort cflog, wrapped so it can't propagate --->
            <cftry>
                <cflog file="digitalweddings_errors" type="error"
                       text="[ON ERROR] ErrorNotifier failed. PAGE=#CGI.SCRIPT_NAME# ERR=#arguments.exception.message# NOTIFIER_ERR=#cfcatch.message#">
            <cfcatch></cfcatch>
            </cftry>
        </cfcatch>
        </cftry>

        <!--- Return JSON for AJAX, friendly page for regular requests --->
        <cfif isAjax>
            <cfheader name="Content-Type" value="application/json">
            <cfset writeOutput('{"success":false,"message":"An error occurred. Please try again."}')>
        <cfelse>
            <cfheader statuscode="500" statustext="Internal Server Error">
            <cfset writeOutput('<!DOCTYPE html><html><head><meta charset="UTF-8"><title>Something went wrong</title><style>body{margin:0;font-family:Georgia,serif;background:##FDFAF5;color:##2C2C2C;display:flex;align-items:center;justify-content:center;min-height:100vh;text-align:center;padding:40px}h1{color:##B8860B;margin-bottom:16px}p{opacity:.7;margin-bottom:24px}a{color:##B8860B}</style></head><body><div><h1>Something went wrong</h1><p>We have been notified and are working to fix it. Please try again in a moment.</p><a href="/index.cfm">Return Home</a></div></body></html>')>
        </cfif>
    </cffunction>

</cfcomponent>
