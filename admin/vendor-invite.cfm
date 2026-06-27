<cfinclude template="admin-check.cfm">

<cfset pageTitle   = "Vendor Invite | Admin">
<cfset activePage  = "admin">
<cfparam name="form.action"          default="">
<cfparam name="form.vendorName"      default="">
<cfparam name="form.vendorEmail"     default="">
<cfparam name="form.vendorCategory"  default="">
<cfparam name="form.vendorWebsite"   default="">
<cfparam name="form.vendorInstagram" default="">
<cfparam name="form.vendorFacebook"  default="">
<cfparam name="form.personalMessage" default="">
<cfparam name="url.sent"             default="">
<cfparam name="url.preview"          default="">
<cfparam name="url.error"            default="">

<cfset registerLink = "https://digitalweddings.love/register-vendor-complimentary.cfm">
<cfset categories   = ["Photography","Videography","Catering","Florist","DJ / Music","Band / Entertainment","Hair & Makeup","Wedding Planner / Coordinator","Venue","Cake / Desserts","Transportation","Officiant","Jewelry","Attire / Fashion","Decor / Rentals","Stationery","Other"]>

<!--- ── SEND PREVIEW ── --->
<cfif form.action EQ "preview">
    <cfif !isValid("email", trim(form.vendorEmail)) AND !len(trim(form.vendorName))>
        <cflocation url="vendor-invite.cfm?error=missing" addToken="false">
    </cfif>
    <cfset vendorName      = len(trim(form.vendorName)) ? trim(form.vendorName) : "Valued Vendor">
    <cfset vendorCategory  = trim(form.vendorCategory)>
    <cfset personalMessage = trim(form.personalMessage)>
    <cfset previewRedirect = "vendor-invite.cfm?error=mailfail">
    <cftry>
        <cfmail to="#session.user.email#"
                from="#application.config.mailFrom#"
                replyto="#session.user.email#"
                subject="[PREVIEW] You are invited to join digitalweddings.love!"
                server="localhost"
                port="25"
                timeout="60"
                type="html"><cfinclude template="email-vendor-invite-body.cfm"></cfmail>
        <cfset previewRedirect = "vendor-invite.cfm?preview=1">
    <cfcatch>
        <cfset previewRedirect = "vendor-invite.cfm?error=mailfail">
    </cfcatch>
    </cftry>
    <cflocation url="#previewRedirect#" addToken="false">
</cfif>

<!--- ── SEND INVITE ── --->
<cfif form.action EQ "send">
    <cfif !len(trim(form.vendorName)) OR !isValid("email", trim(form.vendorEmail))>
        <cflocation url="vendor-invite.cfm?error=missing" addToken="false">
    </cfif>

    <cfset vendorName      = trim(form.vendorName)>
    <cfset vendorEmail     = lCase(trim(form.vendorEmail))>
    <cfset vendorCategory  = trim(form.vendorCategory)>
    <cfset vendorWebsite   = trim(form.vendorWebsite)>
    <cfset vendorInstagram = trim(form.vendorInstagram)>
    <cfset vendorFacebook  = trim(form.vendorFacebook)>
    <cfset personalMessage = trim(form.personalMessage)>

    <!--- Upsert complimentary record so they can register with this email --->
    <cfquery name="qExisting" datasource="#application.config.datasource#">
        SELECT vendor_id FROM dbo.Vendors
        WHERE email = <cfqueryparam value="#vendorEmail#" cfsqltype="cf_sql_varchar">
    </cfquery>
    <cfif qExisting.recordCount>
        <cfquery datasource="#application.config.datasource#">
            UPDATE dbo.Vendors SET
                business_name  = <cfqueryparam value="#vendorName#"     cfsqltype="cf_sql_nvarchar">,
                category       = <cfqueryparam value="#vendorCategory#" cfsqltype="cf_sql_nvarchar" null="#!len(vendorCategory)#">,
                complimentary  = 1,
                status         = 'pending',
                updated_at     = SYSUTCDATETIME()
            WHERE vendor_id = <cfqueryparam value="#qExisting.vendor_id#" cfsqltype="cf_sql_bigint">
        </cfquery>
    <cfelse>
        <cfquery datasource="#application.config.datasource#">
            INSERT INTO dbo.Vendors (business_name, email, category, complimentary, status, description, location)
            VALUES (
                <cfqueryparam value="#vendorName#"     cfsqltype="cf_sql_nvarchar">,
                <cfqueryparam value="#vendorEmail#"    cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#vendorCategory#" cfsqltype="cf_sql_nvarchar" null="#!len(vendorCategory)#">,
                1,
                'pending',
                <cfqueryparam value="" cfsqltype="cf_sql_nvarchar">,
                <cfqueryparam value="" cfsqltype="cf_sql_nvarchar">
            )
        </cfquery>
    </cfif>

    <cfset sendRedirect = "vendor-invite.cfm?error=mailfail">
    <cftry>
        <cfmail to="#vendorEmail#"
                from="#application.config.mailFrom#"
                replyto="#session.user.email#"
                bcc="#session.user.email#"
                subject="You are invited to join digitalweddings.love as a vendor!"
                server="localhost"
                port="25"
                timeout="60"
                type="html"><cfinclude template="email-vendor-invite-body.cfm"></cfmail>
        <cfset sendRedirect = "vendor-invite.cfm?sent=1">
    <cfcatch>
        <cfset sendRedirect = "vendor-invite.cfm?error=mailfail">
    </cfcatch>
    </cftry>
    <cflocation url="#sendRedirect#" addToken="false">
