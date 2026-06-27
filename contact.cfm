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
                to="moniqueboea@gmail.com"
                from="noreply@digitalweddings.love"
                replyto="#trim(form.email)#"
                subject="New Contact Form Message"
                server="localhost"
                port="25"
                type="html"
                timeout="60">
                <h2>New Contact Form Submission</h2>
                <p><strong>Name:</strong> #HTMLEditFormat(form.name)#</p>
                <p><strong>Email:</strong> #HTMLEditFormat(form.email)#</p>
                <p><strong>Message:</strong></p>
                <p>#replace(HTMLEditFormat(form.message), chr(10), "<br>", "all")#</p>
            </cfmail>
            <cfset successMessage = "Thank you! Your message has been sent.">
            <cfset form.name    = "">
            <cfset form.email   = "">
            <cfset form.message = "">
        <cfcatch>
            <cfset errorMessage = "Could not send your message. Error: #HTMLEditFormat(cfcatch.message)#">
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
