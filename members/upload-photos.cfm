<cfinclude template="../includes/auth-check.cfm">
<cfparam name="url.siteId" default="0">
<cfparam name="form.action" default="">

<cfset userId    = session.user.id>
<cfset siteId    = isNumeric(url.siteId) && url.siteId GT 0 ? val(url.siteId) : 0>
<cfset uploadDir = expandPath("/uploads/wedding-images/")>
<cfset messages  = []>
<cfset errors    = []>

<!--- Ensure couple_photo_url column exists --->
<cftry>
<cfquery datasource="#application.config.datasource#">
    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='WeddingSites' AND COLUMN_NAME='couple_photo_url')
        ALTER TABLE dbo.WeddingSites ADD couple_photo_url NVARCHAR(MAX) NULL;
</cfquery>
<cfcatch type="any"></cfcatch>
</cftry>

<!--- Create upload dir if needed --->
<cfif !directoryExists(uploadDir)>
    <cftry>
        <cfdirectory action="create" directory="#uploadDir#">
    <cfcatch type="any">
        <cflog file="digitalweddings_errors" type="error" text="upload-photos mkdir failed: #cfcatch.message# USER=#userId#">
        <cfset arrayAppend(errors, "Upload folder is unavailable. Please contact support.")>
    </cfcatch>
    </cftry>
</cfif>

<!--- Load site record --->
<cfif siteId GT 0>
    <cfquery name="qSite" datasource="#application.config.datasource#">
        SELECT wedding_site_id, couple_name_1, couple_name_2, hero_image_url, couple_photo_url, gallery_images_json
        FROM dbo.WeddingSites
        WHERE wedding_site_id = <cfqueryparam value="#siteId#" cfsqltype="cf_sql_bigint">
          AND user_id          = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
    </cfquery>
    <cfif !qSite.recordCount>
        <cflocation url="wedding-sites.cfm" addToken="false">
    </cfif>
<cfelse>
    <cflocation url="wedding-sites.cfm" addToken="false">
</cfif>

<cfset currentHero        = len(trim(qSite.hero_image_url)) ? trim(qSite.hero_image_url) : "">
<cfset currentCouple = structKeyExists(qSite,"couple_photo_url") && len(trim(qSite.couple_photo_url)) ? trim(qSite.couple_photo_url) : "">
<cfset galleryList    = []>
<cftry>
    <cfif len(trim(qSite.gallery_images_json))>
        <cfset galleryList = deserializeJSON(qSite.gallery_images_json)>
    </cfif>
<cfcatch type="any"><cfset galleryList = []></cfcatch>
</cftry>

<!--- ===== HANDLE HERO UPLOAD ===== --->
<cfif form.action EQ "uploadHero">
<cftry>
    <cfif !structKeyExists(form,"heroFile") || !len(trim(form.heroFile))>
        <cfset arrayAppend(errors, "Please choose an image file to upload.")>
    <cfelse>
        <cffile action="upload"
                filefield="heroFile"
                destination="#uploadDir#"
                accept="image/jpeg,image/jpg,image/png,image/gif,image/webp"
                nameconflict="makeunique">
        <cfset newUrl = "/uploads/wedding-images/" & cffile.serverFile>
        <cfquery datasource="#application.config.datasource#">
            UPDATE dbo.WeddingSites
            SET hero_image_url = <cfqueryparam value="#newUrl#" cfsqltype="cf_sql_nvarchar">,
                updated_at     = SYSUTCDATETIME()
            WHERE wedding_site_id = <cfqueryparam value="#siteId#" cfsqltype="cf_sql_bigint">
              AND user_id          = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
        </cfquery>
        <cfset currentHero = newUrl>
        <cfset arrayAppend(messages, "Hero photo uploaded successfully.")>
    </cfif>
<cfcatch type="any">
    <cflog file="digitalweddings_errors" type="error" text="upload-photos hero failed: #cfcatch.message# USER=#userId#">
    <cfset arrayAppend(errors, "Hero photo upload failed. Please try again or contact support.")>
</cfcatch>
</cftry>
</cfif>

<!--- ===== HANDLE REMOVE HERO ===== --->
<cfif form.action EQ "removeHero">
    <cfquery datasource="#application.config.datasource#">
        UPDATE dbo.WeddingSites
        SET hero_image_url = NULL,
            updated_at     = SYSUTCDATETIME()
        WHERE wedding_site_id = <cfqueryparam value="#siteId#" cfsqltype="cf_sql_bigint">
          AND user_id          = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
    </cfquery>
    <cfset currentHero = "">
    <cfset arrayAppend(messages, "Hero photo removed.")>
