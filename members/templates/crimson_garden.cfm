<!---
  crimson_garden.cfm - watercolor floral, white & burgundy
  Palette: white #FDFCFB, blush #F5E8E6, burgundy #7B2835, wine #4A1020, sage #7A9B6A, taupe #9C8078
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

<!--- Countdown: days until wedding --->
<cfset cdDaysUntil = 0>
<cfset cdIsFuture = false>
<cfif len(trim(site.wedding_date))>
<cftry>
  <cfset _wdToday = createDate(year(now()),month(now()),day(now()))>
  <cfset cdDaysUntil = dateDiff("d", _wdToday, parseDateTime(site.wedding_date))>
  <cfset cdIsFuture = (cdDaysUntil GT 0)>
<cfcatch><cfset cdDaysUntil = 0></cfcatch>
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
<cfset ceremonyTimeDisplay = "">
<cfif structKeyExists(site,"ceremony_start_time") AND len(trim(site.ceremony_start_time))>
<cftry>
<cfset ceremonyTimeDisplay = timeFormat(site.ceremony_start_time,"h:mm tt")>
<cfif structKeyExists(site,"ceremony_end_time") AND len(trim(site.ceremony_end_time))>
<cfset ceremonyTimeDisplay = ceremonyTimeDisplay & " - " & timeFormat(site.ceremony_end_time,"h:mm tt")>
</cfif>
<cfcatch><cfset ceremonyTimeDisplay = ""></cfcatch>
</cftry>
</cfif>
<cfset receptionTimeDisplay = "">
<cfif structKeyExists(site,"reception_start_time") AND len(trim(site.reception_start_time))>
<cftry>
<cfset receptionTimeDisplay = timeFormat(site.reception_start_time,"h:mm tt")>
<cfif structKeyExists(site,"reception_end_time") AND len(trim(site.reception_end_time))>
<cfset receptionTimeDisplay = receptionTimeDisplay & " - " & timeFormat(site.reception_end_time,"h:mm tt")>
</cfif>
<cfcatch><cfset receptionTimeDisplay = ""></cfcatch>
</cftry>
</cfif>
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
<link href="https://fonts.googleapis.com/css2?family=Cormorant+Garamond:ital,wght@0,300;0,400;0,600;1,300;1,400&family=Great+Vibes&family=Jost:wght@300;400&display=swap" rel="stylesheet">
<style>
:root{--white:#FDFCFB;--blush:#F5E8E6;--blush-dark:#EDD5D0;--burgundy:#7B2835;--wine:#4A1020;--sage:#7A9B6A;--taupe:#9C8078;--muted:rgba(74,16,32,.45)}
*{margin:0;padding:0;box-sizing:border-box}
html{scroll-behavior:smooth}
body{background:var(--white);color:var(--wine);font-family:'Jost',sans-serif;font-weight:300;line-height:1.7;overflow-x:hidden}

/* ---- HERO ---- */
.hero{background:var(--white);position:relative;text-align:center;display:flex;flex-direction:column;justify-content:flex-start}

/* Top watercolor image - full width below nav */
.hero-top-floral{display:block;width:100%;height:420px;object-fit:contain;object-position:right top;background:var(--white)}

/* NAV */
nav{background:var(--white);border-bottom:1px solid var(--blush-dark);backdrop-filter:blur(6px)}
nav .inner{max-width:960px;margin:0 auto;display:flex;align-items:center;justify-content:center;flex-wrap:wrap;overflow-x:auto}
nav a{color:var(--taupe);text-decoration:none;font-size:.72rem;letter-spacing:.2em;text-transform:uppercase;padding:16px 16px;border-bottom:2px solid transparent;transition:color .2s,border-color .2s;white-space:nowrap;font-family:'Jost',sans-serif}
nav a:hover,nav a.active{color:var(--burgundy);border-bottom-color:var(--burgundy)}

/* Hero text block */
.hero-text{padding:0 24px 28px;position:relative;margin-top:-320px}
.hero-monoline{font-size:.62rem;letter-spacing:.38em;text-transform:uppercase;color:var(--taupe);margin-bottom:20px;font-family:'Jost',sans-serif}
.hero-couple{font-family:'Great Vibes',cursive;font-size:clamp(3rem,8vw,6rem);color:var(--wine);line-height:1.1;margin-bottom:24px}
.hero-rule{display:flex;align-items:center;justify-content:center;gap:16px;margin-bottom:20px}
.hero-rule .line{height:1px;width:60px;background:var(--blush-dark)}
.hero-rule .diamond{color:var(--burgundy);font-size:.7rem}
.hero-date{font-size:.68rem;letter-spacing:.28em;text-transform:uppercase;color:var(--taupe);margin-bottom:6px}
.hero-venue{font-size:.68rem;letter-spacing:.18em;text-transform:uppercase;color:rgba(156,128,120,.7)}

/* Corner floral bottom-left in hero-text area */
.hero-corner-floral{position:absolute;bottom:0;left:0;width:min(380px,55vw);pointer-events:none;display:block}

/* ---- SECTIONS ---- */
.section{padding:80px 48px;max-width:860px;margin:0 auto}
.section-blush{background:var(--blush);padding:80px 48px}
.section-blush .inner{max-width:860px;margin:0 auto}
.divider{width:100%;height:1px;background:var(--blush-dark)}

.section-title{text-align:center;margin-bottom:52px}
.section-title .eyebrow{font-size:.72rem;letter-spacing:.32em;text-transform:uppercase;color:var(--taupe);display:block;margin-bottom:12px;font-family:'Jost',sans-serif}
.section-title h2{font-family:'Cormorant Garamond',Georgia,serif;font-size:clamp(2.2rem,4vw,3.2rem);font-weight:300;color:var(--wine);letter-spacing:.04em;font-style:italic}
.burg-rule{display:flex;align-items:center;justify-content:center;gap:14px;margin-top:16px}
.burg-rule .line{height:1px;width:48px;background:var(--burgundy);opacity:.3}
.burg-rule .dot{width:4px;height:4px;border-radius:50%;background:var(--burgundy);opacity:.4}

/* ---- DETAILS ---- */
.details-grid{display:flex;flex-wrap:wrap;gap:1px;background:var(--blush-dark);max-width:860px;margin:0 auto}
.detail-block{flex:1;min-width:160px;padding:44px 36px;background:var(--white);text-align:center}
.detail-block .lbl{font-size:.62rem;letter-spacing:.32em;text-transform:uppercase;color:var(--burgundy);margin-bottom:14px;display:block;font-family:'Jost',sans-serif;opacity:.8}
.detail-block .val{font-family:'Cormorant Garamond',Georgia,serif;font-size:1.7rem;font-weight:300;color:var(--wine);line-height:1.25;font-style:italic}
.detail-block .sub{font-size:.78rem;color:var(--muted);margin-top:8px}

/* ---- STORY ---- */
.story-body{font-family:'Cormorant Garamond',Georgia,serif;font-size:1.25rem;font-weight:300;line-height:2.1;color:var(--wine);white-space:pre-wrap;font-style:italic;max-width:620px;margin:0 auto;text-align:center}

/* ---- GALLERY ---- */
.gallery-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(230px,1fr));gap:4px;max-width:860px;margin:0 auto}
.g-photo{aspect-ratio:1;overflow:hidden;cursor:pointer;border-radius:10px}
.g-photo img{width:100%;height:100%;object-fit:cover;transition:transform .5s,filter .3s;filter:saturate(.9)}
.g-photo:hover img{transform:scale(1.05);filter:saturate(1.1)}

