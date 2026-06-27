<cfinclude template="../includes/auth-check.cfm">

<!--- Auto-add reception columns if missing --->
<cftry>
<cfquery datasource="#application.config.datasource#">
    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='WeddingSites' AND COLUMN_NAME='reception_venue_name')
        ALTER TABLE dbo.WeddingSites ADD reception_venue_name NVARCHAR(MAX) NULL;
    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='WeddingSites' AND COLUMN_NAME='reception_venue_address')
        ALTER TABLE dbo.WeddingSites ADD reception_venue_address NVARCHAR(MAX) NULL;
    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='WeddingSites' AND COLUMN_NAME='travel_info_link')
        ALTER TABLE dbo.WeddingSites ADD travel_info_link NVARCHAR(MAX) NULL;
    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='WeddingSites' AND COLUMN_NAME='things_to_do_link')
        ALTER TABLE dbo.WeddingSites ADD things_to_do_link NVARCHAR(MAX) NULL;
    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='WeddingSites' AND COLUMN_NAME='travel_links_json')
        ALTER TABLE dbo.WeddingSites ADD travel_links_json NVARCHAR(MAX) NULL;
    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='WeddingSites' AND COLUMN_NAME='things_links_json')
        ALTER TABLE dbo.WeddingSites ADD things_links_json NVARCHAR(MAX) NULL;
    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='WeddingSites' AND COLUMN_NAME='couple_photo_url')
        ALTER TABLE dbo.WeddingSites ADD couple_photo_url NVARCHAR(MAX) NULL;
</cfquery>
<cfcatch type="any">
</cfcatch>
</cftry>

<cfset userId = session.user.id>
<cfparam name="url.siteId" default="0">
<cfparam name="url.template" default="">
<cfparam name="url.slugError" default="">
<cfparam name="form.action" default="">

