<cfparam name="form.slug"               default="">
<cfparam name="form.guestEmail"          default="">
<cfparam name="form.rsvpStatus"          default="">
<cfparam name="form.plusOneName"         default="">
<cfparam name="form.dietaryRestrictions" default="">
<cfparam name="form.confirmUpdate"       default="">

<cfset slug       = trim(form.slug)>
<cfset guestEmail = lCase(trim(form.guestEmail))>
<cfset rsvpStatus = trim(form.rsvpStatus)>

<!--- Validate --->
<cfif !len(slug) OR !len(guestEmail) OR !len(rsvpStatus)>
    <cflocation url="/rsvp.cfm?slug=#URLEncodedFormat(slug)#&error=Please+fill+in+all+required+fields." addToken="false">
</cfif>

<!--- Get wedding site --->
<cfquery name="qSite" datasource="#application.config.datasource#">
    SELECT wedding_site_id, couple_name_1, couple_name_2, user_id, wedding_date, template
    FROM dbo.WeddingSites
    WHERE slug = <cfqueryparam value="#slug#" cfsqltype="cf_sql_varchar">
      AND published = 1
</cfquery>

<cfif !qSite.recordCount>
    <cflocation url="/rsvp.cfm?slug=#URLEncodedFormat(slug)#&error=Wedding+site+not+found." addToken="false">
</cfif>

<!--- Look up guest by email --->
<cfquery name="qGuest" datasource="#application.config.datasource#">
    SELECT guest_id, name, rsvp_status FROM dbo.Guests
    WHERE user_id = <cfqueryparam value="#qSite.user_id#" cfsqltype="cf_sql_bigint">
      AND email   = <cfqueryparam value="#guestEmail#"    cfsqltype="cf_sql_varchar">
</cfquery>

<!--- Not on the guest list --->
<cfif !qGuest.recordCount>
    <cflocation url="/rsvp.cfm?slug=#URLEncodedFormat(slug)#&error=notfound" addToken="false">
</cfif>

<!--- Already RSVPd — ask to confirm update unless they already confirmed --->
<cfif form.confirmUpdate NEQ "1" AND qGuest.rsvp_status NEQ "pending">
    <cflocation url="/rsvp.cfm?slug=#URLEncodedFormat(slug)#&alreadyrsvp=1&currentstatus=#URLEncodedFormat(qGuest.rsvp_status)#&email=#URLEncodedFormat(guestEmail)#" addToken="false">
</cfif>

<!--- Update RSVP --->
<cfquery datasource="#application.config.datasource#">
    UPDATE dbo.Guests SET
        rsvp_status          = <cfqueryparam value="#rsvpStatus#" cfsqltype="cf_sql_varchar">,
        plus_one_name        = <cfqueryparam value="#trim(form.plusOneName)#" cfsqltype="cf_sql_nvarchar" null="#!len(trim(form.plusOneName))#">,
        dietary_restrictions = <cfqueryparam value="#trim(form.dietaryRestrictions)#" cfsqltype="cf_sql_nvarchar" null="#!len(trim(form.dietaryRestrictions))#">,
        updated_at           = SYSUTCDATETIME()
    WHERE guest_id = <cfqueryparam value="#qGuest.guest_id#" cfsqltype="cf_sql_bigint">
</cfquery>

<!--- Get couple's email to notify them --->
<cfquery name="qUser" datasource="#application.config.datasource#">
    SELECT email FROM dbo.Users
    WHERE user_id = <cfqueryparam value="#qSite.user_id#" cfsqltype="cf_sql_bigint">
</cfquery>

<!--- Load theme from the couple's template (used by both emails) --->
<cfset qSiteForEmail = qSite>
<cfinclude template="members/email-theme-helper.cfm">

