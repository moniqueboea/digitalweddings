<cfset pageTitle = "Resend Verification | digitalweddings.love">
<cfparam name="form.email" default="">
<cfparam name="form.action" default="">
<cfset errorMsg = "">
<cfset successMsg = "">

<cfif form.action EQ "resend">
    <cfset email = lCase(trim(form.email))>
    <cfif !isValid("email", email)>
        <cfset errorMsg = "Please enter a valid email address.">
    <cfelse>
        <cftry>
            <cfquery name="found" datasource="#application.config.datasource#">
                SELECT user_id, first_name, email, is_active FROM dbo.Users
                WHERE email = <cfqueryparam value="#email#" cfsqltype="cf_sql_varchar">
            </cfquery>
            <cfif found.recordCount && !found.is_active>
                <cfquery name="recent" datasource="#application.config.datasource#">
                    SELECT TOP 1 token_id FROM dbo.EmailVerificationTokens
                    WHERE user_id = <cfqueryparam value="#found.user_id#" cfsqltype="cf_sql_bigint">
                      AND created_at > DATEADD(minute, -1, SYSUTCDATETIME())
                </cfquery>
                <cfif !recent.recordCount>
                    <cfset verService = new services.VerificationService()>
                    <cfset verification = verService.createToken()>
                    <cftransaction>
                        <cfquery datasource="#application.config.datasource#">
                            UPDATE dbo.EmailVerificationTokens SET used_at = SYSUTCDATETIME()
                            WHERE user_id = <cfqueryparam value="#found.user_id#" cfsqltype="cf_sql_bigint"> AND used_at IS NULL
                        </cfquery>
                        <cfquery datasource="#application.config.datasource#">
                            INSERT INTO dbo.EmailVerificationTokens (user_id, token_hash, expires_at)
                            VALUES (
                                <cfqueryparam value="#found.user_id#" cfsqltype="cf_sql_bigint">,
                                <cfqueryparam value="#verification.hash#" cfsqltype="cf_sql_varchar">,
                                DATEADD(hour, <cfqueryparam value="#application.config.verificationTokenHours#" cfsqltype="cf_sql_integer">, SYSUTCDATETIME())
                            )
                        </cfquery>
                    </cftransaction>
                    <cfset verificationUrl = application.config.frontendUrl & "/verify-email.cfm?token=" & URLEncodedFormat(verification.raw)>
                    <cftry>
                        <cfmail to="#found.email#"
                                from="#application.config.mailFromName# <#application.config.mailFrom#>"
                                subject="Verify your digitalweddings.love account"
                                type="html" server="localhost" port="25" timeout="60">
<!DOCTYPE html><html lang="en"><head><meta charset="UTF-8"></head>
<body style="margin:0;padding:0;background-color:##F6F4EF;font-family:Georgia,serif">
<table width="100%" cellpadding="0" cellspacing="0" style="background-color:##F6F4EF;padding:40px 16px">
<tr><td align="center"><table width="100%" cellpadding="0" cellspacing="0" style="max-width:580px">
  <tr><td style="background-color:##1a1a1a;padding:28px 40px;text-align:center;border-radius:8px 8px 0 0">
    <p style="margin:0 0 4px;font-size:11px;letter-spacing:4px;text-transform:uppercase;color:##C9A96A;font-family:Arial,sans-serif">Celebrating Love</p>
    <p style="margin:0;font-size:22px;color:##ffffff;font-family:Georgia,serif">digitalweddings<span style="color:##C9A96A">.love</span></p>
  </td></tr>
  <tr><td style="background-color:##C9A96A;height:3px;font-size:0;line-height:0">&nbsp;</td></tr>
  <tr><td style="background-color:##ffffff;padding:44px 48px;border-radius:0 0 8px 8px;font-family:Arial,sans-serif">
    <h1 style="margin:0 0 8px;font-size:26px;color:##1a1a1a;font-family:Georgia,serif">Welcome, #HTMLEditFormat(found.first_name)#!</h1>
    <p style="margin:0 0 24px;font-size:13px;letter-spacing:3px;text-transform:uppercase;color:##C9A96A">One last step</p>
    <p style="margin:0 0 20px;font-size:16px;line-height:1.7;color:##444">Please verify your email address to activate your digitalweddings.love account.</p>
    <table width="100%" cellpadding="0" cellspacing="0" style="margin:32px 0">
      <tr><td align="center">
        <a href="#HTMLEditFormat(verificationUrl)#" style="display:inline-block;background-color:##7A9E7E;color:##ffffff;text-decoration:none;padding:16px 40px;border-radius:4px;font-size:14px;font-weight:bold;letter-spacing:1px;text-transform:uppercase">Verify My Email</a>
      </td></tr>
    </table>
    <p style="margin:0 0 8px;font-size:13px;color:##888;text-align:center">This link expires in #application.config.verificationTokenHours# hours.</p>
    <p style="margin:24px 0 0;font-size:12px;color:##aaa;text-align:center">Or copy and paste this link:<br><span style="color:##C9A96A;word-break:break-all">#HTMLEditFormat(verificationUrl)#</span></p>
    <table width="100%" cellpadding="0" cellspacing="0" style="margin-top:36px">
      <tr><td style="border-top:1px solid ##e7e1d7;padding-top:24px;text-align:center">
        <p style="margin:0;font-size:11px;color:##999">&copy; digitalweddings.love &mdash; Celebrating Love</p>
      </td></tr>
    </table>
  </td></tr>
</table></td></tr></table>
</body></html>
                        </cfmail>
                    <cfcatch></cfcatch>
                    </cftry>
                </cfif>
            </cfif>
            <cfset successMsg = "If an unverified account exists for that email, a new verification link has been sent.">
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
        <h1 class="auth-title">Resend Verification</h1>
        <p class="auth-subtitle">Enter your email to receive a new verification link</p>
        <cfif len(errorMsg)><div class="alert alert-error"><cfoutput>#HTMLEditFormat(errorMsg)#</cfoutput></div></cfif>
        <cfif len(successMsg)><div class="alert alert-success"><cfoutput>#HTMLEditFormat(successMsg)#</cfoutput></div></cfif>
        <cfif !len(successMsg)>
        <form method="post" action="resend-verification.cfm">
            <input type="hidden" name="action" value="resend">
            <div class="field">
                <label for="email">Email Address</label>
                <input type="email" id="email" name="email" required value="<cfoutput>#HTMLEditFormat(form.email)#</cfoutput>">
            </div>
            <button type="submit" class="btn btn-primary btn-full">Send Verification Email</button>
        </form>
        </cfif>
        <div class="auth-footer"><a href="/login.cfm">Back to Sign In</a></div>
    </div>
</div>
<cfinclude template="includes/layout-end.cfm">
