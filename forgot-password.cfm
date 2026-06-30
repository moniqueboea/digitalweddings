<cfset pageTitle = "Forgot Password | digitalweddings.love">
<cfparam name="form.email" default="">
<cfparam name="form.action" default="">
<cfset errorMsg = "">
<cfset successMsg = "">

<cfif form.action EQ "forgot">
    <cfset email = lCase(trim(form.email))>
    <cfif !isValid("email", email)>
        <cfset errorMsg = "Please enter a valid email address.">
    <cfelse>
        <cftry>
            <cfquery name="found" datasource="#application.config.datasource#">
                SELECT user_id, first_name, email, is_active FROM dbo.Users
                WHERE email = <cfqueryparam value="#email#" cfsqltype="cf_sql_varchar">
            </cfquery>
            <cfif found.recordCount && found.is_active>
                <cfquery name="recent" datasource="#application.config.datasource#">
                    SELECT TOP 1 token_id FROM dbo.PasswordResetTokens
                    WHERE user_id = <cfqueryparam value="#found.user_id#" cfsqltype="cf_sql_bigint">
                      AND created_at > DATEADD(minute, -1, SYSUTCDATETIME())
                </cfquery>
                <cfif !recent.recordCount>
                    <cfset verService = new services.VerificationService()>
                    <cfset resetToken = verService.createToken()>
                    <cftransaction>
                        <cfquery datasource="#application.config.datasource#">
                            UPDATE dbo.PasswordResetTokens SET used_at = SYSUTCDATETIME()
                            WHERE user_id = <cfqueryparam value="#found.user_id#" cfsqltype="cf_sql_bigint"> AND used_at IS NULL
                        </cfquery>
                        <cfquery datasource="#application.config.datasource#">
                            INSERT INTO dbo.PasswordResetTokens (user_id, token_hash, expires_at)
                            VALUES (
                                <cfqueryparam value="#found.user_id#" cfsqltype="cf_sql_bigint">,
                                <cfqueryparam value="#resetToken.hash#" cfsqltype="cf_sql_varchar">,
                                DATEADD(hour, <cfqueryparam value="#application.config.passwordResetTokenHours#" cfsqltype="cf_sql_integer">, SYSUTCDATETIME())
                            )
                        </cfquery>
                    </cftransaction>
                    <cftry>
                        <cfset emailService = new services.EmailService()>
                        <cfset emailService.sendPasswordResetEmail(found.email, found.first_name, resetToken.raw)>
                    <cfcatch></cfcatch>
                    </cftry>
                </cfif>
            </cfif>
            <cfset successMsg = "If an account exists for that email, a password reset link has been sent.">
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
        <h1 class="auth-title">Forgot Password</h1>
        <p class="auth-subtitle">Enter your email and we'll send you a reset link</p>
        <cfif len(errorMsg)><div class="alert alert-error"><cfoutput>#encodeForHTML(errorMsg)#</cfoutput></div></cfif>
        <cfif len(successMsg)><div class="alert alert-success"><cfoutput>#encodeForHTML(successMsg)#</cfoutput></div></cfif>
        <cfif !len(successMsg)>
        <form method="post" action="forgot-password.cfm">
            <input type="hidden" name="action" value="forgot">
            <div class="field">
                <label for="email">Email Address</label>
                <input type="email" id="email" name="email" required value="<cfoutput>#encodeForHTMLAttribute(form.email)#</cfoutput>">
            </div>
            <button type="submit" class="btn btn-primary btn-full">Send Reset Link</button>
        </form>
        </cfif>
        <div class="auth-footer"><a href="/login.cfm">Back to Sign In</a></div>
    </div>
</div>
<cfinclude template="includes/layout-end.cfm">
