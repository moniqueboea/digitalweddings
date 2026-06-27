<!---
  first_light.cfm — soft greige floral, minimalist fine-art
  Palette: warm white #FAF9F7, greige #E8E4DF, taupe #8C7B6B, charcoal #2C2828, warm black #1A1716
--->
<cfset weddingDateFull = "">
<cfset weddingDayMonth = "">
<cfset weddingYear     = "">
<cfif len(trim(site.wedding_date))>
<cftry>
  <cfset _d = parseDateTime(site.wedding_date)>
  <cfset weddingDateFull = dateFormat(_d,"dddd, mmmm d, yyyy")>
  <cfset weddingDayMonth = dateFormat(_d,"mmmm d")>
  <cfset weddingYear     = dateFormat(_d,"yyyy")>
<cfcatch><cfset weddingDateFull = site.wedding_date></cfcatch>
</cftry>
</cfif>

<cfset galleryList = []>
<cfif len(trim(site.gallery_images_json))>
<cftry><cfset galleryList = deserializeJSON(site.gallery_images_json)><cfcatch><cfset galleryList = []></cfcatch></cftry>
</cfif>
<cfset faqList = []>
<cfif len(trim(site.faq_json))>
<cftry><cfset faqList = deserializeJSON(site.faq_json)><cfcatch><cfset faqList = []></cfcatch></cftry>
</cfif>