</cfif>

<cfinclude template="../includes/layout-start.cfm">
<section style="padding:60px 0">
<div class="container" style="max-width:700px">

    <div class="page-header">
        <p class="eyebrow"><a href="/admin/index.cfm" style="color:var(--gold)">Admin</a></p>
        <h1>Vendor <span class="script">Invite</span></h1>
        <p style="color:var(--text-muted);margin-top:8px">Send a complimentary registration invitation to a vendor.</p>
    </div>

    <cfif url.sent EQ "1">
    <div class="alert alert-success" style="margin-bottom:24px">Invitation sent! A copy was BCC'd to you.</div>
    </cfif>
    <cfif url.preview EQ "1">
    <div class="alert alert-success" style="margin-bottom:24px">
        Preview sent to <cfoutput>#HTMLEditFormat(session.user.email)#</cfoutput> &mdash; check your inbox!
    </div>
    </cfif>
    <cfif url.error EQ "missing">
    <div class="alert alert-error" style="margin-bottom:24px">Please enter a vendor name and valid email address.</div>
    </cfif>

    <cfif url.error EQ "mailfail">
    <div class="alert alert-error" style="margin-bottom:24px">Email could not be sent. Please try again.</div>
    </cfif>

    <div class="panel">
        <form method="post" action="/admin/vendor-invite.cfm" id="inviteForm">
            <input type="hidden" name="action" value="send" id="formAction">

            <div style="display:grid;grid-template-columns:1fr 1fr;gap:16px">
                <div class="field">
                    <label>Vendor / Business Name *</label>
                    <input type="text" name="vendorName" required placeholder="e.g. Elegance Photography"
                           value="<cfoutput>#HTMLEditFormat(form.vendorName)#</cfoutput>">
                </div>
                <div class="field">
                    <label>Vendor Email *</label>
                    <input type="email" name="vendorEmail" required placeholder="vendor@email.com"
                           value="<cfoutput>#HTMLEditFormat(form.vendorEmail)#</cfoutput>">
                </div>
            </div>

            <div class="field">
                <label>Category</label>
                <select name="vendorCategory">
                    <option value="">Select a category</option>
                    <cfoutput><cfloop array="#categories#" index="cat">
                    <option value="#HTMLEditFormat(cat)#" <cfif form.vendorCategory EQ cat>selected</cfif>>#HTMLEditFormat(cat)#</option>
                    </cfloop></cfoutput>
                </select>
            </div>

            <div class="field">
                <label>Website</label>
                <input type="url" name="vendorWebsite" placeholder="https://theirbusiness.com"
                       value="<cfoutput>#HTMLEditFormat(form.vendorWebsite)#</cfoutput>">
            </div>

            <div style="display:grid;grid-template-columns:1fr 1fr;gap:16px">
                <div class="field">
                    <label>Instagram</label>
                    <input type="url" name="vendorInstagram" placeholder="https://instagram.com/theirbusiness"
                           value="<cfoutput>#HTMLEditFormat(form.vendorInstagram)#</cfoutput>">
                </div>
                <div class="field">
                    <label>Facebook</label>
                    <input type="url" name="vendorFacebook" placeholder="https://facebook.com/theirbusiness"
                           value="<cfoutput>#HTMLEditFormat(form.vendorFacebook)#</cfoutput>">
                </div>
            </div>
            <p style="margin:-8px 0 20px;font-size:12px;color:var(--text-muted)">At least one link is required.</p>

            <div class="field">
                <label>Personal Message <span style="font-weight:400;text-transform:none;letter-spacing:0">(optional &mdash; replaces default copy)</span></label>
                <textarea name="personalMessage" rows="5"
                          placeholder="Hi! I came across your work and would love to invite you to list your business on digitalweddings.love..."
                          style="width:100%;resize:vertical"><cfoutput>#HTMLEditFormat(form.personalMessage)#</cfoutput></textarea>
            </div>

            <div style="display:flex;gap:12px;align-items:center;flex-wrap:wrap">
                <button type="submit" class="btn btn-primary">Send Invitation</button>
                <button type="button" class="btn btn-ghost" onclick="sendPreview()">&#128233; Send Preview to Myself</button>
            </div>
            <p style="margin:10px 0 0;font-size:12px;color:var(--text-muted)">
                Preview sends a test to <cfoutput>#HTMLEditFormat(session.user.email)#</cfoutput> using the name/category/message you've entered.
            </p>
        </form>
    </div>

</div>
</section>

<script>
function validateLinks() {
    var website   = document.querySelector('[name="vendorWebsite"]').value.trim();
    var instagram = document.querySelector('[name="vendorInstagram"]').value.trim();
    var facebook  = document.querySelector('[name="vendorFacebook"]').value.trim();
    if (!website && !instagram && !facebook) {
        alert('Please enter at least one link — website, Instagram, or Facebook.');
        return false;
    }
    return true;
}
function sendPreview() {
    var name = document.querySelector('[name="vendorName"]').value.trim();
    if (!name) { alert('Please enter a vendor name first.'); return; }
    document.getElementById('formAction').value = 'preview';
    document.getElementById('inviteForm').submit();
    document.getElementById('formAction').value = 'send';
}
</script>

<cfinclude template="../includes/layout-end.cfm">
