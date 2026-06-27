<cfset pageTitle = "Find a Vendor | digitalweddings.love">
<cfset activePage = "vendors">
<cfparam name="url.q" default="">
<cfparam name="url.category" default="">
<cfparam name="url.location" default="">
<cfset vendorCategories = ["Photography", "Videography", "Catering", "Florist", "DJ / Music", "Band / Entertainment", "Hair & Makeup", "Wedding Planner / Coordinator", "Venue", "Cake / Desserts", "Transportation", "Officiant", "Jewelry", "Attire / Fashion", "Decor / Rentals", "Stationery", "Other"]>

<cfset search = trim(url.q)>
<cfset filterCat = trim(url.category)>
<cfset filterLoc = trim(url.location)>

<cfquery name="vendors" datasource="#application.config.datasource#">
    SELECT v.vendor_id, v.business_name, v.category, v.description, v.location,
           v.phone, v.email, v.website, v.price_range, v.image_url, v.featured,
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
             v.phone, v.email, v.website, v.price_range, v.image_url, v.featured
    ORDER BY v.featured DESC, v.business_name
</cfquery>


<cfinclude template="includes/layout-start.cfm">
<section style="padding:60px 0">
    <div class="container">
        <p class="eyebrow">Directory</p>
        <h1 style="font-size:38px;margin-bottom:8px">Find a <span class="script">Vendor</span></h1>
        <p style="color:var(--text-muted);margin-bottom:36px">Discover talented wedding vendors in your area.</p>

        <form method="get" action="vendors.cfm" style="margin-bottom:40px">
            <div class="actions-row">
                <input type="text" name="q" class="search-input" placeholder="Search vendors..." value="<cfoutput>#HTMLEditFormat(search)#</cfoutput>">
                <select name="category" class="filter-select">
                    <option value="">All Categories</option>
                    <cfoutput><cfloop array="#vendorCategories#" index="cat">
                        <option value="#HTMLEditFormat(cat)#" <cfif filterCat EQ cat>selected</cfif>>#HTMLEditFormat(cat)#</option>
                    </cfloop></cfoutput>
                </select>
                <input type="text" name="location" class="filter-select" placeholder="Location..." value="<cfoutput>#HTMLEditFormat(filterLoc)#</cfoutput>" style="width:160px">
                <button type="submit" class="btn btn-primary">Search</button>
                <cfif len(search) || len(filterCat) || len(filterLoc)>
                    <a href="/vendors.cfm" class="btn btn-ghost">Clear</a>
                </cfif>
            </div>
        </form>

        <cfif !vendors.recordCount>
            <div class="empty-state">
               <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="lucide lucide-store w-12 h-12 mx-auto mb-4 text-muted-foreground/30"><path d="m2 7 4.41-4.41A2 2 0 0 1 7.83 2h8.34a2 2 0 0 1 1.42.59L22 7"></path><path d="M4 12v8a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2v-8"></path><path d="M15 22v-4a2 2 0 0 0-2-2h-2a2 2 0 0 0-2 2v4"></path><path d="M2 7h20"></path><path d="M22 7v3a2 2 0 0 1-2 2a2.7 2.7 0 0 1-1.59-.63.7.7 0 0 0-.82 0A2.7 2.7 0 0 1 16 12a2.7 2.7 0 0 1-1.59-.63.7.7 0 0 0-.82 0A2.7 2.7 0 0 1 12 12a2.7 2.7 0 0 1-1.59-.63.7.7 0 0 0-.82 0A2.7 2.7 0 0 1 8 12a2.7 2.7 0 0 1-1.59-.63.7.7 0 0 0-.82 0A2.7 2.7 0 0 1 4 12a2 2 0 0 1-2-2V7"></path></svg>
                <p>No vendors found. <a href="/register-vendor.cfm">Register as a vendor</a></p>
            </div>
        <cfelse>
            <p style="color:var(--text-muted);margin-bottom:24px;font-size:14px"><cfoutput>#vendors.recordCount#</cfoutput> vendor<cfif vendors.recordCount NEQ 1>s</cfif> found</p>
            <div class="grid-3">
                <cfoutput query="vendors">
                    <div class="card" style="padding:0;overflow:hidden">
                        <cfif len(image_url)>
                            <img src="#HTMLEditFormat(image_url)#" alt="#HTMLEditFormat(business_name)#" style="width:100%;height:200px;object-fit:cover">
                        <cfelse>
                            <div style="width:100%;height:200px;background:var(--gold-light);display:flex;align-items:center;justify-content:center;font-size:48px">&##127968;</div>
                        </cfif>
                        <div style="padding:20px">
                            <cfif featured><span class="badge badge-gold" style="margin-bottom:10px">Featured</span></cfif>
                            <h3 style="font-size:17px;margin-bottom:4px">#HTMLEditFormat(business_name)#</h3>
                            <p style="font-size:12px;color:var(--text-muted);margin-bottom:8px">#HTMLEditFormat(category)# &bull; #HTMLEditFormat(location)#
                                <cfif len(price_range)> &bull; #HTMLEditFormat(price_range)#</cfif>
                            </p>
                            <cfif review_count GT 0>
                                <p style="font-size:12px;color:var(--gold);margin-bottom:8px">
                                    &##9733; #numberFormat(avg_rating, "0.0")# (#review_count# review<cfif review_count NEQ 1>s</cfif>)
                                </p>
                            </cfif>
                            <p style="font-size:13px;color:var(--text-muted);margin-bottom:16px;line-height:1.5">#left(HTMLEditFormat(description), 120)#<cfif len(description) GT 120>...</cfif></p>
                            <div style="display:flex;gap:8px;flex-wrap:wrap">
                                <cfif len(email)><a href="mailto:#HTMLEditFormat(email)#" class="btn btn-outline btn-sm">Email</a></cfif>
                                <cfif len(phone)><a href="tel:#HTMLEditFormat(phone)#" class="btn btn-ghost btn-sm">#HTMLEditFormat(phone)#</a></cfif>
                                <cfif len(website)><a href="#HTMLEditFormat(website)#" class="btn btn-ghost btn-sm" target="_blank" rel="noopener">Website</a></cfif>
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
<cfinclude template="includes/layout-end.cfm">
