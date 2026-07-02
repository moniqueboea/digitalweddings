<!--- v2 --->
<cfinclude template="../includes/auth-check.cfm">
<cfset pageTitle = "Find a Vendor | digitalweddings.love">
<cfset activePage = "vendors">
<cfparam name="url.q"         default="">
<cfparam name="url.contacted" default="">
<cfparam name="url.category" default="">
<cfparam name="url.location" default="">
<cfset vendorCategories = ["Photography", "Videography", "Catering", "Florist", "DJ / Music", "Band / Entertainment", "Hair & Makeup", "Wedding Planner / Coordinator", "Venue", "Cake / Desserts", "Transportation", "Officiant", "Jewelry", "Attire / Fashion", "Decor / Rentals", "Stationery", "Other"]>

<cfset search = trim(url.q)>
<cfset filterCat = trim(url.category)>
<cfset filterLoc = trim(url.location)>

<cfquery name="vendors" datasource="#application.config.datasource#">
    SELECT v.vendor_id, v.business_name, v.category, v.description, v.location,
           v.phone, v.email, v.website_url, v.instagram_url, v.facebook_url, v.price_range, v.image_url, v.featured,
           AVG(CAST(vr.rating AS FLOAT)) AS avg_rating,
           COUNT(vr.vendor_review_id) AS review_count
    FROM dbo.Vendors v
    LEFT JOIN dbo.VendorReviews vr ON v.vendor_id = vr.vendor_id
    WHERE v.status = 'approved'
    <cfif len(search)>
        AND (v.business_name LIKE <cfqueryparam value="%#search#%" cfsqltype="cf_sql_varchar">
          OR v.description LIKE <cfqueryparam value="%#search#%" cfsqltype="cf_sql_varchar">)
    </cfif>
    <cfif len(filterCat)>
        AND v.category = <cfqueryparam value="#filterCat#" cfsqltype="cf_sql_nvarchar">
    </cfif>
    <cfif len(filterLoc)>
        AND v.location LIKE <cfqueryparam value="%#filterLoc#%" cfsqltype="cf_sql_varchar">
    </cfif>
    GROUP BY v.vendor_id, v.business_name, v.category, v.description, v.location,
             v.phone, v.email, v.website_url, v.instagram_url, v.facebook_url, v.price_range, v.image_url, v.featured
    ORDER BY v.featured DESC, v.business_name
</cfquery>