</cfif>

<!--- ===== HANDLE COUPLE PHOTO UPLOAD ===== --->
<cfif form.action EQ "uploadCouple">
<cftry>
    <cfif !structKeyExists(form,"coupleFile") || !len(trim(form.coupleFile))>
        <cfset arrayAppend(errors, "Please choose an image file to upload.")>
    <cfelse>
        <cffile action="upload"
                filefield="coupleFile"
                destination="#uploadDir#"
                accept="image/jpeg,image/jpg,image/png,image/gif,image/webp"
                nameconflict="makeunique">
        <cfset newUrl = "/uploads/wedding-images/" & cffile.serverFile>
        <cfquery datasource="#application.config.datasource#">
            UPDATE dbo.WeddingSites
            SET couple_photo_url = <cfqueryparam value="#newUrl#" cfsqltype="cf_sql_nvarchar">,
                updated_at       = SYSUTCDATETIME()
            WHERE wedding_site_id = <cfqueryparam value="#siteId#" cfsqltype="cf_sql_bigint">
              AND user_id          = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
        </cfquery>
        <cfset currentCouple = newUrl>
        <cfset arrayAppend(messages, "Couple photo uploaded successfully.")>
    </cfif>
<cfcatch type="any">
    <cflog file="digitalweddings_errors" type="error" text="upload-photos couple failed: #cfcatch.message# USER=#userId#">
    <cfset arrayAppend(errors, "Couple photo upload failed. Please try again or contact support.")>
</cfcatch>
</cftry>
</cfif>

<!--- ===== HANDLE REMOVE COUPLE PHOTO ===== --->
<cfif form.action EQ "removeCouple">
    <cfquery datasource="#application.config.datasource#">
        UPDATE dbo.WeddingSites
        SET couple_photo_url = NULL,
            updated_at       = SYSUTCDATETIME()
        WHERE wedding_site_id = <cfqueryparam value="#siteId#" cfsqltype="cf_sql_bigint">
          AND user_id          = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
    </cfquery>
    <cfset currentCouple = "">
    <cfset arrayAppend(messages, "Couple photo removed.")>
</cfif>

<!--- ===== HANDLE GALLERY UPLOAD ===== --->
<cfif form.action EQ "uploadGallery">
<cftry>
    <cfif !structKeyExists(form,"galleryFile") || !len(trim(form.galleryFile))>
        <cfset arrayAppend(errors, "Please choose an image file to upload.")>
    <cfelseif arrayLen(galleryList) GTE 10>
        <cfset arrayAppend(errors, "You have reached the maximum of 10 gallery photos. Remove one before adding more.")>
    <cfelse>
        <cffile action="upload"
                filefield="galleryFile"
                destination="#uploadDir#"
                accept="image/jpeg,image/jpg,image/png,image/gif,image/webp"
                nameconflict="makeunique">
        <cfset newUrl = "/uploads/wedding-images/" & cffile.serverFile>
        <cfset arrayAppend(galleryList, newUrl)>
        <cfquery datasource="#application.config.datasource#">
            UPDATE dbo.WeddingSites
            SET gallery_images_json = <cfqueryparam value="#serializeJSON(galleryList)#" cfsqltype="cf_sql_nvarchar">,
                updated_at          = SYSUTCDATETIME()
            WHERE wedding_site_id = <cfqueryparam value="#siteId#" cfsqltype="cf_sql_bigint">
              AND user_id          = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
        </cfquery>
        <cfset arrayAppend(messages, "Photo added to gallery.")>
    </cfif>
<cfcatch type="any">
    <cflog file="digitalweddings_errors" type="error" text="upload-photos gallery failed: #cfcatch.message# USER=#userId#">
    <cfset arrayAppend(errors, "Gallery photo upload failed. Please try again or contact support.")>
</cfcatch>
</cftry>
</cfif>