<cfset receptionVenueName    = structKeyExists(site,"reception_venue_name")    ? trim(site.reception_venue_name)    : "">
<cfset receptionVenueAddress = structKeyExists(site,"reception_venue_address") ? trim(site.reception_venue_address) : "">
<cfset travelLinks = []>
<cftry><cfif structKeyExists(site,"travel_links_json") && len(trim(site.travel_links_json))><cfset travelLinks = deserializeJSON(site.travel_links_json)></cfif><cfcatch type="any"><cfset travelLinks = []></cfcatch></cftry>
<cfset thingsLinks = []>
<cftry><cfif structKeyExists(site,"things_links_json") && len(trim(site.things_links_json))><cfset thingsLinks = deserializeJSON(site.things_links_json)></cfif><cfcatch type="any"><cfset thingsLinks = []></cfcatch></cftry>
<cfset heroImg               = len(trim(site.hero_image_url)) ? trim(site.hero_image_url) : "">

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title><cfoutput>#HTMLEditFormat(site.couple_name_1)# &amp; #HTMLEditFormat(site.couple_name_2)#</cfoutput></title>
<link href="https://fonts.googleapis.com/css2?family=Cormorant+Garamond:ital,wght@0,300;0,400;1,300;1,400&family=Jost:wght@200;300;400&display=swap" rel="stylesheet">
<style>
:root{--white:#FAF9F7;--greige:#E8E4DF;--greige-dark:#D4CFC9;--taupe:#8C7B6B;--charcoal:#2C2828;--warm-black:#1A1716;--muted:rgba(44,40,40,.45)}
*{margin:0;padding:0;box-sizing:border-box}
html{scroll-behavior:smooth}
body{background:var(--white);color:var(--charcoal);font-family:'Jost',sans-serif;font-weight:300;line-height:1.7;overflow-x:hidden}

/* ---- HERO ---- */
.hero{position:relative;height:65vh;min-height:440px;overflow:hidden;display:flex;flex-direction:column}
.hero-img{position:absolute;inset:0;background:var(--greige)}
.hero-img img{width:100%;height:100%;object-fit:cover;object-position:center;display:block}
.hero-overlay{position:absolute;inset:0;background:linear-gradient(to bottom,rgba(250,249,247,.15) 0%,rgba(250,249,247,.05) 50%,rgba(250,249,247,.55) 100%)}

/* ---- NAV on hero ---- */
.hero-nav{position:relative;z-index:10;display:flex;align-items:center;justify-content:center;flex-wrap:wrap;padding:28px 24px 0;gap:0}
.hero-nav a{color:rgba(44,40,40,.7);text-decoration:none;font-size:.75rem;letter-spacing:.18em;text-transform:uppercase;font-family:'Jost',sans-serif;font-weight:300;padding:10px 16px;border-bottom:1px solid transparent;transition:color .2s,border-color .2s;white-space:nowrap}
.hero-nav a:hover,.hero-nav a.active{color:var(--warm-black);border-bottom-color:var(--charcoal)}

/* ---- HERO TEXT centered bottom ---- */
.hero-text{position:relative;z-index:10;margin-top:auto;padding:0 24px 52px;text-align:center;display:flex;flex-direction:column;align-items:center}
.hero-couple{font-family:'Cormorant Garamond',Georgia,serif;font-size:clamp(2.8rem,7vw,5.5rem);font-weight:300;color:var(--warm-black);line-height:1.05;letter-spacing:.03em}
.hero-meta{margin-top:14px;display:flex;align-items:center;justify-content:center;gap:14px;flex-wrap:wrap}
.hero-date-line{font-size:.58rem;letter-spacing:.3em;text-transform:uppercase;color:var(--taupe);font-family:'Jost',sans-serif}
.hero-dot{width:2px;height:2px;border-radius:50%;background:var(--taupe);flex-shrink:0}
.hero-venue-line{font-size:.58rem;letter-spacing:.2em;text-transform:uppercase;color:rgba(140,123,107,.7);font-family:'Jost',sans-serif}

@media(max-width:600px){
  .hero-couple{font-size:2.4rem}
  .hero-nav a{padding:8px 10px;font-size:.54rem}
}

/* ---- STICKY NAV ---- */
.sticky-nav{position:sticky;top:0;z-index:100;background:rgba(250,249,247,.97);border-bottom:1px solid var(--greige);backdrop-filter:blur(8px);display:none}
.sticky-nav .inner{max-width:960px;margin:0 auto;display:flex;align-items:center;justify-content:center;flex-wrap:wrap}
.sticky-nav a{color:rgba(44,40,40,.6);text-decoration:none;font-size:.75rem;letter-spacing:.15em;text-transform:uppercase;padding:18px 16px;border-bottom:2px solid transparent;transition:color .2s,border-color .2s;white-space:nowrap;font-family:'Jost',sans-serif}
.sticky-nav a:hover,.sticky-nav a.active{color:var(--warm-black);border-bottom-color:var(--taupe)}

/* ---- SECTIONS ---- */
.section{padding:90px 48px;max-width:860px;margin:0 auto}
.section-tint{background:var(--greige);padding:90px 48px}
.section-tint .inner{max-width:860px;margin:0 auto}
.divider{width:100%;height:1px;background:var(--greige)}

.section-title{margin-bottom:52px}
.section-title .eyebrow{font-size:.75rem;letter-spacing:.3em;text-transform:uppercase;color:var(--taupe);display:block;margin-bottom:14px;font-family:'Jost',sans-serif}
.section-title h2{font-family:'Cormorant Garamond',Georgia,serif;font-size:clamp(2.4rem,4vw,3.4rem);font-weight:300;color:var(--warm-black);letter-spacing:.04em;font-style:italic}
.taupe-rule{width:32px;height:1px;background:var(--taupe);margin-top:16px;opacity:.5}

/* ---- DETAILS ---- */
.details-grid{display:flex;flex-wrap:wrap;gap:1px;background:var(--greige-dark);max-width:860px;margin:0 auto}
.detail-block{flex:1;min-width:160px;padding:44px 40px;background:var(--white);text-align:center}
.detail-block .lbl{font-size:.53rem;letter-spacing:.36em;text-transform:uppercase;color:var(--taupe);margin-bottom:16px;display:block;font-family:'Jost',sans-serif}
.detail-block .val{font-family:'Cormorant Garamond',Georgia,serif;font-size:1.6rem;font-weight:300;color:var(--warm-black);line-height:1.25;font-style:italic}
.detail-block .sub{font-size:.78rem;color:var(--muted);margin-top:8px}

/* ---- STORY ---- */
.story-body{font-family:'Cormorant Garamond',Georgia,serif;font-size:1.3rem;font-weight:300;line-height:2.1;color:var(--charcoal);white-space:pre-wrap;font-style:italic;max-width:600px}

/* ---- GALLERY ---- */
.gallery-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(240px,1fr));gap:3px;max-width:860px;margin:0 auto}
.g-photo{aspect-ratio:1;overflow:hidden;cursor:pointer;border-radius:10px}
.g-photo img{width:100%;height:100%;object-fit:cover;transition:transform .5s,filter .4s;filter:saturate(.85)}
.g-photo:hover img{transform:scale(1.04);filter:saturate(1)}

