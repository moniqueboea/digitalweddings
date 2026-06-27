<!---
  copper_rose.cfm — peach/apricot roses, bordeaux_rose/midnight_peony style
  Palette: near-black #080503, charcoal #130A06, cream #F7EDE4, copper #C87A50
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
:root{--black:#080503;--charcoal:#130A06;--cream:#F7EDE4;--copper:#C87A50;--muted:rgba(247,237,228,.5)}
*{margin:0;padding:0;box-sizing:border-box}
html{scroll-behavior:smooth}
body{background:var(--black);color:var(--cream);font-family:'Jost',sans-serif;font-weight:300;line-height:1.7;overflow-x:hidden}

/* ---- HERO ---- */
.hero{position:relative;height:70vh;min-height:520px;overflow:hidden;display:flex;flex-direction:column}
.hero-img{position:absolute;inset:0}
.hero-img img{width:100%;height:100%;object-fit:cover;object-position:center center;display:block}
.hero-overlay{position:absolute;inset:0;background:linear-gradient(to bottom,rgba(0,0,0,.5) 0%,rgba(0,0,0,.2) 40%,rgba(0,0,0,.72) 100%)}

/* ---- NAV overlaid on hero ---- */
.hero-nav{position:relative;z-index:10;display:flex;align-items:center;justify-content:center;flex-wrap:wrap;gap:0;padding:28px 24px 0}
.hero-nav a{color:rgba(247,237,228,.75);text-decoration:none;font-size:.75rem;letter-spacing:.18em;text-transform:uppercase;font-family:'Jost',sans-serif;font-weight:300;padding:10px 16px;border-bottom:1px solid transparent;transition:color .2s,border-color .2s;white-space:nowrap}
.hero-nav a:hover,.hero-nav a.active{color:var(--cream);border-bottom-color:var(--cream)}

/* ---- HERO TEXT ---- */
.hero-text{position:relative;z-index:10;margin-top:auto;padding:0 48px 56px;display:flex;flex-direction:column;align-items:center;text-align:center}
.hero-couple{font-family:'Cormorant Garamond',Georgia,serif;font-size:clamp(3rem,7vw,6rem);font-weight:300;color:var(--cream);line-height:1.05;letter-spacing:.01em}
.hero-meta{margin-top:18px;display:flex;align-items:center;justify-content:center;gap:20px;flex-wrap:wrap}
.hero-date-line{font-size:.8rem;letter-spacing:.22em;text-transform:uppercase;color:rgba(247,237,228,.6);font-family:'Jost',sans-serif}
.hero-dot{width:3px;height:3px;border-radius:50%;background:var(--copper);flex-shrink:0}
.hero-venue-line{font-size:.8rem;letter-spacing:.16em;text-transform:uppercase;color:rgba(247,237,228,.5);font-family:'Jost',sans-serif}

@media(max-width:600px){
  .hero-text{padding:0 24px 40px}
  .hero-couple{font-size:2.8rem}
  .hero-nav a{font-size:.68rem;padding:8px 10px}
}

/* ---- SECTIONS ---- */
.section{padding:80px 48px;max-width:900px;margin:0 auto}
.section-dark{background:var(--charcoal);padding:80px 48px}
.section-dark .inner{max-width:900px;margin:0 auto}

.section-title{margin-bottom:48px}
.section-title .eyebrow{font-size:.75rem;letter-spacing:.25em;text-transform:uppercase;color:var(--copper);display:block;margin-bottom:12px;font-family:'Jost',sans-serif}
.section-title h2{font-family:'Cormorant Garamond',Georgia,serif;font-size:clamp(2rem,4vw,3rem);font-weight:300;color:var(--cream);letter-spacing:.03em}
.copper-rule{width:40px;height:1px;background:var(--copper);margin-top:16px;opacity:.6}

/* ---- DETAILS ---- */
.details-grid{display:flex;flex-wrap:wrap;gap:1px;background:rgba(200,122,80,.2);max-width:860px;margin:0 auto}
.detail-block{flex:1;min-width:150px;padding:48px 32px;background:var(--charcoal);text-align:center}
.detail-block .lbl{font-size:.75rem;letter-spacing:.22em;text-transform:uppercase;color:var(--copper);margin-bottom:14px;display:block;font-family:'Jost',sans-serif}
.detail-block .val{font-family:'Cormorant Garamond',Georgia,serif;font-size:1.7rem;font-weight:300;color:var(--cream);line-height:1.25;font-style:italic}
.detail-block .sub{font-size:.78rem;color:var(--muted);margin-top:8px}

/* ---- STORY ---- */
.story-body{font-family:'Cormorant Garamond',Georgia,serif;font-size:1.25rem;font-weight:300;line-height:2;color:rgba(247,237,228,.85);white-space:pre-wrap;font-style:italic;max-width:640px}

/* ---- GALLERY ---- */
.gallery-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(220px,1fr));gap:3px}
.g-photo{aspect-ratio:1;overflow:hidden;cursor:pointer;border-radius:10px}
.g-photo img{width:100%;height:100%;object-fit:cover;transition:transform .5s,filter .4s;filter:saturate(.8) brightness(.95)}
.g-photo:hover img{transform:scale(1.05);filter:saturate(1) brightness(1.05)}