<!--- Send notification email to the couple --->
<cfif qUser.recordCount AND len(trim(qUser.email))>
    <cfset rsvpLabel = rsvpStatus EQ "attending" ? "Yes, attending" : (rsvpStatus EQ "declined" ? "Can't make it" : "Maybe")>
    <cftry>
        <cfmail to="#trim(qUser.email)#"
                from="#application.config.mailFrom#"
                replyto="#guestEmail#"
                subject="#HTMLEditFormat(qGuest.name)# just RSVPd to your wedding!"
                server="localhost"
                port="25"
                timeout="60"
                type="html">
            <cfoutput>
            <div style="font-family:#emailTheme.fontStack#;max-width:560px;margin:0 auto;padding:0;background:#emailTheme.bodyBg#">
                <!--- Header --->
                <div style="background:#emailTheme.headerBg#;padding:32px;text-align:center">
                    <p style="font-size:11px;letter-spacing:4px;text-transform:uppercase;color:#emailTheme.accentColor#;margin:0 0 10px;font-family:Arial,Helvetica,sans-serif">RSVP Notification</p>
                    <h1 style="margin:0;color:#emailTheme.headerText#;font-size:26px;font-weight:300;font-family:#emailTheme.headingFont#">#HTMLEditFormat(qGuest.name)# has responded!</h1>
                </div>
                <!--- Body --->
                <div style="background:#emailTheme.bodyCardBg#;padding:32px">
                    <table style="width:100%;border-collapse:collapse;margin-bottom:24px">
                        <tr>
                            <td style="padding:10px 14px;background:#emailTheme.bodyBg#;font-weight:600;color:#emailTheme.bodyText#;width:40%;border-bottom:1px solid #emailTheme.dividerColor#">Guest</td>
                            <td style="padding:10px 14px;background:#emailTheme.bodyBg#;color:#emailTheme.bodyText#;border-bottom:1px solid #emailTheme.dividerColor#">#HTMLEditFormat(qGuest.name)#</td>
                        </tr>
                        <tr>
                            <td style="padding:10px 14px;font-weight:600;color:#emailTheme.bodyText#;border-bottom:1px solid #emailTheme.dividerColor#">Response</td>
                            <td style="padding:10px 14px;color:#emailTheme.bodyText#;border-bottom:1px solid #emailTheme.dividerColor#"><strong>#HTMLEditFormat(rsvpLabel)#</strong></td>
                        </tr>
                        <cfif len(trim(form.plusOneName))>
                        <tr>
                            <td style="padding:10px 14px;font-weight:600;color:#emailTheme.bodyText#;border-bottom:1px solid #emailTheme.dividerColor#">Plus One</td>
                            <td style="padding:10px 14px;color:#emailTheme.bodyText#;border-bottom:1px solid #emailTheme.dividerColor#">#HTMLEditFormat(trim(form.plusOneName))#</td>
                        </tr>
                        </cfif>
                        <cfif len(trim(form.dietaryRestrictions))>
                        <tr>
                            <td style="padding:10px 14px;font-weight:600;color:#emailTheme.bodyText#">Dietary</td>
                            <td style="padding:10px 14px;color:#emailTheme.bodyText#">#HTMLEditFormat(trim(form.dietaryRestrictions))#</td>
                        </tr>
                        </cfif>
                    </table>
                    <p style="margin:0;font-size:13px;color:#emailTheme.mutedText#">
                        View all RSVPs at <a href="https://digitalweddings.love/members/guests.cfm" style="color:#emailTheme.accentColor#;text-decoration:none">digitalweddings.love</a>
                    </p>
                </div>
                <!--- Footer --->
                <div style="background:#emailTheme.bodyBg#;padding:16px 32px;text-align:center;border-top:1px solid #emailTheme.dividerColor#">
                    <p style="margin:0;font-size:12px;color:#emailTheme.mutedText#">Powered by <a href="https://digitalweddings.love" style="color:#emailTheme.accentColor#;text-decoration:none">digitalweddings.love</a></p>
                </div>
            </div>
            </cfoutput>
        </cfmail>
    <cfcatch>
        <cfset coupleMailError = cfcatch.message>
    </cfcatch>
    </cftry>
</cfif>

<!--- Send confirmation email to the guest --->
<cfset rsvpLabel = rsvpStatus EQ "attending" ? "Yes, I'll be there!" : (rsvpStatus EQ "declined" ? "Sorry, I can't make it" : "I'm not sure yet")>