<cfinclude template="../includes/layout-start.cfm">
<section style="padding:60px 0">
    <div class="container">
        <p class="eyebrow">Directory</p>
        <h1 style="font-size:38px;margin-bottom:8px">Find a <span class="script">Vendor</span></h1>
        <p style="color:var(--text-muted);margin-bottom:36px">Discover talented wedding vendors in your area.</p>

        <form method="get" action="/members/vendors.cfm" style="margin-bottom:40px;max-width:480px">
            <div class="field">
                <label>Search</label>
                <input type="text" name="q" placeholder="Search vendors..." value="<cfoutput>#encodeForHTMLAttribute(search)#</cfoutput>">
            </div>
            <div class="field">
                <label>Category</label>
                <select name="category">
                    <option value="">All Categories</option>
                    <cfoutput><cfloop array="#vendorCategories#" index="cat">
                        <option value="#encodeForHTMLAttribute(cat)#" <cfif filterCat EQ cat>selected</cfif>>#encodeForHTML(cat)#</option>
                    </cfloop></cfoutput>
                </select>
            </div>
            <div class="field">
                <label>Location</label>
                <input type="text" name="location" placeholder="City, state..." value="<cfoutput>#encodeForHTMLAttribute(filterLoc)#</cfoutput>">
            </div>
            <div style="display:flex;gap:10px;margin-top:8px">
                <button type="submit" class="btn btn-primary">Search</button>
                <cfif len(search) OR len(filterCat) OR len(filterLoc)>
                    <a href="/members/vendors.cfm" class="btn btn-ghost">Clear</a>
                </cfif>
            </div>
        </form>

        <cfif url.contacted EQ "1">
        <div class="alert alert-success" style="margin-bottom:24px">Your message was sent! The vendor will be in touch soon.</div>
        </cfif>
        <cfif url.contacted EQ "error">
        <div class="alert alert-error" style="margin-bottom:24px">Something went wrong. Please try again.</div>
        </cfif>

        <cfif !vendors.recordCount>
            <div class="empty-state">
               <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="m2 7 4.41-4.41A2 2 0 0 1 7.83 2h8.34a2 2 0 0 1 1.42.59L22 7"></path><path d="M4 12v8a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2v-8"></path><path d="M15 22v-4a2 2 0 0 0-2-2h-2a2 2 0 0 0-2 2v4"></path><path d="M2 7h20"></path><path d="M22 7v3a2 2 0 0 1-2 2a2.7 2.7 0 0 1-1.59-.63.7.7 0 0 0-.82 0A2.7 2.7 0 0 1 16 12a2.7 2.7 0 0 1-1.59-.63.7.7 0 0 0-.82 0A2.7 2.7 0 0 1 12 12a2.7 2.7 0 0 1-1.59-.63.7.7 0 0 0-.82 0A2.7 2.7 0 0 1 8 12a2.7 2.7 0 0 1-1.59-.63.7.7 0 0 0-.82 0A2.7 2.7 0 0 1 4 12a2 2 0 0 1-2-2V7"></path></svg>
                <p>No vendors found. <a href="/register-vendor.cfm">Register as a vendor</a></p>
            </div>
        <cfelse>
            <p style="color:var(--text-muted);margin-bottom:24px;font-size:14px"><cfoutput>#vendors.recordCount#</cfoutput> vendor<cfif vendors.recordCount NEQ 1>s</cfif> found</p>
            <div style="display:flex;flex-direction:column;gap:16px">
                <cfoutput query="vendors">
                    <div class="card" style="padding:0;overflow:hidden;display:flex;flex-direction:row">
                        <div style="flex-shrink:0;width:160px">
                            <cfif len(image_url)>
                                <img src="#encodeForHTMLAttribute(image_url)#" alt="#encodeForHTMLAttribute(business_name)#" style="width:160px;height:100%;min-height:140px;object-fit:cover;display:block">
                            <cfelse>
                                <div style="width:160px;min-height:140px;height:100%;background:var(--gold-light);display:flex;align-items:center;justify-content:center;font-size:40px">#chr(55356)##chr(57264)#</div>
                            </cfif>
                        </div>
                        <div style="padding:18px 20px;flex:1;min-width:0">
                            <cfif featured><span class="badge badge-gold" style="margin-bottom:8px">Featured</span></cfif>
                            <h3 style="font-size:17px;margin-bottom:4px">#encodeForHTML(business_name)#</h3>
                            <p style="font-size:12px;color:var(--text-muted);margin-bottom:6px">#encodeForHTML(category)# &bull; #encodeForHTML(location)#<cfif len(price_range)> &bull; #encodeForHTML(price_range)#</cfif></p>
                            <cfif review_count GT 0>
                                <p style="font-size:12px;color:var(--gold);margin-bottom:6px">#chr(9733)# #numberFormat(avg_rating, "0.0")# (#review_count# review<cfif review_count NEQ 1>s</cfif>)</p>
                            </cfif>
                            <p style="font-size:13px;color:var(--text-muted);margin-bottom:14px;line-height:1.5">#left(encodeForHTML(description), 180)#<cfif len(description) GT 180>...</cfif></p>
                            <div style="display:flex;gap:8px;flex-wrap:wrap">
                                <button type="button" class="btn btn-primary btn-sm" onclick="openContact(#vendor_id#,'#JSStringFormat(business_name)#')">Contact</button>
                                <cfif len(phone)><a href="/vendor-track.cfm?id=#vendor_id#&type=phone_click&redirect=#URLEncodedFormat('tel:'&phone)#" class="btn btn-ghost btn-sm">#encodeForHTML(phone)#</a></cfif>
                                <cfif len(website_url)><a href="/vendor-track.cfm?id=#vendor_id#&type=website_click&redirect=#URLEncodedFormat(trim(website_url))#" class="btn btn-ghost btn-sm" target="_blank" rel="noopener">Website</a></cfif>
                                <cfif len(instagram_url)><a href="/vendor-track.cfm?id=#vendor_id#&type=instagram_click&redirect=#URLEncodedFormat(trim(instagram_url))#" class="btn btn-ghost btn-sm" target="_blank" rel="noopener">Instagram</a></cfif>
                                <cfif len(facebook_url)><a href="/vendor-track.cfm?id=#vendor_id#&type=facebook_click&redirect=#URLEncodedFormat(trim(facebook_url))#" class="btn btn-ghost btn-sm" target="_blank" rel="noopener">Facebook</a></cfif>
                            </div>
                        </div>
                    </div>
                </cfoutput>
            </div>
        </cfif>

        <div style="margin-top:48px;padding:24px;background:var(--gold-light);border-radius:var(--radius);text-align:center">
            <h3 style="margin-bottom:8px">Are you a vendor?</h3>
            <p style="color:var(--text-muted);margin-bottom:16px">Join our directory and connect with couples planning their perfect day.</p>
            <a href="/register-vendor.cfm" class="btn btn-primary">Register as a Vendor</a>
        </div>
    </div>