<!--- ===== HANDLE REMOVE GALLERY PHOTO ===== --->
<cfif form.action EQ "removeGallery" && structKeyExists(form,"removeIndex") && isNumeric(form.removeIndex)>
    <cfset ri = val(form.removeIndex)>
    <cfif ri GTE 1 && ri LTE arrayLen(galleryList)>
        <cfset arrayDeleteAt(galleryList, ri)>
        <cfquery datasource="#application.config.datasource#">
            UPDATE dbo.WeddingSites
            SET gallery_images_json = <cfqueryparam value="#serializeJSON(galleryList)#" cfsqltype="cf_sql_nvarchar">,
                updated_at          = SYSUTCDATETIME()
            WHERE wedding_site_id = <cfqueryparam value="#siteId#" cfsqltype="cf_sql_bigint">
              AND user_id          = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
        </cfquery>
        <cfset arrayAppend(messages, "Photo removed from gallery.")>
    </cfif>
</cfif>

<cfset pageTitle  = "Upload Photos | digitalweddings.love">
<cfset activePage = "wedding-sites">
<cfinclude template="../includes/layout-start.cfm">

<style>
.up-section   { background:#fff; border:1px solid #e5e5e5; border-radius:12px; padding:28px; margin-bottom:24px; }
.up-title     { font-size:13px; font-weight:700; letter-spacing:.1em; text-transform:uppercase; color:#555; margin-bottom:16px; }
.up-btn       { display:inline-block; padding:11px 28px; background:#B8860B; color:#fff; border:none; border-radius:8px; font-size:14px; font-weight:600; cursor:pointer; text-decoration:none; }
.up-btn:hover { background:#9a700a; }
.up-btn-sm    { padding:8px 18px; font-size:13px; }
.up-btn-danger{ background:#dc2626; }
.up-btn-danger:hover{ background:#b91c1c; }
.up-btn-sec   { background:#fff; color:#555; border:1px solid #ddd; }
.up-btn-sec:hover{ border-color:#B8860B; color:#B8860B; background:#fff; }
.up-file-row  { display:flex; gap:10px; align-items:flex-end; flex-wrap:wrap; }
.up-file-input{ flex:1; min-width:200px; padding:10px 12px; border:1px solid #ddd; border-radius:8px; font-size:14px; background:#fafaf9; }
.up-hero-img  { max-width:100%; max-height:260px; border-radius:8px; display:block; margin-bottom:14px; border:1px solid #e5e5e5; }
.up-gallery   { display:grid; grid-template-columns:repeat(auto-fill,minmax(130px,1fr)); gap:10px; margin-bottom:16px; }
.up-gallery-item { position:relative; aspect-ratio:1; border-radius:8px; overflow:hidden; border:1px solid #e5e5e5; }
.up-gallery-item img { width:100%; height:100%; object-fit:cover; display:block; }
.up-remove-btn { position:absolute; top:4px; right:4px; width:24px; height:24px; border-radius:50%; background:rgba(220,38,38,.85); color:#fff; border:none; font-size:15px; line-height:1; cursor:pointer; display:flex; align-items:center; justify-content:center; padding:0; }
.up-msg  { padding:10px 14px; border-radius:8px; font-size:13px; margin-bottom:16px; }
.up-msg-ok   { background:#dcfce7; border:1px solid #86efac; color:#166534; }
.up-msg-err  { background:#fee2e2; border:1px solid #fca5a5; color:#dc2626; }
.up-hint { font-size:12px; color:#999; margin-top:6px; }
</style>

<section style="padding:60px 0">
<div class="container" style="max-width:680px">

    <div style="margin-bottom:8px">
        <a href="/members/wedding-site-edit.cfm?siteId=<cfoutput>#siteId#</cfoutput>" style="font-size:13px;color:var(--gold);text-decoration:none;display:inline-flex;align-items:center;gap:6px">
            <i data-lucide="arrow-left" style="width:14px;height:14px"></i> Back to Editor
        </a>
    </div>

    <div class="page-header">
        <p class="eyebrow">Wedding Site Photos</p>
        <h1><cfoutput>#HTMLEditFormat(qSite.couple_name_1)# &amp; #HTMLEditFormat(qSite.couple_name_2)#</cfoutput> &mdash; <span class="script">Upload Photos</span></h1>
    </div>

    <cfif arrayLen(messages)>
    <cfloop array="#messages#" item="msg">
    <div class="up-msg up-msg-ok"><cfoutput>#HTMLEditFormat(msg)#</cfoutput></div>
    </cfloop>
    </cfif>

    <cfif arrayLen(errors)>
    <cfloop array="#errors#" item="err">
    <div class="up-msg up-msg-err"><cfoutput>#HTMLEditFormat(err)#</cfoutput></div>
    </cfloop>
    </cfif>

    <!--- ===== COUPLE PHOTO ===== --->
    <div class="up-section">
        <p class="up-title">Couple Photo</p>
        <p style="font-size:13px;color:#777;margin-bottom:16px">A portrait of you two displayed as a circle just below your names on the wedding site. Best with a square or portrait-oriented photo. Optional &mdash; leave blank to skip.</p>

        <cfif len(currentCouple)>
            <div style="display:flex;align-items:center;gap:20px;margin-bottom:16px;flex-wrap:wrap">
                <img src="<cfoutput>#HTMLEditFormat(currentCouple)#</cfoutput>" alt="Couple photo" style="width:110px;height:110px;border-radius:50%;object-fit:cover;border:3px solid #e5e5e5;flex-shrink:0">
                <div>
                    <p style="font-size:13px;color:#555;margin-bottom:10px">Looking great! Upload a new photo below to replace it.</p>
                    <form method="post" action="/members/upload-photos.cfm?siteId=<cfoutput>#siteId#</cfoutput>" style="display:inline">
                        <input type="hidden" name="action" value="removeCouple">
                        <button type="submit" class="up-btn up-btn-sm up-btn-danger" onclick="return confirm('Remove couple photo?')">Remove Photo</button>
                    </form>
                </div>
            </div>
        <cfelse>
            <p style="font-size:13px;color:#aaa;margin-bottom:14px;font-style:italic">No couple photo uploaded yet.</p>
        </cfif>

        <form method="post" action="/members/upload-photos.cfm?siteId=<cfoutput>#siteId#</cfoutput>" enctype="multipart/form-data">
            <input type="hidden" name="action" value="uploadCouple">
            <div class="up-file-row">
                <input type="file" name="coupleFile" class="up-file-input" accept="image/jpeg,image/jpg,image/png,image/gif,image/webp" required>
                <button type="submit" class="up-btn up-btn-sm">Upload Couple Photo</button>
            </div>
            <p class="up-hint">Square crop works best &bull; JPG, PNG, or WebP &bull; Will be displayed as a circle</p>
        </form>
    </div>

    <!--- ===== GALLERY ===== --->
    <div class="up-section">
        <p class="up-title">Photo Gallery (<cfoutput>#arrayLen(galleryList)#</cfoutput> / 10)</p>
        <p style="font-size:13px;color:#777;margin-bottom:16px">Upload up to 10 photos for your gallery section. Upload one at a time.</p>

        <cfif arrayLen(galleryList)>
        <div class="up-gallery">
        <cfloop from="1" to="#arrayLen(galleryList)#" index="gi">
        <cfoutput>
        <div class="up-gallery-item">
            <img src="#HTMLEditFormat(galleryList[gi])#" alt="Gallery photo #gi#">
            <form method="post" action="/members/upload-photos.cfm?siteId=#siteId#" style="margin:0">
                <input type="hidden" name="action" value="removeGallery">
                <input type="hidden" name="removeIndex" value="#gi#">
                <button type="submit" class="up-remove-btn" title="Remove photo" onclick="return confirm('Remove this photo?')">&times;</button>
            </form>
        </div>
        </cfoutput>
        </cfloop>
        </div>
        </cfif>

        <cfif arrayLen(galleryList) LT 10>
        <form method="post" action="/members/upload-photos.cfm?siteId=<cfoutput>#siteId#</cfoutput>" enctype="multipart/form-data">
            <input type="hidden" name="action" value="uploadGallery">
            <div class="up-file-row">
                <input type="file" name="galleryFile" class="up-file-input" accept="image/jpeg,image/jpg,image/png,image/gif,image/webp" required>
                <button type="submit" class="up-btn up-btn-sm">Add Photo</button>
            </div>
            <p class="up-hint">JPG, PNG, WebP, or GIF &bull; Square or landscape crops work best</p>
        </form>
        <cfelse>
        <p style="font-size:13px;color:#aaa;font-style:italic">Gallery is full (10 photos). Remove a photo to add another.</p>
        </cfif>
    </div>

    <div style="padding-top:8px">
        <a href="/members/wedding-site-edit.cfm?siteId=<cfoutput>#siteId#</cfoutput>" class="up-btn">Done &mdash; Back to Editor</a>
    </div>

</div>
</section>

<cfinclude template="../includes/layout-end.cfm">