/* ---- FAQ ---- */
.faq-list{display:flex;flex-direction:column;gap:1px;max-width:680px}
.faq-item{padding:24px 0;border-bottom:1px solid rgba(255,255,255,.08)}
.faq-item .q{font-family:'Cormorant Garamond',Georgia,serif;font-size:1.15rem;font-weight:400;color:var(--cream);margin-bottom:8px;font-style:italic}
.faq-item .a{font-size:.95rem;color:var(--muted);line-height:1.9}

/* ---- TEXT ---- */
.text-body{font-size:1rem;color:rgba(247,237,228,.75);line-height:2;white-space:pre-wrap;max-width:620px}
.link-btn{display:inline-block;margin-top:24px;padding:13px 36px;border:1px solid var(--copper);color:var(--copper);text-decoration:none;font-size:.75rem;letter-spacing:.2em;text-transform:uppercase;font-family:'Jost',sans-serif;transition:background .2s,color .2s}
.link-btn:hover{background:var(--copper);color:var(--black)}

/* ---- RSVP ---- */
.rsvp-section{text-align:center;padding:120px 24px;position:relative;overflow:hidden}
.rsvp-section .bg{position:absolute;inset:0}
.rsvp-section .bg img{width:100%;height:100%;object-fit:cover;filter:brightness(.2) saturate(.5)}
.rsvp-section .content{position:relative;z-index:2}
.rsvp-section .eyebrow{font-size:.75rem;letter-spacing:.25em;text-transform:uppercase;color:var(--copper);display:block;margin-bottom:16px}
.rsvp-section h2{font-family:'Cormorant Garamond',Georgia,serif;font-size:clamp(2.2rem,5vw,3.8rem);font-weight:300;color:var(--cream);margin-bottom:16px;letter-spacing:.03em}
.rsvp-section p{color:var(--muted);margin-bottom:44px;max-width:420px;margin-left:auto;margin-right:auto;font-size:.9rem;line-height:1.9}
.rsvp-btn{display:inline-block;padding:16px 56px;border:1px solid var(--cream);color:var(--cream);font-size:.65rem;letter-spacing:.3em;text-transform:uppercase;text-decoration:none;font-family:'Jost',sans-serif;transition:background .25s,color .25s}
.rsvp-btn:hover{background:var(--cream);color:var(--black)}

/* ---- FOOTER ---- */
footer{text-align:center;padding:70px 24px;border-top:1px solid rgba(255,255,255,.08)}
footer .names{font-family:'Cormorant Garamond',Georgia,serif;font-size:2.4rem;font-weight:300;color:var(--cream);letter-spacing:.05em;margin-bottom:8px}
footer .date{font-size:.6rem;letter-spacing:.28em;text-transform:uppercase;color:var(--muted)}
footer .credit{font-size:1.1rem;font-weight:500;font-weight:500;color:rgba(255,255,255,.12);margin-top:24px}