/* ---- FAQ ---- */
.faq-list{display:flex;flex-direction:column;max-width:660px}
.faq-item{padding:28px 0;border-bottom:1px solid var(--greige-dark)}
.faq-item .q{font-family:'Cormorant Garamond',Georgia,serif;font-size:1.15rem;font-weight:400;color:var(--warm-black);margin-bottom:10px;font-style:italic}
.faq-item .a{font-size:.85rem;color:var(--muted);line-height:1.9}

/* ---- TEXT ---- */
.text-body{font-size:.9rem;color:var(--charcoal);line-height:2;white-space:pre-wrap;max-width:600px;opacity:.8}
.link-btn{display:inline-block;margin-top:28px;padding:13px 36px;border:1px solid var(--taupe);color:var(--taupe);text-decoration:none;font-size:.58rem;letter-spacing:.28em;text-transform:uppercase;font-family:'Jost',sans-serif;transition:background .2s,color .2s}
.link-btn:hover{background:var(--taupe);color:var(--white)}

/* ---- RSVP ---- */
.rsvp-section{text-align:center;padding:130px 24px;position:relative;overflow:hidden}
.rsvp-bg{position:absolute;inset:0;background:var(--greige)}
.rsvp-bg img{width:100%;height:100%;object-fit:cover;filter:brightness(1.05) saturate(0) contrast(.85)}
.rsvp-content{position:relative;z-index:2}
.rsvp-content .eyebrow{font-size:.85rem;letter-spacing:.28em;text-transform:uppercase;color:var(--taupe);display:block;margin-bottom:18px}
.rsvp-content h2{font-family:'Cormorant Garamond',Georgia,serif;font-size:clamp(2.8rem,5vw,4.8rem);font-weight:300;color:var(--warm-black);margin-bottom:18px;letter-spacing:.03em;font-style:italic}
.rsvp-content p{color:var(--muted);margin-bottom:48px;max-width:420px;margin-left:auto;margin-right:auto;font-size:1rem;line-height:2}
.rsvp-btn{display:inline-block;padding:15px 56px;border:1px solid var(--charcoal);color:var(--warm-black);font-size:.6rem;letter-spacing:.3em;text-transform:uppercase;text-decoration:none;font-family:'Jost',sans-serif;transition:background .25s,color .25s}
.rsvp-btn:hover{background:var(--warm-black);color:var(--white)}

/* ---- FOOTER ---- */
footer{text-align:center;padding:70px 24px;border-top:1px solid var(--greige)}
footer .names{font-family:'Cormorant Garamond',Georgia,serif;font-size:2rem;font-weight:300;color:var(--warm-black);letter-spacing:.06em;font-style:italic;margin-bottom:10px}
footer .date{font-size:.56rem;letter-spacing:.32em;text-transform:uppercase;color:var(--taupe)}
footer .credit{font-size:1.1rem;font-weight:500;font-weight:500;color:rgba(44,40,40,.18);margin-top:28px}

