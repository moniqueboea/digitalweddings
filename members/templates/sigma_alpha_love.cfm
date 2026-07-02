<!---
  sigma_alpha_love.cfm — Full-bleed hero image, Chi Omega cardinal red & gold accents
  Palette: dark #1A0040, deep #220055, purple #6B21A8, purple-light #C4A0E8, gold #C9A84C, gold-light #E8C97A, cream #FAF6EE
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
<cfset heroImg = len(trim(site.hero_image_url)) ? trim(site.hero_image_url) : "">

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title><cfoutput>#HTMLEditFormat(site.couple_name_1)# &amp; #HTMLEditFormat(site.couple_name_2)#</cfoutput></title>
<link href="https://fonts.googleapis.com/css2?family=Cormorant+Garamond:ital,wght@0,300;0,400;0,600;1,300;1,400&family=Great+Vibes&family=Cinzel:wght@400;600&display=swap" rel="stylesheet">
<style>
:root{
  --dark:#1A0040;
  --deep:#220055;
  --purple:#6B21A8;
  --purple-light:#C4A0E8;
  --gold:#C9A84C;
  --gold-light:#E8C97A;
  --cream:#FAF6EE;
  --muted:rgba(250,246,238,.5);
}
*{margin:0;padding:0;box-sizing:border-box}
html{scroll-behavior:smooth}
body{background:var(--dark);color:var(--cream);font-family:'Cinzel',serif;font-weight:400;line-height:1.7;overflow-x:hidden}

/* ---- HERO ---- */
.hero{position:relative;height:85vh;min-height:600px;overflow:hidden;display:flex;flex-direction:column}
.hero-img{position:absolute;inset:0;background:var(--dark);display:flex;align-items:flex-start;justify-content:center}
.hero-img img{width:auto;height:100%;max-width:100%;object-fit:contain;object-position:center top;display:block}
.hero-overlay{position:absolute;inset:0;background:linear-gradient(to bottom,rgba(26,0,64,.5) 0%,rgba(26,0,64,.2) 40%,rgba(26,0,64,.85) 100%)}

/* Red & gold top border */
.hero-border{position:absolute;top:0;left:0;right:0;height:5px;z-index:5;background:linear-gradient(to right,var(--purple),var(--gold),var(--gold-light),var(--gold),var(--purple))}

/* ---- NAV overlaid on hero ---- */
.hero-nav{position:absolute;bottom:370px;left:0;right:0;z-index:10;display:flex;align-items:center;justify-content:center;flex-wrap:wrap;gap:0;padding:0 24px}
.hero-nav a{color:rgba(250,246,238,.7);text-decoration:none;font-size:.68rem;letter-spacing:.2em;text-transform:uppercase;font-family:'Cinzel',serif;font-weight:400;padding:10px 14px;border-bottom:1px solid transparent;transition:color .2s,border-color .2s;white-space:nowrap}
.hero-nav a:hover,.hero-nav a.active{color:var(--gold-light);border-bottom-color:var(--gold)}

/* ---- HERO TEXT ---- */
.hero-text{position:absolute;bottom:40px;left:0;right:0;z-index:10;padding:0 48px;display:flex;flex-direction:column;align-items:center;text-align:center}
.hero-couple{font-family:'Great Vibes',cursive;font-size:clamp(3rem,7vw,6rem);color:var(--cream);line-height:1.05}
.hero-meta{margin-top:18px;display:flex;align-items:center;justify-content:center;gap:20px;flex-wrap:wrap}
.hero-date-line{font-size:.72rem;letter-spacing:.22em;text-transform:uppercase;color:rgba(250,246,238,.6);font-family:'Cinzel',serif}
.hero-dot{width:4px;height:4px;border-radius:50%;background:var(--gold);flex-shrink:0}
.hero-venue-line{font-size:.72rem;letter-spacing:.16em;text-transform:uppercase;color:rgba(250,246,238,.45);font-family:'Cinzel',serif}

