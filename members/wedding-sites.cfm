<cfprocessingdirective pageencoding="utf-8">
<cferror type="request"   template="/error.cfm">
<cferror type="exception" template="/error.cfm">
<cfinclude template="../includes/auth-check.cfm">

<!--- Auto-add columns if missing --->
<cftry>
<cfquery datasource="#application.config.datasource#">
    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='WeddingSites' AND COLUMN_NAME='scripture')
        ALTER TABLE dbo.WeddingSites ADD scripture NVARCHAR(MAX) NULL;
    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='WeddingSites' AND COLUMN_NAME='things_to_do')
        ALTER TABLE dbo.WeddingSites ADD things_to_do NVARCHAR(MAX) NULL;
    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='WeddingSites' AND COLUMN_NAME='hero_image_url')
        ALTER TABLE dbo.WeddingSites ADD hero_image_url NVARCHAR(MAX) NULL;
    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='WeddingSites' AND COLUMN_NAME='gallery_images_json')
        ALTER TABLE dbo.WeddingSites ADD gallery_images_json NVARCHAR(MAX) NULL;
    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='WeddingSites' AND COLUMN_NAME='faq_json')
        ALTER TABLE dbo.WeddingSites ADD faq_json NVARCHAR(MAX) NULL;
</cfquery>
<cfcatch></cfcatch>
</cftry>

<cfset pageTitle = "Wedding Sites | digitalweddings.love">
<cfset activePage = "wedding-sites">
<cfset userId = session.user.id>
<cfparam name="form.action" default="">
<cfparam name="url.saved" default="">
<cfparam name="url.changeTpl" default="0">

<!--- ===== TOGGLE PUBLISH ===== --->
<cfif form.action EQ "toggle_publish" && isNumeric(form.siteId)>
    <cfquery datasource="#application.config.datasource#">
        UPDATE dbo.WeddingSites SET published = ~published, updated_at = SYSUTCDATETIME()
        WHERE wedding_site_id = <cfqueryparam value="#form.siteId#" cfsqltype="cf_sql_bigint">
          AND user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
    </cfquery>
    <cflocation url="wedding-sites.cfm" addToken="false">
</cfif>

<!--- ===== ARCHIVE (soft delete - keeps all data) ===== --->
<cfif form.action EQ "delete_site" && isNumeric(form.siteId)>
    <cfquery datasource="#application.config.datasource#">
        UPDATE dbo.WeddingSites
        SET published = 0, updated_at = SYSUTCDATETIME()
        WHERE wedding_site_id = <cfqueryparam value="#form.siteId#" cfsqltype="cf_sql_bigint">
          AND user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
    </cfquery>
    <cflocation url="wedding-sites.cfm" addToken="false">
</cfif>

<!--- ===== CHANGE TEMPLATE ===== --->
<cfif form.action EQ "change_template" && isNumeric(form.siteId) && len(trim(form.newTemplate))>
    <cfset newTpl = lCase(reReplace(trim(form.newTemplate),"[^a-z_]","","all"))>
    <cfinclude template="../includes/template-list.cfm">
    <cfset validTpl = application.templates>
    <cfif listFind(validTpl, newTpl)>
        <cfquery datasource="#application.config.datasource#">
            UPDATE dbo.WeddingSites
            SET template = <cfqueryparam value="#newTpl#" cfsqltype="cf_sql_varchar">,
                updated_at = SYSUTCDATETIME()
            WHERE wedding_site_id = <cfqueryparam value="#form.siteId#" cfsqltype="cf_sql_bigint">
              AND user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
        </cfquery>
    </cfif>
    <cflocation url="wedding-sites.cfm?saved=1" addToken="false">
</cfif>

<!--- ===== LOAD DATA ===== --->
<cftry>

<cfquery name="sites" datasource="#application.config.datasource#">
    SELECT * FROM dbo.WeddingSites
    WHERE user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
    ORDER BY created_at DESC
</cfquery>


<cfcatch type="any">
    <cflocation url="/error.cfm" addToken="false">
</cfcatch>
</cftry>

<!--- Template image map (id -> image url) --->
<cfset tplImages = {
    rose_wood:         "/assets/rose-wood.jpg",
    rose_cascade:      "/assets/rose-cascade.jpg",
    peach_silk:        "/assets/peach-silk.jpg",
    bloom_frame:       "/assets/bloom-frame.jpg",
    blushing_rose:     "/assets/blushing-rose.jpg",
    crimson_frame:     "/assets/crimson-frame.jpg",
    tulle_rose:        "/assets/tulle-rose.jpg",
    pearl_wreath:      "/assets/pearl-wreath.jpg",
    petal_glow:        "/assets/petal-glow.jpg",
    copper_rose:       "/assets/copper-rose.jpg",
    garden_romance:    "/assets/garden-romance.jpg",
    velvet_rouge:      "/assets/velvet-rouge.jpg",
    bordeaux_rose:     "/assets/bourdeaux-rose.jpg",
    scarlet_rose:      "/assets/scarlet-rose.jpg",
    blush_bouquet:     "/assets/blush-bouquet.jpg",
    dusty_rose:        "/assets/dusty-rose.jpg",
    rose_garden:       "/assets/rose-scatter.jpg",
    midnight_peony:    "/assets/midnight-peony.jpg",
    rouge_peony:       "/assets/rouge-peony-1.jpg",
    blush_silk:        "/assets/blush-silk.jpg",
    sage_wreath:       "/assets/sage-wreath.jpg",
    violet_garden:     "/assets/violet-floral-top.jpg",
    velvet_peony:      "/assets/peony-top.jpg",
    indigo_bloom:      "/assets/blue-floral-left.jpg",
    golden_affair:     "/assets/gold-corner-top.jpg",
    crimson_garden:    "/assets/watercolor-top.jpg",
    romantic_rose:     "/assets/roses-hero.jpeg",
    midnight_rose:     "/assets/dark-roses.jpg",
    midnight_garden:   "/assets/dark-bloom.jpg",
    first_light:       "/assets/first-light.jpg",
    pride_rainbow:     "/assets/pride-rainbow.jpg",
    chi_omega_love:    "/assets/chi-omega-love.png",
    delta_delta_love:  "/assets/delta-delta-love.png",
    sigma_alpha_love:  "/assets/sigma-alpha-love.png",
    aka_love:          "/assets/aka-love.jpg",
    alpha_love:        "/assets/alpha-love.jpg",
    kappa_love:        "/assets/kappa-love.jpg",
    delta_love:        "/assets/delta-love.jpg",
    zeta_love:         "/assets/zeta-love.jpg",
    omega_love:        "/assets/omega-love.jpg",
    classic_gold:      "/assets/ivory-wood.jpg",
    sunset_bliss:      "/assets/dark-texture.jpg",
    aka_inspired:      "/assets/aka-inspired.jpg",
    delta_inspired:    "/assets/delta-inspired.jpg",
    blush_pearl:       "/assets/blush-pearl.jpg",
    sapphire_rose:     "/assets/sapphire-rose.jpg"
}>

<cfinclude template="../includes/layout-start.cfm">