/* ---- FAQ ---- */
.faq-list{display:flex;flex-direction:column;max-width:660px;margin:0 auto}
.faq-item{padding:28px 0;border-bottom:1px solid var(--blush-dark)}
.faq-item .q{font-family:'Cormorant Garamond',Georgia,serif;font-size:1.15rem;font-weight:600;color:var(--wine);margin-bottom:8px;font-style:italic}
.faq-item .a{font-size:.88rem;color:var(--muted);line-height:1.9}

/* ---- TEXT ---- */
.text-body{font-size:.92rem;color:var(--wine);line-height:2;white-space:pre-wrap;max-width:620px;margin:0 auto;text-align:center;opacity:.8}
.link-btn{display:inline-block;margin-top:28px;padding:13px 36px;border:1px solid var(--burgundy);color:var(--burgundy);text-decoration:none;font-size:.62rem;letter-spacing:.26em;text-transform:uppercase;font-family:'Jost',sans-serif;transition:background .2s,color .2s}
.link-btn:hover{background:var(--burgundy);color:var(--white)}

/* ---- RSVP ---- */
.rsvp-section{text-align:center;padding:100px 24px;background:var(--blush);position:relative;overflow:hidden}
.rsvp-floral-left{position:absolute;bottom:0;left:0;width:min(300px,40vw);opacity:.6;pointer-events:none}
.rsvp-floral-right{position:absolute;top:0;right:0;width:min(300px,40vw);opacity:.6;pointer-events:none;transform:rotate(180deg)}
.rsvp-content{position:relative;z-index:2}
.rsvp-content .eyebrow{font-size:.8rem;letter-spacing:.3em;text-transform:uppercase;color:var(--taupe);display:block;margin-bottom:16px}
.rsvp-content h2{font-family:'Cormorant Garamond',Georgia,serif;font-size:clamp(2.6rem,5vw,4.4rem);font-weight:300;color:var(--wine);margin-bottom:16px;letter-spacing:.03em;font-style:italic}
.rsvp-content p{color:var(--muted);margin-bottom:44px;max-width:400px;margin-left:auto;margin-right:auto;font-size:1rem;line-height:2}
.rsvp-btn{display:inline-block;padding:15px 56px;background:var(--burgundy);color:var(--white);font-size:.65rem;letter-spacing:.28em;text-transform:uppercase;text-decoration:none;font-family:'Jost',sans-serif;transition:background .25s}
.rsvp-btn:hover{background:var(--wine)}