/* Gold rule used throughout */
.gold-rule{width:60px;height:1px;background:linear-gradient(to right,transparent,var(--gold),transparent);margin-top:16px}

/* ---- SECTIONS ---- */
.section{padding:40px 48px 80px;max-width:900px;margin:0 auto}
.section-dark{background:var(--deep);padding:80px 48px}
.section-dark .inner{max-width:900px;margin:0 auto}

.section-title{margin-bottom:48px}
.section-title .eyebrow{font-size:.65rem;letter-spacing:.32em;text-transform:uppercase;color:var(--gold);display:block;margin-bottom:12px;font-family:'Cinzel',serif}
.section-title h2{font-family:'Cormorant Garamond',Georgia,serif;font-size:clamp(2rem,4vw,3rem);font-weight:300;color:var(--cream);letter-spacing:.04em;font-style:italic}

/* ---- DETAILS ---- */
.details-grid{display:flex;flex-wrap:wrap;gap:1px;background:rgba(107,33,168,.2);max-width:860px;margin:0 auto}
.detail-block{flex:1;min-width:150px;padding:48px 32px;background:var(--deep);text-align:center}
.detail-block .lbl{font-size:.65rem;letter-spacing:.28em;text-transform:uppercase;color:var(--gold);margin-bottom:14px;display:block;font-family:'Cinzel',serif}
.detail-block .val{font-family:'Cormorant Garamond',Georgia,serif;font-size:1.7rem;font-weight:300;color:var(--cream);line-height:1.25;font-style:italic}
.detail-block .sub{font-size:.78rem;color:var(--muted);margin-top:8px}

/* ---- STORY ---- */
.story-body{font-family:'Cormorant Garamond',Georgia,serif;font-size:1.25rem;font-weight:300;line-height:2;color:rgba(250,246,238,.85);white-space:pre-wrap;font-style:italic;max-width:640px}

/* ---- GALLERY ---- */
.gallery-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(220px,1fr));gap:3px}
.g-photo{aspect-ratio:1;overflow:hidden;cursor:pointer;border-radius:2px;position:relative}
.g-photo::after{content:'';position:absolute;inset:0;border:2px solid transparent;transition:border-color .3s}
.g-photo:hover::after{border-color:var(--gold)}
.g-photo img{width:100%;height:100%;object-fit:cover;transition:transform .5s,filter .4s;filter:saturate(.8) brightness(.9)}
.g-photo:hover img{transform:scale(1.05);filter:saturate(1.05) brightness(1.05)}

/* ---- FAQ ---- */
.faq-list{display:flex;flex-direction:column;gap:1px;max-width:680px}
.faq-item{padding:24px 0;border-bottom:1px solid rgba(201,168,76,.15)}
.faq-item .q{font-family:'Cormorant Garamond',Georgia,serif;font-size:1.15rem;font-weight:400;color:var(--cream);margin-bottom:8px;font-style:italic}
.faq-item .a{font-size:.95rem;color:var(--muted);line-height:1.9;font-family:'Cormorant Garamond',Georgia,serif}

/* ---- TEXT BLOCKS ---- */
.text-body{font-size:.95rem;color:rgba(250,246,238,.75);line-height:2;white-space:pre-wrap;max-width:620px;font-family:'Cormorant Garamond',Georgia,serif}
.link-btn{display:inline-block;margin-top:24px;padding:13px 36px;border:1px solid var(--gold);color:var(--gold);text-decoration:none;font-size:.62rem;letter-spacing:.22em;text-transform:uppercase;font-family:'Cinzel',serif;transition:background .2s,color .2s}
.link-btn:hover{background:var(--gold);color:var(--dark)}

/* ---- DIVIDER ---- */
.divider{width:100%;height:1px;background:linear-gradient(to right,transparent,var(--gold),var(--gold-light),var(--gold),transparent)}