<!--- ===== FORM: SAVE ===== --->
<cfif form.action EQ "save">
    <cftry>
    <cfset slug = lCase(reReplace(trim(form.slug),"[^a-z0-9\-]","","all"))>
    <cfif !len(slug) && len(trim(form.coupleName1)) && len(trim(form.coupleName2))>
        <cfset slug = lCase(reReplace(trim(form.coupleName1) & "and" & trim(form.coupleName2),"[^a-z0-9]","-","all"))>
        <cfset slug = reReplace(slug,"-+","-","all")>
    </cfif>

    <cfset slugOk = true>
    <cfif len(slug)>
        <cfquery name="slugCheck" datasource="#application.config.datasource#">
            SELECT wedding_site_id FROM dbo.WeddingSites
            WHERE slug = <cfqueryparam value="#slug#" cfsqltype="cf_sql_varchar">
            <cfif isNumeric(form.siteId) && form.siteId GT 0>
                AND wedding_site_id <> <cfqueryparam value="#form.siteId#" cfsqltype="cf_sql_bigint">
            </cfif>
        </cfquery>
        <cfif slugCheck.recordCount><cfset slugOk = false></cfif>
    </cfif>

    <cfif !slugOk>
        <cflocation url="wedding-site-edit.cfm?siteId=#URLEncodedFormat(form.siteId)#&template=#URLEncodedFormat(form.template)#&slugError=1" addToken="false">
    </cfif>

    <cfset galleryArr = []>
    <cfif structKeyExists(form, "galleryImagesJson") && len(trim(form.galleryImagesJson))>
        <cftry>
            <cfset galleryArr = deserializeJSON(trim(form.galleryImagesJson))>
        <cfcatch><cfset galleryArr = []></cfcatch>
        </cftry>
    </cfif>

    <cfset faqArr = []>
    <cfloop from="1" to="20" index="fi">
        <cfset qField = "faqQ" & fi>
        <cfset aField = "faqA" & fi>
        <cfif structKeyExists(form, qField) && len(trim(form[qField]))>
            <cfset arrayAppend(faqArr, {question: trim(form[qField]), answer: structKeyExists(form, aField) ? trim(form[aField]) : ""})>
        </cfif>
    </cfloop>

    <cfset travelLinksArr = []>
    <cfloop from="1" to="20" index="tli">
        <cfset tlLabel = "travelLinkLabel" & tli>
        <cfset tlUrl   = "travelLinkUrl" & tli>
        <cfif structKeyExists(form, tlUrl) && len(trim(form[tlUrl]))>
            <cfset arrayAppend(travelLinksArr, {label: structKeyExists(form,tlLabel) ? trim(form[tlLabel]) : "", url: trim(form[tlUrl])})>
        </cfif>
    </cfloop>

    <cfset thingsLinksArr = []>
    <cfloop from="1" to="20" index="tdi">
        <cfset tdLabel = "thingsLinkLabel" & tdi>
        <cfset tdUrl   = "thingsLinkUrl" & tdi>
        <cfif structKeyExists(form, tdUrl) && len(trim(form[tdUrl]))>
            <cfset arrayAppend(thingsLinksArr, {label: structKeyExists(form,tdLabel) ? trim(form[tdLabel]) : "", url: trim(form[tdUrl])})>
        </cfif>
    </cfloop>

    <cfif isNumeric(form.siteId) && form.siteId GT 0>
        <cfquery datasource="#application.config.datasource#">
            UPDATE dbo.WeddingSites SET
                template            = <cfqueryparam value="#trim(form.template)#" cfsqltype="cf_sql_varchar">,
                couple_name_1       = <cfqueryparam value="#trim(form.coupleName1)#" cfsqltype="cf_sql_nvarchar">,
                couple_name_2       = <cfqueryparam value="#trim(form.coupleName2)#" cfsqltype="cf_sql_nvarchar">,
                wedding_date        = <cfqueryparam value="#trim(form.weddingDate)#" cfsqltype="cf_sql_date" null="#!len(trim(form.weddingDate))#">,
                venue_name               = <cfqueryparam value="#trim(form.venueName)#" cfsqltype="cf_sql_nvarchar" null="#!len(trim(form.venueName))#">,
                venue_address            = <cfqueryparam value="#trim(form.venueAddress)#" cfsqltype="cf_sql_nvarchar" null="#!len(trim(form.venueAddress))#">,
                reception_venue_name     = <cfqueryparam value="#trim(form.receptionVenueName)#" cfsqltype="cf_sql_nvarchar" null="#!len(trim(form.receptionVenueName))#">,
                reception_venue_address  = <cfqueryparam value="#trim(form.receptionVenueAddress)#" cfsqltype="cf_sql_nvarchar" null="#!len(trim(form.receptionVenueAddress))#">,
                story               = <cfqueryparam value="#trim(form.story)#" cfsqltype="cf_sql_nvarchar" null="#!len(trim(form.story))#">,
                scripture           = <cfqueryparam value="#trim(form.scripture)#" cfsqltype="cf_sql_nvarchar" null="#!len(trim(form.scripture))#">,
                dress_code          = <cfqueryparam value="#trim(form.dressCode)#" cfsqltype="cf_sql_nvarchar" null="#!len(trim(form.dressCode))#">,
                travel_info         = <cfqueryparam value="#trim(form.travelInfo)#" cfsqltype="cf_sql_nvarchar" null="#!len(trim(form.travelInfo))#">,
                travel_links_json   = <cfqueryparam value="#serializeJSON(travelLinksArr)#" cfsqltype="cf_sql_nvarchar">,
                things_to_do        = <cfqueryparam value="#trim(form.thingsToDo)#" cfsqltype="cf_sql_nvarchar" null="#!len(trim(form.thingsToDo))#">,
                things_links_json   = <cfqueryparam value="#serializeJSON(thingsLinksArr)#" cfsqltype="cf_sql_nvarchar">,
                hero_image_url      = <cfqueryparam value="#trim(form.heroImageUrl)#" cfsqltype="cf_sql_nvarchar" null="#!len(trim(form.heroImageUrl))#">,
                couple_photo_url    = <cfqueryparam value="#trim(form.couplePhotoUrl)#" cfsqltype="cf_sql_nvarchar" null="#!len(trim(form.couplePhotoUrl))#">,
                gallery_images_json = <cfqueryparam value="#serializeJSON(galleryArr)#" cfsqltype="cf_sql_nvarchar">,
                faq_json            = <cfqueryparam value="#serializeJSON(faqArr)#" cfsqltype="cf_sql_nvarchar">,
                slug                = <cfqueryparam value="#slug#" cfsqltype="cf_sql_varchar" null="#!len(slug)#">,
                published           = <cfqueryparam value="#(structKeyExists(form,'published') && form.published EQ 'on') ? 1 : 0#" cfsqltype="cf_sql_bit">,
                updated_at          = SYSUTCDATETIME()
            WHERE wedding_site_id = <cfqueryparam value="#form.siteId#" cfsqltype="cf_sql_bigint">
              AND user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
        </cfquery>
    <cfelse>
        <cfquery datasource="#application.config.datasource#">
            INSERT INTO dbo.WeddingSites
                (user_id, template, couple_name_1, couple_name_2, wedding_date, venue_name, venue_address,
                 reception_venue_name, reception_venue_address,
                 story, scripture, dress_code, travel_info, travel_links_json, things_to_do, things_links_json, hero_image_url, couple_photo_url, gallery_images_json, faq_json, slug, published)
            VALUES (
                <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">,
                <cfqueryparam value="#trim(form.template)#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#trim(form.coupleName1)#" cfsqltype="cf_sql_nvarchar">,
                <cfqueryparam value="#trim(form.coupleName2)#" cfsqltype="cf_sql_nvarchar">,
                <cfqueryparam value="#trim(form.weddingDate)#" cfsqltype="cf_sql_date" null="#!len(trim(form.weddingDate))#">,
                <cfqueryparam value="#trim(form.venueName)#" cfsqltype="cf_sql_nvarchar" null="#!len(trim(form.venueName))#">,
                <cfqueryparam value="#trim(form.venueAddress)#" cfsqltype="cf_sql_nvarchar" null="#!len(trim(form.venueAddress))#">,
                <cfqueryparam value="#trim(form.receptionVenueName)#" cfsqltype="cf_sql_nvarchar" null="#!len(trim(form.receptionVenueName))#">,
                <cfqueryparam value="#trim(form.receptionVenueAddress)#" cfsqltype="cf_sql_nvarchar" null="#!len(trim(form.receptionVenueAddress))#">,
                <cfqueryparam value="#trim(form.story)#" cfsqltype="cf_sql_nvarchar" null="#!len(trim(form.story))#">,
                <cfqueryparam value="#trim(form.scripture)#" cfsqltype="cf_sql_nvarchar" null="#!len(trim(form.scripture))#">,
                <cfqueryparam value="#trim(form.dressCode)#" cfsqltype="cf_sql_nvarchar" null="#!len(trim(form.dressCode))#">,
                <cfqueryparam value="#trim(form.travelInfo)#" cfsqltype="cf_sql_nvarchar" null="#!len(trim(form.travelInfo))#">,
                <cfqueryparam value="#serializeJSON(travelLinksArr)#" cfsqltype="cf_sql_nvarchar">,
                <cfqueryparam value="#trim(form.thingsToDo)#" cfsqltype="cf_sql_nvarchar" null="#!len(trim(form.thingsToDo))#">,
                <cfqueryparam value="#serializeJSON(thingsLinksArr)#" cfsqltype="cf_sql_nvarchar">,
                <cfqueryparam value="#trim(form.heroImageUrl)#" cfsqltype="cf_sql_nvarchar" null="#!len(trim(form.heroImageUrl))#">,
                <cfqueryparam value="#trim(form.couplePhotoUrl)#" cfsqltype="cf_sql_nvarchar" null="#!len(trim(form.couplePhotoUrl))#">,
                <cfqueryparam value="#serializeJSON(galleryArr)#" cfsqltype="cf_sql_nvarchar">,
                <cfqueryparam value="#serializeJSON(faqArr)#" cfsqltype="cf_sql_nvarchar">,
                <cfqueryparam value="#slug#" cfsqltype="cf_sql_varchar" null="#!len(slug)#">,
                <cfqueryparam value="#(structKeyExists(form,'published') && form.published EQ 'on') ? 1 : 0#" cfsqltype="cf_sql_bit">
            )
        </cfquery>
    </cfif>
    <cflocation url="wedding-sites.cfm?saved=1" addToken="false">
    
    <cfcatch type="any">
        <cfsetting enablecfoutputonly="false">
        <h1 style="color:red">Error: #cfcatch.message#</h1>
        <p>#cfcatch.detail#</p>
    </cfcatch>
    </cftry>
