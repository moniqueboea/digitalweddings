<cfset pageTitle = "Create Account | digitalweddings.love">
<cfparam name="form.firstName" default="">
<cfparam name="form.lastName" default="">
<cfparam name="form.username" default="">
<cfparam name="form.email" default="">
<cfparam name="form.password" default="">
<cfparam name="form.action" default="">

<cfif structKeyExists(session, "user") && structKeyExists(session.user, "id")>
    <cflocation url="/planning-tools.cfm" addToken="false">
</cfif>

<cfset errorMsg = "">
<cfset successMsg = "">

<cfif form.action EQ "register">
    <cfset firstName = trim(form.firstName)>
    <cfset lastName = trim(form.lastName)>
    <cfset username = lCase(trim(form.username))>
    <cfset email = lCase(trim(form.email))>
    <cfset password = form.password>

    <cfif !len(firstName) || !len(lastName)>
        <cfset errorMsg = "First name and last name are required.">
    <cfelseif !reFind("^[a-z0-9][a-z0-9._-]{2,29}$", username)>
        <cfset errorMsg = "Username must be 3–30 characters using only letters, numbers, periods, underscores, or hyphens.">
    <cfelseif !isValid("email", email)>
        <cfset errorMsg = "Please enter a valid email address.">
    <cfelseif len(password) LT 10>
        <cfset errorMsg = "Password must be at least 10 characters.">
    <cfelse>
        <cftry>
            <cfquery name="existing" datasource="#application.config.datasource#">
                SELECT username, email FROM dbo.Users
                WHERE username = <cfqueryparam value="#username#" cfsqltype="cf_sql_varchar">
                   OR email = <cfqueryparam value="#email#" cfsqltype="cf_sql_varchar">
            </cfquery>

            <cfset conflict = "">
            <cfloop query="existing">
                <cfif existing.username EQ username><cfset conflict = "That username is already taken."></cfif>
                <cfif existing.email EQ email><cfset conflict = "An account already exists for this email address."></cfif>
            </cfloop>

            <cfif len(conflict)>
                <cfset errorMsg = conflict>
            <cfelse>
                <cfset pwService = new services.PasswordService()>
                <cfset pwRecord = pwService.createHash(password)>
                <cfset verService = new services.VerificationService()>
                <cfset verification = verService.createToken()>

                <cftransaction>
                    <cfquery name="inserted" datasource="#application.config.datasource#">
                        INSERT INTO dbo.Users
                            (username, first_name, last_name, email, password_hash, password_salt, password_iterations, password_algorithm, role, is_active, email_verified_at)
                        OUTPUT INSERTED.user_id
                        VALUES
                            (<cfqueryparam value="#username#" cfsqltype="cf_sql_varchar">,
                             <cfqueryparam value="#firstName#" cfsqltype="cf_sql_nvarchar">,
                             <cfqueryparam value="#lastName#" cfsqltype="cf_sql_nvarchar">,
                             <cfqueryparam value="#email#" cfsqltype="cf_sql_varchar">,
                             <cfqueryparam value="#pwRecord.hash#" cfsqltype="cf_sql_varchar">,
                             <cfqueryparam value="#pwRecord.salt#" cfsqltype="cf_sql_varchar">,
                             <cfqueryparam value="#pwRecord.iterations#" cfsqltype="cf_sql_integer">,
                             <cfqueryparam value="#pwRecord.algorithm#" cfsqltype="cf_sql_varchar">,
                             'user', 0, NULL)
                    </cfquery>
                    <cfset newUserId = inserted.user_id>
                    <cfquery datasource="#application.config.datasource#">
                        INSERT INTO dbo.EmailVerificationTokens (user_id, token_hash, expires_at)
                        VALUES (
                            <cfqueryparam value="#newUserId#" cfsqltype="cf_sql_bigint">,
                            <cfqueryparam value="#verification.hash#" cfsqltype="cf_sql_varchar">,
                            DATEADD(hour, <cfqueryparam value="#application.config.verificationTokenHours#" cfsqltype="cf_sql_integer">, SYSUTCDATETIME())
                        )
                    </cfquery>
                </cftransaction>

                <cfset verificationUrl = application.config.frontendUrl & "/verify-email.cfm?token=" & URLEncodedFormat(verification.raw)>
                <cftry>
                    <cfmail to="#email#"
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
    <h1 style="margin:0 0 8px;font-size:26px;color:##1a1a1a;font-family:Georgia,serif">Welcome, #HTMLEditFormat(firstName)#!</h1>
    <p style="margin:0 0 24px;font-size:13px;letter-spacing:3px;text-transform:uppercase;color:##C9A96A">One last step</p>
    <p style="margin:0 0 20px;font-size:16px;line-height:1.7;color:##444">Thank you for joining digitalweddings.love. Please verify your email address to activate your account and start planning your dream wedding.</p>
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

                <cfset successMsg = "Account created! Please check your email to verify your account before signing in.">
                <cfset form.firstName = ""><cfset form.lastName = "">
                <cfset form.username = ""><cfset form.email = ""><cfset form.password = "">
            </cfif>
        <cfcatch>
            <cfset errorMsg = "An error occurred. Please try again.">
        </cfcatch>
        </cftry>
    </cfif>
</cfif>

<cfinclude template="includes/layout-start.cfm">
<div class="auth-wrap">
    <div class="auth-box" style="max-width:500px">
        <div class="auth-logo">
            <a href="/index.cfm">digitalweddings<span>.love</span></a>
        </div>
        <h1 class="auth-title">Create your account</h1>
        <p class="auth-subtitle">Start planning your perfect wedding</p>

        <cfif len(errorMsg)>
            <div class="alert alert-error"><cfoutput>#HTMLEditFormat(errorMsg)#</cfoutput></div>
        </cfif>
        <cfif len(successMsg)>
            <div class="alert alert-success"><cfoutput>#HTMLEditFormat(successMsg)#</cfoutput></div>
        </cfif>

        <cfif !len(successMsg)>
        <form method="post" action="register.cfm">
            <input type="hidden" name="action" value="register">
            <div class="field-row">
                <div class="field">
                    <label for="firstName">First Name</label>
                    <input type="text" id="firstName" name="firstName" required value="<cfoutput>#HTMLEditFormat(form.firstName)#</cfoutput>">
                </div>
                <div class="field">
                    <label for="lastName">Last Name</label>
                    <input type="text" id="lastName" name="lastName" required value="<cfoutput>#HTMLEditFormat(form.lastName)#</cfoutput>">
                </div>
            </div>
            <div class="field">
                <label for="username">Username</label>
                <input type="text" id="username" name="username" required autocomplete="username" value="<cfoutput>#HTMLEditFormat(form.username)#</cfoutput>" placeholder="e.g. jasmine_and_david">
            </div>
            <div class="field">
                <label for="email">Email Address</label>
                <input type="email" id="email" name="email" required autocomplete="email" value="<cfoutput>#HTMLEditFormat(form.email)#</cfoutput>">
            </div>
            <div class="field">
                <label for="password">Password <span style="font-weight:400;text-transform:none;letter-spacing:0">(min. 10 characters)</span></label>
                <input type="password" id="password" name="password" required autocomplete="new-password" minlength="10">
            </div>
            <button type="submit" class="btn btn-primary btn-full">Create Account</button>
        </form>
        </cfif>

        <div class="auth-footer">
            Already have an account? <a href="/login.cfm">Sign in</a>
        </div>
    </div>
</div>
<cfinclude template="includes/layout-end.cfm">
