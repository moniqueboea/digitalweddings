<cfset pageTitle = "Contact | digitalweddings.love">
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
                from="noreply@digitalweddings.love"
                replyto="#trim(form.email)#"
                subject="New Contact Form Message from #HTMLEditFormat(trim(form.name))#"
                server="localhost"
                port="25"
                type="html"
                timeout="60">
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>New Contact Message</title>
</head>
<body style="margin:0;padding:0;background-color:##F5F0E8;font-family:Georgia,serif;-webkit-text-size-adjust:100%">

<table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0" style="background:##F5F0E8">
<tr><td align="center" style="padding:40px 12px">
<table role="presentation" width="600" cellpadding="0" cellspacing="0" border="0" style="max-width:600px;width:100%">

  <!--- Header --->
  <tr><td align="center" style="background:##1a1a1a;padding:36px 40px 28px;border-radius:12px 12px 0 0">
    <p style="margin:0 0 8px 0;color:##B8860B;font-size:10px;letter-spacing:5px;text-transform:uppercase;font-family:Arial,Helvetica,sans-serif">
      DigitalWeddings.Love
    </p>
    <h1 style="margin:0;color:##FDFAF5;font-family:Georgia,serif;font-size:28px;font-weight:400;line-height:1.2">
      New Contact Message
    </h1>
    <table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0" style="margin-top:20px">
    <tr>
      <td style="height:1px;background-color:##B8860B;opacity:0.4;font-size:0;line-height:0">&nbsp;</td>
      <td width="32" align="center" style="color:##B8860B;font-size:14px;padding:0 10px;line-height:1;font-family:Georgia,serif">&##10022;</td>
      <td style="height:1px;background-color:##B8860B;opacity:0.4;font-size:0;line-height:0">&nbsp;</td>
    </tr>
    </table>
  </td></tr>

  <!--- Body --->
  <tr><td style="background:##FDFAF5;padding:40px 48px;border-radius:0 0 12px 12px">

    <!--- Sender info --->
    <table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0" style="margin-bottom:28px;border:1px solid ##E8E0D0;border-radius:8px;overflow:hidden">
      <tr>
        <td width="120" style="background:##F5F0E8;padding:14px 18px;font-family:Arial,Helvetica,sans-serif;font-size:11px;font-weight:700;letter-spacing:2px;text-transform:uppercase;color:##888;vertical-align:top">Name</td>
        <td style="background:##FDFAF5;padding:14px 18px;font-family:Georgia,serif;font-size:16px;color:##1a1a1a;vertical-align:top">#HTMLEditFormat(trim(form.name))#</td>
      </tr>
      <tr>
        <td width="120" style="background:##F5F0E8;padding:14px 18px;font-family:Arial,Helvetica,sans-serif;font-size:11px;font-weight:700;letter-spacing:2px;text-transform:uppercase;color:##888;border-top:1px solid ##E8E0D0;vertical-align:top">Email</td>
        <td style="background:##FDFAF5;padding:14px 18px;font-family:Georgia,serif;font-size:16px;color:##1a1a1a;border-top:1px solid ##E8E0D0;vertical-align:top">
          <a href="mailto:#HTMLEditFormat(trim(form.email))#" style="color:##B8860B;text-decoration:none">#HTMLEditFormat(trim(form.email))#</a>
        </td>
      </tr>
    </table>

    <!--- Message --->
    <p style="margin:0 0 10px 0;font-family:Arial,Helvetica,sans-serif;font-size:11px;font-weight:700;letter-spacing:2px;text-transform:uppercase;color:##888">Message</p>
    <div style="background:##F5F0E8;border-left:3px solid ##B8860B;border-radius:0 6px 6px 0;padding:20px 24px;margin-bottom:32px">
      <p style="margin:0;font-family:Georgia,serif;font-size:16px;line-height:1.8;color:##2C2C2C;white-space:pre-line">#HTMLEditFormat(trim(form.message))#</p>
    </div>

    <!--- Reply button --->
    <table role="presentation" cellpadding="0" cellspacing="0" border="0" style="margin:0 auto">
    <tr><td align="center" style="border-radius:6px;background:##B8860B">
      <a href="mailto:#HTMLEditFormat(trim(form.email))#"
         style="display:inline-block;padding:14px 40px;background:##B8860B;color:##fff;font-family:Arial,Helvetica,sans-serif;font-size:13px;font-weight:700;letter-spacing:2px;text-transform:uppercase;text-decoration:none;border-radius:6px">
        Reply to #HTMLEditFormat(trim(form.name))#
      </a>
    </td></tr>
    </table>

  </td></tr>

  <!--- Footer --->
  <tr><td align="center" style="padding:24px 0 0">
    <p style="margin:0;font-family:Arial,Helvetica,sans-serif;font-size:11px;color:##aaa;letter-spacing:1px">
      DigitalWeddings.Love &nbsp;&bull;&nbsp; Contact Form Submission
    </p>
  </td></tr>

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
            <cflog file="digitalweddings_errors" type="error" text="contact.cfm mail failed: #cfcatch.message#">
            <cfset errorMessage = "Could not send your message. Please try again or email us directly at contact@digitalweddings.love">
        </cfcatch>
        </cftry>
    </cfif>

</cfif>

<cfinclude template="includes/layout-start.cfm">
<section style="padding:60px 0">
    <div class="container" style="max-width:640px">

        <div class="page-header">
            <p class="eyebrow">Get in Touch</p>
            <h1>Contact <span class="script">Us</span></h1>
            <p style="color:var(--text-muted);margin-top:8px">Have a question or feedback? We'd love to hear from you.</p>
        </div>

        <cfif len(successMessage)>
            <div class="alert alert-success" style="margin-bottom:24px"><cfoutput>#HTMLEditFormat(successMessage)#</cfoutput></div>
        </cfif>
        <cfif len(errorMessage)>
            <div class="alert alert-error" style="margin-bottom:24px"><cfoutput>#HTMLEditFormat(errorMessage)#</cfoutput></div>
        </cfif>

        <div class="panel">
            <form method="post" action="<cfoutput>#CGI.SCRIPT_NAME#</cfoutput>">
                <input type="hidden" name="submitted" value="1">

                <div class="field">
                    <label>Name</label>
                    <input type="text" name="name" value="<cfoutput>#HTMLEditFormat(form.name)#</cfoutput>" placeholder="Your full name" required>
                </div>

                <div class="field">
                    <label>Email</label>
                    <input type="email" name="email" value="<cfoutput>#HTMLEditFormat(form.email)#</cfoutput>" placeholder="your@email.com" required>
                </div>

                <div class="field">
                    <label>Message</label>
                    <textarea name="message" rows="6" placeholder="What's on your mind?" style="width:100%;resize:vertical"><cfoutput>#HTMLEditFormat(form.message)#</cfoutput></textarea>
                </div>

                <button type="submit" class="btn btn-primary">Send Message</button>
            </form>
        </div>

    </div>
</section>
<cfinclude template="includes/layout-end.cfm">
