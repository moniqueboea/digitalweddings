<cfset pageTitle = "Verify Email | digitalweddings.love">
<cfparam name="url.token" default="">
<cfset errorMsg = "">
<cfset successMsg = "">

<cfif len(trim(url.token))>
    <cftry>
        <cfset tokenHash = hash(trim(url.token), "SHA-256")>
        <cfquery name="found" datasource="#application.config.datasource#">
            SELECT token_id, user_id FROM dbo.EmailVerificationTokens
            WHERE token_hash = <cfqueryparam value="#tokenHash#" cfsqltype="cf_sql_varchar">
              AND used_at IS NULL
              AND expires_at > SYSUTCDATETIME()
        </cfquery>
        <cfif !found.recordCount>
            <cfset errorMsg = "This verification link is invalid or has expired.">
        <cfelse>
            <cftransaction>
                <cfquery datasource="#application.config.datasource#">
                    UPDATE dbo.Users SET is_active = 1, email_verified_at = SYSUTCDATETIME(), updated_at = SYSUTCDATETIME()
                    WHERE user_id = <cfqueryparam value="#found.user_id#" cfsqltype="cf_sql_bigint">
                </cfquery>
                <cfquery datasource="#application.config.datasource#">
                    UPDATE dbo.EmailVerificationTokens SET used_at = SYSUTCDATETIME()
                    WHERE user_id = <cfqueryparam value="#found.user_id#" cfsqltype="cf_sql_bigint"> AND used_at IS NULL
                </cfquery>
            </cftransaction>
            <cflocation url="/login.cfm?verified=1" addToken="false">
        </cfif>
    <cfcatch>
        <cfset errorMsg = "An error occurred. Please try again.">
    </cfcatch>
    </cftry>
<cfelse>
    <cfset errorMsg = "No verification token provided.">
</cfif>

<cfinclude template="includes/layout-start.cfm">
<div class="auth-wrap">
    <div class="auth-box" style="text-align:center">
        <div class="auth-logo"><a href="/index.cfm">digitalweddings<span>.love</span></a></div>
        <cfif len(errorMsg)>
            <div style="font-size:48px;margin-bottom:16px">&#10060;</div>
            <h1 class="auth-title">Verification Failed</h1>
            <div class="alert alert-error" style="text-align:left"><cfoutput>#HTMLEditFormat(errorMsg)#</cfoutput></div>
            <a href="/resend-verification.cfm" class="btn btn-outline">Resend Verification Email</a>
        </cfif>
    </div>
</div>
<cfinclude template="includes/layout-end.cfm">
