<cfinclude template="includes/auth-check.cfm">
<cfset pageTitle = "Wedding Website | digitalweddings.love">
<cfset activePage = "wedding-sites">
<cfset userId = session.user.id>
<cfparam name="form.action" default="">

<cfif form.action EQ "save">
    <cfquery name="existing" datasource="#application.config.datasource#">
        SELECT wedding_site_id FROM dbo.WeddingSites WHERE user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
    </cfquery>

    <cfset slug = len(trim(form.slug)) ? lCase(reReplace(trim(form.slug),"[^a-z0-9\-]","","all")) : "">
    <cfif !len(slug) && len(trim(form.coupleName1)) && len(trim(form.coupleName2))>
        <cfset slug = lCase(reReplace(trim(form.coupleName1)&"-and-"&trim(form.coupleName2),"[^a-z0-9\-]","-","all"))>
    </cfif>

    <cfif existing.recordCount>
        <cfquery datasource="#application.config.datasource#">
            UPDATE dbo.WeddingSites SET
                template = <cfqueryparam value="#len(trim(form.template)) ? trim(form.template) : 'classic_gold'#" cfsqltype="cf_sql_varchar">,
                couple_name_1 = <cfqueryparam value="#trim(form.coupleName1)#" cfsqltype="cf_sql_nvarchar">,
                couple_name_2 = <cfqueryparam value="#trim(form.coupleName2)#" cfsqltype="cf_sql_nvarchar">,
                wedding_date = <cfqueryparam value="#trim(form.weddingDate)#" cfsqltype="cf_sql_date" null="#!len(trim(form.weddingDate))#">,
                venue_name = <cfqueryparam value="#trim(form.venueName)#" cfsqltype="cf_sql_nvarchar" null="#!len(trim(form.venueName))#">,
                venue_address = <cfqueryparam value="#trim(form.venueAddress)#" cfsqltype="cf_sql_nvarchar" null="#!len(trim(form.venueAddress))#">,
                story = <cfqueryparam value="#trim(form.story)#" cfsqltype="cf_sql_nvarchar" null="#!len(trim(form.story))#">,
                dress_code = <cfqueryparam value="#trim(form.dressCode)#" cfsqltype="cf_sql_nvarchar" null="#!len(trim(form.dressCode))#">,
                travel_info = <cfqueryparam value="#trim(form.travelInfo)#" cfsqltype="cf_sql_nvarchar" null="#!len(trim(form.travelInfo))#">,
                slug = <cfqueryparam value="#slug#" cfsqltype="cf_sql_varchar" null="#!len(slug)#">,
                published = <cfqueryparam value="#(structKeyExists(form,'published') && form.published EQ 'on') ? 1 : 0#" cfsqltype="cf_sql_bit">,
                updated_at = SYSUTCDATETIME()
            WHERE user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
        </cfquery>
    <cfelse>
        <cfquery datasource="#application.config.datasource#">
            INSERT INTO dbo.WeddingSites (user_id, template, couple_name_1, couple_name_2, wedding_date, venue_name, venue_address, story, dress_code, travel_info, slug, published)
            VALUES (
                <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">,
                <cfqueryparam value="#len(trim(form.template)) ? trim(form.template) : 'classic_gold'#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#trim(form.coupleName1)#" cfsqltype="cf_sql_nvarchar">,
                <cfqueryparam value="#trim(form.coupleName2)#" cfsqltype="cf_sql_nvarchar">,
                <cfqueryparam value="#trim(form.weddingDate)#" cfsqltype="cf_sql_date" null="#!len(trim(form.weddingDate))#">,
                <cfqueryparam value="#trim(form.venueName)#" cfsqltype="cf_sql_nvarchar" null="#!len(trim(form.venueName))#">,
                <cfqueryparam value="#trim(form.venueAddress)#" cfsqltype="cf_sql_nvarchar" null="#!len(trim(form.venueAddress))#">,
                <cfqueryparam value="#trim(form.story)#" cfsqltype="cf_sql_nvarchar" null="#!len(trim(form.story))#">,
                <cfqueryparam value="#trim(form.dressCode)#" cfsqltype="cf_sql_nvarchar" null="#!len(trim(form.dressCode))#">,
                <cfqueryparam value="#trim(form.travelInfo)#" cfsqltype="cf_sql_nvarchar" null="#!len(trim(form.travelInfo))#">,
                <cfqueryparam value="#slug#" cfsqltype="cf_sql_varchar" null="#!len(slug)#">,
                <cfqueryparam value="#(structKeyExists(form,'published') && form.published EQ 'on') ? 1 : 0#" cfsqltype="cf_sql_bit">
            )
        </cfquery>
    </cfif>
    <cflocation url="wedding-sites.cfm?saved=1" addToken="false">