<style>
/* ---- Template Grid ---- */
.tpl-grid { display:grid; grid-template-columns:repeat(3,1fr); gap:24px; margin-top:8px; }
@media(max-width:900px){ .tpl-grid{ grid-template-columns:repeat(2,1fr); } }
@media(max-width:580px){ .tpl-grid{ grid-template-columns:1fr; } }
.tpl-card { background:#fff; border:1px solid #e5e5e5; border-radius:12px; overflow:hidden; transition:box-shadow 0.3s; cursor:pointer; }
.tpl-card:hover { box-shadow:0 8px 28px rgba(0,0,0,0.13); }
.tpl-img-wrap { position:relative; aspect-ratio:16/9; overflow:hidden; }
.tpl-img-wrap img { width:100%; height:100%; object-fit:cover; transition:transform 0.5s; display:block; }
.tpl-card:hover .tpl-img-wrap img { transform:scale(1.05); }
.tpl-overlay { display:none; position:absolute; inset:0; background:rgba(0,0,0,0.3); align-items:center; justify-content:center; gap:10px; }
.tpl-card:hover .tpl-overlay { display:flex; }
.tpl-btn-preview { display:inline-flex;align-items:center;gap:6px;padding:9px 18px;background:#fff;color:#1a1a1a;border:none;border-radius:8px;font-size:13px;font-weight:600;cursor:pointer;text-decoration:none;white-space:nowrap; }
.tpl-btn-select  { display:inline-flex;align-items:center;gap:6px;padding:9px 18px;background:#B8860B;color:#fff;border:none;border-radius:8px;font-size:13px;font-weight:600;cursor:pointer;text-decoration:none;white-space:nowrap; }
.tpl-card-body { padding:20px; }
.tpl-name { font-size:19px; font-weight:700; font-family:var(--font-heading); color:#1a1a1a; margin-bottom:6px; }
.tpl-desc { font-size:13px; color:#777; line-height:1.55; }
.color-dot { width:16px;height:16px;border-radius:50%;border:1.5px solid rgba(0,0,0,0.1);display:inline-block;flex-shrink:0; }

/* ---- Your Sites List ---- */
.site-row { display:flex;align-items:center;gap:16px;padding:20px;background:#fff;border:1px solid #e5e5e5;border-radius:12px;margin-bottom:12px;transition:box-shadow 0.2s; }
.site-row:hover { box-shadow:0 4px 16px rgba(0,0,0,0.08); }
.site-thumb { width:80px;height:56px;object-fit:cover;border-radius:8px;flex-shrink:0; }
.site-row-actions { display:flex;align-items:center;gap:8px;flex-shrink:0;flex-wrap:wrap; }
@media(max-width:768px){
    .site-row { flex-direction:column;align-items:stretch; }
    .site-row-top { display:flex;align-items:center;gap:12px; }
    .site-row-actions { flex-direction:row;flex-wrap:wrap;gap:8px;margin-top:12px; }
    .site-row-actions a, .site-row-actions button { flex:1;min-width:calc(50% - 4px);text-align:center;justify-content:center;box-sizing:border-box; }
    .site-row-actions .btn-change-tpl { flex:none;width:100%; }
}
</style>

<section style="padding:60px 0">
<div class="container">

    <div class="page-header">
        <p class="eyebrow">Share Your Story</p>
        <h1 style="font-family:var(--font-heading);font-size:clamp(2rem,4vw,2.8rem);font-weight:700">Wedding Site Templates</h1>
        <p style="color:var(--text-muted);margin-top:8px">Choose a beautiful template and create your personalized wedding website.</p>
    </div>

    <cfif url.saved EQ "1">
    <div class="alert alert-success" style="margin-bottom:24px">Your wedding site has been saved successfully!</div>
    </cfif>
    <!--- ===== YOUR SITES ===== --->
    <cfif sites.recordCount>
    <div style="margin-bottom:48px">
        <h2 style="font-size:22px;font-weight:700;font-family:var(--font-heading);margin-bottom:16px">Your Wedding Sites</h2>
        <cfoutput query="sites">
        <cfset tImg = structKeyExists(tplImages, template) ? tplImages[template] : "">
        <div class="site-row">
            <div class="site-row-top">
                <img src="#HTMLEditFormat(tImg)#" alt="#HTMLEditFormat(template)#" class="site-thumb">
                <div style="flex:1;min-width:0">
                    <p style="font-weight:700;font-size:16px;color:##1a1a1a">#HTMLEditFormat(couple_name_1)# &amp; #HTMLEditFormat(couple_name_2)#</p>
                    <p style="font-size:12px;color:##888;margin-top:2px">#replace(HTMLEditFormat(template),'_',' ','all')# template<cfif len(wedding_date)> &middot; #dateFormat(wedding_date,'mmmm d, yyyy')#</cfif></p>
                    <cfif len(slug)>
                    <cfif published>
                    <p style="font-size:12px;font-family:monospace;color:var(--gold);margin-top:4px;word-break:break-all">
                        digitalweddings.love/site.cfm?slug=#HTMLEditFormat(slug)#
                        &nbsp;<a href="/site.cfm?slug=#URLEncodedFormat(slug)#" target="_blank" style="color:var(--gold)"><i data-lucide="external-link" style="width:11px;height:11px;vertical-align:middle"></i></a>
                    </p>
                    <cfelse>
                    <p style="font-size:11px;color:##d97706;font-style:italic;margin-top:4px">Publish your site so guests can view it</p>
                    </cfif>
                    </cfif>
                </div>
            </div>
            <div class="site-row-actions">
                <form method="post" action="/members/wedding-sites.cfm" style="display:inline">
                    <input type="hidden" name="action" value="toggle_publish">
                    <input type="hidden" name="siteId" value="#wedding_site_id#">
                    <button type="submit" style="padding:7px 14px;font-size:12px;font-weight:600;border-radius:7px;cursor:pointer;border:1px solid;#published ? 'background:##059669;color:##fff;border-color:##059669' : 'background:##fff;color:##555;border-color:##ddd'#">
                        <i data-lucide="globe" style="width:12px;height:12px;vertical-align:middle;margin-right:3px"></i>#published ? 'Published' : 'Publish'#
                    </button>
                </form>
                <a href="/site.cfm?siteId=#wedding_site_id#&preview=1" target="_blank" class="btn btn-ghost btn-sm" title="Preview site"><i data-lucide="eye" style="width:14px;height:14px"></i></a>
                <cfif published && len(slug)>
                <a href="/site.cfm?slug=#URLEncodedFormat(slug)#" target="_blank" class="btn btn-ghost btn-sm" title="View live site" style="color:var(--gold)"><i data-lucide="external-link" style="width:14px;height:14px"></i></a>
                </cfif>
                <a href="/members/wedding-site-edit.cfm?siteId=#wedding_site_id#" class="btn btn-ghost btn-sm" title="Edit"><i data-lucide="pencil" style="width:14px;height:14px"></i></a>
                <a href="/members/wedding-sites.cfm?changeTpl=#wedding_site_id#" class="btn-change-tpl" style="padding:7px 14px;font-size:12px;font-weight:600;border-radius:7px;cursor:pointer;border:1px solid ##5f8464;color:##5f8464;background:##fff;text-decoration:none;display:inline-flex;align-items:center;justify-content:center;gap:5px"><i data-lucide="palette" style="width:12px;height:12px"></i> Change Template</a>
            </div>
        </div>

        <!--- INLINE TEMPLATE PICKER for this site --->
        <cfif url.changeTpl EQ wedding_site_id>
        <div style="background:##fffbf4;border:1px solid ##f0e0b0;border-radius:10px;padding:20px 24px;margin-top:12px">
            <p style="font-size:13px;font-weight:700;color:##555;margin-bottom:14px;letter-spacing:.05em;text-transform:uppercase">Choose a new template &mdash; your content will be kept</p>
            <div style="display:flex;flex-wrap:wrap;gap:8px">
            <cfset tplList = application.templates>
            <cfloop list="#tplList#" index="t">
            <form method="post" action="/members/wedding-sites.cfm" style="display:inline">
                <input type="hidden" name="action" value="change_template">
                <input type="hidden" name="siteId" value="#wedding_site_id#">
                <input type="hidden" name="newTemplate" value="#t#">
                <button type="submit" style="padding:7px 14px;font-size:12px;border-radius:6px;cursor:pointer;border:1px solid ##ddd;background:#t EQ template ? '##B8860B' : '##fff'#;color:#t EQ template ? '##fff' : '##444'#;font-weight:#t EQ template ? '700' : '400'#">
                    #replace(t,'_',' ','all')#
                </button>
            </form>
            </cfloop>
            </div>
            <p style="font-size:12px;color:##999;margin-top:10px">Click any template name to switch. <a href="/members/wedding-sites.cfm" style="color:var(--gold)">Cancel</a></p>
        </div>
        </cfif>

        </cfoutput>
    </div>
    </cfif>

    <!--- ===== TEMPLATE GRID ===== --->
    <cfif NOT sites.recordCount>
    <h2 style="font-size:22px;font-weight:700;font-family:var(--font-heading);margin-bottom:24px">Choose a Template</h2>
    </cfif>

    <style>
    .tpl-category{width:100%;margin:32px 0 16px;padding-bottom:10px;border-bottom:2px solid var(--gold-light);display:flex;align-items:center;gap:12px}
    .tpl-category-label{font-size:15px;letter-spacing:.18em;text-transform:uppercase;font-weight:700;color:var(--gold);font-family:var(--font-heading);white-space:nowrap}
    .tpl-category-line{flex:1;height:1px;background:linear-gradient(to right,var(--border),transparent)}
    .tpl-premium-badge{position:absolute;top:10px;left:10px;background:rgba(0,0,0,0.72);color:#fcd34d;font-size:11px;font-weight:700;letter-spacing:.06em;padding:4px 10px;border-radius:20px;z-index:2;pointer-events:none}
    </style>

    <div class="tpl-grid">
<!--- Floral & Romantic --->
    <div class="tpl-category" style="grid-column:1/-1">
        <span class="tpl-category-label">Floral &amp; Romantic</span>
        <div class="tpl-category-line"></div>
    </div>

        <div class="tpl-card">
            <div class="tpl-img-wrap">
                <img src="/assets/blush-pearl.jpg" alt="Blush Pearl" onerror="this.style.background='#f5ede8'">
                <div class="tpl-overlay">
                    <a href="/members/preview-template.cfm?template=blush_pearl" target="_blank" class="tpl-btn-preview"><i data-lucide="eye" style="width:14px;height:14px"></i>Preview</a>
                    <a href="/members/wedding-site-edit.cfm?template=blush_pearl" class="tpl-btn-select"><i data-lucide="check" style="width:14px;height:14px"></i>Select</a>
                </div>
            </div>
            <div class="tpl-card-body">
                <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:8px">
                    <p class="tpl-name">Blush Pearl</p>
                    <div style="display:flex;gap:5px"><span class="color-dot" style="background:#C8907A"></span><span class="color-dot" style="background:#B8945A"></span><span class="color-dot" style="background:#FDFAF7"></span></div>
                </div>
                <p class="tpl-desc">Blush roses, pearls &amp; gold rings &mdash; soft and romantic on a dreamy white satin background.</p>
            </div>
        </div>

        <div class="tpl-card">
            <div class="tpl-img-wrap">
                <img src="/assets/sapphire-rose.jpg" alt="Sapphire Rose" onerror="this.style.background='#020408'">
                <div class="tpl-overlay">
                    <a href="/members/preview-template.cfm?template=sapphire_rose" target="_blank" class="tpl-btn-preview"><i data-lucide="eye" style="width:14px;height:14px"></i>Preview</a>
                    <a href="/members/wedding-site-edit.cfm?template=sapphire_rose" class="tpl-btn-select"><i data-lucide="check" style="width:14px;height:14px"></i>Select</a>
                </div>
            </div>
            <div class="tpl-card-body">
                <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:8px">
                    <p class="tpl-name">Sapphire Rose</p>
                    <div style="display:flex;gap:5px"><span class="color-dot" style="background:#2B5FA8"></span><span class="color-dot" style="background:#E8EEF4"></span><span class="color-dot" style="background:#020408"></span></div>
                </div>
                <p class="tpl-desc">Deep blue roses &mdash; moody, dramatic sapphire and midnight tones with silver accents.</p>
            </div>
        </div>

        <div class="tpl-card">
            <div class="tpl-img-wrap">
                <img src="/assets/rose-wood.jpg" alt="Rose Wood" onerror="this.style.background='#160C0A'">
                <div class="tpl-overlay">
                    <a href="/members/preview-template.cfm?template=rose_wood" target="_blank" class="tpl-btn-preview"><i data-lucide="eye" style="width:14px;height:14px"></i>Preview</a>
                    <a href="/members/wedding-site-edit.cfm?template=rose_wood" class="tpl-btn-select"><i data-lucide="check" style="width:14px;height:14px"></i>Select</a>
                </div>
            </div>
            <div class="tpl-card-body">
                <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:8px">
                    <p class="tpl-name">Rose Wood</p>
                    <div style="display:flex;gap:5px"><span class="color-dot" style="background:#0A0605"></span><span class="color-dot" style="background:#C41830"></span><span class="color-dot" style="background:#F5EDE8"></span></div>
                </div>
                <p class="tpl-desc">Red roses arching over dark wood &mdash;a moody, dramatic fixed background with cream text throughout.</p>
            </div>
        </div>

        <div class="tpl-card">
            <div class="tpl-img-wrap">
                <img src="/assets/rose-cascade.jpg" alt="Rose Cascade" onerror="this.style.background='#0E0808'">
                <div class="tpl-overlay">
                    <a href="/members/preview-template.cfm?template=rose_cascade" target="_blank" class="tpl-btn-preview"><i data-lucide="eye" style="width:14px;height:14px"></i>Preview</a>
                    <a href="/members/wedding-site-edit.cfm?template=rose_cascade" class="tpl-btn-select"><i data-lucide="check" style="width:14px;height:14px"></i>Select</a>
                </div>
            </div>
            <div class="tpl-card-body">
                <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:8px">
                    <p class="tpl-name">Rose Cascade</p>
                    <div style="display:flex;gap:5px"><span class="color-dot" style="background:#0E0808"></span><span class="color-dot" style="background:#D4A0A8"></span><span class="color-dot" style="background:#FDF6F0"></span></div>
                </div>
                <p class="tpl-desc">Cream &amp; pink roses cascading over marble &mdash;delicate, vintage, and breathtaking.</p>
            </div>
        </div>

        <div class="tpl-card">
            <div class="tpl-img-wrap">
                <img src="/assets/peach-silk.jpg" alt="Peach Silk" onerror="this.style.background='#130806'">
                <div class="tpl-overlay">
                    <a href="/members/preview-template.cfm?template=peach_silk" target="_blank" class="tpl-btn-preview"><i data-lucide="eye" style="width:14px;height:14px"></i>Preview</a>
                    <a href="/members/wedding-site-edit.cfm?template=peach_silk" class="tpl-btn-select"><i data-lucide="check" style="width:14px;height:14px"></i>Select</a>
                </div>
            </div>
            <div class="tpl-card-body">
                <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:8px">
                    <p class="tpl-name">Peach Silk</p>
                    <div style="display:flex;gap:5px"><span class="color-dot" style="background:#130806"></span><span class="color-dot" style="background:#C8806A"></span><span class="color-dot" style="background:#FDF5EE"></span></div>
                </div>
                <p class="tpl-desc">Peach roses &amp; white blooms on draped silk &mdash;soft, luminous, and effortlessly romantic.</p>
            </div>
        </div>

        <div class="tpl-card">
            <div class="tpl-img-wrap">
                <img src="/assets/bloom-frame.jpg" alt="Bloom Frame" onerror="this.style.background='#150308'">
                <div class="tpl-overlay">
                    <a href="/members/preview-template.cfm?template=bloom_frame" target="_blank" class="tpl-btn-preview"><i data-lucide="eye" style="width:14px;height:14px"></i>Preview</a>
                    <a href="/members/wedding-site-edit.cfm?template=bloom_frame" class="tpl-btn-select"><i data-lucide="check" style="width:14px;height:14px"></i>Select</a>
                </div>
            </div>
            <div class="tpl-card-body">
                <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:8px">
                    <p class="tpl-name">Bloom Frame</p>
                    <div style="display:flex;gap:5px"><span class="color-dot" style="background:#150308"></span><span class="color-dot" style="background:#D4708A"></span><span class="color-dot" style="background:#FDF5F0"></span></div>
                </div>
                <p class="tpl-desc">Red, pink &amp; cream roses framing an open center &mdash;lush, romantic, and full of life.</p>
            </div>
        </div>

        <div class="tpl-card">
            <div class="tpl-img-wrap">
                <img src="/assets/blushing-rose.jpg" alt="Blushing Rose" onerror="this.style.background='#100608'">
                <div class="tpl-overlay">
                    <a href="/members/preview-template.cfm?template=blushing_rose" target="_blank" class="tpl-btn-preview"><i data-lucide="eye" style="width:14px;height:14px"></i>Preview</a>
                    <a href="/members/wedding-site-edit.cfm?template=blushing_rose" class="tpl-btn-select"><i data-lucide="check" style="width:14px;height:14px"></i>Select</a>
                </div>
            </div>
            <div class="tpl-card-body">
                <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:8px">
                    <p class="tpl-name">Blushing Rose</p>
                    <div style="display:flex;gap:5px"><span class="color-dot" style="background:#060405"></span><span class="color-dot" style="background:#D4899A"></span><span class="color-dot" style="background:#FBF3F0"></span></div>
                </div>
                <p class="tpl-desc">Soft blush roses with dreamy bokeh &mdash;delicate, romantic, and luminous.</p>
            </div>
        </div>

        <div class="tpl-card">
            <div class="tpl-img-wrap">
                <img src="/assets/crimson-frame.jpg" alt="Crimson Frame" onerror="this.style.background='#3A0610'">
                <div class="tpl-overlay">
                    <a href="/members/preview-template.cfm?template=crimson_frame" target="_blank" class="tpl-btn-preview"><i data-lucide="eye" style="width:14px;height:14px"></i>Preview</a>
                    <a href="/members/wedding-site-edit.cfm?template=crimson_frame" class="tpl-btn-select"><i data-lucide="check" style="width:14px;height:14px"></i>Select</a>
                </div>
            </div>
            <div class="tpl-card-body">
                <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:8px">
                    <p class="tpl-name">Crimson Frame</p>
                    <div style="display:flex;gap:5px"><span class="color-dot" style="background:#3A0610"></span><span class="color-dot" style="background:#C41830"></span><span class="color-dot" style="background:#FDF8F5"></span></div>
                </div>
                <p class="tpl-desc">Red and white roses framing a deep crimson center &mdash;bold, romantic, and unforgettable.</p>
            </div>
        </div>

        <div class="tpl-card">
            <div class="tpl-img-wrap">
                <img src="/assets/tulle-rose.jpg" alt="Tulle Rose" onerror="this.style.background='#F5F0E8'">
                <div class="tpl-overlay">
                    <a href="/members/preview-template.cfm?template=tulle_rose" target="_blank" class="tpl-btn-preview"><i data-lucide="eye" style="width:14px;height:14px"></i>Preview</a>
                    <a href="/members/wedding-site-edit.cfm?template=tulle_rose" class="tpl-btn-select"><i data-lucide="check" style="width:14px;height:14px"></i>Select</a>
                </div>
            </div>
            <div class="tpl-card-body">
                <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:8px">
                    <p class="tpl-name">Tulle Rose</p>
                    <div style="display:flex;gap:5px"><span class="color-dot" style="background:#3D2E26"></span><span class="color-dot" style="background:#C8B4A0"></span><span class="color-dot" style="background:#FDFBF8"></span></div>
                </div>
                <p class="tpl-desc">Cream roses draped in soft white tulle &mdash;airy, romantic, and timeless.</p>
            </div>
        </div>

        <div class="tpl-card">
            <div class="tpl-img-wrap">
                <img src="/assets/pearl-wreath.jpg" alt="Pearl Wreath" onerror="this.style.background='#121008'">
                <div class="tpl-overlay">
                    <a href="/members/preview-template.cfm?template=pearl_wreath" target="_blank" class="tpl-btn-preview"><i data-lucide="eye" style="width:14px;height:14px"></i>Preview</a>
                    <a href="/members/wedding-site-edit.cfm?template=pearl_wreath" class="tpl-btn-select"><i data-lucide="check" style="width:14px;height:14px"></i>Select</a>
                </div>
            </div>
            <div class="tpl-card-body">
                <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:8px">
                    <p class="tpl-name">Pearl Wreath</p>
                    <div style="display:flex;gap:5px"><span class="color-dot" style="background:#080706"></span><span class="color-dot" style="background:#D4BFA0"></span><span class="color-dot" style="background:#FAF5EE"></span></div>
                </div>
                <p class="tpl-desc">Cream roses in a delicate wreath with ribbon &mdash;dark and elegant with warm pearl accents.</p>
            </div>
        </div>

        <div class="tpl-card">
            <div class="tpl-img-wrap">
                <img src="/assets/petal-glow.jpg" alt="Petal Glow" onerror="this.style.background='#120810'">
                <div class="tpl-overlay">
                    <a href="/members/preview-template.cfm?template=petal_glow" target="_blank" class="tpl-btn-preview"><i data-lucide="eye" style="width:14px;height:14px"></i>Preview</a>
                    <a href="/members/wedding-site-edit.cfm?template=petal_glow" class="tpl-btn-select"><i data-lucide="check" style="width:14px;height:14px"></i>Select</a>
                </div>
            </div>
            <div class="tpl-card-body">
                <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:8px">
                    <p class="tpl-name">Petal Glow</p>
                    <div style="display:flex;gap:5px"><span class="color-dot" style="background:#080608"></span><span class="color-dot" style="background:#E8A0B8"></span><span class="color-dot" style="background:#FBF2F5"></span></div>
                </div>
                <p class="tpl-desc">Soft pink peonies with dreamy bokeh &mdash;dark and romantic with blush accents throughout.</p>
            </div>
        </div>


        <div class="tpl-card">
            <div class="tpl-img-wrap">
                <img src="/assets/copper-rose.jpg" alt="Copper Rose" onerror="this.style.background='#130A06'">
                <div class="tpl-overlay">
                    <a href="/members/preview-template.cfm?template=copper_rose" target="_blank" class="tpl-btn-preview"><i data-lucide="eye" style="width:14px;height:14px"></i>Preview</a>
                    <a href="/members/wedding-site-edit.cfm?template=copper_rose" class="tpl-btn-select"><i data-lucide="check" style="width:14px;height:14px"></i>Select</a>
                </div>
            </div>
            <div class="tpl-card-body">
                <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:8px">
                    <p class="tpl-name">Copper Rose</p>
                    <div style="display:flex;gap:5px"><span class="color-dot" style="background:#080503"></span><span class="color-dot" style="background:#C87A50"></span><span class="color-dot" style="background:#F7EDE4"></span></div>
                </div>
                <p class="tpl-desc">Warm peach and apricot roses in a rich dark full-bleed template with copper accents.</p>
            </div>
        </div>

        <div class="tpl-card">
            <div class="tpl-img-wrap">
                <img src="/assets/garden-romance.jpg" alt="Garden Romance" onerror="this.style.background='#FDF6F7'">
                <div class="tpl-overlay">
                    <a href="/members/preview-template.cfm?template=garden_romance" target="_blank" class="tpl-btn-preview"><i data-lucide="eye" style="width:14px;height:14px"></i>Preview</a>
                    <a href="/members/wedding-site-edit.cfm?template=garden_romance" class="tpl-btn-select"><i data-lucide="check" style="width:14px;height:14px"></i>Select</a>
                </div>
            </div>
            <div class="tpl-card-body">
                <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:8px">
                    <p class="tpl-name">Garden Romance</p>
                    <div style="display:flex;gap:5px"><span class="color-dot" style="background:#C0404A"></span><span class="color-dot" style="background:#FDF6F7;border-color:#e8d0d4"></span><span class="color-dot" style="background:#6B1A24"></span></div>
                </div>
                <p class="tpl-desc">Mixed cream, red, and pink roses frame the page as a fixed background &mdash;content floats above the blooms.</p>
            </div>
        </div>

        <div class="tpl-card">
            <div class="tpl-img-wrap">
                <img src="/assets/velvet-rouge.jpg" alt="Velvet Rouge" onerror="this.style.background='#F5E8E8'">
                <div class="tpl-overlay">
                    <a href="/members/preview-template.cfm?template=velvet_rouge" target="_blank" class="tpl-btn-preview"><i data-lucide="eye" style="width:14px;height:14px"></i>Preview</a>
                    <a href="/members/wedding-site-edit.cfm?template=velvet_rouge" class="tpl-btn-select"><i data-lucide="check" style="width:14px;height:14px"></i>Select</a>
                </div>
            </div>
            <div class="tpl-card-body">
                <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:8px">
                    <p class="tpl-name">Velvet Rouge</p>
                    <div style="display:flex;gap:5px"><span class="color-dot" style="background:#B01030"></span><span class="color-dot" style="background:#F5E8E8;border-color:#e0c8c8"></span><span class="color-dot" style="background:#5C1020"></span></div>
                </div>
                <p class="tpl-desc">Red roses as a fixed full-page background with a soft overlay &mdash;content floats above the roses throughout.</p>
            </div>
        </div>

        <div class="tpl-card">
            <div class="tpl-img-wrap">
                <img src="/assets/bourdeaux-rose.jpg" alt="Bordeaux Rose" onerror="this.style.background='#0F0808'">
                <div class="tpl-overlay">
                    <a href="/members/preview-template.cfm?template=bordeaux_rose" target="_blank" class="tpl-btn-preview"><i data-lucide="eye" style="width:14px;height:14px"></i>Preview</a>
                    <a href="/members/wedding-site-edit.cfm?template=bordeaux_rose" class="tpl-btn-select"><i data-lucide="check" style="width:14px;height:14px"></i>Select</a>
                </div>
            </div>
            <div class="tpl-card-body">
                <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:8px">
                    <p class="tpl-name">Bordeaux Rose</p>
                    <div style="display:flex;gap:5px"><span class="color-dot" style="background:#060404"></span><span class="color-dot" style="background:#8B1A2A"></span><span class="color-dot" style="background:#F2EAE6"></span></div>
                </div>
                <p class="tpl-desc">Deep burgundy roses fill the frame in this dark, dramatic full-bleed template.</p>
            </div>
        </div>

        <div class="tpl-card">
            <div class="tpl-img-wrap">
                <img src="/assets/scarlet-rose.jpg" alt="Scarlet Rose" onerror="this.style.background='#120A0E'">
                <div class="tpl-overlay">
                    <a href="/members/preview-template.cfm?template=scarlet_rose" target="_blank" class="tpl-btn-preview"><i data-lucide="eye" style="width:14px;height:14px"></i>Preview</a>
                    <a href="/members/wedding-site-edit.cfm?template=scarlet_rose" class="tpl-btn-select"><i data-lucide="check" style="width:14px;height:14px"></i>Select</a>
                </div>
            </div>
            <div class="tpl-card-body">
                <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:8px">
                    <p class="tpl-name">Scarlet Rose</p>
                    <div style="display:flex;gap:5px"><span class="color-dot" style="background:#080406"></span><span class="color-dot" style="background:#C41E3A"></span><span class="color-dot" style="background:#F5EBE8"></span></div>
                </div>
                <p class="tpl-desc">Dark moody full-bleed hero with a deep red rose and scattered hearts, crimson accents.</p>
            </div>
        </div>

        <div class="tpl-card">
            <div class="tpl-img-wrap">
                <img src="/assets/blush-bouquet.jpg" alt="Blush Bouquet" onerror="this.style.background='#F7EDE8'">
                <div class="tpl-overlay">
                    <a href="/members/preview-template.cfm?template=blush_bouquet" target="_blank" class="tpl-btn-preview"><i data-lucide="eye" style="width:14px;height:14px"></i>Preview</a>
                    <a href="/members/wedding-site-edit.cfm?template=blush_bouquet" class="tpl-btn-select"><i data-lucide="check" style="width:14px;height:14px"></i>Select</a>
                </div>
            </div>
            <div class="tpl-card-body">
                <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:8px">
                    <p class="tpl-name">Blush Bouquet</p>
                    <div style="display:flex;gap:5px"><span class="color-dot" style="background:#D4907A"></span><span class="color-dot" style="background:#F7EDE8;border-color:#E0C8C0"></span><span class="color-dot" style="background:#5C2535"></span></div>
                </div>
                <p class="tpl-desc">Peach and blush watercolor roses with a ribbon bow, text left-aligned on cream.</p>
            </div>
        </div>

        <div class="tpl-card">
            <div class="tpl-img-wrap">
                <img src="/assets/dusty-rose.jpg" alt="Dusty Rose" onerror="this.style.background='#F5EEF0'">
                <div class="tpl-overlay">
                    <a href="/members/preview-template.cfm?template=dusty_rose" target="_blank" class="tpl-btn-preview"><i data-lucide="eye" style="width:14px;height:14px"></i>Preview</a>
                    <a href="/members/wedding-site-edit.cfm?template=dusty_rose" class="tpl-btn-select"><i data-lucide="check" style="width:14px;height:14px"></i>Select</a>
                </div>
            </div>
            <div class="tpl-card-body">
                <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:8px">
                    <p class="tpl-name">Dusty Rose</p>
                    <div style="display:flex;gap:5px"><span class="color-dot" style="background:#B8849A"></span><span class="color-dot" style="background:#F5EEF0;border-color:#E2D0D8"></span><span class="color-dot" style="background:#4A2540"></span></div>
                </div>
                <p class="tpl-desc">Watercolor mauve roses with floating hearts on a cream background, text right-aligned.</p>
            </div>
        </div>

        <div class="tpl-card">
            <div class="tpl-img-wrap">
                <img src="/assets/rose-scatter.jpg" alt="Rose Garden" onerror="this.style.background='#FFF0F3'">
                <div class="tpl-overlay">
                    <a href="/members/preview-template.cfm?template=rose_garden" target="_blank" class="tpl-btn-preview"><i data-lucide="eye" style="width:14px;height:14px"></i>Preview</a>
                    <a href="/members/wedding-site-edit.cfm?template=rose_garden" class="tpl-btn-select"><i data-lucide="check" style="width:14px;height:14px"></i>Select</a>
                </div>
            </div>
            <div class="tpl-card-body">
                <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:8px">
                    <p class="tpl-name">Rose Garden</p>
                    <div style="display:flex;gap:5px"><span class="color-dot" style="background:#D63670"></span><span class="color-dot" style="background:#FFF0F3;border-color:#F9D0DF"></span><span class="color-dot" style="background:#9C1C4A"></span></div>
                </div>
                <p class="tpl-desc">Scattered pink roses on a blush background with hot pink accents and script details.</p>
            </div>
        </div>

        <div class="tpl-card">
            <div class="tpl-img-wrap">
                <img src="/assets/midnight-peony.jpg" alt="Midnight Peony" onerror="this.style.background='#150E12'">
                <div class="tpl-overlay">
                    <a href="/members/preview-template.cfm?template=midnight_peony" target="_blank" class="tpl-btn-preview"><i data-lucide="eye" style="width:14px;height:14px"></i>Preview</a>
                    <a href="/members/wedding-site-edit.cfm?template=midnight_peony" class="tpl-btn-select"><i data-lucide="check" style="width:14px;height:14px"></i>Select</a>
                </div>
            </div>
            <div class="tpl-card-body">
                <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:8px">
                    <p class="tpl-name">Midnight Peony</p>
                    <div style="display:flex;gap:5px"><span class="color-dot" style="background:#0A0608"></span><span class="color-dot" style="background:#C4707A"></span><span class="color-dot" style="background:#F0EAE2"></span></div>
                </div>
                <p class="tpl-desc">Dark moody pink peonies with cream typography on a near-black background.</p>
            </div>
        </div>

        <div class="tpl-card">
            <div class="tpl-img-wrap">
                <img src="/assets/rouge-peony-1.jpg" alt="Rouge Peony" onerror="this.style.background='#FAF0EE'">
                <div class="tpl-overlay">
                    <a href="/members/preview-template.cfm?template=rouge_peony" target="_blank" class="tpl-btn-preview"><i data-lucide="eye" style="width:14px;height:14px"></i>Preview</a>
                    <a href="/members/wedding-site-edit.cfm?template=rouge_peony" class="tpl-btn-select"><i data-lucide="check" style="width:14px;height:14px"></i>Select</a>
                </div>
            </div>
            <div class="tpl-card-body">
                <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:8px">
                    <p class="tpl-name">Rouge Peony</p>
                    <div style="display:flex;gap:5px"><span class="color-dot" style="background:#8B2035"></span><span class="color-dot" style="background:#C4707A"></span><span class="color-dot" style="background:#FAF0EE"></span></div>
                </div>
                <p class="tpl-desc">Crimson botanical peonies in opposing corners on a clean white background.</p>
            </div>
        </div>

        <div class="tpl-card">
            <div class="tpl-img-wrap">
                <img src="/assets/blush-silk.jpg" alt="Blush Silk" onerror="this.style.background='#F2DDD8'">
                <div class="tpl-overlay">
                    <a href="/members/preview-template.cfm?template=blush_silk" target="_blank" class="tpl-btn-preview"><i data-lucide="eye" style="width:14px;height:14px"></i>Preview</a>
                    <a href="/members/wedding-site-edit.cfm?template=blush_silk" class="tpl-btn-select"><i data-lucide="check" style="width:14px;height:14px"></i>Select</a>
                </div>
            </div>
            <div class="tpl-card-body">
                <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:8px">
                    <p class="tpl-name">Blush Silk</p>
                    <div style="display:flex;gap:5px"><span class="color-dot" style="background:#C49090"></span><span class="color-dot" style="background:#F2DDD8"></span><span class="color-dot" style="background:#7A3D42"></span></div>
                </div>
                <p class="tpl-desc">Soft blush chiffon full-bleed hero with rose and deep wine accents.</p>
            </div>
        </div>

        <div class="tpl-card">
            <div class="tpl-img-wrap">
                <img src="/assets/dark-roses.jpg" alt="Midnight Rose" onerror="this.style.background='#1C1C1C'" style="object-position:center">
                <div class="tpl-overlay">
                    <a href="/members/preview-template.cfm?template=midnight_rose" target="_blank" class="tpl-btn-preview"><i data-lucide="eye" style="width:14px;height:14px"></i>Preview</a>
                    <a href="/members/wedding-site-edit.cfm?template=midnight_rose" class="tpl-btn-select"><i data-lucide="check" style="width:14px;height:14px"></i>Select</a>
                </div>
            </div>
            <div class="tpl-card-body">
                <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:8px">
                    <p class="tpl-name">Midnight Rose</p>
                    <div style="display:flex;gap:5px"><span class="color-dot" style="background:#0D0D0D"></span><span class="color-dot" style="background:#C9A97A"></span><span class="color-dot" style="background:#F5EFE6"></span></div>
                </div>
                <p class="tpl-desc">Dark and moody with a dramatic floral hero, cream typography, and gold accents.</p>
            </div>
        </div>

        <div class="tpl-card">
            <div class="tpl-img-wrap">
                <img src="/assets/dark-bloom.jpg" alt="Midnight Garden" onerror="this.style.background='#150E12'" style="object-position:center">
                <div class="tpl-overlay">
                    <a href="/members/preview-template.cfm?template=midnight_garden" target="_blank" class="tpl-btn-preview"><i data-lucide="eye" style="width:14px;height:14px"></i>Preview</a>
                    <a href="/members/wedding-site-edit.cfm?template=midnight_garden" class="tpl-btn-select"><i data-lucide="check" style="width:14px;height:14px"></i>Select</a>
                </div>
            </div>
            <div class="tpl-card-body">
                <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:8px">
                    <p class="tpl-name">Midnight Garden</p>
                    <div style="display:flex;gap:5px"><span class="color-dot" style="background:#0A0608"></span><span class="color-dot" style="background:#3D1A2E"></span><span class="color-dot" style="background:#F0EAE2"></span></div>
                </div>
                <p class="tpl-desc">Moody plum florals with oversized centered names and a cinematic dark aesthetic.</p>
            </div>
        </div>

    <!--- Modern & Minimal --->
    <div class="tpl-category" style="grid-column:1/-1">
        <span class="tpl-category-label">Modern &amp; Minimal</span>
        <div class="tpl-category-line"></div>
    </div>

        <div class="tpl-card">
            <div class="tpl-img-wrap">
                <img src="/assets/sage-wreath.jpg" alt="Sage Wreath" onerror="this.style.background='#E8EFE9'">
                <div class="tpl-overlay">
                    <a href="/members/preview-template.cfm?template=sage_wreath" target="_blank" class="tpl-btn-preview"><i data-lucide="eye" style="width:14px;height:14px"></i>Preview</a>
                    <a href="/members/wedding-site-edit.cfm?template=sage_wreath" class="tpl-btn-select"><i data-lucide="check" style="width:14px;height:14px"></i>Select</a>
                </div>
            </div>
            <div class="tpl-card-body">
                <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:8px">
                    <p class="tpl-name">Sage Wreath</p>
                    <div style="display:flex;gap:5px"><span class="color-dot" style="background:#7A9B82"></span><span class="color-dot" style="background:#B8922A"></span><span class="color-dot" style="background:#FAFAF7"></span></div>
                </div>
                <p class="tpl-desc">Eucalyptus and gold wreath frames couple names on a clean white background.</p>
            </div>
        </div>

        <div class="tpl-card">
            <div class="tpl-img-wrap">
                <img src="/assets/violet-floral-top.jpg" alt="Violet Garden" onerror="this.style.background='#EDE5F5'">
                <div class="tpl-overlay">
                    <a href="/members/preview-template.cfm?template=violet_garden" target="_blank" class="tpl-btn-preview"><i data-lucide="eye" style="width:14px;height:14px"></i>Preview</a>
                    <a href="/members/wedding-site-edit.cfm?template=violet_garden" class="tpl-btn-select"><i data-lucide="check" style="width:14px;height:14px"></i>Select</a>
                </div>
            </div>
            <div class="tpl-card-body">
                <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:8px">
                    <p class="tpl-name">Violet Garden</p>
                    <div style="display:flex;gap:5px"><span class="color-dot" style="background:#7B5EA7"></span><span class="color-dot" style="background:#6BBFBF"></span><span class="color-dot" style="background:#D4809A"></span></div>
                </div>
                <p class="tpl-desc">Watercolor anemone and succulent florals on white with lavender and teal accents.</p>
            </div>
        </div>

        <div class="tpl-card">
            <div class="tpl-img-wrap">
                <img src="/assets/peony-top.jpg" alt="Velvet Peony" onerror="this.style.background='#111B2E'">
                <div class="tpl-overlay">
                    <a href="/members/preview-template.cfm?template=velvet_peony" target="_blank" class="tpl-btn-preview"><i data-lucide="eye" style="width:14px;height:14px"></i>Preview</a>
                    <a href="/members/wedding-site-edit.cfm?template=velvet_peony" class="tpl-btn-select"><i data-lucide="check" style="width:14px;height:14px"></i>Select</a>
                </div>
            </div>
            <div class="tpl-card-body">
                <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:8px">
                    <p class="tpl-name">Velvet Peony</p>
                    <div style="display:flex;gap:5px"><span class="color-dot" style="background:#7D2235"></span><span class="color-dot" style="background:#111B2E"></span><span class="color-dot" style="background:#C4A35A"></span></div>
                </div>
                <p class="tpl-desc">Botanical peonies frame a dark navy watercolor hero with gold and rose accents.</p>
            </div>
        </div>

        <div class="tpl-card">
            <div class="tpl-img-wrap">
                <img src="/assets/blue-floral-left.jpg" alt="Indigo Bloom" onerror="this.style.background='#EEF3F9'">
                <div class="tpl-overlay">
                    <a href="/members/preview-template.cfm?template=indigo_bloom" target="_blank" class="tpl-btn-preview"><i data-lucide="eye" style="width:14px;height:14px"></i>Preview</a>
                    <a href="/members/wedding-site-edit.cfm?template=indigo_bloom" class="tpl-btn-select"><i data-lucide="check" style="width:14px;height:14px"></i>Select</a>
                </div>
            </div>
            <div class="tpl-card-body">
                <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:8px">
                    <p class="tpl-name">Indigo Bloom</p>
                    <div style="display:flex;gap:5px"><span class="color-dot" style="background:#1C3166"></span><span class="color-dot" style="background:#EEF3F9"></span><span class="color-dot" style="background:#B8922A"></span></div>
                </div>
                <p class="tpl-desc">Navy watercolor peonies framing a white page with gold accents and elegant typography.</p>
            </div>
        </div>

        <div class="tpl-card">
            <div class="tpl-img-wrap">
                <img src="/assets/gold-corner-top.jpg" alt="Golden Affair" onerror="this.style.background='#F7F0E3'" style="object-position:right top">
                <div class="tpl-overlay">
                    <a href="/members/preview-template.cfm?template=golden_affair" target="_blank" class="tpl-btn-preview"><i data-lucide="eye" style="width:14px;height:14px"></i>Preview</a>
                    <a href="/members/wedding-site-edit.cfm?template=golden_affair" class="tpl-btn-select"><i data-lucide="check" style="width:14px;height:14px"></i>Select</a>
                </div>
            </div>
            <div class="tpl-card-body">
                <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:8px">
                    <p class="tpl-name">Golden Affair</p>
                    <div style="display:flex;gap:5px"><span class="color-dot" style="background:#C9A242"></span><span class="color-dot" style="background:#F7F0E3"></span><span class="color-dot" style="background:#1E1A14"></span></div>
                </div>
                <p class="tpl-desc">Gold glitter corner accents on white with champagne tones and elegant script names.</p>
            </div>
        </div>

        <div class="tpl-card">
            <div class="tpl-img-wrap">
                <img src="/assets/watercolor-top.jpg" alt="Crimson Garden" onerror="this.style.background='#F5E8E6'" style="object-position:center top">
                <div class="tpl-overlay">
                    <a href="/members/preview-template.cfm?template=crimson_garden" target="_blank" class="tpl-btn-preview"><i data-lucide="eye" style="width:14px;height:14px"></i>Preview</a>
                    <a href="/members/wedding-site-edit.cfm?template=crimson_garden" class="tpl-btn-select"><i data-lucide="check" style="width:14px;height:14px"></i>Select</a>
                </div>
            </div>
            <div class="tpl-card-body">
                <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:8px">
                    <p class="tpl-name">Crimson Garden</p>
                    <div style="display:flex;gap:5px"><span class="color-dot" style="background:#7B2835"></span><span class="color-dot" style="background:#F5E8E6"></span><span class="color-dot" style="background:#7A9B6A"></span></div>
                </div>
                <p class="tpl-desc">Watercolor burgundy florals on white with script names and romantic blush accents.</p>
            </div>
        </div>

        <div class="tpl-card">
            <div class="tpl-img-wrap">
                <img src="/assets/roses-hero.jpeg" alt="Romantic Rose" onerror="this.src='/assets/roses-hero.jpg'" style="object-position:center 30%">
                <div class="tpl-overlay">
                    <a href="/members/preview-template.cfm?template=romantic_rose" target="_blank" class="tpl-btn-preview"><i data-lucide="eye" style="width:14px;height:14px"></i>Preview</a>
                    <a href="/members/wedding-site-edit.cfm?template=romantic_rose" class="tpl-btn-select"><i data-lucide="check" style="width:14px;height:14px"></i>Select</a>
                </div>
            </div>
            <div class="tpl-card-body">
                <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:8px">
                    <p class="tpl-name">Romantic Rose</p>
                    <div style="display:flex;gap:5px"><span class="color-dot" style="background:#C4686A"></span><span class="color-dot" style="background:#F2D6D6"></span><span class="color-dot" style="background:#6B2D35"></span></div>
                </div>
                <p class="tpl-desc">Dusty rose and blush tones with a dramatic center-panel hero and script accents.</p>
            </div>
        </div>

        <div class="tpl-card">
            <div class="tpl-img-wrap">
                <img src="/assets/first-light.jpg" alt="First Light" onerror="this.style.background='#E8E4DF'" style="object-position:center">
                <div class="tpl-overlay">
                    <a href="/members/preview-template.cfm?template=first_light" target="_blank" class="tpl-btn-preview"><i data-lucide="eye" style="width:14px;height:14px"></i>Preview</a>
                    <a href="/members/wedding-site-edit.cfm?template=first_light" class="tpl-btn-select"><i data-lucide="check" style="width:14px;height:14px"></i>Select</a>
                </div>
            </div>
            <div class="tpl-card-body">
                <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:8px">
                    <p class="tpl-name">First Light</p>
                    <div style="display:flex;gap:5px"><span class="color-dot" style="background:#FAF9F7;border-color:#ccc"></span><span class="color-dot" style="background:#E8E4DF"></span><span class="color-dot" style="background:#8C7B6B"></span></div>
                </div>
                <p class="tpl-desc">Soft greige and warm white with fine-art floral photography and minimal serif elegance.</p>
            </div>
        </div>


    <!--- Greek Inspired --->
    <div class="tpl-category" style="grid-column:1/-1">
        <span class="tpl-category-label">Greek Inspired</span>
        <div class="tpl-category-line"></div>
    </div>

        <div class="tpl-card" style="border:2px solid #C41230;background:#1A0000">
            <div class="tpl-img-wrap">
                <img src="/assets/chi-omega-love.png" alt="Chi Omega Love" onerror="this.style.background='#1A0000'" style="object-position:center top">
                <div class="tpl-overlay">
                    <a href="/members/preview-template.cfm?template=chi_omega_love" target="_blank" class="tpl-btn-preview"><i data-lucide="eye" style="width:14px;height:14px"></i>Preview</a>
                    <a href="/members/wedding-site-edit.cfm?template=chi_omega_love" class="tpl-btn-select"><i data-lucide="check" style="width:14px;height:14px"></i>Select</a>
                </div>
            </div>
            <div class="tpl-card-body">
                <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:8px">
                    <p class="tpl-name">Chi Omega Love</p>
                    <div style="display:flex;gap:5px"><span class="color-dot" style="background:#C41230"></span><span class="color-dot" style="background:#C9A84C"></span><span class="color-dot" style="background:#FAF6EE;border-color:#ccc"></span></div>
                </div>
                <p class="tpl-desc">Cardinal red &amp; gold &mdash; a regal crest design with rich crimson draping and gilded accents.</p>
            </div>
        </div>

        <div class="tpl-card" style="border:2px solid #6B21A8;background:#1A0040">
            <div class="tpl-img-wrap">
                <img src="/assets/sigma-alpha-love.png" alt="Sigma Alpha Love" onerror="this.style.background='#1A0040'" style="object-position:center top">
                <div class="tpl-overlay">
                    <a href="/members/preview-template.cfm?template=sigma_alpha_love" target="_blank" class="tpl-btn-preview"><i data-lucide="eye" style="width:14px;height:14px"></i>Preview</a>
                    <a href="/members/wedding-site-edit.cfm?template=sigma_alpha_love" class="tpl-btn-select"><i data-lucide="check" style="width:14px;height:14px"></i>Select</a>
                </div>
            </div>
            <div class="tpl-card-body">
                <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:8px">
                    <p class="tpl-name">Sigma Alpha Love</p>
                    <div style="display:flex;gap:5px"><span class="color-dot" style="background:#6B21A8"></span><span class="color-dot" style="background:#C9A84C"></span><span class="color-dot" style="background:#FAF6EE;border-color:#ccc"></span></div>
                </div>
                <p class="tpl-desc">Royal purple &amp; gold &mdash; regal purple draping with lion crest and gilded gold accents.</p>
            </div>
        </div>

        <div class="tpl-card" style="border:2px solid #1A3FA0;background:#080F2A">
            <div class="tpl-img-wrap">
                <img src="/assets/delta-delta-love.png" alt="Delta Delta Love" onerror="this.style.background='#080F2A'" style="object-position:center top">
                <div class="tpl-overlay">
                    <a href="/members/preview-template.cfm?template=delta_delta_love" target="_blank" class="tpl-btn-preview"><i data-lucide="eye" style="width:14px;height:14px"></i>Preview</a>
                    <a href="/members/wedding-site-edit.cfm?template=delta_delta_love" class="tpl-btn-select"><i data-lucide="check" style="width:14px;height:14px"></i>Select</a>
                </div>
            </div>
            <div class="tpl-card-body">
                <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:8px">
                    <p class="tpl-name">Delta Delta Love</p>
                    <div style="display:flex;gap:5px"><span class="color-dot" style="background:#1A3FA0"></span><span class="color-dot" style="background:#C9A84C"></span><span class="color-dot" style="background:#FAF6EE;border-color:#ccc"></span></div>
                </div>
                <p class="tpl-desc">Navy blue &amp; gold &mdash; elegant navy draping with trident crest and gold accents.</p>
            </div>
        </div>

        <div class="tpl-card" style="border:2px solid #C4547A;background:#1A0A10">
            <div class="tpl-img-wrap">
                <img src="/assets/aka-love.jpg" alt="AKA Love" onerror="this.style.background='linear-gradient(to bottom,#C4547A,#1A0A10)'">
                <div class="tpl-overlay">
                    <a href="/members/preview-template.cfm?template=aka_love" target="_blank" class="tpl-btn-preview"><i data-lucide="eye" style="width:14px;height:14px"></i>Preview</a>
                    <a href="/members/wedding-site-edit.cfm?template=aka_love" class="tpl-btn-select"><i data-lucide="check" style="width:14px;height:14px"></i>Select</a>
                </div>
            </div>
            <div class="tpl-card-body" style="background:#1A0A10">
                <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:8px">
                    <p class="tpl-name" style="color:#FAF6EE">AKA Love</p>
                    <div style="display:flex;gap:5px"><span class="color-dot" style="background:#C4547A"></span><span class="color-dot" style="background:#2D6A4F"></span><span class="color-dot" style="background:#F8F4F0"></span></div>
                </div>
                <p class="tpl-desc" style="color:rgba(250,246,238,.6)">Pink, green &amp; pearl elegance</p>
            </div>
        </div>

        <div class="tpl-card" style="border:2px solid #C41230;background:#1A0000">
            <div class="tpl-img-wrap">
                <img src="/assets/kappa-love.jpg" alt="Kappa Love" style="object-position:center top" onerror="this.style.background='linear-gradient(to bottom,#C41230,#1A0000)'">
                <div class="tpl-overlay">
                    <a href="/members/preview-template.cfm?template=kappa_love" target="_blank" class="tpl-btn-preview"><i data-lucide="eye" style="width:14px;height:14px"></i>Preview</a>
                    <a href="/members/wedding-site-edit.cfm?template=kappa_love" class="tpl-btn-select"><i data-lucide="check" style="width:14px;height:14px"></i>Select</a>
                </div>
            </div>
            <div class="tpl-card-body" style="background:#1A0000">
                <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:8px">
                    <p class="tpl-name" style="color:#FAF6EE">Kappa Love</p>
                    <div style="display:flex;gap:5px"><span class="color-dot" style="background:#C41230"></span><span class="color-dot" style="background:#FAF6EE;border:1px solid #ccc"></span><span class="color-dot" style="background:#C9A84C"></span></div>
                </div>
                <p class="tpl-desc" style="color:rgba(250,246,238,.6)">Crimson, cream &amp; gold elegance</p>
            </div>
        </div>

        <div class="tpl-card" style="border:2px solid #C41230;background:#1A0000">
            <div class="tpl-img-wrap">
                <img src="/assets/delta-love.jpg" alt="Delta Love" style="object-position:center top" onerror="this.style.background='linear-gradient(to bottom,#C41230,#1A0000)'">
                <div class="tpl-overlay">
                    <a href="/members/preview-template.cfm?template=delta_love" target="_blank" class="tpl-btn-preview"><i data-lucide="eye" style="width:14px;height:14px"></i>Preview</a>
                    <a href="/members/wedding-site-edit.cfm?template=delta_love" class="tpl-btn-select"><i data-lucide="check" style="width:14px;height:14px"></i>Select</a>
                </div>
            </div>
            <div class="tpl-card-body" style="background:#1A0000">
                <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:8px">
                    <p class="tpl-name" style="color:#FAF6EE">Delta Love</p>
                    <div style="display:flex;gap:5px"><span class="color-dot" style="background:#C41230"></span><span class="color-dot" style="background:#FAF6EE;border:1px solid #ccc"></span><span class="color-dot" style="background:#C9A84C"></span></div>
                </div>
                <p class="tpl-desc" style="color:rgba(250,246,238,.6)">Crimson, cream &amp; gold elegance</p>
            </div>
        </div>

        <div class="tpl-card" style="border:2px solid #1A3FA0;background:#080F2A">
            <div class="tpl-img-wrap">
                <img src="/assets/zeta-love.jpg" alt="Zeta Love" style="object-position:center top" onerror="this.style.background='linear-gradient(to bottom,#1A3FA0,#080F2A)'">
                <div class="tpl-overlay">
                    <a href="/members/preview-template.cfm?template=zeta_love" target="_blank" class="tpl-btn-preview"><i data-lucide="eye" style="width:14px;height:14px"></i>Preview</a>
                    <a href="/members/wedding-site-edit.cfm?template=zeta_love" class="tpl-btn-select"><i data-lucide="check" style="width:14px;height:14px"></i>Select</a>
                </div>
            </div>
            <div class="tpl-card-body" style="background:#080F2A">
                <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:8px">
                    <p class="tpl-name" style="color:#FAF6EE">Zeta Love</p>
                    <div style="display:flex;gap:5px"><span class="color-dot" style="background:#1A3FA0"></span><span class="color-dot" style="background:#FAF6EE;border:1px solid #ccc"></span><span class="color-dot" style="background:#C0C8D8"></span></div>
                </div>
                <p class="tpl-desc" style="color:rgba(250,246,238,.6)">Royal blue, white &amp; silver elegance</p>
            </div>
        </div>

        <div class="tpl-card" style="border:2px solid #C9A84C;background:#0A0A00">
            <div class="tpl-img-wrap">
                <img src="/assets/alpha-love.jpg" alt="Alpha Love" style="object-position:center top" onerror="this.style.background='linear-gradient(to bottom,#C9A84C,#0A0A00)'">
                <div class="tpl-overlay">
                    <a href="/members/preview-template.cfm?template=alpha_love" target="_blank" class="tpl-btn-preview"><i data-lucide="eye" style="width:14px;height:14px"></i>Preview</a>
                    <a href="/members/wedding-site-edit.cfm?template=alpha_love" class="tpl-btn-select"><i data-lucide="check" style="width:14px;height:14px"></i>Select</a>
                </div>
            </div>
            <div class="tpl-card-body" style="background:#0A0A00">
                <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:8px">
                    <p class="tpl-name" style="color:#FAF6EE">Alpha Love</p>
                    <div style="display:flex;gap:5px"><span class="color-dot" style="background:#0A0A00;border:1px solid #C9A84C"></span><span class="color-dot" style="background:#C9A84C"></span><span class="color-dot" style="background:#E8C97A"></span></div>
                </div>
                <p class="tpl-desc" style="color:rgba(250,246,238,.6)">Black &amp; gold regal elegance</p>
            </div>
        </div>

        <div class="tpl-card" style="border:2px solid #C9A84C;background:#0A0010">
            <div class="tpl-img-wrap">
                <img src="/assets/omega-love.jpg" alt="Omega Love" style="filter:brightness(1.8);object-position:center top" onerror="this.style.background='linear-gradient(to bottom,#4B0082,#0A0010)'">
                <div class="tpl-overlay">
                    <a href="/members/preview-template.cfm?template=omega_love" target="_blank" class="tpl-btn-preview"><i data-lucide="eye" style="width:14px;height:14px"></i>Preview</a>
                    <a href="/members/wedding-site-edit.cfm?template=omega_love" class="tpl-btn-select"><i data-lucide="check" style="width:14px;height:14px"></i>Select</a>
                </div>
            </div>
            <div class="tpl-card-body" style="background:#0A0010">
                <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:8px">
                    <p class="tpl-name" style="color:#FAF6EE">Omega Love</p>
                    <div style="display:flex;gap:5px"><span class="color-dot" style="background:#4B0082"></span><span class="color-dot" style="background:#6A0DAD"></span><span class="color-dot" style="background:#C9A84C"></span></div>
                </div>
                <p class="tpl-desc" style="color:rgba(250,246,238,.6)">Deep purple &amp; gold &mdash; a regal, elegant design for Omega Psi Phi couples.</p>
            </div>
        </div>

    <!--- Pride & Community --->
    <div class="tpl-category" style="grid-column:1/-1">
        <span class="tpl-category-label">Pride &amp; Community</span>
        <div class="tpl-category-line"></div>
    </div>

        <div class="tpl-card" style="border:2px solid transparent;border-image:linear-gradient(135deg,#E8373A,#F4831F,#FBBF24,#22A55B,#1D6FB5,#7B3FBE) 1">
            <div class="tpl-img-wrap">
                <img src="/assets/pride-rainbow.jpg" alt="Pride Rainbow" onerror="this.style.background='linear-gradient(135deg,#E8373A,#F4831F,#FBBF24,#22A55B,#1D6FB5,#7B3FBE)'">
                <div class="tpl-overlay">
                    <a href="/members/preview-template.cfm?template=pride_rainbow" target="_blank" class="tpl-btn-preview"><i data-lucide="eye" style="width:14px;height:14px"></i>Preview</a>
                    <a href="/members/wedding-site-edit.cfm?template=pride_rainbow" class="tpl-btn-select"><i data-lucide="check" style="width:14px;height:14px"></i>Select</a>
                </div>
            </div>
            <div class="tpl-card-body">
                <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:8px">
                    <p class="tpl-name">Pride Rainbow</p>
                    <div style="display:flex;gap:5px">
                        <span class="color-dot" style="background:#E8373A"></span>
                        <span class="color-dot" style="background:#FBBF24"></span>
                        <span class="color-dot" style="background:#22A55B"></span>
                        <span class="color-dot" style="background:#1D6FB5"></span>
                        <span class="color-dot" style="background:#7B3FBE"></span>
                    </div>
                </div>
                <p class="tpl-desc">Bold rainbow stripes &amp; vibrant love &mdash; a joyful, colorful celebration of your unique love story.</p>
            </div>
        </div>

    </div><!--- end tpl-grid --->

</div>
</section>

<cfinclude template="../includes/layout-end.cfm">
