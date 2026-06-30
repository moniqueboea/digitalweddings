<cfset pageTitle = "Register as a Vendor | digitalweddings.love">
<cfset activePage = "register-vendor">
<cfparam name="form.businessName"  default="">
<cfparam name="form.category"      default="">
<cfparam name="form.description"   default="">
<cfparam name="form.location"      default="">
<cfparam name="form.phone"         default="">
<cfparam name="form.email"         default="">
<cfparam name="form.website"       default="">
<cfparam name="form.instagram"     default="">
<cfparam name="form.facebook"      default="">
<cfparam name="form.priceRange"    default="">
<cfparam name="form.action"        default="">
<cfset errorMsg   = "">
<cfset successMsg = "">

<cfset categories = ["Photography","Videography","Catering","Florist","DJ / Music","Band / Entertainment","Hair & Makeup","Wedding Planner / Coordinator","Venue","Cake / Desserts","Transportation","Officiant","Jewelry","Attire / Fashion","Decor / Rentals","Stationery","Other"]>

<cfif form.action EQ "register">
    <cfset hasImage = structKeyExists(form,"image") AND len(trim(form.image))>
    <cfset hasLink  = len(trim(form.website)) OR len(trim(form.instagram)) OR len(trim(form.facebook))>
    <cfif !len(trim(form.businessName)) OR !len(trim(form.category)) OR !len(trim(form.description)) OR !len(trim(form.location)) OR !isValid("email", trim(form.email))>
        <cfset errorMsg = "Please fill in all required fields with a valid email address.">
    <cfelseif !hasLink>
        <cfset errorMsg = "Please enter at least one online presence - your website, Instagram, or Facebook page.">
    <cfelseif !hasImage>
        <cfset errorMsg = "Please upload a photo of your business or work.">
    <cfelse>
        <cfquery name="qInvited" datasource="#application.config.datasource#">
            SELECT vendor_id FROM dbo.Vendors
            WHERE email        = <cfqueryparam value="#lCase(trim(form.email))#" cfsqltype="cf_sql_varchar">
              AND complimentary = 1
        </cfquery>
        <cfif !qInvited.recordCount>
            <cfset errorMsg = "Registration is by invitation only. If you received an invitation, please use the exact email address it was sent to. To request an invitation, contact us at hello@digitalweddings.love.">
        <cfelse>
            <cftry>
                <!--- Handle image upload --->
                <cfset uploadDir = expandPath("/assets/vendors/")>
                <cfif !directoryExists(uploadDir)>
                    <cfdirectory action="create" directory="#uploadDir#">
                </cfif>
                <cffile action="upload"
                        filefield="image"
                        destination="#uploadDir#"
                        nameconflict="makeunique"
                        accept="image/jpeg,image/png,image/webp,image/gif">
                <cfset imageUrl = "/assets/vendors/" & cffile.serverFile>

                <cfset ownerId = (structKeyExists(session,"user") AND structKeyExists(session.user,"id")) ? session.user.id : javaCast("null","")>
                <cfquery datasource="#application.config.datasource#">
                    UPDATE dbo.Vendors SET
                        owner_user_id = <cfif isNull(ownerId)>NULL<cfelse><cfqueryparam value="#ownerId#" cfsqltype="cf_sql_bigint"></cfif>,
                        business_name = <cfqueryparam value="#trim(form.businessName)#" cfsqltype="cf_sql_nvarchar">,
                        category      = <cfqueryparam value="#trim(form.category)#"     cfsqltype="cf_sql_nvarchar">,
                        description   = <cfqueryparam value="#trim(form.description)#"  cfsqltype="cf_sql_nvarchar">,
                        location      = <cfqueryparam value="#trim(form.location)#"     cfsqltype="cf_sql_nvarchar">,
                        phone         = <cfqueryparam value="#trim(form.phone)#"        cfsqltype="cf_sql_varchar"  null="#!len(trim(form.phone))#">,
                        website       = <cfqueryparam value="#trim(form.website)#"      cfsqltype="cf_sql_nvarchar" null="#!len(trim(form.website))#">,
                        instagram_url = <cfqueryparam value="#trim(form.instagram)#"    cfsqltype="cf_sql_nvarchar" null="#!len(trim(form.instagram))#">,
                        facebook_url  = <cfqueryparam value="#trim(form.facebook)#"     cfsqltype="cf_sql_nvarchar" null="#!len(trim(form.facebook))#">,
                        price_range   = <cfqueryparam value="#trim(form.priceRange)#"   cfsqltype="cf_sql_varchar"  null="#!len(trim(form.priceRange))#">,
                        image_url     = <cfqueryparam value="#imageUrl#"                cfsqltype="cf_sql_nvarchar">,
                        status        = 'pending',
                        updated_at    = SYSUTCDATETIME()
                    WHERE vendor_id = <cfqueryparam value="#qInvited.vendor_id#" cfsqltype="cf_sql_bigint">
                </cfquery>
                <cfset successMsg = "Thank you! Your vendor listing has been submitted for review. We'll notify you when it's approved.">
            <cfcatch>
                <cfset errorMsg = "An error occurred. Please try again.">
            </cfcatch>
            </cftry>
        </cfif>
    </cfif>
</cfif>