/* ---- RSVP ---- */
.rsvp-section{text-align:center;padding:120px 24px;position:relative;overflow:hidden}
.rsvp-section .bg{position:absolute;inset:0}
.rsvp-section .bg img{width:100%;height:100%;object-fit:cover;filter:brightness(.12) saturate(.4)}
.rsvp-section::before{content:'';position:absolute;top:0;left:0;right:0;height:4px;z-index:2;background:linear-gradient(to right,var(--purple),var(--gold),var(--gold-light),var(--gold),var(--purple))}
.rsvp-section .content{position:relative;z-index:2}
.rsvp-section .eyebrow{font-size:.68rem;letter-spacing:.28em;text-transform:uppercase;color:var(--gold);display:block;margin-bottom:16px;font-family:'Cinzel',serif}
.rsvp-section h2{font-family:'Cormorant Garamond',Georgia,serif;font-size:clamp(2.2rem,5vw,3.8rem);font-weight:300;color:var(--cream);margin-bottom:16px;letter-spacing:.03em;font-style:italic}
.rsvp-section p{color:var(--muted);margin-bottom:44px;max-width:420px;margin-left:auto;margin-right:auto;font-size:.95rem;line-height:1.9;font-family:'Cormorant Garamond',Georgia,serif}
.rsvp-btn{display:inline-block;padding:16px 56px;border:1px solid var(--gold);color:var(--gold);font-size:.62rem;letter-spacing:.3em;text-transform:uppercase;text-decoration:none;font-family:'Cinzel',serif;transition:background .25s,color .25s}
.rsvp-btn:hover{background:var(--gold);color:var(--dark)}

/* ---- FOOTER ---- */
footer{text-align:center;padding:70px 24px;border-top:1px solid rgba(201,168,76,.2)}
footer .names{font-family:'Great Vibes',cursive;font-size:2.6rem;color:var(--cream);margin-bottom:8px}
footer .date{font-size:.6rem;letter-spacing:.28em;text-transform:uppercase;color:var(--gold)}
footer .ornament{color:rgba(201,168,76,.35);font-size:.9rem;margin-top:14px;letter-spacing:.4em}
footer .credit{font-size:1.1rem;color:rgba(255,255,255,.1);margin-top:16px}

/* ---- LIGHTBOX ---- */
#lightbox{position:fixed;inset:0;background:rgba(0,0,0,.97);z-index:999;display:none;align-items:center;justify-content:center;padding:20px}
#lightbox.show{display:flex}
#lightbox img{max-height:85vh;max-width:90vw;border-radius:2px;object-fit:contain}
#lightbox button{position:absolute;background:rgba(201,168,76,.12);border:none;color:var(--cream);cursor:pointer}
#lightbox .nav-btn{width:52px;height:52px;font-size:1.8rem;top:50%;transform:translateY(-50%)}
#lightbox .prev{left:20px}
#lightbox .next{right:20px}
#lightbox .close-lb{top:16px;right:16px;width:40px;height:40px;font-size:1.1rem}
#lightbox .count{position:absolute;bottom:20px;color:rgba(255,255,255,.25);font-size:.75rem;letter-spacing:.1em}

@media(max-width:600px){
  .hero-text{padding:0 24px 40px}
  .hero-couple{font-size:2.8rem}
  .hero-nav a{font-size:.62rem;padding:8px 10px}
  .section{padding:64px 24px}
  .section-dark{padding:64px 24px}
}
</style>
</head>
<body>