</section>
<!--- Contact modal --->
<div id="contactModal" style="display:none;position:fixed;inset:0;z-index:9999;background:rgba(0,0,0,0.55);align-items:center;justify-content:center;padding:20px">
    <div style="background:var(--bg);border:1px solid var(--border);border-radius:12px;width:100%;max-width:500px;box-shadow:0 8px 40px rgba(0,0,0,0.2)">
        <div style="display:flex;align-items:center;justify-content:space-between;padding:20px 24px;border-bottom:1px solid var(--border)">
            <h2 id="contactModalTitle" style="font-size:18px;margin:0">Contact Vendor</h2>
            <button onclick="closeContact()" style="background:none;border:none;font-size:22px;cursor:pointer;color:var(--text-muted);line-height:1">&times;</button>
        </div>
        <form method="post" action="/vendor-contact.cfm?return=/members/vendors.cfm" style="padding:24px">
            <input type="hidden" name="vendorId" id="contactVendorId" value="">
            <div class="field">
                <label>Your Name *</label>
                <input type="text" name="senderName" required placeholder="e.g. Monique Johnson">
            </div>
            <div class="field">
                <label>Your Email *</label>
                <cfoutput><input type="email" name="senderEmail" required placeholder="you@email.com" value="#HTMLEditFormat(session.user.email)#"></cfoutput>
            </div>
            <div class="field">
                <label>Message *</label>
                <textarea name="message" rows="5" required placeholder="Hi! I'm interested in your services for my wedding on..."></textarea>
            </div>
            <div style="display:flex;gap:10px;justify-content:flex-end;margin-top:4px">
                <button type="button" class="btn btn-ghost" onclick="closeContact()">Cancel</button>
                <button type="submit" class="btn btn-primary">Send Message</button>
            </div>
        </form>
    </div>
</div>

<cfif vendors.recordCount>
<cfoutput>
<script>
var vendorIds = [<cfloop query="vendors">#vendor_id#,</cfloop>];
vendorIds.forEach(function(id){
    fetch('/vendor-track.cfm?id=' + id + '&type=view', { method:'GET', keepalive:true });
});
</script>
</cfoutput>
</cfif>

<script>
function openContact(id, name) {
    document.getElementById('contactVendorId').value = id;
    document.getElementById('contactModalTitle').textContent = 'Contact ' + name;
    var m = document.getElementById('contactModal');
    m.style.display = 'flex';
}
function closeContact() {
    document.getElementById('contactModal').style.display = 'none';
}
document.getElementById('contactModal').addEventListener('click', function(e){
    if (e.target === this) closeContact();
});
document.addEventListener('keydown', function(e){
    if (e.key === 'Escape') closeContact();
});
</script>
<cfinclude template="../includes/layout-end.cfm">