/* ---- FOOTER ---- */
footer{background:var(--white);position:relative;text-align:center;overflow:hidden}
.footer-floral{width:100%;display:block;max-height:280px;object-fit:cover;object-position:center top;transform:rotate(180deg)}
.footer-text{padding:40px 24px 56px;position:relative;z-index:2}
footer .names{font-family:'Great Vibes',cursive;font-size:2.6rem;color:var(--wine);margin-bottom:10px}
footer .date{font-size:.6rem;letter-spacing:.3em;text-transform:uppercase;color:var(--taupe)}
footer .credit{font-size:1.1rem;font-weight:500;font-weight:500;color:rgba(74,16,32,.18);margin-top:20px}

/* ---- LIGHTBOX ---- */
#lightbox{position:fixed;inset:0;background:rgba(74,16,32,.95);z-index:999;display:none;align-items:center;justify-content:center;padding:20px}
#lightbox.show{display:flex}
#lightbox img{max-height:85vh;max-width:90vw;object-fit:contain}
#lightbox button{position:absolute;background:rgba(255,255,255,.12);border:none;color:#fff;cursor:pointer}
#lightbox .nav-btn{width:52px;height:52px;font-size:1.8rem;top:50%;transform:translateY(-50%)}
#lightbox .prev{left:20px}
#lightbox .next{right:20px}
#lightbox .close-lb{top:16px;right:16px;width:40px;height:40px;font-size:1.1rem}
#lightbox .count{position:absolute;bottom:20px;color:rgba(255,255,255,.35);font-size:.75rem;letter-spacing:.1em}