<cfif structKeyExists(site,"is_preview") AND site.is_preview>
<div style="position:fixed;top:0;left:0;right:0;z-index:9999;background:#1A0040;color:#FAF6EE;display:flex;align-items:center;justify-content:space-between;padding:12px 24px;font-family:Arial,sans-serif;font-size:13px;border-bottom:1px solid rgba(201,168,76,.3);gap:12px">
  <cfif isNumeric(url.siteId) AND url.siteId GT 0>
  <span style="opacity:.75">&#128065; Previewing your wedding site</span>
  <button onclick="window.close()" style="padding:8px 20px;background:rgba(201,168,76,.15);color:#FAF6EE;border:1px solid rgba(201,168,76,.4);border-radius:4px;font-weight:600;cursor:pointer;font-size:13px">&times; Close Preview</button>
  <cfelse>
  <span style="opacity:.75">&#128065; Template preview &mdash; sample data shown</span>
  <a href="/members/wedding-site-edit.cfm?template=sigma_alpha_love" style="padding:8px 20px;background:#C9A84C;color:#1A0040;border-radius:4px;font-weight:700;text-decoration:none;white-space:nowrap">Use This Template &rarr;</a>
  </cfif>
</div>
<div style="height:48px"></div>
</cfif>

<!--- HERO --->
<div class="hero">
  <div class="hero-border"></div>
  <div class="hero-img">
    <cfif len(heroImg)>
    <img src="<cfoutput>#HTMLEditFormat(heroImg)#</cfoutput>" alt="Wedding">
    <cfelse>
    <img src="/assets/sigma-alpha-love.png" alt="Sigma Alpha Love" onerror="this.style.display='none'">
    </cfif>
  </div>
  <div class="hero-overlay"></div>

  <nav class="hero-nav">
    <cfif len(trim(site.story))><a href="#our_story">Our Story</a></cfif>
    <a href="#details">Details</a>
    <cfif structKeyExists(site,"registry_url") AND len(trim(site.registry_url))><a href="<cfoutput>#HTMLEditFormat(trim(site.registry_url))#</cfoutput>" target="_blank" rel="noopener">Registry</a></cfif>
    <a href="#rsvp">RSVP</a>
    <cfif arrayLen(galleryList)><a href="#photos">Photos</a></cfif>
    <cfif arrayLen(faqList)><a href="#q_and_a">Q &amp; A</a></cfif>
    <cfif len(trim(site.dress_code))><a href="#dress_code">Dress Code</a></cfif>
    <cfif len(trim(site.travel_info)) OR arrayLen(travelLinks)><a href="#travel">Travel</a></cfif>
    <cfif len(trim(site.things_to_do)) OR arrayLen(thingsLinks)><a href="#things_to_do">Things to Do</a></cfif>
  </nav>

<cfoutput>
<cfif cdIsFuture>
<div style="position:relative;z-index:10;text-align:center;padding:18px 24px;border-bottom:1px solid rgba(201,168,76,.2);font-family:'Cinzel',serif">
  <span style="font-size:.6rem;letter-spacing:.4em;text-transform:uppercase;color:##C9A84C">Countdown</span>
  <div style="margin:6px 0;display:flex;align-items:baseline;justify-content:center;gap:8px">
    <span style="font-size:2.4rem;font-weight:600;color:##C9A84C;line-height:1">#cdDaysUntil#</span>
    <span style="font-size:.7rem;letter-spacing:.25em;text-transform:uppercase;color:rgba(250,246,238,0.7)">#cdDaysUntil EQ 1 ? 'day' : 'days'# to go</span>
  </div>
  <cfif len(weddingDateFull)><span style="font-size:.68rem;letter-spacing:.15em;text-transform:uppercase;color:rgba(250,246,238,.45)">#weddingDateFull#</span></cfif>
</div>
</cfif>
<cfif cdDaysUntil EQ 0 AND len(trim(site.wedding_date))>
<div style="position:relative;z-index:10;text-align:center;padding:16px 24px;border-bottom:1px solid rgba(201,168,76,.2);font-family:'Cinzel',serif">
  <span style="font-size:.68rem;letter-spacing:.35em;text-transform:uppercase;color:##C9A84C">Today Is The Day</span>