/* ---- LIGHTBOX ---- */
#lightbox{position:fixed;inset:0;background:rgba(26,23,22,.96);z-index:999;display:none;align-items:center;justify-content:center;padding:20px}
#lightbox.show{display:flex}
#lightbox img{max-height:85vh;max-width:90vw;object-fit:contain}
#lightbox button{position:absolute;background:rgba(255,255,255,.08);border:none;color:#fff;cursor:pointer}
#lightbox .nav-btn{width:52px;height:52px;font-size:1.8rem;top:50%;transform:translateY(-50%)}
#lightbox .prev{left:20px}
#lightbox .next{right:20px}
#lightbox .close-lb{top:16px;right:16px;width:40px;height:40px;font-size:1.1rem}
#lightbox .count{position:absolute;bottom:20px;color:rgba(255,255,255,.3);font-size:.75rem;letter-spacing:.1em}
</style>
</head>
<body>

<cfif structKeyExists(site,"is_preview") AND site.is_preview>
<div style="position:fixed;top:0;left:0;right:0;z-index:9999;background:#1a1716;color:#fff;display:flex;align-items:center;justify-content:space-between;padding:12px 24px;font-family:Arial,sans-serif;font-size:13px;border-bottom:1px solid #2c2828;gap:12px">
  <cfif isNumeric(url.siteId) AND url.siteId GT 0>
  <span style="opacity:.7">&#128065; Previewing your wedding site</span>
  <button onclick="window.close()" style="padding:8px 20px;background:#2c2828;color:#fff;border:none;border-radius:4px;font-weight:600;cursor:pointer;font-size:13px">&times; Close Preview</button>
  <cfelse>
  <span style="opacity:.7">&#128065; Template preview &mdash; sample data shown</span>
  <a href="/members/wedding-site-edit.cfm?template=first_light" style="padding:8px 20px;background:#8C7B6B;color:#fff;border-radius:4px;font-weight:600;text-decoration:none;white-space:nowrap">Use This Template &rarr;</a>
  </cfif>
</div>
<div style="height:48px"></div>
</cfif>

<!--- HERO --->
<div class="hero" id="welcome">
  <div class="hero-img">
    <cfif len(heroImg)>
    <img src="<cfoutput>#HTMLEditFormat(heroImg)#</cfoutput>" alt="Wedding">
    <cfelse>
    <img src="/assets/first-light.jpg" alt="White flower" onerror="this.style.display='none'">
    </cfif>
  </div>
  <div class="hero-overlay"></div>

  <nav class="hero-nav">
    <cfif len(trim(site.story))><a href="#our_story">Our Story</a></cfif>
    <a href="#details">Details</a>
    <cfif structKeyExists(site,"registry_url") AND len(trim(site.registry_url))><a href="<cfoutput>#HTMLEditFormat(trim(site.registry_url))#</cfoutput>" target="_blank" rel="noopener">Registry</a></cfif><a href="#rsvp">RSVP</a>
    <cfif arrayLen(galleryList)><a href="#photos">Photos</a></cfif>
    <cfif arrayLen(faqList)><a href="#q_and_a">Q &amp; A</a></cfif>
    <cfif len(trim(site.dress_code))><a href="#dress_code">Dress Code</a></cfif>
    <cfif len(trim(site.travel_info)) OR (structKeyExists(site,"travel_links_json") AND len(trim(site.travel_links_json)))><a href="#travel">Travel</a></cfif>
    <cfif len(trim(site.things_to_do)) OR arrayLen(thingsLinks)><a href="#things_to_do">Things to Do</a></cfif>
  </nav>

  <div class="hero-text">
    <cfset couplePhoto = structKeyExists(site,"couple_photo_url") ? trim(site.couple_photo_url) : "">
    <cfset couplePhotoSrc = len(couplePhoto) ? couplePhoto : "/assets/couple-placeholder.jpg">
    <img src="<cfoutput>#HTMLEditFormat(couplePhotoSrc)#</cfoutput>" alt="Couple photo" style="width:130px;height:130px;border-radius:50%;object-fit:cover;border:3px solid rgba(255,255,255,.5);box-shadow:0 4px 24px rgba(0,0,0,.5);display:block;margin-bottom:22px">
    <div class="hero-couple">
      <cfoutput>#HTMLEditFormat(site.couple_name_1)# &amp; #HTMLEditFormat(site.couple_name_2)#</cfoutput>
    </div>
    <div class="hero-meta">
      <cfif len(weddingDateFull)>
      <span class="hero-date-line"><cfoutput>#weddingDateFull#</cfoutput></span>
      </cfif>
      <cfif len(weddingDateFull) AND len(trim(site.venue_name))>
      <div class="hero-dot"></div>
      </cfif>
      <cfif len(trim(site.venue_name))>
      <span class="hero-venue-line"><cfoutput>#HTMLEditFormat(site.venue_name)#</cfoutput></span>
      </cfif>
    </div>
  </div>