@media(max-width:600px){
  .hero-corner-floral{width:min(220px,70vw)}
  .section{padding:60px 24px}
  .section-blush{padding:60px 24px}
  .detail-block{padding:32px 20px}
}
</style>
</head>
<body>

<cfif structKeyExists(site,"is_preview") AND site.is_preview>
<div style="position:fixed;top:0;left:0;right:0;z-index:9999;background:#4A1020;color:#fff;display:flex;align-items:center;justify-content:space-between;padding:12px 24px;font-family:Arial,sans-serif;font-size:13px;gap:12px">
  <cfif isNumeric(url.siteId) AND url.siteId GT 0>
  <span style="opacity:.8">&#128065; Previewing your wedding site</span>
  <button onclick="window.close()" style="padding:8px 20px;background:rgba(255,255,255,.15);color:#fff;border:none;border-radius:4px;font-weight:600;cursor:pointer;font-size:13px">&times; Close Preview</button>
  <cfelse>
  <span style="opacity:.8">&#128065; Template preview &mdash; sample data shown</span>
  <a href="/members/wedding-site-edit.cfm?template=crimson_garden" style="padding:8px 20px;background:#7B2835;color:#fff;border-radius:4px;font-weight:600;text-decoration:none;white-space:nowrap">Use This Template &rarr;</a>
  </cfif>
</div>
<div style="height:48px"></div>
</cfif>

<nav>
  <div class="inner">
    <cfif len(trim(site.story))><a href="#our_story">Our Story</a></cfif>
    <a href="#details">Details</a>
    <cfif structKeyExists(site,"registry_url") AND len(trim(site.registry_url))><a href="<cfoutput>#HTMLEditFormat(trim(site.registry_url))#</cfoutput>" target="_blank" rel="noopener">Registry</a></cfif><a href="#rsvp">RSVP</a>
    <cfif arrayLen(galleryList)><a href="#photos">Photos</a></cfif>
    <cfif arrayLen(faqList)><a href="#q_and_a">Q &amp; A</a></cfif>
    <cfif len(trim(site.dress_code))><a href="#dress_code">Dress Code</a></cfif>
    <cfif len(trim(site.travel_info)) OR arrayLen(travelLinks)><a href="#travel">Travel</a></cfif>
    <cfif len(trim(site.things_to_do)) OR arrayLen(thingsLinks)><a href="#things_to_do">Things to Do</a></cfif>
  </div>
</nav>

<cfoutput>
<cfif cdIsFuture>
<div style="text-align:center;padding:18px 24px;border-bottom:1px solid rgba(0,0,0,0.1);font-family:'Jost',sans-serif">
  <span style="font-size:.6rem;letter-spacing:.4em;text-transform:uppercase;color:##7A9B6A">Countdown</span>
  <div style="margin:6px 0;display:flex;align-items:baseline;justify-content:center;gap:8px">
    <span style="font-size:2.4rem;font-weight:700;color:##7A9B6A;line-height:1">#cdDaysUntil#</span>
    <span style="font-size:.7rem;letter-spacing:.25em;text-transform:uppercase;color:rgba(30,20,10,0.75);opacity:.7">#cdDaysUntil EQ 1 ? 'day' : 'days'# to go</span>
  </div>
  <cfif len(weddingDateFull)><span style="font-size:.68rem;letter-spacing:.15em;text-transform:uppercase;color:rgba(30,20,10,0.75);opacity:.5">#weddingDateFull#</span></cfif>
</div>
</cfif>
<cfif cdDaysUntil EQ 0 AND len(trim(site.wedding_date))>
<div style="text-align:center;padding:16px 24px;border-bottom:1px solid rgba(0,0,0,0.1);font-family:'Jost',sans-serif">
  <span style="font-size:.68rem;letter-spacing:.35em;text-transform:uppercase;color:##7A9B6A">Today Is The Day</span>
</div>
</cfif>
</cfoutput>


<!--- TOP FLORAL: full width --->
<div style="line-height:0;overflow:hidden">
  <img src="/assets/watercolor-top.jpg" alt="" class="hero-top-floral" onerror="this.style.display='none'">