</div>
</cfif>
</cfoutput>

  <div class="hero-text">
    <cfset couplePhoto = structKeyExists(site,"couple_photo_url") ? trim(site.couple_photo_url) : "">
    <cfset couplePhotoSrc = len(couplePhoto) ? couplePhoto : "/assets/couple-placeholder.jpg">
    <img src="<cfoutput>#HTMLEditFormat(couplePhotoSrc)#</cfoutput>" alt="Couple photo"
      style="width:130px;height:130px;border-radius:50%;object-fit:cover;
             border:3px solid var(--gold);
             box-shadow:0 0 0 6px rgba(107,33,168,.2),0 4px 24px rgba(0,0,0,.6);
             display:block;margin-bottom:22px">
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
<nav id="stickyNav" style="display:none;position:sticky;top:0;z-index:40;background:var(--deep);border-bottom:1px solid rgba(201,168,76,.2);text-align:center">
  <cfif len(trim(site.story))><a href="#our_story" style="color:rgba(250,246,238,.7);text-decoration:none;font-size:.68rem;letter-spacing:.2em;text-transform:uppercase;font-family:'Cinzel',serif;display:inline-block;padding:16px 14px;border-bottom:2px solid transparent">Our Story</a></cfif>
  <a href="#details" style="color:rgba(250,246,238,.7);text-decoration:none;font-size:.68rem;letter-spacing:.2em;text-transform:uppercase;font-family:'Cinzel',serif;display:inline-block;padding:16px 14px;border-bottom:2px solid transparent">Details</a>
  <cfif structKeyExists(site,"registry_url") AND len(trim(site.registry_url))><a href="<cfoutput>#HTMLEditFormat(trim(site.registry_url))#</cfoutput>" target="_blank" rel="noopener" style="color:rgba(250,246,238,.7);text-decoration:none;font-size:.68rem;letter-spacing:.2em;text-transform:uppercase;font-family:'Cinzel',serif;display:inline-block;padding:16px 14px;border-bottom:2px solid transparent">Registry</a></cfif>
  <a href="#rsvp" style="color:rgba(250,246,238,.7);text-decoration:none;font-size:.68rem;letter-spacing:.2em;text-transform:uppercase;font-family:'Cinzel',serif;display:inline-block;padding:16px 14px;border-bottom:2px solid transparent">RSVP</a>
  <cfif arrayLen(galleryList)><a href="#photos" style="color:rgba(250,246,238,.7);text-decoration:none;font-size:.68rem;letter-spacing:.2em;text-transform:uppercase;font-family:'Cinzel',serif;display:inline-block;padding:16px 14px;border-bottom:2px solid transparent">Photos</a></cfif>
  <cfif arrayLen(faqList)><a href="#q_and_a" style="color:rgba(250,246,238,.7);text-decoration:none;font-size:.68rem;letter-spacing:.2em;text-transform:uppercase;font-family:'Cinzel',serif;display:inline-block;padding:16px 14px;border-bottom:2px solid transparent">Q &amp; A</a></cfif>
  <cfif len(trim(site.dress_code))><a href="#dress_code" style="color:rgba(250,246,238,.7);text-decoration:none;font-size:.68rem;letter-spacing:.2em;text-transform:uppercase;font-family:'Cinzel',serif;display:inline-block;padding:16px 14px;border-bottom:2px solid transparent">Dress Code</a></cfif>
  <cfif len(trim(site.travel_info)) OR arrayLen(travelLinks)><a href="#travel" style="color:rgba(250,246,238,.7);text-decoration:none;font-size:.68rem;letter-spacing:.2em;text-transform:uppercase;font-family:'Cinzel',serif;display:inline-block;padding:16px 14px;border-bottom:2px solid transparent">Travel</a></cfif>
  <cfif len(trim(site.things_to_do)) OR arrayLen(thingsLinks)><a href="#things_to_do" style="color:rgba(250,246,238,.7);text-decoration:none;font-size:.68rem;letter-spacing:.2em;text-transform:uppercase;font-family:'Cinzel',serif;display:inline-block;padding:16px 14px;border-bottom:2px solid transparent">Things to Do</a></cfif>
