<!---
  romantic_rose.cfm - requires "site" struct set before cfinclude
  Color palette: dusty rose #C4686A, blush #F2D6D6, ivory #FDF8F6, deep mauve #6B2D35
--->
<cfset monogram = UCase(left(site.couple_name_1,1)) & UCase(left(site.couple_name_2,1))>

<cfset weddingDateFull = "">
<cfset weddingDayMonth = "">
<cfset weddingYear = "">
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

<!--- Safe access for optional fields --->
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
<title><cfoutput>#HTMLEditFormat(site.couple_name_1)# &amp; #HTMLEditFormat(site.couple_name_2)#</cfoutput> &mdash; Romantic Rose</title>
<link href="https://fonts.googleapis.com/css2?family=Cormorant+Garamond:ital,wght@0,300;0,400;0,600;1,300;1,400&family=Great+Vibes&family=Montserrat:wght@300;400;500&display=swap" rel="stylesheet">
<style>
:root{--rose:#C4686A;--rose-dark:#6B2D35;--blush:#F2D6D6;--blush-light:#FAF0F0;--ivory:#FDF8F6;--mauve-text:#3D1F20;--muted:#9B7B7C}
*{margin:0;padding:0;box-sizing:border-box}
body{background:var(--blush-light);color:var(--mauve-text);font-family:'Montserrat',sans-serif;line-height:1.7;overflow-x:hidden}

/* ---- HERO ---- */
.hero{min-height:88vh;position:relative;overflow:hidden;display:flex;flex-direction:column}
.hero-bg{position:absolute;inset:0;background:var(--blush)}
.hero-bg img{width:100%;height:100%;object-fit:cover;object-position:center top;display:block}
.hero-center{position:absolute;top:0;bottom:0;left:50%;transform:translateX(-50%);z-index:2;width:400px;max-width:88vw;background:#fff;display:flex;flex-direction:column;align-items:center;justify-content:center;padding:48px 40px;text-align:center;box-shadow:0 8px 60px rgba(0,0,0,.25);overflow-y:auto}
.hero-center::before{content:'';position:absolute;top:0;left:0;right:0;height:4px;background:var(--rose)}
.monogram-lg{font-family:'Cormorant Garamond',Georgia,serif;font-size:4.5rem;font-weight:300;color:var(--rose);letter-spacing:.1em;line-height:1;margin-bottom:6px}
.tagline{font-family:'Great Vibes',cursive;font-size:1.4rem;color:var(--rose);margin-bottom:44px}
.welcome{font-family:'Cormorant Garamond',Georgia,serif;font-size:3rem;font-weight:300;color:var(--rose);letter-spacing:.25em;text-transform:uppercase;margin-bottom:32px}
.hero-rule{width:60px;height:1px;background:var(--rose);opacity:.4;margin:0 auto 28px}
.couple-names{font-family:'Great Vibes',cursive;font-size:3.2rem;color:var(--rose);line-height:1.5;margin-bottom:24px}
.hero-date{font-size:.75rem;letter-spacing:.28em;text-transform:uppercase;color:var(--rose);opacity:.8;margin-bottom:10px;font-family:'Montserrat',sans-serif}
.hero-venue{font-size:.8rem;letter-spacing:.18em;text-transform:uppercase;color:var(--rose);opacity:.7;font-family:'Montserrat',sans-serif}
.scroll-hint{margin-top:36px;color:var(--rose);opacity:.5;font-size:.58rem;letter-spacing:.3em;text-transform:uppercase;font-family:'Montserrat',sans-serif}
@media(max-width:800px){
  .hero-center{padding:40px 24px}
  .monogram-lg{font-size:3rem}
  .welcome{font-size:2rem}
}

/* ---- NAV ---- */
nav{background:rgba(250,240,240,.97);border-bottom:2px solid var(--blush);backdrop-filter:blur(8px)}
nav .inner{max-width:960px;margin:0 auto;display:flex;align-items:center;justify-content:center;overflow-x:auto}
nav a{padding:18px 16px;font-size:.62rem;letter-spacing:.16em;color:var(--rose-dark);text-decoration:none;white-space:nowrap;cursor:pointer;border-bottom:2px solid transparent;transition:color .2s,border-color .2s;text-transform:uppercase;font-family:'Montserrat',sans-serif}
nav a:hover{color:var(--rose)}
nav a.active{color:var(--rose);border-bottom-color:var(--rose);font-weight:600}

/* ---- SECTIONS ---- */
.section{padding:80px 24px 60px;max-width:860px;margin:0 auto}
.section-alt{background:var(--blush);padding:80px 24px 60px}
.section-alt .inner{max-width:860px;margin:0 auto}
.section-title{text-align:center;margin-bottom:48px}
.section-title .script{font-family:'Great Vibes',cursive;font-size:1.8rem;color:var(--rose);display:block;margin-bottom:4px}
.section-title h2{font-family:'Cormorant Garamond',Georgia,serif;font-size:2.4rem;font-weight:300;color:var(--rose-dark);letter-spacing:.06em}
.rose-rule{display:flex;align-items:center;justify-content:center;gap:14px;margin-top:16px;color:var(--rose);font-size:1rem;letter-spacing:.3em}
.rose-rule .line{height:1px;width:60px;background:var(--rose);opacity:.4}
.rose-divider{text-align:center;padding:20px 0 40px;color:var(--rose);font-size:1.1rem;letter-spacing:.5em;opacity:.5}

/* ---- DETAIL CARDS ---- */
.detail{display:flex;justify-content:center;flex-wrap:wrap;gap:24px}
.detail-card{background:var(--ivory);border:1px solid var(--rose);border-top:3px solid var(--rose);border-radius:12px;padding:28px 32px;text-align:center;min-width:180px;box-shadow:0 6px 28px rgba(196,104,106,.12)}
.detail-card .lbl{font-size:.58rem;letter-spacing:.32em;text-transform:uppercase;color:var(--rose);margin-bottom:10px;display:block;font-family:'Montserrat',sans-serif;font-weight:600}
.detail-card .val{font-family:'Cormorant Garamond',Georgia,serif;font-size:1.5rem;font-weight:400;color:var(--rose-dark);line-height:1.3}
.detail-card .sub{font-size:.78rem;color:var(--muted);margin-top:6px}

/* ---- STORY ---- */
.story-text{font-family:'Cormorant Garamond',Georgia,serif;font-size:1.25rem;font-weight:300;line-height:2;color:var(--rose-dark);white-space:pre-wrap;max-width:620px;margin:0 auto;text-align:center;font-style:italic}

/* ---- GALLERY ---- */
.photos{display:grid;grid-template-columns:repeat(auto-fill,minmax(200px,1fr));gap:6px;border-radius:12px;overflow:hidden;border:2px solid var(--blush)}
.photo{cursor:pointer;aspect-ratio:1;overflow:hidden}
.photo img{width:100%;height:100%;object-fit:cover;transition:transform .4s,filter .3s}
.photo:hover img{transform:scale(1.06);filter:saturate(1.15) brightness(1.04)}

/* ---- FAQ ---- */
.faq-list{max-width:660px;margin:0 auto;display:flex;flex-direction:column;gap:14px}
.faq-item{background:var(--ivory);border-radius:10px;padding:24px 28px;border-left:4px solid var(--rose);box-shadow:0 3px 16px rgba(196,104,106,.1)}
.faq-item .q{font-family:'Cormorant Garamond',Georgia,serif;font-size:1.15rem;font-weight:600;color:var(--rose-dark);margin-bottom:8px;font-style:italic}
.faq-item .a{font-size:.88rem;color:var(--muted);line-height:1.85}

/* ---- TEXT SECTIONS ---- */
.text-content{font-size:.93rem;color:var(--rose-dark);line-height:2;white-space:pre-wrap;max-width:620px;margin:0 auto;text-align:center}
.link-btn{display:inline-block;margin-top:28px;padding:13px 36px;background:var(--rose);color:#fff;border-radius:50px;text-decoration:none;font-size:.65rem;letter-spacing:.22em;text-transform:uppercase;font-weight:600;font-family:'Montserrat',sans-serif;box-shadow:0 4px 20px rgba(196,104,106,.3);transition:background .2s,transform .2s}
.link-btn:hover{background:var(--rose-dark);transform:translateY(-2px)}

/* ---- RSVP ---- */
.rsvp{text-align:center;padding:100px 24px;background:var(--rose);position:relative;overflow:hidden}
.rsvp::before{content:'';position:absolute;top:-80px;left:50%;transform:translateX(-50%);width:400px;height:400px;border-radius:50%;background:rgba(255,255,255,.07)}
.rsvp::after{content:'';position:absolute;bottom:-60px;right:-60px;width:280px;height:280px;border-radius:50%;background:rgba(255,255,255,.05)}
.rsvp .script{font-family:'Great Vibes',cursive;font-size:2.2rem;color:rgba(255,255,255,.72);display:block;margin-bottom:8px}
.rsvp h2{font-family:'Cormorant Garamond',Georgia,serif;font-size:clamp(2rem,5vw,3.2rem);font-weight:300;color:#fff;margin-bottom:16px;letter-spacing:.04em}
.rsvp p{color:rgba(255,255,255,.75);margin-bottom:40px;max-width:440px;margin-left:auto;margin-right:auto;line-height:1.9;font-size:.9rem}
.rsvp .btn{display:inline-block;padding:16px 56px;background:#fff;color:var(--rose);font-size:.7rem;letter-spacing:.25em;text-transform:uppercase;border-radius:50px;font-weight:700;text-decoration:none;font-family:'Montserrat',sans-serif;box-shadow:0 6px 24px rgba(0,0,0,.15);transition:transform .2s}
.rsvp .btn:hover{transform:translateY(-2px)}

/* ---- FOOTER ---- */
footer{text-align:center;padding:70px 24px;background:var(--rose-dark);color:#fff}
footer .mono{font-family:'Cormorant Garamond',Georgia,serif;font-size:3rem;font-weight:300;letter-spacing:.12em;color:rgba(255,255,255,.85);margin-bottom:6px}
footer .names{font-family:'Great Vibes',cursive;font-size:1.9rem;color:var(--blush);margin-bottom:8px}
footer .date{font-size:.6rem;opacity:.4;letter-spacing:.28em;text-transform:uppercase;font-family:'Montserrat',sans-serif}
footer .credit{font-size:1.1rem;font-weight:500;font-weight:500;opacity:.2;margin-top:24px}

/* ---- LIGHTBOX ---- */
#lightbox{position:fixed;inset:0;background:rgba(61,31,32,.95);z-index:999;display:none;align-items:center;justify-content:center;padding:20px}
#lightbox.show{display:flex}
#lightbox img{max-height:85vh;max-width:90vw;border-radius:8px;object-fit:contain}
#lightbox button{position:absolute;background:rgba(255,255,255,.15);border:none;color:#fff;border-radius:50%;cursor:pointer}
#lightbox .nav-btn{width:48px;height:48px;font-size:2rem;top:50%;transform:translateY(-50%)}
#lightbox .prev{left:20px}
#lightbox .next{right:20px}
#lightbox .close-lb{top:16px;right:16px;width:40px;height:40px;font-size:1.2rem}
#lightbox .count{position:absolute;bottom:20px;color:rgba(255,255,255,.4);font-size:.8rem}
</style>
</head>
<body>

<cfif structKeyExists(site,"is_preview") AND site.is_preview>
<div style="position:fixed;top:0;left:0;right:0;z-index:9999;background:#1a1a1a;color:#fff;display:flex;align-items:center;justify-content:space-between;padding:12px 24px;font-family:Arial,sans-serif;font-size:13px;gap:12px">
  <cfif isNumeric(url.siteId) AND url.siteId GT 0>
  <span style="opacity:.85">&#128065; Previewing your wedding site &mdash; this is how guests will see it</span>
  <button onclick="window.close()" style="padding:8px 20px;background:#444;color:#fff;border:none;border-radius:6px;font-weight:600;cursor:pointer;font-size:13px;white-space:nowrap">&times; Close Preview</button>
  <cfelse>
  <span style="opacity:.85">&#128065; Template preview &mdash; sample data shown</span>
  <a href="/members/wedding-site-edit.cfm?template=romantic_rose" style="padding:8px 20px;background:#C4686A;color:#fff;border-radius:6px;font-weight:600;text-decoration:none;white-space:nowrap">Use This Template &rarr;</a>
  </cfif>
</div>
<div style="height:48px"></div>
</cfif>

<nav>
  <div class="inner">
    <a href="#details">Details</a>
    <cfif len(trim(site.story))><a href="#our_story">Our Story</a></cfif>
    <cfif arrayLen(galleryList)><a href="#photos">Photos</a></cfif>
    <cfif arrayLen(faqList)><a href="#q_and_a">Q &amp; A</a></cfif>
    <cfif len(trim(site.dress_code))><a href="#dress_code">Dress Code</a></cfif>
    <cfif len(trim(site.travel_info)) OR (structKeyExists(site,"travel_links_json") AND len(trim(site.travel_links_json)))><a href="#travel">Travel</a></cfif>
    <cfif len(trim(site.things_to_do)) OR arrayLen(thingsLinks)><a href="#things_to_do">Things to Do</a></cfif>
    <cfif structKeyExists(site,"registry_url") AND len(trim(site.registry_url))><a href="<cfoutput>#HTMLEditFormat(trim(site.registry_url))#</cfoutput>" target="_blank" rel="noopener">Registry</a></cfif><a href="#rsvp">RSVP</a>
  </div>
</nav>

<cfoutput>
<cfif cdIsFuture>
<div style="text-align:center;padding:18px 24px;border-bottom:1px solid rgba(0,0,0,0.1);font-family:'Montserrat',sans-serif">
  <span style="font-size:.6rem;letter-spacing:.4em;text-transform:uppercase;color:##C4686A">Countdown</span>
  <div style="margin:6px 0;display:flex;align-items:baseline;justify-content:center;gap:8px">
    <span style="font-size:2.4rem;font-weight:700;color:##C4686A;line-height:1">#cdDaysUntil#</span>
    <span style="font-size:.7rem;letter-spacing:.25em;text-transform:uppercase;color:rgba(30,20,10,0.75);opacity:.7">#cdDaysUntil EQ 1 ? 'day' : 'days'# to go</span>
  </div>
  <cfif len(weddingDateFull)><span style="font-size:.68rem;letter-spacing:.15em;text-transform:uppercase;color:rgba(30,20,10,0.75);opacity:.5">#weddingDateFull#</span></cfif>
</div>
</cfif>
<cfif cdDaysUntil EQ 0 AND len(trim(site.wedding_date))>
<div style="text-align:center;padding:16px 24px;border-bottom:1px solid rgba(0,0,0,0.1);font-family:'Montserrat',sans-serif">
  <span style="font-size:.68rem;letter-spacing:.35em;text-transform:uppercase;color:##C4686A">Today Is The Day</span>
</div>
</cfif>
</cfoutput>


<!--- HERO --->
<div class="hero">
  <div class="hero-bg">
    <cfif len(heroImg)>
    <img src="<cfoutput>#HTMLEditFormat(heroImg)#</cfoutput>" alt="Wedding">
    <cfelse>
    <img src="/assets/roses-hero.jpeg" alt="Pink roses" onerror="this.style.display='none'">
    </cfif>
  </div>
  <div class="hero-center">
    <cfset couplePhoto = structKeyExists(site,"couple_photo_url") ? trim(site.couple_photo_url) : "">
    <cfset couplePhotoSrc = len(couplePhoto) ? couplePhoto : "/assets/couple-placeholder.jpg">
    <img src="<cfoutput>#HTMLEditFormat(couplePhotoSrc)#</cfoutput>" alt="Couple photo" style="width:120px;height:120px;border-radius:50%;object-fit:cover;border:4px solid var(--rose);box-shadow:0 4px 20px rgba(196,104,106,.3);display:block;margin-bottom:20px">
    <div class="tagline">We&rsquo;re Getting Married</div>
    <div class="welcome">Welcome</div>
    <div class="hero-rule"></div>
    <div class="couple-names">
      <cfoutput>#HTMLEditFormat(site.couple_name_1)#</cfoutput><br>
      &amp;<br>
      <cfoutput>#HTMLEditFormat(site.couple_name_2)#</cfoutput>
    </div>
    <cfif len(weddingDateFull)>
    <div class="hero-date"><cfoutput>#weddingDateFull#</cfoutput></div>
    </cfif>
  </div>
</div>

<!--- DETAILS --->
<section class="section" id="details" style="text-align:center">
  <div class="section-title">
    <span class="script">Celebration Details</span>
    <h2>Join Us</h2>
    <div class="rose-rule"><div class="line"></div>&#10022;<div class="line"></div></div>
  </div>
  <div class="detail">
    <cfif len(weddingDayMonth)>
    <div class="detail-card">
      <span class="lbl">Wedding Day</span>
      <div class="val"><cfoutput>#weddingDayMonth#</cfoutput></div>
      <div class="sub"><cfoutput>#weddingYear#</cfoutput></div>
    </div>
    </cfif>
    <cfif len(trim(site.venue_name))>
    <div class="detail-card">
      <span class="lbl">Ceremony</span>
      <div class="val"><cfoutput>#HTMLEditFormat(site.venue_name)#</cfoutput></div>
      <cfif len(trim(site.venue_address))><div class="sub"><cfoutput>#HTMLEditFormat(site.venue_address)#</cfoutput></div></cfif>
    </div>
    </cfif>
    <cfif len(receptionVenueName)>
    <div class="detail-card">
      <span class="lbl">Reception</span>
      <div class="val"><cfoutput>#HTMLEditFormat(receptionVenueName)#</cfoutput></div>
      <cfif len(receptionVenueAddress)><div class="sub"><cfoutput>#HTMLEditFormat(receptionVenueAddress)#</cfoutput></div></cfif>
    </div>
    </cfif>
  </div>
</section>
<div class="rose-divider">&#10022; &#10022; &#10022;</div>

<!--- OUR STORY --->
<cfif len(trim(site.story))>
<div class="section-alt" id="our_story">
  <div class="inner" style="text-align:center">
    <div class="section-title">
      <span class="script">How It All Began</span>
      <h2>Our Story</h2>
      <div class="rose-rule"><div class="line"></div>&#10022;<div class="line"></div></div>
    </div>
    <p class="story-text"><cfoutput>#HTMLEditFormat(site.story)#</cfoutput></p>
  </div>
</div>
<div class="rose-divider">&#10022; &#10022; &#10022;</div>
</cfif>

<!--- GALLERY --->
<cfif arrayLen(galleryList)>
<section class="section" id="photos" style="max-width:1000px">
  <div class="section-title">
    <span class="script">Memories Together</span>
    <h2>Our Photos</h2>
    <div class="rose-rule"><div class="line"></div>&#10022;<div class="line"></div></div>
  </div>
  <div class="photos">
    <cfloop from="1" to="#arrayLen(galleryList)#" index="gi">
    <cfset giIdx = gi - 1>
    <div class="photo" onclick="openLightbox(<cfoutput>#giIdx#</cfoutput>)">
      <img src="<cfoutput>#HTMLEditFormat(galleryList[gi])#</cfoutput>" alt="Photo <cfoutput>#gi#</cfoutput>" loading="lazy">
    </div>
    </cfloop>
  </div>
</section>
<div class="rose-divider">&#10022; &#10022; &#10022;</div>
</cfif>

<!--- FAQ --->
<cfif arrayLen(faqList)>
<div class="section-alt" id="q_and_a">
  <div class="inner" style="text-align:center">
    <div class="section-title">
      <span class="script">We&rsquo;ve Got Answers</span>
      <h2>Q &amp; A</h2>
      <div class="rose-rule"><div class="line"></div>&#10022;<div class="line"></div></div>
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
<div class="rose-divider">&#10022; &#10022; &#10022;</div>
</cfif>

<!--- DRESS CODE --->
<cfif len(trim(site.dress_code))>
<section class="section" id="dress_code" style="text-align:center">
  <div class="section-title">
    <span class="script">Looking Your Best</span>
    <h2>Dress Code</h2>
    <div class="rose-rule"><div class="line"></div>&#10022;<div class="line"></div></div>
  </div>
  <p class="text-content"><cfoutput>#HTMLEditFormat(site.dress_code)#</cfoutput></p>
</section>
<div class="rose-divider">&#10022; &#10022; &#10022;</div>
</cfif>

<!--- TRAVEL --->
<cfif len(trim(site.travel_info)) OR (structKeyExists(site,"travel_links_json") AND len(trim(site.travel_links_json)))>
<div class="section-alt" id="travel">
  <div class="inner" style="text-align:center">
    <div class="section-title">
      <span class="script">Getting Here</span>
      <h2>Travel &amp; Accommodations</h2>
      <div class="rose-rule"><div class="line"></div>&#10022;<div class="line"></div></div>
    </div>
    <p class="text-content"><cfoutput>#HTMLEditFormat(site.travel_info)#</cfoutput></p>
    <cfif arrayLen(travelLinks)>
    <div style="display:flex;flex-wrap:wrap;gap:12px;margin-top:24px">
    <cfloop array="#travelLinks#" item="tl">
    <cfoutput><a href="#HTMLEditFormat(tl.url)#" target="_blank" rel="noopener" class="link-btn">#len(trim(tl.label)) ? HTMLEditFormat(tl.label) : "View Link"# &rarr;</a></cfoutput>
    </cfloop>
    </div>
    </cfif>
  </div>
</div>
<div class="rose-divider">&#10022; &#10022; &#10022;</div>
</cfif>

<!--- THINGS TO DO --->
<cfif len(trim(site.things_to_do)) OR arrayLen(thingsLinks)>
<section class="section" id="things_to_do" style="text-align:center">
  <div class="section-title">
    <span class="script">While You&rsquo;re Here</span>
    <h2>Things to Do</h2>
    <div class="rose-rule"><div class="line"></div>&#10022;<div class="line"></div></div>
  </div>
  <p class="text-content"><cfoutput>#HTMLEditFormat(site.things_to_do)#</cfoutput></p>
  <cfif arrayLen(thingsLinks)>
  <div style="display:flex;flex-wrap:wrap;gap:12px;margin-top:24px">
  <cfloop array="#thingsLinks#" item="tl">
  <cfoutput><a href="#HTMLEditFormat(tl.url)#" target="_blank" rel="noopener" class="link-btn">#len(trim(tl.label)) ? HTMLEditFormat(tl.label) : "Explore"# &rarr;</a></cfoutput>
  </cfloop>
  </div>
  </cfif>
</section>
<div class="rose-divider">&#10022; &#10022; &#10022;</div>
</cfif>

<!--- RSVP --->
<section class="rsvp" id="rsvp">
  <span class="script">You&rsquo;re Invited</span>
  <h2>Will You Join Us?</h2>
  <p>Please let us know if you&rsquo;ll be celebrating with us on our special day.</p>
  <a href="/rsvp.cfm?slug=<cfoutput>#URLEncodedFormat(site.slug)#</cfoutput>" class="btn">RSVP Now</a>
</section>

<footer>
  <div class="mono"><cfoutput>#HTMLEditFormat(monogram)#</cfoutput></div>
  <div class="names"><cfoutput>#HTMLEditFormat(site.couple_name_1)#</cfoutput> &amp; <cfoutput>#HTMLEditFormat(site.couple_name_2)#</cfoutput></div>
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
var secs=document.querySelectorAll('section[id],div[id]');
var navLinks=document.querySelectorAll('nav a');
window.addEventListener('scroll',function(){
  var pos=window.scrollY+100;
  secs.forEach(function(s){
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