/* ---- DIVIDER ---- */
.divider{width:100%;height:1px;background:rgba(255,255,255,.07);margin:0}

/* ---- LIGHTBOX ---- */
#lightbox{position:fixed;inset:0;background:rgba(0,0,0,.96);z-index:999;display:none;align-items:center;justify-content:center;padding:20px}
#lightbox.show{display:flex}
#lightbox img{max-height:85vh;max-width:90vw;border-radius:2px;object-fit:contain}
#lightbox button{position:absolute;background:rgba(255,255,255,.08);border:none;color:var(--cream);border-radius:0;cursor:pointer;font-family:'Jost',sans-serif}
#lightbox .nav-btn{width:52px;height:52px;font-size:1.8rem;top:50%;transform:translateY(-50%)}
#lightbox .prev{left:20px}
#lightbox .next{right:20px}
#lightbox .close-lb{top:16px;right:16px;width:40px;height:40px;font-size:1.1rem}
#lightbox .count{position:absolute;bottom:20px;color:rgba(255,255,255,.3);font-size:.75rem;letter-spacing:.1em}
</style>
</head>
<body>

<cfif structKeyExists(site,"is_preview") AND site.is_preview>
<div style="position:fixed;top:0;left:0;right:0;z-index:9999;background:#111;color:#fff;display:flex;align-items:center;justify-content:space-between;padding:12px 24px;font-family:Arial,sans-serif;font-size:13px;border-bottom:1px solid #333;gap:12px">
  <cfif isNumeric(url.siteId) AND url.siteId GT 0>
  <span style="opacity:.75">&#128065; Previewing your wedding site</span>
  <button onclick="window.close()" style="padding:8px 20px;background:#333;color:#fff;border:none;border-radius:4px;font-weight:600;cursor:pointer;font-size:13px">&times; Close Preview</button>
  <cfelse>
  <span style="opacity:.75">&#128065; Template preview &mdash; sample data shown</span>
  <a href="/members/wedding-site-edit.cfm?template=copper_rose" style="padding:8px 20px;background:#C87A50;color:#fff;border-radius:4px;font-weight:600;text-decoration:none;white-space:nowrap">Use This Template &rarr;</a>
  </cfif>
</div>
<div style="height:48px"></div>
</cfif>

<!--- HERO --->
<div class="hero">
  <div class="hero-img">
    <cfif len(heroImg)>
    <img src="<cfoutput>#HTMLEditFormat(heroImg)#</cfoutput>" alt="Wedding">
    <cfelse>
    <img src="/assets/copper-rose.jpg" alt="Copper roses" onerror="this.style.display='none'">
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

<!--- OUR STORY --->
<cfif len(trim(site.story))>
<div class="divider"></div>
<section class="section" id="our_story">
  <div class="section-title">
    <span class="eyebrow">The Beginning</span>
    <h2>Our Story</h2>
    <div class="copper-rule"></div>
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
      <div class="copper-rule"></div>
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
<section id="photos" style="padding:80px 48px;max-width:1100px;margin:0 auto">
  <div class="section-title">
    <span class="eyebrow">Memories Together</span>
    <h2>Photos</h2>
    <div class="copper-rule"></div>
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
      <div class="copper-rule"></div>
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
    <div class="copper-rule"></div>
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
      <div class="copper-rule"></div>
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
    <div class="copper-rule"></div>
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
    <img src="/assets/copper-rose.jpg" alt="" onerror="this.style.display='none'">
    </cfif>
  </div>
  <div class="content">
    <span class="eyebrow">You&rsquo;re Invited</span>
    <h2>Will You Join Us?</h2>
    <p>Please let us know if you&rsquo;ll be celebrating with us.</p>
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
var secs=document.querySelectorAll('section[id],div[id]');
var navLinks=document.querySelectorAll('.hero-nav a');
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