</nav>

<!--- OUR STORY --->
<cfif len(trim(site.story))>
<div class="divider"></div>
<section class="section" id="our_story">
  <div class="section-title">
    <span class="eyebrow">The Beginning</span>
    <h2>Our Story</h2>
    <div class="gold-rule"></div>
  </div>
  <p class="story-body"><cfoutput>#HTMLEditFormat(site.story)#</cfoutput></p>
</section>
</cfif>

<!--- DETAILS --->
<div class="divider"></div>
<section id="details" style="padding:80px 0">
  <div style="max-width:900px;margin:0 auto;padding:0 48px 48px">
    <div class="section-title">
      <span class="eyebrow">Celebration Details</span>
      <h2>Join Us</h2>
      <div class="gold-rule"></div>
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
<section id="photos" style="padding:80px 48px;max-width:1100px;margin:0 auto">
  <div class="section-title">
    <span class="eyebrow">Captured Moments</span>
    <h2>Photos</h2>
    <div class="gold-rule"></div>
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
<div class="section-dark" id="q_and_a">
  <div class="inner">
    <div class="section-title">
      <span class="eyebrow">Good to Know</span>
      <h2>Q &amp; A</h2>
      <div class="gold-rule"></div>
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
    <div class="gold-rule"></div>
  </div>
  <p class="text-body"><cfoutput>#HTMLEditFormat(site.dress_code)#</cfoutput></p>
</section>
</cfif>

<!--- TRAVEL --->
<cfif len(trim(site.travel_info)) OR (structKeyExists(site,"travel_links_json") AND len(trim(site.travel_links_json)))>
<div class="divider"></div>
<div class="section-dark" id="travel">
  <div class="inner">
    <div class="section-title">
      <span class="eyebrow">Getting Here</span>
      <h2>Travel &amp; Accommodations</h2>
      <div class="gold-rule"></div>
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
    <div class="gold-rule"></div>
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
  <div class="bg">
    <cfif len(heroImg)>
    <img src="<cfoutput>#HTMLEditFormat(heroImg)#</cfoutput>" alt="">
    <cfelse>
    <img src="/assets/sigma-alpha-love.png" alt="" onerror="this.style.display='none'">
    </cfif>
  </div>
  <div class="content">
    <span class="eyebrow">You&rsquo;re Invited</span>
    <h2>Will You Join Us?</h2>
    <p>Please let us know if you&rsquo;ll be celebrating with us on our special day.</p>
    <a href="/rsvp.cfm?slug=<cfoutput>#URLEncodedFormat(site.slug)#</cfoutput>" class="rsvp-btn">RSVP</a>
  </div>
</section>

<footer>
  <div class="names"><cfoutput>#HTMLEditFormat(site.couple_name_1)# &amp; #HTMLEditFormat(site.couple_name_2)#</cfoutput></div>
  <cfif len(weddingDateFull)><div class="date"><cfoutput>#weddingDateFull#</cfoutput></div></cfif>
  <div class="ornament">&diams; &diams; &diams;</div>
  <div class="credit">digitalweddings.love &#9829;</div>
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
});
</script>

<button onclick="window.scrollTo({top:0,behavior:'smooth'})" id="backToTop" aria-label="Back to top" style="display:none;position:fixed;bottom:28px;right:28px;z-index:9000;width:44px;height:44px;border-radius:50%;border:1px solid var(--gold);cursor:pointer;background:rgba(26,0,64,.85);color:var(--gold);font-size:20px;line-height:44px;text-align:center;box-shadow:0 4px 16px rgba(0,0,0,.5)">&uarr;</button>
<script>
(function(){
  var btn=document.getElementById('backToTop');
  window.addEventListener('scroll',function(){btn.style.display=window.scrollY>400?'block':'none';});
})();
</script>
</body>
</html>