</div>

<!--- HERO --->
<div class="hero">
  <div class="hero-text">
    <cfset couplePhoto = structKeyExists(site,"couple_photo_url") ? trim(site.couple_photo_url) : "">
    <cfset couplePhotoSrc = len(couplePhoto) ? couplePhoto : "/assets/couple-placeholder.jpg">
    <img src="<cfoutput>#HTMLEditFormat(couplePhotoSrc)#</cfoutput>" alt="Couple photo" style="width:110px;height:110px;border-radius:50%;object-fit:cover;border:3px solid var(--burgundy);box-shadow:0 4px 20px rgba(74,16,32,.2);display:block;margin:0 auto 20px">
    <p class="hero-monoline">We&rsquo;re Getting Married</p>
    <div class="hero-couple">
      <cfoutput>#HTMLEditFormat(site.couple_name_1)#</cfoutput><br>
      &amp;<br>
      <cfoutput>#HTMLEditFormat(site.couple_name_2)#</cfoutput>
    </div>
    <div class="hero-rule">
      <div class="line"></div>
      <span class="diamond">&#10022;</span>
      <div class="line"></div>
    </div>
    <cfif len(weddingDateFull)>
    <p class="hero-date"><cfoutput>#weddingDateFull#</cfoutput></p>
    </cfif>
    <cfif len(trim(site.venue_name))>
    <p class="hero-venue"><cfoutput>#HTMLEditFormat(site.venue_name)#</cfoutput></p>
    </cfif>
  </div>
</div>

<!--- OUR STORY --->
<cfif len(trim(site.story))>
<div class="divider"></div>
<section class="section" id="our_story">
  <div class="section-title">
    <span class="eyebrow">The Beginning</span>
    <h2>Our Story</h2>
    <div class="burg-rule"><div class="line"></div><div class="dot"></div><div class="line"></div></div>
  </div>
  <p class="story-body"><cfoutput>#HTMLEditFormat(site.story)#</cfoutput></p>
</section>
</cfif>

<!--- DETAILS --->
<div class="divider"></div>
<section id="details" style="padding:80px 0">
  <div style="max-width:860px;margin:0 auto;padding:0 48px 52px;text-align:center">
    <div class="section-title">
      <span class="eyebrow">Celebration Details</span>
      <h2>Join Us</h2>
      <div class="burg-rule"><div class="line"></div><div class="dot"></div><div class="line"></div></div>
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
      <cfif len(ceremonyTimeDisplay)><div class="sub"><cfoutput>#HTMLEditFormat(ceremonyTimeDisplay)#</cfoutput></div></cfif>
    </div>
    </cfif>
    <cfif len(receptionVenueName)>
    <div class="detail-block">
      <span class="lbl">Reception</span>
      <div class="val"><cfoutput>#HTMLEditFormat(receptionVenueName)#</cfoutput></div>
      <cfif len(receptionVenueAddress)><div class="sub"><cfoutput>#HTMLEditFormat(receptionVenueAddress)#</cfoutput></div></cfif>
      <cfif len(receptionTimeDisplay)><div class="sub"><cfoutput>#HTMLEditFormat(receptionTimeDisplay)#</cfoutput></div></cfif>
    </div>
    </cfif>
  </div>
</section>

<!--- GALLERY --->
<cfif arrayLen(galleryList)>
<div class="divider"></div>
<section class="section" id="photos" style="max-width:1000px">
  <div class="section-title">
    <span class="eyebrow">Captured Moments</span>
    <h2>Photos</h2>
    <div class="burg-rule"><div class="line"></div><div class="dot"></div><div class="line"></div></div>
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
<div class="section-blush" id="q_and_a">
  <div class="inner">
    <div class="section-title">
      <span class="eyebrow">Good to Know</span>
      <h2>Q &amp; A</h2>
      <div class="burg-rule"><div class="line"></div><div class="dot"></div><div class="line"></div></div>
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
<section class="section" id="dress_code" style="text-align:center">
  <div class="section-title">
    <span class="eyebrow">Attire</span>
    <h2>Dress Code</h2>
    <div class="burg-rule"><div class="line"></div><div class="dot"></div><div class="line"></div></div>
  </div>
  <p class="text-body"><cfoutput>#HTMLEditFormat(site.dress_code)#</cfoutput></p>
