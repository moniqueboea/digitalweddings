<cfparam name="url.slug" default="">
<cfparam name="url.siteId" default="0">
<cfparam name="url.preview" default="0">
<cfset slug = lCase(reReplace(trim(url.slug),"[^a-z0-9\-]","","all"))>
<cfset isPreview = (url.preview EQ "1" && isNumeric(url.siteId) && url.siteId GT 0)>

<!--- Preview mode: load by siteId only if user owns it --->
<cfif isPreview>
    <cfif !structKeyExists(session,"user") || !structKeyExists(session.user,"id")>
        <cflocation url="/login.cfm" addToken="false">
    </cfif>
    <cfquery name="qSite" datasource="#application.config.datasource#">
        SELECT * FROM dbo.WeddingSites
        WHERE wedding_site_id = <cfqueryparam value="#url.siteId#" cfsqltype="cf_sql_bigint">
          AND user_id = <cfqueryparam value="#session.user.id#" cfsqltype="cf_sql_bigint">
    </cfquery>
    <cfset notFound = (qSite.recordCount EQ 0)>
<!--- Normal mode: load by slug, must be published --->
<cfelseif len(slug)>
    <cfquery name="qSite" datasource="#application.config.datasource#">
        SELECT * FROM dbo.WeddingSites
        WHERE slug = <cfqueryparam value="#slug#" cfsqltype="cf_sql_varchar">
          AND published = 1
    </cfquery>
    <cfset notFound = (qSite.recordCount EQ 0)>
<cfelse>
    <cfset notFound = true>
</cfif>

<!--- Not found page --->
<cfif notFound>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Site Not Found | digitalweddings.love</title>
<style>
body{margin:0;font-family:Georgia,serif;background:#FDFAF5;color:#2C2C2C;display:flex;align-items:center;justify-content:center;min-height:100vh;text-align:center;padding:40px}
h1{font-size:2rem;margin-bottom:16px}
p{opacity:0.6;margin-bottom:24px}
a{color:#B8860B}
</style>
</head>
<body>
<div>
  <p style="font-size:3rem;margin-bottom:16px">&#128141;</p>
  <h1>Wedding Site Not Found</h1>
  <p>This wedding site doesn&rsquo;t exist or hasn&rsquo;t been published yet.</p>
  <a href="/index.cfm">Return Home</a>
</div>
</body>
</html>
<cfabort>
</cfif>

<!--- Validate template --->
<cfset tplId = lCase(trim(qSite.template))>
<cfinclude template="includes/template-list.cfm">
<cfif !listFind(application.templates, tplId)>
    <cfset tplId = "classic_gold">
</cfif>

<!--- Look up registry link for this site's owner --->
<cfset siteOwnerId = listFindNoCase(qSite.columnList,"user_id") ? qSite.user_id : 0>
<cfset registryUrl = "">
<cfif siteOwnerId GT 0>
    <cfquery name="qRegistry" datasource="#application.config.datasource#">
        SELECT physical_registry_link FROM dbo.GiftRegistries
        WHERE user_id = <cfqueryparam value="#siteOwnerId#" cfsqltype="cf_sql_bigint">
          AND physical_registry_link IS NOT NULL
          AND physical_registry_link <> ''
    </cfquery>
    <cfif qRegistry.recordCount AND len(trim(qRegistry.physical_registry_link))>
        <cfset registryUrl = trim(qRegistry.physical_registry_link)>
    </cfif>
</cfif>

<!--- Build site struct from query row --->
<cfset site = {
    couple_name_1:       trim(qSite.couple_name_1),
    couple_name_2:       trim(qSite.couple_name_2),
    wedding_date:        trim(qSite.wedding_date),
    venue_name:                trim(qSite.venue_name),
    venue_address:             trim(qSite.venue_address),
    reception_venue_name:      listFindNoCase(qSite.columnList,"reception_venue_name") ? trim(qSite.reception_venue_name) : "",
    reception_venue_address:   listFindNoCase(qSite.columnList,"reception_venue_address") ? trim(qSite.reception_venue_address) : "",
    story:               trim(qSite.story),
    dress_code:          trim(qSite.dress_code),
    travel_info:         trim(qSite.travel_info),
    travel_links_json:   listFindNoCase(qSite.columnList,"travel_links_json") ? trim(qSite.travel_links_json) : "",
    things_to_do:        trim(qSite.things_to_do),
    things_links_json:   listFindNoCase(qSite.columnList,"things_links_json") ? trim(qSite.things_links_json) : "",
    scripture:           trim(qSite.scripture),
    hero_image_url:      trim(qSite.hero_image_url),
    couple_photo_url:    listFindNoCase(qSite.columnList,"couple_photo_url") ? trim(qSite.couple_photo_url) : "",
    gallery_images_json: trim(qSite.gallery_images_json),
    faq_json:            trim(qSite.faq_json),
    slug:                trim(qSite.slug),
    is_preview:          isPreview,
    registry_url:        registryUrl
}>

<!--- Render the selected template --->
<cfinclude template="members/templates/#tplId#.cfm">