</div>

<!--- STICKY NAV --->
<nav class="sticky-nav" id="stickyNav">
  <div class="inner">
    <cfif len(trim(site.story))><a href="#our_story">Our Story</a></cfif>
    <a href="#details">Details</a>
    <cfif structKeyExists(site,"registry_url") AND len(trim(site.registry_url))><a href="<cfoutput>#HTMLEditFormat(trim(site.registry_url))#</cfoutput>" target="_blank" rel="noopener">Registry</a></cfif><a href="#rsvp">RSVP</a>
    <cfif arrayLen(galleryList)><a href="#photos">Photos</a></cfif>
    <cfif arrayLen(faqList)><a href="#q_and_a">Q &amp; A</a></cfif>
    <cfif len(trim(site.dress_code))><a href="#dress_code">Dress Code</a></cfif>
    <cfif len(trim(site.travel_info)) OR (structKeyExists(site,"travel_links_json") AND len(trim(site.travel_links_json)))><a href="#travel">Travel</a></cfif>
    <cfif len(trim(site.things_to_do)) OR arrayLen(thingsLinks)><a href="#things_to_do">Things to Do</a></cfif>
  </div>
</nav>

<!--- OUR STORY --->
<cfif len(trim(site.story))>
<div class="divider"></div>
<section class="section" id="our_story">
  <div class="section-title">
    <span class="eyebrow">The Beginning</span>
    <h2>Our Story</h2>
    <div class="taupe-rule"></div>
  </div>
  <p class="story-body"><cfoutput>#HTMLEditFormat(site.story)#</cfoutput></p>
</section>
</cfif>

<!--- DETAILS --->
<div class="divider"></div>
<section id="details" style="padding:90px 0">
  <div style="max-width:860px;margin:0 auto;padding:0 48px 52px">
    <div class="section-title">
      <span class="eyebrow">Celebration Details</span>
      <h2>Join Us</h2>
      <div class="taupe-rule"></div>
    </div>
  </div>
  <div class="details-grid">
    <cfif len(weddingDateFull)>
    <div class="detail-block">
      <span class="lbl">Date</span>
      <div class="val"><cfoutput>#weddingDayMonth#</cfoutput></div>
      <div class="sub"><cfoutput>#weddingYear#</cfoutput></div>
    </div>
    </cfif>
    <cfif len(trim(site.venue_name))>
    <div class="detail-block">
      <span class="lbl">Ceremony</span>
      <div class="val"><cfoutput>#HTMLEditFormat(site.venue_name)#</cfoutput></div>
      <cfif len(trim(site.venue_address))><div class="sub"><cfoutput>#HTMLEditFormat(site.venue_address)#</cfoutput></div></cfif>
    </div>
    </cfif>
    <cfif len(receptionVenueName)>
    <div class="detail-block">
      <span class="lbl">Reception</span>
      <div class="val"><cfoutput>#HTMLEditFormat(receptionVenueName)#</cfoutput></div>
      <cfif len(receptionVenueAddress)><div class="sub"><cfoutput>#HTMLEditFormat(receptionVenueAddress)#</cfoutput></div></cfif>
    </div>
    </cfif>
  </div>
</section>