</section>
</cfif>

<!--- TRAVEL --->
<cfif len(trim(site.travel_info)) OR (structKeyExists(site,"travel_links_json") AND len(trim(site.travel_links_json)))>
<div class="divider"></div>
<div class="section-blush" id="travel">
  <div class="inner" style="text-align:center">
    <div class="section-title">
      <span class="eyebrow">Getting Here</span>
      <h2>Travel &amp; Accommodations</h2>
      <div class="burg-rule"><div class="line"></div><div class="dot"></div><div class="line"></div></div>
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
<section class="section" id="things_to_do" style="text-align:center">
  <div class="section-title">
    <span class="eyebrow">While You&rsquo;re Here</span>
    <h2>Things to Do</h2>
    <div class="burg-rule"><div class="line"></div><div class="dot"></div><div class="line"></div></div>
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
  <img src="/assets/watercolor-corner.jpg" alt="" class="rsvp-floral-left" onerror="this.style.display='none'">
  <img src="/assets/watercolor-corner.jpg" alt="" class="rsvp-floral-right" onerror="this.style.display='none'">
  <div class="rsvp-content">
    <span class="eyebrow">You&rsquo;re Invited</span>
    <h2>Will You Join Us?</h2>
    <p>Please let us know if you&rsquo;ll be celebrating with us on our special day.</p>
    <a href="/rsvp.cfm?slug=<cfoutput>#URLEncodedFormat(site.slug)#</cfoutput>" class="rsvp-btn">RSVP</a>
  </div>
</section>

<!--- FOOTER --->
<footer>
  <div class="footer-text">
    <div class="names"><cfoutput>#HTMLEditFormat(site.couple_name_1)# &amp; #HTMLEditFormat(site.couple_name_2)#</cfoutput></div>
    <cfif len(weddingDateFull)><div class="date"><cfoutput>#weddingDateFull#</cfoutput></div></cfif>
    <div class="credit">digitalweddings.love <span style="color:#e03">&#9829;</span></div>
  </div>
</footer>
<!--- CORNER FLORAL: flush left at very bottom --->
<div style="line-height:0;overflow:hidden;text-align:left">
  <img src="/assets/watercolor-corner.jpg" alt="" style="height:clamp(260px,48vh,480px);width:auto;display:inline-block" onerror="this.style.display='none'">
</div>

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
var navLinks=document.querySelectorAll('nav a');
window.addEventListener('scroll',function(){
  var pos=window.scrollY+100;
  document.querySelectorAll('section[id],div[id]').forEach(function(s){
    if(pos>=s.offsetTop&&pos<s.offsetTop+s.offsetHeight){
      navLinks.forEach(function(a){a.classList.remove('active');if(a.getAttribute('href')==='#'+s.id)a.classList.add('active');});
    }
  });
});
</script>

<!-- Back to top button -->
<button onclick="window.scrollTo({top:0,behavior:'smooth'})" id="backToTop" aria-label="Back to top" style="display:none;position:fixed;bottom:28px;right:28px;z-index:9000;width:44px;height:44px;border-radius:50%;border:none;cursor:pointer;background:rgba(0,0,0,0.55);color:#fff;font-size:20px;line-height:44px;text-align:center;box-shadow:0 4px 16px rgba(0,0,0,0.25);transition:opacity .2s,background .2s" onmouseover="this.style.background='rgba(0,0,0,0.75)'" onmouseout="this.style.background='rgba(0,0,0,0.55)'">&uarr;</button>
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
