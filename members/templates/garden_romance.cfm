<!---
  garden_romance.cfm — mixed roses full-page fixed background, light overlay
  Palette: white #FFFFFF, blush #FDF6F7, rose #C0404A, deep #6B1A24, muted rgba(107,26,36,.5)
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
<link href="https://fonts.googleapis.com/css2?family=Cormorant+Garamond:ital,wght@0,300;0,400;0,600;1,300;1,400&family=Great+Vibes&family=Jost:wght@300;400&display=swap" rel="stylesheet">
<style>
:root{--white:#FFFFFF;--blush:#FDF6F7;--rose:#C0404A;--deep:#2C2C2C;--muted:rgba(44,44,44,.65)}

*{margin:0;padding:0;box-sizing:border-box}
html{scroll-behavior:smooth}

/* ---- FULL PAGE FIXED BACKGROUND ---- */
body{
  min-height:100vh;
  font-family:'Jost',sans-serif;
  font-weight:300;
  line-height:1.7;
  overflow-x:hidden;
  color:var(--deep);
  background-color:#fff;
}
.page-bg{
  position:fixed;
  inset:0;
  z-index:0;
  background-image:url('/assets/garden-romance.jpg');
  background-size:cover;
  background-position:center bottom;
  background-repeat:no-repeat;
}
.page-bg::after{
  content:'';
  position:absolute;
  inset:0;
  background:rgba(255,255,255,0);
}
.page-wrap{
  position:relative;
  z-index:1;
}

/* ---- NAV ---- */
nav{
  background:rgba(255,255,255,.8);
  border-bottom:1px solid rgba(192,64,74,.12);
  text-align:center;
  backdrop-filter:blur(12px);
  position:sticky;
  top:0;
  z-index:100;
}
nav a{color:var(--muted);text-decoration:none;font-size:.78rem;letter-spacing:.16em;text-transform:uppercase;display:inline-block;padding:18px 16px;border-bottom:2px solid transparent;transition:color .2s,border-color .2s;white-space:nowrap;font-family:'Jost',sans-serif}
nav a:hover,nav a.active{color:var(--deep);border-bottom-color:var(--rose)}

/* ---- HERO ---- */
.hero{
  min-height:72vh;
  max-width:860px;
  margin:0 auto;
  display:flex;
  flex-direction:column;
  align-items:center;
  justify-content:center;
  text-align:center;
  padding:80px 48px 120px;
  background:rgba(255,255,255,.72);
  backdrop-filter:blur(4px);
}
.hero-eyebrow{font-size:.78rem;letter-spacing:.38em;text-transform:uppercase;color:var(--rose);margin-bottom:20px;display:block;font-family:'Jost',sans-serif}
.hero-couple{font-family:'Great Vibes',cursive;font-size:clamp(4rem,9vw,7.5rem);color:var(--deep);line-height:1.1;margin-bottom:32px}
.hero-rule{display:flex;align-items:center;justify-content:center;gap:16px;margin-bottom:24px}
.hero-rule .line{height:1px;width:60px;background:var(--rose);opacity:.35}
.hero-rule .petal{color:var(--rose);font-size:1.1rem;opacity:.7}
.hero-date{font-size:.88rem;letter-spacing:.28em;text-transform:uppercase;color:var(--muted);margin-bottom:8px}
.hero-venue{font-size:.85rem;letter-spacing:.16em;text-transform:uppercase;color:var(--rose)}

/* ---- DIVIDER ---- */
.divider{height:1px;background:rgba(192,64,74,.1);margin:0}

/* ---- SECTIONS ---- */
.section{padding:88px 56px;max-width:860px;margin:0 auto;text-align:center;background:rgba(255,255,255,.72);backdrop-filter:blur(6px)}
.section-sheer{padding:88px 56px;max-width:860px;margin:0 auto;text-align:center;background:rgba(255,255,255,.72);backdrop-filter:blur(6px)}
.section-sheer .inner{max-width:100%;margin:0 auto;text-align:center}

.section-title{margin-bottom:52px}
.section-title .eyebrow{font-size:.8rem;letter-spacing:.28em;text-transform:uppercase;color:var(--rose);display:block;margin-bottom:12px;font-family:'Jost',sans-serif}
.section-title h2{font-family:'Cormorant Garamond',Georgia,serif;font-size:clamp(2.4rem,4vw,3.4rem);font-weight:300;color:var(--deep);letter-spacing:.04em;font-style:italic}
.petal-rule{display:flex;align-items:center;justify-content:center;gap:14px;margin-top:16px}
.petal-rule .line{height:1px;width:44px;background:var(--rose);opacity:.3}
.petal-rule .dot{width:5px;height:5px;border-radius:50%;background:var(--rose);opacity:.3}

/* ---- DETAILS ---- */
.details-grid{display:flex;flex-wrap:wrap;gap:1px;background:rgba(192,64,74,.1);max-width:860px;margin:0 auto}
.detail-block{flex:1;min-width:150px;padding:48px 32px;background:rgba(255,255,255,.65);text-align:center;backdrop-filter:blur(4px)}
.detail-block .lbl{font-size:.78rem;letter-spacing:.28em;text-transform:uppercase;color:var(--rose);margin-bottom:14px;display:block;font-family:'Jost',sans-serif}
.detail-block .val{font-family:'Cormorant Garamond',Georgia,serif;font-size:1.85rem;font-weight:300;color:var(--deep);line-height:1.25;font-style:italic}
.detail-block .sub{font-size:.85rem;color:var(--muted);margin-top:8px}

/* ---- STORY ---- */
.story-body{font-family:'Cormorant Garamond',Georgia,serif;font-size:1.35rem;font-weight:300;line-height:2.1;color:var(--deep);white-space:pre-wrap;font-style:italic;max-width:620px;margin:0 auto;opacity:.85}

/* ---- GALLERY ---- */
.gallery-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(150px,1fr));gap:4px;max-width:100%;margin:0 auto;text-align:left}
.g-photo{aspect-ratio:1;overflow:hidden;cursor:pointer;border-radius:10px}
.g-photo img{width:100%;height:100%;object-fit:cover;transition:transform .5s,filter .3s}
.g-photo:hover img{transform:scale(1.05);filter:saturate(1.1)}