</cfif>

<cfquery name="site" datasource="#application.config.datasource#">
    SELECT * FROM dbo.WeddingSites WHERE user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
</cfquery>

<cfset saved = structKeyExists(url,"saved") && url.saved EQ "1">
<cfset templates = ["classic_gold","sunset_bliss"]>

<cfinclude template="includes/layout-start.cfm">
<section style="padding:60px 0">
<div class="container" style="max-width:760px">
    <div class="page-header">
        <p class="eyebrow">Your Online Presence</p>
        <h1>Wedding <span class="script">Website</span></h1>
    </div>

    <cfif saved><div class="alert alert-success">Wedding website saved!</div></cfif>

    <cfif site.recordCount && site.published && len(site.slug)>
    <div class="alert alert-info">
        Your wedding site is published at: <strong>/w/<cfoutput>#HTMLEditFormat(site.slug)#</cfoutput></strong>
    </div>
    </cfif>

    <div class="panel">
        <form method="post" action="wedding-sites.cfm">
            <input type="hidden" name="action" value="save">
            <div class="field-row">
                <div class="field">
                    <label for="coupleName1">Partner 1 Name *</label>
                    <input type="text" id="coupleName1" name="coupleName1" required placeholder="e.g. Jasmine" value="<cfoutput>#site.recordCount ? HTMLEditFormat(site.couple_name_1) : ''#</cfoutput>">
                </div>
                <div class="field">
                    <label for="coupleName2">Partner 2 Name *</label>
                    <input type="text" id="coupleName2" name="coupleName2" required placeholder="e.g. David" value="<cfoutput>#site.recordCount ? HTMLEditFormat(site.couple_name_2) : ''#</cfoutput>">
                </div>
            </div>
            <div class="field-row">
                <div class="field">
                    <label for="weddingDate">Wedding Date</label>
                    <input type="date" id="weddingDate" name="weddingDate" value="<cfoutput>#site.recordCount && len(site.wedding_date) ? dateFormat(site.wedding_date,'yyyy-mm-dd') : ''#</cfoutput>">
                </div>
                <div class="field">
                    <label for="slug">URL Slug</label>
                    <input type="text" id="slug" name="slug" placeholder="e.g. jasmine-and-david" value="<cfoutput>#site.recordCount ? HTMLEditFormat(site.slug) : ''#</cfoutput>">
                </div>
            </div>
            <div class="field-row">
                <div class="field">
                    <label for="venueName">Venue Name</label>
                    <input type="text" id="venueName" name="venueName" placeholder="e.g. The Grand Ballroom" value="<cfoutput>#site.recordCount ? HTMLEditFormat(site.venue_name) : ''#</cfoutput>">
                </div>
                <div class="field">
                    <label for="dressCode">Dress Code</label>
                    <input type="text" id="dressCode" name="dressCode" placeholder="e.g. Black Tie Optional" value="<cfoutput>#site.recordCount ? HTMLEditFormat(site.dress_code) : ''#</cfoutput>">
                </div>
            </div>
            <div class="field">
                <label for="venueAddress">Venue Address</label>
                <input type="text" id="venueAddress" name="venueAddress" value="<cfoutput>#site.recordCount ? HTMLEditFormat(site.venue_address) : ''#</cfoutput>">
            </div>
            <div class="field">
                <label for="story">Our Love Story</label>
                <textarea id="story" name="story" rows="5" placeholder="Share how you met, your proposal story, what makes your love special..."><cfoutput>#site.recordCount ? HTMLEditFormat(site.story) : ''#</cfoutput></textarea>
            </div>
            <div class="field">
                <label for="travelInfo">Travel &amp; Accommodations</label>
                <textarea id="travelInfo" name="travelInfo" rows="3" placeholder="Recommended hotels, airports, transportation..."><cfoutput>#site.recordCount ? HTMLEditFormat(site.travel_info) : ''#</cfoutput></textarea>
            </div>
            <div class="field">
                <label for="template">Invitation Theme</label>
                <select id="template" name="template">
                    <cfoutput><cfloop array="#templates#" index="t">
                        <option value="#HTMLEditFormat(t)#" <cfif site.recordCount && site.template EQ t>selected</cfif>>#replace(t,'_',' ','all')#</option>
                    </cfloop></cfoutput>
                </select>
            </div>
            <div class="field-check">
                <input type="checkbox" id="published" name="published" <cfif site.recordCount && site.published>checked</cfif>>
                <label for="published">Publish my wedding website (make it publicly accessible)</label>
            </div>
            <button type="submit" class="btn btn-primary btn-lg">Save Wedding Website</button>
        </form>
    </div>
</div>
</section>
<cfinclude template="includes/layout-end.cfm">