</cfif>

<!--- ===== LOAD EXISTING DATA FOR EDIT ===== --->
<cfset editData = {
    siteId:"", template:"", coupleName1:"", coupleName2:"", weddingDate:"",
    venueName:"", venueAddress:"", receptionVenueName:"", receptionVenueAddress:"",
    story:"", scripture:"", dressCode:"",
    travelInfo:"", travelLinks:[], thingsToDo:"", thingsLinks:[], heroImageUrl:"", couplePhotoUrl:"", slug:"", published:0,
    galleryUrls:[], galleryJson:"[]", faqItems:[]
}>

<cfif isNumeric(url.siteId) && url.siteId GT 0>
    <cfquery name="editRow" datasource="#application.config.datasource#">
        SELECT * FROM dbo.WeddingSites
        WHERE wedding_site_id = <cfqueryparam value="#url.siteId#" cfsqltype="cf_sql_bigint">
          AND user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
    </cfquery>
    <cfif editRow.recordCount>
        <cfset editData.siteId      = editRow.wedding_site_id>
        <cfset editData.template    = editRow.template>
        <cfset editData.coupleName1 = editRow.couple_name_1>
        <cfset editData.coupleName2 = editRow.couple_name_2>
        <cfset editData.weddingDate = len(editRow.wedding_date) ? dateFormat(editRow.wedding_date,"yyyy-mm-dd") : "">
        <cfset editData.venueName              = editRow.venue_name>
        <cfset editData.venueAddress           = editRow.venue_address>
        <cfset editData.receptionVenueName     = editRow.reception_venue_name>
        <cfset editData.receptionVenueAddress  = editRow.reception_venue_address>
        <cfset editData.story       = editRow.story>
        <cfset editData.scripture   = editRow.scripture>
        <cfset editData.dressCode   = editRow.dress_code>
        <cfset editData.travelInfo  = editRow.travel_info>
        <cfset editData.thingsToDo  = editRow.things_to_do>
        <cftry>
            <cfif structKeyExists(editRow,"travel_links_json") && len(trim(editRow.travel_links_json))>
                <cfset editData.travelLinks = deserializeJSON(editRow.travel_links_json)>
            </cfif>
        <cfcatch type="any"><cfset editData.travelLinks = []></cfcatch></cftry>
        <cftry>
            <cfif structKeyExists(editRow,"things_links_json") && len(trim(editRow.things_links_json))>
                <cfset editData.thingsLinks = deserializeJSON(editRow.things_links_json)>
            </cfif>
        <cfcatch type="any"><cfset editData.thingsLinks = []></cfcatch></cftry>
        <cfset editData.heroImageUrl   = editRow.hero_image_url>
        <cfset editData.couplePhotoUrl = structKeyExists(editRow,"couple_photo_url") ? editRow.couple_photo_url : "">
        <cfset editData.slug        = editRow.slug>
        <cfset editData.published   = editRow.published>
        <cftry>
            <cfif len(trim(editRow.gallery_images_json))>
                <cfset editData.galleryUrls = deserializeJSON(editRow.gallery_images_json)>
                <cfset editData.galleryJson = editRow.gallery_images_json>
            </cfif>
        <cfcatch type="any">
            <cfset editData.galleryJson = "[]">
            <cfset editData.galleryUrls = []>
        </cfcatch></cftry>
        <cftry>
            <cfif len(trim(editRow.faq_json))>
                <cfset editData.faqItems = deserializeJSON(editRow.faq_json)>
            </cfif>
        <cfcatch type="any">
            <cfset editData.faqItems = []>
        </cfcatch></cftry>
    <cfelse>
        <cflocation url="wedding-sites.cfm" addToken="false">
    </cfif>
