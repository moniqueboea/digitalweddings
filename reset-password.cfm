<cfset pageTitle = "Reset Password | digitalweddings.love">
<cfparam name="url.token" default="">
<cfparam name="form.token" default="">
<cfparam name="form.newPassword" default="">
<cfparam name="form.confirmPassword" default="">
<cfparam name="form.action" default="">
<cfset errorMsg = "">
<cfset successMsg = "">
<cfset rawToken = len(trim(form.token)) ? trim(form.token) : trim(url.token)>

<cfif !len(rawToken)>
    <cflocation url="/forgot-password.cfm" addToken="false">
</cfif>

<cfset tokenValid = false>
<cftry>
    <cfset tokenHash = hash(rawToken, "SHA-256")>
    <cfquery name="tokenCheck" datasource="#application.config.datasource#">
        SELECT token_id, user_id FROM dbo.PasswordResetTokens
        WHERE token_hash = <cfqueryparam value="#tokenHash#" cfsqltype="cf_sql_varchar">
          AND used_at IS NULL AND expires_at > SYSUTCDATETIME()
    </cfquery>
    <cfset tokenValid = tokenCheck.recordCount GT 0>
<cfcatch>
    <cfset tokenValid = false>
</cfcatch>
</cftry>

<cfif !tokenValid>
    <cfinclude template="includes/layout-start.cfm">
    <div class="auth-wrap">
        <div class="auth-box" style="text-align:center">
            <div class="auth-logo"><a href="/index.cfm">digitalweddings<span>.love</span></a></div>
            <h1 class="auth-title">Link Expired</h1>
            <div class="alert alert-error">This password reset link is invalid or has expired.</div>
            <a href="/forgot-password.cfm" class="btn btn-primary">Request New Link</a>
        </div>
    </div>
    <cfinclude template="includes/layout-end.cfm">
    <cfabort>
</cfif>

<cfif form.action EQ "reset">
    <cfif len(form.newPassword) LT 10>
        <cfset errorMsg = "Password must be at least 10 characters.">
    <cfelseif form.newPassword NEQ form.confirmPassword>
        <cfset errorMsg = "Passwords do not match.">
    <cfelse>
        <cftry>
            <cfset pwService = new services.PasswordService()>
            <cfset pwRecord = pwService.createHash(form.newPassword)>
            <cftransaction>
                <cfquery datasource="#application.config.datasource#">
                    UPDATE dbo.Users SET
                        password_hash = <cfqueryparam value="#pwRecord.hash#" cfsqltype="cf_sql_varchar">,
                        password_salt = <cfqueryparam value="#pwRecord.salt#" cfsqltype="cf_sql_varchar">,
                        password_iterations = <cfqueryparam value="#pwRecord.iterations#" cfsqltype="cf_sql_integer">,
                        password_algorithm = <cfqueryparam value="#pwRecord.algorithm#" cfsqltype="cf_sql_varchar">,
                        updated_at = SYSUTCDATETIME()
                    WHERE user_id = <cfqueryparam value="#tokenCheck.user_id#" cfsqltype="cf_sql_bigint">
                </cfquery>
                <cfquery datasource="#application.config.datasource#">
                    UPDATE dbo.PasswordResetTokens SET used_at = SYSUTCDATETIME()
                    WHERE user_id = <cfqueryparam value="#tokenCheck.user_id#" cfsqltype="cf_sql_bigint"> AND used_at IS NULL
                </cfquery>
            </cftransaction>
            <cfset structClear(session)>
            <cfset sessionInvalidate()>
            <cflocation url="/login.cfm?reset=1" addToken="false">
        <cfcatch>
            <cfset errorMsg = "An error occurred. Please try again.">
        </cfcatch>
        </cftry>
    </cfif>
</cfif>

<cfinclude template="includes/layout-start.cfm">
<div class="auth-wrap">
    <div class="auth-box">
        <div class="auth-logo"><a href="/index.cfm">digitalweddings<span>.love</span></a></div>
        <h1 class="auth-title">Reset Password</h1>
        <p class="auth-subtitle">Choose a new password for your account</p>
        <cfif len(errorMsg)><div class="alert alert-error"><cfoutput>#HTMLEditFormat(errorMsg)#</cfoutput></div></cfif>
        <form method="post" action="reset-password.cfm">
            <input type="hidden" name="action" value="reset">
            <input type="hidden" name="token" value="<cfoutput>#HTMLEditFormat(rawToken)#</cfoutput>">
            <div class="field">
                <label for="newPassword">New Password <span style="font-weight:400;text-transform:none;letter-spacing:0">(min. 10 characters)</span></label>
                <input type="password" id="newPassword" name="newPassword" required minlength="10" autocomplete="new-password">
            </div>
            <div class="field">
                <label for="confirmPassword">Confirm Password</label>
                <input type="password" id="confirmPassword" name="confirmPassword" required minlength="10" autocomplete="new-password">
            </div>
            <button type="submit" class="btn btn-primary btn-full">Reset Password</button>
        </form>
    </div>
</div>
<cfinclude template="includes/layout-end.cfm">