/* ---- FAQ ---- */
.faq-list{display:flex;flex-direction:column;max-width:640px;margin:0 auto;text-align:left}
.faq-item{padding:28px 0;border-bottom:1px solid rgba(192,64,74,.1)}
.faq-item .q{font-family:'Cormorant Garamond',Georgia,serif;font-size:1.25rem;font-weight:600;color:var(--deep);margin-bottom:8px;font-style:italic}
.faq-item .a{font-size:1rem;color:var(--muted);line-height:1.9}

/* ---- TEXT ---- */
.text-body{font-size:1.05rem;color:var(--deep);line-height:2;white-space:pre-wrap;max-width:600px;margin:0 auto;opacity:.8}
.link-btn{display:inline-block;margin-top:28px;padding:13px 36px;border:1px solid var(--rose);color:var(--rose);text-decoration:none;font-size:.78rem;letter-spacing:.22em;text-transform:uppercase;font-family:'Jost',sans-serif;transition:background .2s,color .2s}
.link-btn:hover{background:var(--rose);color:#fff}

/* ---- RSVP ---- */
.rsvp-section{position:relative;text-align:center;padding:130px 24px;overflow:hidden}
.rsvp-section .bg{position:absolute;inset:0}
.rsvp-section .bg img{width:100%;height:100%;object-fit:cover;object-position:center bottom;filter:brightness(.28) saturate(.7)}
.rsvp-section .content{position:relative;z-index:2}
.rsvp-section .eyebrow{font-size:.78rem;letter-spacing:.28em;text-transform:uppercase;color:rgba(253,246,247,.75);display:block;margin-bottom:16px}
.rsvp-section .script{font-family:'Great Vibes',cursive;font-size:2.6rem;color:rgba(253,246,247,.9);display:block;margin-bottom:8px}
.rsvp-section h2{font-family:'Cormorant Garamond',Georgia,serif;font-size:clamp(2.6rem,5vw,4.4rem);font-weight:300;color:#FDFCFC;margin-bottom:16px;letter-spacing:.03em;font-style:italic}
.rsvp-section p{color:rgba(253,246,247,.65);margin-bottom:44px;max-width:400px;margin-left:auto;margin-right:auto;font-size:1rem;line-height:2}
.rsvp-btn{display:inline-block;padding:15px 56px;border:1px solid rgba(253,246,247,.7);color:#FDFCFC;font-size:.78rem;letter-spacing:.28em;text-transform:uppercase;text-decoration:none;font-family:'Jost',sans-serif;transition:background .25s,color .25s}
.rsvp-btn:hover{background:#FDFCFC;color:var(--deep)}

/* ---- FOOTER ---- */
footer{text-align:center;padding:72px 24px;border-top:1px solid rgba(192,64,74,.1);background:rgba(255,255,255,.72);backdrop-filter:blur(12px)}
footer .names{font-family:'Great Vibes',cursive;font-size:2.8rem;color:var(--deep);margin-bottom:12px}
footer .date{font-size:.6rem;letter-spacing:.3em;text-transform:uppercase;color:var(--rose)}
footer .credit{font-size:1.1rem;font-weight:500;font-weight:500;color:rgba(107,26,36,.2);margin-top:24px}

/* ---- LIGHTBOX ---- */
#lightbox{position:fixed;inset:0;background:rgba(107,26,36,.97);z-index:999;display:none;align-items:center;justify-content:center;padding:20px}
#lightbox.show{display:flex}
#lightbox img{max-height:85vh;max-width:90vw;object-fit:contain}
#lightbox button{position:absolute;background:rgba(255,255,255,.1);border:none;color:#fff;cursor:pointer}
#lightbox .nav-btn{width:52px;height:52px;font-size:1.8rem;top:50%;transform:translateY(-50%)}
#lightbox .prev{left:20px}
#lightbox .next{right:20px}
#lightbox .close-lb{top:16px;right:16px;width:40px;height:40px;font-size:1.1rem}
#lightbox .count{position:absolute;bottom:20px;color:rgba(255,255,255,.3);font-size:.75rem;letter-spacing:.1em}

@media(max-width:600px){
  .hero{padding:60px 24px 100px}
  .section,.section-sheer{padding:64px 24px}
  .detail-block{padding:36px 20px}
  nav a{font-size:.72rem;padding:14px 10px}
}
</style>
</head>
<body>

<div class="page-bg" <cfif len(heroImg)>style="background-image:url('<cfoutput>#HTMLEditFormat(heroImg)#</cfoutput>')"</cfif>>
</div>

<div class="page-wrap">

<cfif structKeyExists(site,"is_preview") AND site.is_preview>
<div style="position:fixed;top:0;left:0;right:0;z-index:9999;background:#6B1A24;color:#fff;display:flex;align-items:center;justify-content:space-between;padding:12px 24px;font-family:Arial,sans-serif;font-size:13px;gap:12px">
  <cfif isNumeric(url.siteId) AND url.siteId GT 0>
  <span style="opacity:.8">&#128065; Previewing your wedding site</span>
  <button onclick="window.close()" style="padding:8px 20px;background:rgba(255,255,255,.12);color:#fff;border:none;border-radius:4px;font-weight:600;cursor:pointer;font-size:13px">&times; Close Preview</button>
  <cfelse>
  <span style="opacity:.8">&#128065; Template preview &mdash; sample data shown</span>
  <a href="/members/wedding-site-edit.cfm?template=garden_romance" style="padding:8px 20px;background:#C0404A;color:#fff;border-radius:4px;font-weight:600;text-decoration:none;white-space:nowrap">Use This Template &rarr;</a>
  </cfif>
</div>
<div style="height:48px"></div>
</cfif>

<nav>
  <cfif len(trim(site.story))><a href="#our_story">Our Story</a></cfif>
  <a href="#details">Details</a>
  <cfif structKeyExists(site,"registry_url") AND len(trim(site.registry_url))><a href="<cfoutput>#HTMLEditFormat(trim(site.registry_url))#</cfoutput>" target="_blank" rel="noopener">Registry</a></cfif><a href="#rsvp">RSVP</a>
  <cfif arrayLen(galleryList)><a href="#photos">Photos</a></cfif>
  <cfif arrayLen(faqList)><a href="#q_and_a">Q &amp; A</a></cfif>
  <cfif len(trim(site.dress_code))><a href="#dress_code">Dress Code</a></cfif>
  <cfif len(trim(site.travel_info)) OR (structKeyExists(site,"travel_links_json") AND len(trim(site.travel_links_json)))><a href="#travel">Travel</a></cfif>
  <cfif len(trim(site.things_to_do)) OR arrayLen(thingsLinks)><a href="#things_to_do">Things to Do</a></cfif>
</nav>

<!--- HERO --->
<div class="hero">
  <cfset couplePhoto = structKeyExists(site,"couple_photo_url") ? trim(site.couple_photo_url) : "">
  <cfset couplePhotoSrc = len(couplePhoto) ? couplePhoto : "/assets/couple-placeholder.jpg">
  <img src="<cfoutput>#HTMLEditFormat(couplePhotoSrc)#</cfoutput>" alt="Couple photo" style="width:130px;height:130px;border-radius:50%;object-fit:cover;border:3px solid rgba(255,255,255,.5);box-shadow:0 4px 24px rgba(0,0,0,.5);display:block;margin-bottom:22px">
  <span class="hero-eyebrow">We&rsquo;re Getting Married</span>
  <div class="hero-couple">
    <cfoutput>#HTMLEditFormat(site.couple_name_1)#</cfoutput><br>
    &amp;<br>
    <cfoutput>#HTMLEditFormat(site.couple_name_2)#</cfoutput>
  </div>
  <div class="hero-rule">
    <div class="line"></div>
    <span class="petal">&#10022;</span>
    <div class="line"></div>
  </div>
  <cfif len(weddingDateFull)>
  <p class="hero-date"><cfoutput>#weddingDateFull#</cfoutput></p>
  </cfif>
  <cfif len(trim(site.venue_name))>
  <p class="hero-venue"><cfoutput>#HTMLEditFormat(site.venue_name)#</cfoutput></p>
  </cfif>
</div>

<!--- OUR STORY --->
<cfif len(trim(site.story))>
<div class="divider"></div>
<section class="section" id="our_story">
  <div class="section-title">
    <span class="eyebrow">The Beginning</span>
    <h2>Our Story</h2>
    <div class="petal-rule"><div class="line"></div><div class="dot"></div><div class="line"></div></div>
  </div>
  <p class="story-body"><cfoutput>#HTMLEditFormat(site.story)#</cfoutput></p>
</section>
</cfif>

<!--- DETAILS --->
<div class="divider"></div>
<section id="details" style="padding:88px 56px;max-width:860px;margin:0 auto;background:rgba(255,255,255,.72);backdrop-filter:blur(6px);text-align:center">
  <div style="max-width:860px;margin:0 auto;padding:0 56px 52px;text-align:center">
    <div class="section-title">
      <span class="eyebrow">Celebration Details</span>
      <h2>Join Us</h2>
      <div class="petal-rule"><div class="line"></div><div class="dot"></div><div class="line"></div></div>
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
<section class="section" id="photos">
  <div class="section-title">
    <span class="eyebrow">Captured Moments</span>
    <h2>Photos</h2>
    <div class="petal-rule"><div class="line"></div><div class="dot"></div><div class="line"></div></div>
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
<div class="section-sheer" id="q_and_a">
  <div class="inner">
    <div class="section-title">
      <span class="eyebrow">Good to Know</span>
      <h2>Q &amp; A</h2>
      <div class="petal-rule"><div class="line"></div><div class="dot"></div><div class="line"></div></div>
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
    <div class="petal-rule"><div class="line"></div><div class="dot"></div><div class="line"></div></div>
  </div>
  <p class="text-body"><cfoutput>#HTMLEditFormat(site.dress_code)#</cfoutput></p>
</section>
</cfif>

<!--- TRAVEL --->
<cfif len(trim(site.travel_info)) OR (structKeyExists(site,"travel_links_json") AND len(trim(site.travel_links_json)))>
<div class="divider"></div>
<div class="section-sheer" id="travel">
  <div class="inner">
    <div class="section-title">
      <span class="eyebrow">Getting Here</span>
      <h2>Travel &amp; Accommodations</h2>
      <div class="petal-rule"><div class="line"></div><div class="dot"></div><div class="line"></div></div>
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
    <div class="petal-rule"><div class="line"></div><div class="dot"></div><div class="line"></div></div>
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
    <img src="/assets/garden-romance.jpg" alt="" onerror="this.style.display='none'">
    </cfif>
  </div>
  <div class="content">
    <span class="eyebrow">You&rsquo;re Invited</span>
    <span class="script">with love</span>
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
window.addEventListener('scroll',function(){
  var pos=window.scrollY+100;
  document.querySelectorAll('section[id],div[id]').forEach(function(s){
    if(pos>=s.offsetTop&&pos<s.offsetTop+s.offsetHeight){
      document.querySelectorAll('nav a').forEach(function(a){a.classList.remove('active');if(a.getAttribute('href')==='#'+s.id)a.classList.add('active');});
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