<cfelseif len(url.template)>
    <cfset editData.template = url.template>
</cfif>

<cfset isEdit = editData.siteId GT 0>
<cfset pageTitle = isEdit ? "Edit Wedding Site | digitalweddings.love" : "Create Wedding Site | digitalweddings.love">
<cfset activePage = "wedding-sites">
<cfset slugError = url.slugError EQ "1">

<cfinclude template="../includes/layout-start.cfm">

<style>
.ws-tabs { display:flex; border-bottom:2px solid #e5e5e5; margin-bottom:28px; gap:0; }
.ws-tab { padding:14px 20px; font-size:14px; font-weight:500; color:#888; border-bottom:3px solid transparent; cursor:pointer; background:none; border-top:none; border-left:none; border-right:none; margin-bottom:-2px; transition:color 0.2s; }
.ws-tab.active { color:#B8860B; border-bottom-color:#B8860B; font-weight:600; }
.ws-tab:hover:not(.active) { color:#333; }
.ws-field { margin-bottom:20px; }
.ws-label { display:block; font-size:11px; font-weight:700; letter-spacing:0.12em; text-transform:uppercase; color:#555; margin-bottom:7px; }
.ws-input { width:100%; padding:12px 14px; border:1px solid #ddd; border-radius:8px; font-size:14px; color:#1a1a1a; background:#fafaf9; outline:none; transition:border-color 0.2s; box-sizing:border-box; }
.ws-input:focus { border-color:#B8860B; }
.ws-textarea { width:100%; padding:12px 14px; border:1px solid #ddd; border-radius:8px; font-size:14px; color:#1a1a1a; background:#fafaf9; resize:vertical; outline:none; transition:border-color 0.2s; box-sizing:border-box; }
.ws-textarea:focus { border-color:#B8860B; }
.ws-row { display:grid; grid-template-columns:1fr 1fr; gap:16px; }
@media(max-width:520px){ .ws-row{ grid-template-columns:1fr; } }
.ws-slug-wrap { display:flex; border:1px solid #ddd; border-radius:8px; overflow:hidden; }
.ws-slug-prefix { padding:12px 14px; background:#f0ede8; color:#888; font-size:14px; white-space:nowrap; flex-shrink:0; border-right:1px solid #ddd; }
.ws-slug-input { flex:1; padding:12px 14px; border:none; font-size:14px; color:#1a1a1a; background:#fafaf9; outline:none; }
.ws-slug-input:focus { background:#fff; }
.ws-upload-zone { border:2px dashed #ccc; border-radius:10px; display:flex; flex-direction:column; align-items:center; justify-content:center; gap:8px; color:#999; font-size:14px; cursor:pointer; transition:border-color 0.2s; }
.ws-upload-zone:hover { border-color:#B8860B; color:#B8860B; }
.ws-hero-zone { height:140px; }
.ws-faq-block { border:1px solid #e5e5e5; border-radius:10px; padding:16px; margin-bottom:12px; }
.ws-add-q-btn { width:100%; padding:14px; border:1px solid #ddd; border-radius:10px; background:#fff; color:#1a1a1a; font-size:14px; font-weight:500; cursor:pointer; display:flex; align-items:center; justify-content:center; gap:8px; transition:border-color 0.2s; }
.ws-add-q-btn:hover { border-color:#B8860B; color:#B8860B; }
.ws-remove-q { background:none; border:none; color:#aaa; cursor:pointer; font-size:16px; padding:2px 6px; float:right; }
.ws-remove-q:hover { color:#dc2626; }
.ws-error { background:#fee2e2; border:1px solid #fca5a5; color:#dc2626; border-radius:8px; padding:10px 14px; font-size:13px; margin-bottom:20px; }
.ws-submit-btn { padding:16px 48px; background:#B8860B; color:#fff; border:none; border-radius:10px; font-size:15px; font-weight:600; cursor:pointer; letter-spacing:0.03em; transition:background 0.2s; }
.ws-submit-btn:hover { background:#9a700a; }
</style>

<section style="padding:60px 0">
<div class="container" style="max-width:720px">

    <div style="margin-bottom:8px">
        <a href="/members/wedding-sites.cfm" style="font-size:13px;color:var(--gold);text-decoration:none;display:inline-flex;align-items:center;gap:6px">
            <i data-lucide="arrow-left" style="width:14px;height:14px"></i> Back to Wedding Sites
        </a>
    </div>

    <div class="page-header">
        <p class="eyebrow">Your Wedding Website</p>
        <h1><cfoutput>#isEdit ? "Edit" : "Create"#</cfoutput> <span class="script">Wedding Site</span></h1>
        <p style="color:var(--text-muted);margin-top:8px">Each section only appears on your site if you fill it in. Leave a field blank and that section stays hidden from guests.</p>
    </div>

    <div class="panel">

        <cfif slugError><div class="ws-error">That URL is already taken. Please choose a different one.</div></cfif>

        <div class="ws-tabs" style="flex-wrap:wrap">
            <button type="button" class="ws-tab active" onclick="switchTab('basics',this)">Basics</button>
            <button type="button" class="ws-tab" onclick="switchTab('photos',this)">Photos</button>
            <button type="button" class="ws-tab" onclick="switchTab('details',this)">Details</button>
            <button type="button" class="ws-tab" onclick="switchTab('travel',this)">Travel</button>
            <button type="button" class="ws-tab" onclick="switchTab('things',this)">Things to Do</button>
            <button type="button" class="ws-tab" onclick="switchTab('faq',this)">Q &amp; A</button>
        </div>

        <form method="post" action="/members/wedding-site-edit.cfm" id="wsForm">
        <input type="hidden" name="action" value="save">
        <input type="hidden" name="siteId" value="<cfoutput>#HTMLEditFormat(editData.siteId)#</cfoutput>">
        <input type="hidden" name="template" value="<cfoutput>#HTMLEditFormat(editData.template)#</cfoutput>">

        <!--- BASICS --->
        <div id="tab-basics">
            <div class="ws-row">
                <div class="ws-field">
                    <label class="ws-label">Your Name *</label>
                    <input type="text" name="coupleName1" class="ws-input" required placeholder="e.g. Aisha" value="<cfoutput>#HTMLEditFormat(editData.coupleName1)#</cfoutput>">
                </div>
                <div class="ws-field">
                    <label class="ws-label">Partner's Name *</label>
                    <input type="text" name="coupleName2" class="ws-input" required placeholder="e.g. Marcus" value="<cfoutput>#HTMLEditFormat(editData.coupleName2)#</cfoutput>">
                </div>
            </div>
            <div class="ws-field">
                <label class="ws-label">Wedding Date</label>
                <input type="date" name="weddingDate" class="ws-input" value="<cfoutput>#HTMLEditFormat(editData.weddingDate)#</cfoutput>">
            </div>
            <div class="ws-field">
                <label class="ws-label">Ceremony Venue</label>
                <input type="text" name="venueName" class="ws-input" placeholder="e.g. The Grand Ballroom" value="<cfoutput>#HTMLEditFormat(editData.venueName)#</cfoutput>">
            </div>
            <div class="ws-field">
                <label class="ws-label">Ceremony Venue Address</label>
                <input type="text" name="venueAddress" class="ws-input" value="<cfoutput>#HTMLEditFormat(editData.venueAddress)#</cfoutput>">
            </div>
            <div class="ws-field">
                <label class="ws-label">Reception Venue</label>
                <input type="text" name="receptionVenueName" class="ws-input" placeholder="e.g. The Rooftop Ballroom" value="<cfoutput>#HTMLEditFormat(editData.receptionVenueName)#</cfoutput>">
                <p style="font-size:12px;color:#999;margin-top:5px">Leave blank if your ceremony and reception are at the same location.</p>
            </div>
            <div class="ws-field">
                <label class="ws-label">Reception Venue Address</label>
                <input type="text" name="receptionVenueAddress" class="ws-input" value="<cfoutput>#HTMLEditFormat(editData.receptionVenueAddress)#</cfoutput>">
            </div>
            <div class="ws-field">
                <label class="ws-label">Your Love Story</label>
                <textarea name="story" class="ws-textarea" rows="5" placeholder="Tell your guests how you met and fell in love..."><cfoutput>#HTMLEditFormat(editData.story)#</cfoutput></textarea>
            </div>
            <cfif editData.template EQ "islamic_elegance">
            <div class="ws-field" style="background:#fefce8;border:1px solid #fde68a;border-radius:8px;padding:14px">
                <label class="ws-label" style="color:#92400e">Opening Dua / Blessing</label>
                <input type="text" name="scripture" class="ws-input" style="margin-top:6px" placeholder='e.g. "And among His signs..." — Quran 30:21' value="<cfoutput>#HTMLEditFormat(editData.scripture)#</cfoutput>">
            </div>
            <cfelseif editData.template EQ "christian_sacred">
            <div class="ws-field" style="background:#fffbeb;border:1px solid #fcd34d;border-radius:8px;padding:14px">
                <label class="ws-label" style="color:#92400e">Wedding Scripture</label>
                <input type="text" name="scripture" class="ws-input" style="margin-top:6px" placeholder='e.g. "Two are better than one..." — Ecclesiastes 4:9' value="<cfoutput>#HTMLEditFormat(editData.scripture)#</cfoutput>">
            </div>
            <cfelse>
            <input type="hidden" name="scripture" value="<cfoutput>#HTMLEditFormat(editData.scripture)#</cfoutput>">
            </cfif>
            <div class="ws-field">
                <label class="ws-label">Your Custom URL *</label>
                <div class="ws-slug-wrap">
                    <span class="ws-slug-prefix">digitalweddings.love/</span>
                    <input type="text" name="slug" id="slugInput" class="ws-slug-input" placeholder="billandjane" value="<cfoutput>#HTMLEditFormat(editData.slug)#</cfoutput>" oninput="scheduleSlugCheck()" onblur="checkSlugNow()">
                </div>
                <p id="slugStatus" style="font-size:12px;margin-top:5px;color:#999">Letters, numbers, hyphens only. e.g. "billandjane"</p>
            </div>
            <div style="display:flex;align-items:center;gap:10px;margin-top:4px">
                <input type="checkbox" name="published" id="cbPublished" <cfif editData.published>checked</cfif> style="width:16px;height:16px;accent-color:#B8860B">
                <label for="cbPublished" style="font-size:13px;color:#555;cursor:pointer">Publish my wedding website (make it publicly accessible)</label>
            </div>
        </div>

        <!--- PHOTOS --->
        <div id="tab-photos" style="display:none">
            <cfif isEdit>
                <!--- Show current hero thumbnail if set --->
                <cfif len(editData.heroImageUrl)>
                <div style="margin-bottom:20px">
                    <p class="ws-label">Current Hero Photo</p>
                    <img src="<cfoutput>#HTMLEditFormat(editData.heroImageUrl)#</cfoutput>" alt="Hero photo" style="max-width:100%;max-height:200px;border-radius:8px;border:1px solid #e5e5e5;display:block;margin-bottom:8px">
                </div>
                </cfif>
                <!--- Show gallery count --->
                <cfif arrayLen(editData.galleryUrls)>
                <div style="margin-bottom:20px">
                    <p class="ws-label">Gallery (<cfoutput>#arrayLen(editData.galleryUrls)#</cfoutput> photo<cfif arrayLen(editData.galleryUrls) NEQ 1>s</cfif>)</p>
                    <div style="display:grid;grid-template-columns:repeat(auto-fill,minmax(80px,1fr));gap:6px;margin-bottom:10px">
                    <cfloop array="#editData.galleryUrls#" item="gUrl">
                    <div style="aspect-ratio:1;border-radius:6px;overflow:hidden;border:1px solid #e5e5e5">
                        <img src="<cfoutput>#HTMLEditFormat(gUrl)#</cfoutput>" style="width:100%;height:100%;object-fit:cover">
                    </div>
                    </cfloop>
                    </div>
                </div>
                </cfif>
                <a href="/members/upload-photos.cfm?siteId=<cfoutput>#editData.siteId#</cfoutput>" class="ws-add-q-btn" style="display:flex;text-decoration:none;color:inherit">
                    <i data-lucide="image" style="width:16px;height:16px"></i> Manage Photos
                </a>
                <p style="font-size:12px;color:#999;margin-top:8px">Upload or remove your hero photo and gallery photos on the photo management page.</p>
            <cfelse>
                <p style="font-size:13px;color:#888">Save your site first, then you can upload photos.</p>
            </cfif>
            <input type="hidden" name="heroImageUrl" value="<cfoutput>#HTMLEditFormat(editData.heroImageUrl)#</cfoutput>">
            <input type="hidden" name="couplePhotoUrl" value="<cfoutput>#HTMLEditFormat(editData.couplePhotoUrl)#</cfoutput>">
            <input type="hidden" name="galleryImagesJson" value="<cfoutput>#HTMLEditFormat(editData.galleryJson)#</cfoutput>">
        </div>

        <!--- DETAILS --->
        <div id="tab-details" style="display:none">
            <div class="ws-field">
                <label class="ws-label">Dress Code</label>
                <textarea name="dressCode" class="ws-textarea" rows="3" placeholder="e.g. Black tie optional. We encourage guests to wear earth tones..."><cfoutput>#HTMLEditFormat(editData.dressCode)#</cfoutput></textarea>
            </div>
        </div>

        <!--- TRAVEL --->
        <div id="tab-travel" style="display:none">
            <p style="font-size:14px;color:#888;margin-bottom:20px">Describe how to get there and where to stay. Add buttons guests can click for maps, hotel pages, or directions.</p>
            <div class="ws-field">
                <label class="ws-label">Travel &amp; Accommodations</label>
                <textarea name="travelInfo" class="ws-textarea" rows="4" placeholder="Nearby hotels, airport information, directions..."><cfoutput>#HTMLEditFormat(editData.travelInfo)#</cfoutput></textarea>
            </div>
            <div class="ws-field">
                <label class="ws-label">Links</label>
                <div id="travelLinkList">
                    <cfif arrayLen(editData.travelLinks)>
                    <cfloop from="1" to="#arrayLen(editData.travelLinks)#" index="tli">
                    <cfoutput>
                    <div class="ws-faq-block" id="travelLinkBlock_#tli#" style="margin-bottom:10px">
                        <button type="button" class="ws-remove-q" onclick="removeTravelLink(#tli#)">&times;</button>
                        <div class="ws-row">
                            <div class="ws-field" style="margin-bottom:0">
                                <label class="ws-label">Button Label</label>
                                <input type="text" name="travelLinkLabel#tli#" class="ws-input" placeholder="e.g. View on Google Maps" value="#HTMLEditFormat(editData.travelLinks[tli].label)#">
                            </div>
                            <div class="ws-field" style="margin-bottom:0">
                                <label class="ws-label">URL</label>
                                <input type="url" name="travelLinkUrl#tli#" class="ws-input" placeholder="https://maps.google.com/..." value="#HTMLEditFormat(editData.travelLinks[tli].url)#">
                            </div>
                        </div>
                    </div>
                    </cfoutput>
                    </cfloop>
                    </cfif>
                </div>
                <button type="button" class="ws-add-q-btn" onclick="addTravelLink()">
                    <i data-lucide="plus" style="width:16px;height:16px"></i> Add Link
                </button>
            </div>
        </div>

        <!--- THINGS TO DO --->
        <div id="tab-things" style="display:none">
            <p style="font-size:14px;color:#888;margin-bottom:20px">Share local attractions, restaurants, and activities for out-of-town guests. Add links to guides or reservation pages.</p>
            <div class="ws-field">
                <label class="ws-label">Things to Do</label>
                <textarea name="thingsToDo" class="ws-textarea" rows="4" placeholder="Local attractions, restaurants, activities for out-of-town guests..."><cfoutput>#HTMLEditFormat(editData.thingsToDo)#</cfoutput></textarea>
            </div>
            <div class="ws-field">
                <label class="ws-label">Links</label>
                <div id="thingsLinkList">
                    <cfif arrayLen(editData.thingsLinks)>
                    <cfloop from="1" to="#arrayLen(editData.thingsLinks)#" index="tdi">
                    <cfoutput>
                    <div class="ws-faq-block" id="thingsLinkBlock_#tdi#" style="margin-bottom:10px">
                        <button type="button" class="ws-remove-q" onclick="removeThingsLink(#tdi#)">&times;</button>
                        <div class="ws-row">
                            <div class="ws-field" style="margin-bottom:0">
                                <label class="ws-label">Button Label</label>
                                <input type="text" name="thingsLinkLabel#tdi#" class="ws-input" placeholder="e.g. Explore the City" value="#HTMLEditFormat(editData.thingsLinks[tdi].label)#">
                            </div>
                            <div class="ws-field" style="margin-bottom:0">
                                <label class="ws-label">URL</label>
                                <input type="url" name="thingsLinkUrl#tdi#" class="ws-input" placeholder="https://..." value="#HTMLEditFormat(editData.thingsLinks[tdi].url)#">
                            </div>
                        </div>
                    </div>
                    </cfoutput>
                    </cfloop>
                    </cfif>
                </div>
                <button type="button" class="ws-add-q-btn" onclick="addThingsLink()">
                    <i data-lucide="plus" style="width:16px;height:16px"></i> Add Link
                </button>
            </div>
        </div>

        <!--- FAQ --->
        <div id="tab-faq" style="display:none">
            <p style="font-size:14px;color:#888;margin-bottom:20px">Add frequently asked questions to help your guests.</p>
            <div id="faqList">
                <cfif arrayLen(editData.faqItems)>
                <cfloop from="1" to="#arrayLen(editData.faqItems)#" index="fi">
                <cfoutput>
                <div class="ws-faq-block" id="faqBlock_#fi#">
                    <button type="button" class="ws-remove-q" onclick="removeFaq(#fi#)">&times;</button>
                    <div class="ws-field">
                        <label class="ws-label">Question</label>
                        <input type="text" name="faqQ#fi#" class="ws-input" placeholder="e.g. Is there parking at the venue?" value="#HTMLEditFormat(editData.faqItems[fi].question)#">
                    </div>
                    <div class="ws-field" style="margin-bottom:0">
                        <label class="ws-label">Answer</label>
                        <textarea name="faqA#fi#" class="ws-textarea" rows="2" placeholder="Yes, free parking is available on-site.">#HTMLEditFormat(editData.faqItems[fi].answer)#</textarea>
                    </div>
                </div>
                </cfoutput>
                </cfloop>
                </cfif>
            </div>
            <button type="button" class="ws-add-q-btn" onclick="addFaq()">
                <i data-lucide="plus" style="width:16px;height:16px"></i> Add Question
            </button>
        </div>

        <div style="margin-top:28px;padding-top:20px;border-top:1px solid #eee;display:flex;gap:12px;align-items:center;flex-wrap:wrap">
            <button type="submit" class="ws-submit-btn">
                <cfoutput>#isEdit ? "Update Wedding Site" : "Create Wedding Site"#</cfoutput>
            </button>
            <cfif isEdit>
            <a href="/site.cfm?siteId=<cfoutput>#editData.siteId#</cfoutput>&preview=1" target="_blank" class="btn btn-secondary" style="display:inline-flex;align-items:center;gap:6px">
                <i data-lucide="eye" style="width:14px;height:14px"></i> Preview Site
            </a>
            </cfif>
            <a href="/members/wedding-sites.cfm" class="btn btn-secondary">Cancel</a>
        </div>

        </form>
    </div>

</div>
</section>

<script>
var faqCount = <cfoutput>#arrayLen(editData.faqItems)#</cfoutput>;
var travelLinkCount = <cfoutput>#arrayLen(editData.travelLinks)#</cfoutput>;
var thingsLinkCount = <cfoutput>#arrayLen(editData.thingsLinks)#</cfoutput>;
var currentSiteId = '<cfoutput>#JSStringFormat(editData.siteId)#</cfoutput>';
var slugTimer = null;
var lastCheckedSlug = '';

function scheduleSlugCheck() {
    clearTimeout(slugTimer);
    slugTimer = setTimeout(checkSlugNow, 600);
}

function checkSlugNow() {
    var raw = document.getElementById('slugInput').value.trim();
    var slug = raw.toLowerCase().replace(/[^a-z0-9\-]/g, '');
    var status = document.getElementById('slugStatus');
    if (!slug || slug.length < 2) {
        status.style.color = '#999';
        status.textContent = 'Letters, numbers, hyphens only. e.g. "billandjane"';
        return;
    }
    if (slug === lastCheckedSlug) return;
    lastCheckedSlug = slug;
    status.style.color = '#888';
    status.innerHTML = 'Checking availability...';
    var xhr = new XMLHttpRequest();
    var url = '/members/check-slug.cfm?slug=' + encodeURIComponent(slug) + (currentSiteId ? '&siteId=' + encodeURIComponent(currentSiteId) : '');
    xhr.open('GET', url, true);
    xhr.onload = function() {
        try {
            var res = JSON.parse(xhr.responseText);
            if (res.available) {
                status.style.color = '#059669';
                status.innerHTML = '&#10003; &ldquo;' + res.slug + '&rdquo; is available!';
            } else {
                status.style.color = '#dc2626';
                status.innerHTML = '&#10007; &ldquo;' + res.slug + '&rdquo; is already taken. Please choose another.';
            }
        } catch(e) {
            status.style.color = '#999';
            status.textContent = 'Could not check availability.';
        }
    };
    xhr.onerror = function() {
        status.style.color = '#999';
        status.textContent = 'Could not check availability.';
    };
    xhr.send();
}

function switchTab(name, btn) {
    ['basics','photos','details','travel','things','faq'].forEach(function(t) {
        document.getElementById('tab-' + t).style.display = t === name ? 'block' : 'none';
    });
    document.querySelectorAll('.ws-tab').forEach(function(b) { b.classList.remove('active'); });
    btn.classList.add('active');
    lucide.createIcons();
}

function addFaq() {
    faqCount++;
    var div = document.createElement('div');
    div.className = 'ws-faq-block';
    div.id = 'faqBlock_' + faqCount;
    div.innerHTML = '<button type="button" class="ws-remove-q" onclick="removeFaq(' + faqCount + ')">&times;<\/button>' +
        '<div class="ws-field"><label class="ws-label">Question<\/label>' +
        '<input type="text" name="faqQ' + faqCount + '" class="ws-input" placeholder="e.g. Is there parking at the venue?"><\/div>' +
        '<div class="ws-field" style="margin-bottom:0"><label class="ws-label">Answer<\/label>' +
        '<textarea name="faqA' + faqCount + '" class="ws-textarea" rows="2" placeholder="Yes, free parking is available on-site."><\/textarea><\/div>';
    document.getElementById('faqList').appendChild(div);
}

function removeFaq(id) {
    var el = document.getElementById('faqBlock_' + id);
    if (el) el.remove();
}

function addTravelLink() {
    travelLinkCount++;
    var div = document.createElement('div');
    div.className = 'ws-faq-block';
    div.id = 'travelLinkBlock_' + travelLinkCount;
    div.style.marginBottom = '10px';
    div.innerHTML = '<button type="button" class="ws-remove-q" onclick="removeTravelLink(' + travelLinkCount + ')">&times;<\/button>' +
        '<div class="ws-row">' +
        '<div class="ws-field" style="margin-bottom:0"><label class="ws-label">Button Label<\/label>' +
        '<input type="text" name="travelLinkLabel' + travelLinkCount + '" class="ws-input" placeholder="e.g. View on Google Maps"><\/div>' +
        '<div class="ws-field" style="margin-bottom:0"><label class="ws-label">URL<\/label>' +
        '<input type="url" name="travelLinkUrl' + travelLinkCount + '" class="ws-input" placeholder="https://maps.google.com/..."><\/div>' +
        '<\/div>';
    document.getElementById('travelLinkList').appendChild(div);
}

function removeTravelLink(id) {
    var el = document.getElementById('travelLinkBlock_' + id);
    if (el) el.remove();
}

function addThingsLink() {
    thingsLinkCount++;
    var div = document.createElement('div');
    div.className = 'ws-faq-block';
    div.id = 'thingsLinkBlock_' + thingsLinkCount;
    div.style.marginBottom = '10px';
    div.innerHTML = '<button type="button" class="ws-remove-q" onclick="removeThingsLink(' + thingsLinkCount + ')">&times;<\/button>' +
        '<div class="ws-row">' +
        '<div class="ws-field" style="margin-bottom:0"><label class="ws-label">Button Label<\/label>' +
        '<input type="text" name="thingsLinkLabel' + thingsLinkCount + '" class="ws-input" placeholder="e.g. Explore the City"><\/div>' +
        '<div class="ws-field" style="margin-bottom:0"><label class="ws-label">URL<\/label>' +
        '<input type="url" name="thingsLinkUrl' + thingsLinkCount + '" class="ws-input" placeholder="https://..."><\/div>' +
        '<\/div>';
    document.getElementById('thingsLinkList').appendChild(div);
}

function removeThingsLink(id) {
    var el = document.getElementById('thingsLinkBlock_' + id);
    if (el) el.remove();
}

window.addEventListener('DOMContentLoaded', function() {
    <cfif slugError>switchTab('basics', document.querySelector('.ws-tab'));</cfif>
});
</script>

<cfinclude template="../includes/layout-end.cfm">