<!--- GALLERY --->
<cfif arrayLen(galleryList)>
<div class="divider"></div>
<section id="photos" style="padding:90px 0">
  <div style="max-width:860px;margin:0 auto;padding:0 48px 52px">
    <div class="section-title">
      <span class="eyebrow">Captured Moments</span>
      <h2>Photos</h2>
      <div class="taupe-rule"></div>
    </div>
  </div>
  <div class="gallery-grid">
    <cfloop from="1" to="#arrayLen(galleryList)#" index="gi">
    <div class="g-photo" onclick="openLightbox(<cfoutput>#gi - 1#</cfoutput>)">
      <img src="<cfoutput>#HTMLEditFormat(galleryList[gi])#</cfoutput>" alt="Photo <cfoutput>#gi#</cfoutput>" loading="lazy">
    </div>
    </cfloop>
  </div>
</section>
</cfif>

<!--- FAQ --->
<cfif arrayLen(faqList)>
<div class="divider"></div>
<div class="section-tint" id="q_and_a">
  <div class="inner">
    <div class="section-title">
      <span class="eyebrow">Good to Know</span>
      <h2>Q &amp; A</h2>
      <div class="taupe-rule"></div>
    </div>
    <div class="faq-list">
      <cfloop from="1" to="#arrayLen(faqList)#" index="fi">
      <div class="faq-item">
        <div class="q"><cfoutput>#HTMLEditFormat(faqList[fi].question)#</cfoutput></div>
        <div class="a"><cfoutput>#HTMLEditFormat(faqList[fi].answer)#</cfoutput></div>
      </div>
      </cfloop>
    </div>
  </div>
</div>
</cfif>

<!--- DRESS CODE --->
<cfif len(trim(site.dress_code))>
<div class="divider"></div>
<section class="section" id="dress_code">
  <div class="section-title">
    <span class="eyebrow">Attire</span>
    <h2>Dress Code</h2>
    <div class="taupe-rule"></div>
  </div>
  <p class="text-body"><cfoutput>#HTMLEditFormat(site.dress_code)#</cfoutput></p>
</section>
</cfif>

<!--- TRAVEL --->
<cfif len(trim(site.travel_info)) OR (structKeyExists(site,"travel_links_json") AND len(trim(site.travel_links_json)))>
<div class="divider"></div>
<div class="section-tint" id="travel">
  <div class="inner">
    <div class="section-title">
      <span class="eyebrow">Getting Here</span>
      <h2>Travel &amp; Accommodations</h2>
      <div class="taupe-rule"></div>
    </div>
    <p class="text-body"><cfoutput>#HTMLEditFormat(site.travel_info)#</cfoutput></p>
    <cfif arrayLen(travelLinks)>
    <div style="display:flex;flex-wrap:wrap;gap:12px;margin-top:24px">
    <cfloop array="#travelLinks#" item="tl">
    <cfoutput><a href="#HTMLEditFormat(tl.url)#" target="_blank" rel="noopener" class="link-btn">#len(trim(tl.label)) ? HTMLEditFormat(tl.label) : "View Link"# &rarr;</a></cfoutput>
    </cfloop>
    </div>
    </cfif>
  </div>
</div>
</cfif>

<!--- THINGS TO DO --->
<cfif len(trim(site.things_to_do)) OR arrayLen(thingsLinks)>
<div class="divider"></div>
<section class="section" id="things_to_do">
  <div class="section-title">
    <span class="eyebrow">While You&rsquo;re Here</span>
    <h2>Things to Do</h2>
    <div class="taupe-rule"></div>
  </div>
  <p class="text-body"><cfoutput>#HTMLEditFormat(site.things_to_do)#</cfoutput></p>
  <cfif arrayLen(thingsLinks)>
    <div style="display:flex;flex-wrap:wrap;gap:12px;margin-top:24px">
    <cfloop array="#thingsLinks#" item="tl">
    <cfoutput><a href="#HTMLEditFormat(tl.url)#" target="_blank" rel="noopener" class="link-btn">#len(trim(tl.label)) ? HTMLEditFormat(tl.label) : "Explore"# &rarr;</a></cfoutput>
    </cfloop>
    </div>
    </cfif>
</section>
</cfif>

