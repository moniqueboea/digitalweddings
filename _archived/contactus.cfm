<cfset pageTitle = "Contact Us | digitalweddings.love">
<cfset activePage = "contact">

<cfparam name="form.name"      default="">
<cfparam name="form.email"     default="">
<cfparam name="form.message"   default="">
<cfparam name="form.submitted" default="0">

<cfset successMessage = "">
<cfset errorMessage   = "">

<cfif form.submitted EQ "1">
    <cfif NOT len(trim(form.name))>
        <cfset errorMessage = "Please enter your name.">
    <cfelseif NOT len(trim(form.email))>
        <cfset errorMessage = "Please enter your email address.">
    <cfelseif NOT isValid("email", trim(form.email))>
        <cfset errorMessage = "Please enter a valid email address.">
    <cfelseif NOT len(trim(form.message))>
        <cfset errorMessage = "Please enter a message.">
    <cfelse>
        <cftry>
            <cfmail
                to="contact@digitalweddings.love"
                from="contact@digitalweddings.love"
                replyto="#trim(form.email)#"
                subject="New Contact Message from #HTMLEditFormat(form.name)#"
                server="localhost"
                port="25"
                type="html"
                timeout="60">
<!DOCTYPE html>
<html lang="en">
<head><meta charset="UTF-8"></head>
<body style="margin:0;padding:0;background-color:##F5EDD8;font-family:Georgia,serif">
<table width="100%" cellpadding="0" cellspacing="0" style="background-color:##F5EDD8;padding:40px 16px">
  <tr><td align="center">
    <table width="100%" cellpadding="0" cellspacing="0" style="max-width:580px">
      <tr>
        <td style="background-color:##1a1a1a;padding:28px 40px;text-align:center;border-radius:8px 8px 0 0">
          <p style="margin:0 0 4px;font-size:11px;letter-spacing:4px;text-transform:uppercase;color:##b68a35">Celebrating Love</p>
          <p style="margin:0;font-size:22px;color:##ffffff;font-family:Georgia,serif">digitalweddings<span style="color:##C9A96A">.love</span></p>
        </td>
      </tr>
      <tr><td style="background-color:##b68a35;height:3px;font-size:0;line-height:0">&nbsp;</td></tr>
      <tr>
        <td style="background-color:##ffffff;padding:44px 48px;border-radius:0 0 8px 8px;font-family:Arial,sans-serif">
          <h1 style="margin:0 0 8px;font-size:24px;color:##1a1a1a;font-family:Georgia,serif">New Contact Message</h1>
          <p style="margin:0 0 28px;font-size:13px;letter-spacing:3px;text-transform:uppercase;color:##b68a35">Via digitalweddings.love</p>
          <table width="100%" cellpadding="0" cellspacing="0">
            <tr>
              <td style="padding:12px 16px;background:##faf8f4;border-left:3px solid ##b68a35;margin-bottom:12px">
                <p style="margin:0 0 4px;font-size:11px;text-transform:uppercase;letter-spacing:2px;color:##999">From</p>
                <p style="margin:0;font-size:16px;color:##1a1a1a;font-weight:bold">#HTMLEditFormat(form.name)#</p>
              </td>
            </tr>
            <tr><td style="height:10px"></td></tr>
            <tr>
              <td style="padding:12px 16px;background:##faf8f4;border-left:3px solid ##b68a35">
                <p style="margin:0 0 4px;font-size:11px;text-transform:uppercase;letter-spacing:2px;color:##999">Email</p>
                <p style="margin:0;font-size:16px;color:##b68a35"><a href="mailto:#HTMLEditFormat(form.email)#" style="color:##b68a35;text-decoration:none">#HTMLEditFormat(form.email)#</a></p>
              </td>
            </tr>
            <tr><td style="height:10px"></td></tr>
            <tr>
              <td style="padding:12px 16px;background:##faf8f4;border-left:3px solid ##b68a35">
                <p style="margin:0 0 8px;font-size:11px;text-transform:uppercase;letter-spacing:2px;color:##999">Message</p>
                <p style="margin:0;font-size:15px;line-height:1.7;color:##333">#replace(HTMLEditFormat(form.message), chr(10), "<br>", "all")#</p>
              </td>
            </tr>
          </table>
          <table width="100%" cellpadding="0" cellspacing="0" style="margin-top:36px">
            <tr><td style="border-top:1px solid ##e7e1d7;padding-top:24px;text-align:center">
              <p style="margin:0;font-size:11px;color:##999">&copy; digitalweddings.love &mdash; Celebrating Love</p>
            </td></tr>
          </table>
        </td>
      </tr>
    </table>
  </td></tr>
</table>
</body>
</html>
            </cfmail>
            <cfset successMessage = "Thank you! Your message has been sent.">
            <cfset form.name    = "">
            <cfset form.email   = "">
            <cfset form.message = "">
        <cfcatch>
            <cfset errorMessage = "Could not send your message. Please try again.">
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
        <h1 class="auth-title">Contact Us</h1>
        <p class="auth-subtitle">Have a question or feedback? We&rsquo;d love to hear from you.</p>

        <cfif len(successMessage)>
            <div class="alert alert-success"><cfoutput>#HTMLEditFormat(successMessage)#</cfoutput></div>
        </cfif>
        <cfif len(errorMessage)>
            <div class="alert alert-error"><cfoutput>#HTMLEditFormat(errorMessage)#</cfoutput></div>
        </cfif>

        <form method="post" action="contactus.cfm">
            <input type="hidden" name="submitted" value="1">
            <div class="field">
                <label for="name">Name</label>
                <input type="text" id="name" name="name" required value="<cfoutput>#HTMLEditFormat(form.name)#</cfoutput>">
            </div>
            <div class="field">
                <label for="email">Email</label>
                <input type="email" id="email" name="email" required value="<cfoutput>#HTMLEditFormat(form.email)#</cfoutput>">
            </div>
            <div class="field">
                <label for="message">Message</label>
                <textarea id="message" name="message" rows="6" style="width:100%;resize:vertical"><cfoutput>#HTMLEditFormat(form.message)#</cfoutput></textarea>
            </div>
            <button type="submit" class="btn btn-primary btn-full">Send Message</button>
        </form>

        <div class="auth-footer">
            <a href="/index.cfm">Return Home</a>
        </div>
    </div>
</div>
<cfinclude template="includes/layout-end.cfm">
