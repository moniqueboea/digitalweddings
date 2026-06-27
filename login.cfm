<cfset pageTitle = "Sign In | digitalweddings.love">
<cfparam name="form.login" default="">
<cfparam name="form.password" default="">
<cfparam name="form.action" default="">
<cfparam name="url.redirect" default="">

<cfif structKeyExists(session, "user") && structKeyExists(session.user, "id")>
    <cflocation url="/members/planning-tools.cfm" addToken="false">
</cfif>

<cfset errorMsg = "">
<cfset successMsg = "">

<cfif structKeyExists(url, "verified") && url.verified EQ "1">
    <cfset successMsg = "Your email has been verified. You can now sign in.">
</cfif>
<cfif structKeyExists(url, "reset") && url.reset EQ "1">
    <cfset successMsg = "Your password has been reset. Please sign in.">
</cfif>

<cfif form.action EQ "login">
    <cfset loginVal = lCase(trim(form.login))>
    <cfset passwordVal = trim(form.password)>

    <cfif !len(loginVal) || !len(passwordVal)>
        <cfset errorMsg = "Please enter your username/email and password.">
    <cfelse>
        <cftry>
            <cfquery name="found" datasource="#application.config.datasource#">
                SELECT user_id, username, first_name, last_name, email,
                       password_hash, password_salt, password_iterations,
                       role, is_active, is_admin
                FROM dbo.Users
                WHERE email = <cfqueryparam value="#loginVal#" cfsqltype="cf_sql_varchar">
                   OR username = <cfqueryparam value="#loginVal#" cfsqltype="cf_sql_varchar">
            </cfquery>

            <cfset passwordMatches = false>
            <cfif found.recordCount>
                <cfset pwService = new services.PasswordService()>
                <cfset passwordMatches = pwService.verify(
                    passwordVal,
                    found.password_hash,
                    found.password_salt,
                    found.password_iterations
                )>
            </cfif>

            <cfif !found.recordCount || !passwordMatches>
                <cfset errorMsg = "Invalid username/email or password.">
            <cfelseif !found.is_active>
                <cfset errorMsg = "Please verify your email before signing in. <a href='/resend-verification.cfm'>Resend verification email</a>.">
            <cfelse>
                <cfquery datasource="#application.config.datasource#">
                    UPDATE dbo.Users SET last_login_at = SYSUTCDATETIME() WHERE user_id = <cfqueryparam value="#found.user_id#" cfsqltype="cf_sql_bigint">
                </cfquery>
                <cfset session.user = {
                    id: found.user_id,
                    username: found.username,
                    email: found.email,
                    first_name: found.first_name,
                    last_name: found.last_name,
                    full_name: trim(found.first_name & " " & found.last_name),
                    role: found.role,
                    is_admin: found.is_admin
                }>
                <cfif len(trim(url.redirect))>
                    <cflocation url="#url.redirect#" addToken="false">
                <cfelse>
                    <cflocation url="/members/planning-tools.cfm" addToken="false">
                </cfif>
            </cfif>
        <cfcatch>
            <cfset errorMsg = "An error occurred. Please try again.">
        </cfcatch>
        </cftry>
    </cfif>
</cfif>

<cfinclude template="includes/layout-start.cfm">
<div class="auth-wrap">
    <div class="auth-box">
        <div class="auth-logo">
            <a href="/index.cfm">digitalweddings<span>.love</span></a>
        </div>
        <h1 class="auth-title">Welcome back</h1>
        <p class="auth-subtitle">Sign in to your account</p>

        <cfif len(errorMsg)>
            <div class="alert alert-error"><cfoutput>#errorMsg#</cfoutput></div>
        </cfif>
        <cfif len(successMsg)>
            <div class="alert alert-success"><cfoutput>#HTMLEditFormat(successMsg)#</cfoutput></div>
        </cfif>

        <form method="post" action="login.cfm">
            <input type="hidden" name="action" value="login">
            <cfif len(trim(url.redirect))>
                <input type="hidden" name="redirect" value="<cfoutput>#HTMLEditFormat(url.redirect)#</cfoutput>">
            </cfif>
            <div class="field">
                <label for="login">Username or Email</label>
                <input type="text" id="login" name="login" autocomplete="username" required value="<cfoutput>#HTMLEditFormat(form.login)#</cfoutput>">
            </div>
            <div class="field">
                <label for="password">Password</label>
                <input type="password" id="password" name="password" autocomplete="current-password" required>
            </div>
            <div style="text-align:right;margin-bottom:20px">
                <a href="/forgot-password.cfm" style="font-size:13px">Forgot password?</a>
            </div>
            <button type="submit" class="btn btn-primary btn-full">Sign In</button>
        </form>

        <div class="auth-footer">
            Don't have an account? <a href="/register.cfm">Create one free</a>
        </div>
    </div>
</div>
<cfinclude template="includes/layout-end.cfm">