<cfinclude template="includes/layout-start.cfm">
<section style="padding:60px 0">
    <div class="container" style="max-width:700px">
        <p class="eyebrow">Join Our Directory</p>
        <h1 style="font-size:38px;margin-bottom:8px">Register as a <span class="script">Vendor</span></h1>
        <p style="color:var(--text-muted);margin-bottom:36px">Connect with couples planning their perfect day. Listings are reviewed within 2 business days.</p>

        <cfif len(errorMsg)><div class="alert alert-error"><cfoutput>#HTMLEditFormat(errorMsg)#</cfoutput></div></cfif>
        <cfif len(successMsg)><div class="alert alert-success"><cfoutput>#HTMLEditFormat(successMsg)#</cfoutput></div></cfif>

        <cfif !len(successMsg)>
        <div class="panel">
            <form method="post" action="/register-vendor.cfm" enctype="multipart/form-data">
                <input type="hidden" name="action" value="register">

                <div class="field">
                    <label for="businessName">Business Name *</label>
                    <input type="text" id="businessName" name="businessName" required value="<cfoutput>#HTMLEditFormat(form.businessName)#</cfoutput>">
                </div>

                <div class="field-row">
                    <div class="field">
                        <label for="category">Category *</label>
                        <select id="category" name="category" required>
                            <option value="">Select a category</option>
                            <cfoutput><cfloop array="#categories#" index="cat">
                                <option value="#HTMLEditFormat(cat)#" <cfif form.category EQ cat>selected</cfif>>#HTMLEditFormat(cat)#</option>
                            </cfloop></cfoutput>
                        </select>
                    </div>
                    <div class="field">
                        <label for="priceRange">Price Range</label>
                        <select id="priceRange" name="priceRange">
                            <option value="">Select</option>
                            <cfoutput>
                            <option value="$"    <cfif form.priceRange EQ "$">selected</cfif>>$ (Budget)</option>
                            <option value="$$"   <cfif form.priceRange EQ "$$">selected</cfif>>$$ (Moderate)</option>
                            <option value="$$$"  <cfif form.priceRange EQ "$$$">selected</cfif>>$$$ (Premium)</option>
                            <option value="$$$$" <cfif form.priceRange EQ "$$$$">selected</cfif>>$$$$ (Luxury)</option>
                            </cfoutput>
                        </select>
                    </div>
                </div>

                <div class="field">
                    <label for="description">Business Description *</label>
                    <textarea id="description" name="description" required rows="4"><cfoutput>#HTMLEditFormat(form.description)#</cfoutput></textarea>
                </div>

                <div class="field">
                    <label for="location">Location (City, State) *</label>
                    <input type="text" id="location" name="location" required placeholder="e.g. Atlanta, GA" value="<cfoutput>#HTMLEditFormat(form.location)#</cfoutput>">
                </div>

                <div class="field-row">
                    <div class="field">
                        <label for="email">Business Email *</label>
                        <input type="email" id="email" name="email" required value="<cfoutput>#HTMLEditFormat(form.email)#</cfoutput>">
                    </div>
                    <div class="field">
                        <label for="phone">Phone Number</label>
                        <input type="tel" id="phone" name="phone" value="<cfoutput>#HTMLEditFormat(form.phone)#</cfoutput>">
                    </div>
                </div>

                <div style="background:#F0F7FF;border:1px solid #C8DDF5;border-radius:8px;padding:16px 18px;margin-bottom:4px">
                    <p style="font-weight:700;margin:0 0 4px;font-size:14px">Online Presence <span style="color:#cc0000">*</span></p>
                    <p style="margin:0 0 14px;font-size:13px;color:#444">Please provide at least one link so couples can find and learn more about your business.</p>
                    <div class="field" style="margin-bottom:12px">
                        <label for="website">Website URL</label>
                        <input type="url" id="website" name="website" placeholder="https://yourbusiness.com" value="<cfoutput>#HTMLEditFormat(form.website)#</cfoutput>">
                    </div>
                    <div class="field-row" style="margin-bottom:0">
                        <div class="field" style="margin-bottom:0">
                            <label for="instagram">Instagram</label>
                            <input type="url" id="instagram" name="instagram" placeholder="https://instagram.com/yourbusiness" value="<cfoutput>#HTMLEditFormat(form.instagram)#</cfoutput>">
                        </div>
                        <div class="field" style="margin-bottom:0">
                            <label for="facebook">Facebook</label>
                            <input type="url" id="facebook" name="facebook" placeholder="https://facebook.com/yourbusiness" value="<cfoutput>#HTMLEditFormat(form.facebook)#</cfoutput>">
                        </div>
                    </div>
                </div>

                <div class="field">
                    <label for="image">Business Photo *</label>
                    <input type="file" id="image" name="image" required accept="image/jpeg,image/png,image/webp,image/gif" style="padding:8px 0">
                    <small style="color:var(--text-muted);display:block;margin-top:4px">Upload a photo of your work or business. JPG, PNG or WEBP. Max 10MB.</small>
                </div>

                <button type="submit" class="btn btn-primary btn-lg" onclick="return validateLinks()">Submit for Review</button>
            </form>
            <script>
            function validateLinks() {
                var form = document.querySelector('form');
                if (!form.checkValidity()) { form.reportValidity(); return false; }
                var w = document.getElementById('website').value.trim();
                var i = document.getElementById('instagram').value.trim();
                var f = document.getElementById('facebook').value.trim();
                if (!w && !i && !f) {
                    alert('Please enter at least one link - your website, Instagram, or Facebook page.');
                    return false;
                }
                return true;
            }
            </script>
        </div>
        </cfif>
    </div>
</section>
<cfinclude template="includes/layout-end.cfm">