<!--- RSVP --->
<section class="rsvp-section" id="rsvp">
  <div class="rsvp-bg">
    <cfif len(heroImg)>
    <img src="<cfoutput>#HTMLEditFormat(heroImg)#</cfoutput>" alt="">
    <cfelse>
    <img src="/assets/first-light.jpg" alt="" onerror="this.style.display='none'">
    </cfif>
  </div>
  <div class="rsvp-content">
    <span class="eyebrow">You&rsquo;re Invited</span>
    <h2>Will You Join Us?</h2>
    <p>Please let us know if you&rsquo;ll be celebrating with us on our special day.</p>
    <a href="/rsvp.cfm?slug=<cfoutput>#URLEncodedFormat(site.slug)#</cfoutput>" class="rsvp-btn">RSVP</a>
  </div>
</section>

<footer>
  <div class="names"><cfoutput>#HTMLEditFormat(site.couple_name_1)# &amp; #HTMLEditFormat(site.couple_name_2)#</cfoutput></div>
  <cfif len(weddingDateFull)><div class="date"><cfoutput>#weddingDateFull#</cfoutput></div></cfif>
  <div class="credit">digitalweddings.love <span style="color:#e03">&#9829;</span></div>
</footer>

<!--- LIGHTBOX --->
<div id="lightbox">
  <button class="nav-btn prev" onclick="moveLightbox(-1)">&#8249;</button>
  <img id="lbImg" src="" alt="">
  <button class="nav-btn next" onclick="moveLightbox(1)">&#8250;</button>
  <button class="close-lb" onclick="closeLightbox()">&times;</button>
  <div class="count" id="lbCount"></div>
</div>

<script>
var galleryImages=[<cfloop array="#galleryList#" index="gUrl"><cfoutput>"#JSStringFormat(gUrl)#",</cfoutput></cfloop>];
var lbIdx=0;
function openLightbox(i){lbIdx=i;document.getElementById('lbImg').src=galleryImages[i];document.getElementById('lbCount').textContent=(i+1)+' / '+galleryImages.length;document.getElementById('lightbox').classList.add('show');document.body.style.overflow='hidden';}
function closeLightbox(){document.getElementById('lightbox').classList.remove('show');document.body.style.overflow='';}
function moveLightbox(d){lbIdx=(lbIdx+d+galleryImages.length)%galleryImages.length;openLightbox(lbIdx);}
document.getElementById('lightbox').addEventListener('click',function(e){if(e.target===this)closeLightbox();});
document.addEventListener('keydown',function(e){if(e.key==='Escape')closeLightbox();if(e.key==='ArrowLeft')moveLightbox(-1);if(e.key==='ArrowRight')moveLightbox(1);});
var heroEl=document.querySelector('.hero');
var stickyNav=document.getElementById('stickyNav');
window.addEventListener('scroll',function(){
  stickyNav.style.display=window.scrollY>heroEl.offsetHeight?'block':'none';
  var pos=window.scrollY+80;
  document.querySelectorAll('section[id],div[id]').forEach(function(s){
    if(pos>=s.offsetTop&&pos<s.offsetTop+s.offsetHeight){
      document.querySelectorAll('.sticky-nav a').forEach(function(a){a.classList.remove('active');if(a.getAttribute('href')==='#'+s.id)a.classList.add('active');});
    }
  });
});
</script>

<!-- Back to top button -->
<button onclick="window.scrollTo({top:0,behavior:'smooth'})" id="backToTop" aria-label="Back to top" style="display:none;position:fixed;bottom:28px;right:28px;z-index:9000;width:44px;height:44px;border-radius:50%;border:none;cursor:pointer;background:rgba(0,0,0,0.55);color:#fff;font-size:20px;line-height:44px;text-align:center;box-shadow:0 4px 16px rgba(0,0,0,0.25);transition:opacity .2s,background .2s" onmouseover="this.style.background='rgba(0,0,0,0.75)'" onmouseout="this.style.background='rgba(0,0,0,0.55)'">&#8679;</button>
<script>
(function(){
  var btn=document.getElementById('backToTop');
  window.addEventListener('scroll',function(){
    btn.style.display=window.scrollY>400?'block':'none';
  });
})();
</script>
</body>
</html>