<cftry>
    <cfmail to="#guestEmail#"
            from="#application.config.mailFrom#"
            replyto="#trim(qUser.email)#"
            bcc="#trim(qUser.email)#"
            subject="Your RSVP is confirmed - #HTMLEditFormat(qSite.couple_name_1)# and #HTMLEditFormat(qSite.couple_name_2)#"
            server="localhost"
            port="25"
            timeout="60"
            type="html">
        <cfoutput>
        <div style="font-family:#emailTheme.fontStack#;max-width:560px;margin:0 auto;padding:0;background:#emailTheme.bodyBg#">
            <!--- Header --->
            <div style="background:#emailTheme.headerBg#;padding:40px 32px;text-align:center">
                <p style="font-size:11px;letter-spacing:5px;text-transform:uppercase;color:#emailTheme.accentColor#;margin:0 0 12px;font-family:Arial,Helvetica,sans-serif">RSVP Confirmation</p>
                <h1 style="margin:0;color:#emailTheme.headerText#;font-size:32px;font-weight:300;letter-spacing:.02em;font-family:#emailTheme.headingFont#">#HTMLEditFormat(qSite.couple_name_1)# &amp; #HTMLEditFormat(qSite.couple_name_2)#</h1>
                <cfif len(qSite.wedding_date)>
                <p style="margin:12px 0 0;color:#emailTheme.accentColor#;font-size:13px;letter-spacing:.15em;text-transform:uppercase">#dateFormat(qSite.wedding_date,'mmmm d, yyyy')#</p>
                </cfif>
            </div>
            <!--- Body --->
            <div style="background:#emailTheme.bodyCardBg#;padding:36px 32px">
                <p style="font-size:16px;color:#emailTheme.bodyText#;margin:0 0 24px">Dear #HTMLEditFormat(qGuest.name)#,</p>
                <p style="color:#emailTheme.mutedText#;line-height:1.7;margin:0 0 24px">
                    Thank you! We&rsquo;ve received your RSVP. Here&rsquo;s a summary of your response:
                </p>
                <div style="background:#emailTheme.bodyBg#;border-radius:8px;padding:20px 24px;margin-bottom:24px;border:1px solid #emailTheme.dividerColor#">
                    <table style="width:100%;border-collapse:collapse">
                        <tr>
                            <td style="padding:8px 0;font-weight:600;color:#emailTheme.bodyText#;width:40%;border-bottom:1px solid #emailTheme.dividerColor#">Response</td>
                            <td style="padding:8px 0;color:#emailTheme.bodyText#;border-bottom:1px solid #emailTheme.dividerColor#"><strong>#HTMLEditFormat(rsvpLabel)#</strong></td>
                        </tr>
                        <cfif len(trim(form.plusOneName))>
                        <tr>
                            <td style="padding:8px 0;font-weight:600;color:#emailTheme.bodyText#;border-bottom:1px solid #emailTheme.dividerColor#">Plus One</td>
                            <td style="padding:8px 0;color:#emailTheme.bodyText#;border-bottom:1px solid #emailTheme.dividerColor#">#HTMLEditFormat(trim(form.plusOneName))#</td>
                        </tr>
                        </cfif>
                        <cfif len(trim(form.dietaryRestrictions))>
                        <tr>
                            <td style="padding:8px 0;font-weight:600;color:#emailTheme.bodyText#">Dietary</td>
                            <td style="padding:8px 0;color:#emailTheme.bodyText#">#HTMLEditFormat(trim(form.dietaryRestrictions))#</td>
                        </tr>
                        </cfif>
                    </table>
                </div>
                <p style="color:#emailTheme.mutedText#;line-height:1.7;margin:0 0 8px">
                    Need to make a change? Visit the wedding website to update your RSVP.
                </p>
                <p style="margin:0;font-size:13px;color:#emailTheme.mutedText#">
                    With love,<br>
                    <strong style="color:#emailTheme.bodyText#">#HTMLEditFormat(qSite.couple_name_1)# &amp; #HTMLEditFormat(qSite.couple_name_2)#</strong>
                </p>
            </div>
            <!--- Footer --->
            <div style="background:#emailTheme.bodyBg#;padding:16px 32px;text-align:center;border-top:1px solid #emailTheme.dividerColor#">
                <p style="margin:0;font-size:12px;color:#emailTheme.mutedText#">Powered by <a href="https://digitalweddings.love" style="color:#emailTheme.accentColor#;text-decoration:none">digitalweddings.love</a></p>
            </div>
        </div>
        </cfoutput>
    </cfmail>
<cfcatch><!--- swallow guest mail errors ---></cfcatch>
</cftry>

<cfif structKeyExists(variables,"coupleMailError") AND len(coupleMailError)>
    <cflocation url="/rsvp.cfm?slug=#URLEncodedFormat(slug)#&success=1&mailerr=#URLEncodedFormat(coupleMailError)#" addToken="false">
<cfelse>
    <cflocation url="/rsvp.cfm?slug=#URLEncodedFormat(slug)#&success=1" addToken="false">
</cfif>
