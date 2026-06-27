<!---
  classic_gold.cfm — requires "site" struct set before cfinclude
  Keys: couple_name_1, couple_name_2, wedding_date, venue_name, venue_address,
        story, dress_code, travel_info, things_to_do, scripture,
        hero_image_url, gallery_images_json, faq_json, slug
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

<cfset galleryList = []>
<cfif len(trim(site.gallery_images_json))>
<cftry><cfset galleryList = deserializeJSON(site.gallery_images_json)><cfcatch><cfset galleryList = []></cfcatch></cftry>
</cfif>

<cfset faqList = []>
<cfif len(trim(site.faq_json))>
<cftry><cfset faqList = deserializeJSON(site.faq_json)><cfcatch><cfset faqList = []></cfcatch></cftry>
</cfif>

<cfset travelLinks = []>
<cftry><cfif structKeyExists(site,"travel_links_json") && len(trim(site.travel_links_json))><cfset travelLinks = deserializeJSON(site.travel_links_json)></cfif><cfcatch type="any"><cfset travelLinks = []></cfcatch></cftry>
<cfset thingsLinks = []>
<cftry><cfif structKeyExists(site,"things_links_json") && len(trim(site.things_links_json))><cfset thingsLinks = deserializeJSON(site.things_links_json)></cfif><cfcatch type="any"><cfset thingsLinks = []></cfcatch></cftry>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title><cfoutput>#HTMLEditFormat(site.couple_name_1)# &amp; #HTMLEditFormat(site.couple_name_2)#</cfoutput> &mdash; Classic Gold</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<style>
*{margin:0;padding:0;box-sizing:border-box}
body{background:#FDFAF5;color:#2C2C2C;font-family:'Palatino Linotype',Georgia,serif;line-height:1.6}
.hero{min-height:50vh;display:flex;flex-direction:column;align-items:center;justify-content:center;text-align:center;position:relative;overflow:hidden;padding:80px 24px 60px}
.hero-orn{display:flex;align-items:center;justify-content:center;gap:12px;margin-bottom:20px}
.hero-orn .line{height:1px;width:80px;background:#D4AF37}
.hero-orn span{color:#B8860B;font-size:1rem}
.hero h1{font-family:Georgia,'Times New Roman',serif;font-size:clamp(2.8rem,9vw,6rem);font-weight:700;line-height:1.05;letter-spacing:.03em;text-transform:uppercase;margin-bottom:28px}
.hero h1 .amp{color:#B8860B;font-size:.5em;letter-spacing:.4em}
.hero p.sub{font-size:.85rem;letter-spacing:.25em;text-transform:uppercase;margin-bottom:8px;color:#2C2C2C}
.hero p.venue{color:#B8860B;font-size:.8rem;letter-spacing:.2em;text-transform:uppercase}
.hero p.intro{font-size:clamp(1rem,2.5vw,1.4rem);color:#B8860B;font-style:italic;margin-bottom:16px;letter-spacing:.05em}
nav{position:sticky;top:0;z-index:100;background:rgba(253,250,245,.97);border-bottom:1px solid rgba(212,175,55,.2);backdrop-filter:blur(8px)}
nav .inner{max-width:960px;margin:0 auto;display:flex;align-items:center;justify-content:center;overflow-x:auto}
nav a{padding:18px 20px;font-size:.78rem;letter-spacing:.1em;color:#2C2C2C;text-decoration:none;white-space:nowrap;cursor:pointer;border-bottom:2px solid transparent;transition:color .2s}
nav a:hover{color:#B8860B}
nav a.active{color:#B8860B;border-bottom-color:#B8860B;font-weight:600}
.section{padding:80px 24px 60px;max-width:860px;margin:0 auto}
.section-title{text-align:center;margin-bottom:44px}
.section-title .orn{display:flex;align-items:center;justify-content:center;gap:16px}
.section-title .line{height:1px;width:60px;background:#D4AF37}
.section-title p{color:#B8860B;letter-spacing:.3em;font-size:.7rem;text-transform:uppercase}
.divider{text-align:center;padding:20px 0;color:#D4AF37;font-size:1.1rem;letter-spacing:.6em;opacity:.7}
.detail{display:flex;justify-content:center;align-items:stretch;flex-wrap:wrap;text-align:center;margin-bottom:60px}
.detail .col{padding:0 48px;border-right:1px solid rgba(212,175,55,.25)}
.detail .col:last-child{border-right:none}
.detail .label{color:#B8860B;font-size:.7rem;letter-spacing:.3em;text-transform:uppercase;margin-bottom:10px}
.detail .val{font-family:Georgia,serif;font-size:clamp(1.4rem,4vw,2rem);font-weight:700;text-transform:uppercase;letter-spacing:.04em}
.detail .sub{font-family:Georgia,serif;font-size:1.1rem;letter-spacing:.1em;opacity:.6}
.monogram{display:inline-flex;align-items:center;justify-content:center;width:80px;height:80px;border-radius:50%;border:2px solid #D4AF37;font-family:Georgia,serif;font-size:1.8rem;color:#B8860B}
.story{line-height:1.95;font-size:1.05rem;text-align:center;opacity:.85;white-space:pre-wrap;max-width:640px;margin:0 auto}
.photos{display:grid;grid-template-columns:repeat(auto-fill,minmax(200px,1fr));gap:10px}
.photos .photo{cursor:pointer;border-radius:4px;overflow:hidden;aspect-ratio:1;background:#F5EDD8}
.photos img{width:100%;height:100%;object-fit:cover;transition:transform .3s}
.photos .photo:hover img{transform:scale(1.05)}
.faq-list{max-width:640px;margin:0 auto;display:flex;flex-direction:column;gap:28px}
.faq-item{border-bottom:1px solid rgba(212,175,55,.2);padding-bottom:24px}
.faq-item .q{font-weight:700;font-size:1rem;margin-bottom:8px;font-family:Georgia,serif}
.faq-item .a{opacity:.75;line-height:1.7}
.text-content{line-height:1.9;font-size:1.05rem;opacity:.85;white-space:pre-wrap;max-width:640px;margin:0 auto;text-align:center}
.rsvp{text-align:center;padding:80px 24px;background:#F5EDD8}
.rsvp .label{font-size:.72rem;letter-spacing:.35em;text-transform:uppercase;color:#B8860B;margin-bottom:16px}
.rsvp h2{font-family:Georgia,serif;font-size:clamp(2rem,5vw,3rem);font-weight:400;margin-bottom:16px}
.rsvp p{opacity:.6;margin-bottom:32px;max-width:400px;margin-left:auto;margin-right:auto;line-height:1.7}
.rsvp .btn{display:inline-block;padding:16px 48px;background:#B8860B;color:#fff;font-size:.9rem;letter-spacing:.15em;text-transform:uppercase;border-radius:4px;font-weight:600;text-decoration:none}
footer{text-align:center;padding:48px 24px;border-top:1px solid rgba(212,175,55,.25);background:#F5EDD8}
footer .orn{display:flex;align-items:center;justify-content:center;gap:16px;margin-bottom:12px}
footer .line{height:1px;width:50px;background:#D4AF37}
footer span{color:#B8860B;font-size:1rem}
footer .names{font-family:Georgia,serif;font-size:1.5rem;color:#B8860B;font-style:italic}
footer .date{font-size:.75rem;opacity:.5;letter-spacing:.2em;text-transform:uppercase;margin-top:8px}
footer .credit{font-size:1.1rem;font-weight:500;font-weight:500;opacity:.35;margin-top:16px}
#lightbox{position:fixed;inset:0;background:rgba(0,0,0,.92);z-index:999;display:none;align-items:center;justify-content:center;padding:20px}
#lightbox.show{display:flex}
#lightbox img{max-height:85vh;max-width:90vw;border-radius:8px;object-fit:contain}
#lightbox button{position:absolute;background:rgba(255,255,255,.15);border:none;color:#fff;border-radius:50%;cursor:pointer}
#lightbox .nav-btn{width:48px;height:48px;font-size:2rem;top:50%;transform:translateY(-50%)}
#lightbox .prev{left:20px}
#lightbox .next{right:20px}
#lightbox .close{top:16px;right:16px;width:40px;height:40px;font-size:1.2rem}
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
  <a href="/members/wedding-site-edit.cfm?template=classic_gold" style="padding:8px 20px;background:#B8860B;color:#fff;border-radius:6px;font-weight:600;text-decoration:none;white-space:nowrap">Use This Template &rarr;</a>
  </cfif>
</div>
<div style="height:48px"></div>
</cfif>

  <p class="intro">The Wedding of</p>
  <div class="hero-orn"><div class="line"></div><span>&#10022;</span><div class="line"></div></div>
  <h1><cfoutput>#HTMLEditFormat(site.couple_name_1)#</cfoutput><br><span class="amp">&amp;</span><br><cfoutput>#HTMLEditFormat(site.couple_name_2)#</cfoutput></h1>
  <cfif len(weddingDateFull)><p class="sub"><cfoutput>#weddingDateFull#</cfoutput></p></cfif>
  <cfif len(trim(site.venue_address))><p class="venue"><cfoutput>#HTMLEditFormat(site.venue_address)#</cfoutput></p></cfif>
</div>

<nav>
  <div class="inner">
    <a href="#home_detail">Details</a>
    <cfif len(trim(site.story))><a href="#our_story">Our Story</a></cfif>
    <cfif arrayLen(galleryList)><a href="#photos">Photos</a></cfif>
    <cfif arrayLen(faqList)><a href="#q_and_a">Q + A</a></cfif>
    <cfif len(trim(site.dress_code))><a href="#dress_code">Dress Code</a></cfif>
    <cfif len(trim(site.travel_info)) OR (structKeyExists(site,"travel_links_json") AND len(trim(site.travel_links_json)))><a href="#travel">Travel</a></cfif>
    <cfif len(trim(site.things_to_do)) OR arrayLen(thingsLinks)><a href="#things_to_do">Things to Do</a></cfif>
    <cfif structKeyExists(site,"registry_url") AND len(trim(site.registry_url))><a href="<cfoutput>#HTMLEditFormat(trim(site.registry_url))#</cfoutput>" target="_blank" rel="noopener">Registry</a></cfif><a href="#rsvp">RSVP</a>
  </div>
</nav>

<section class="section" id="home_detail" style="text-align:center">
  <div class="detail">
    <cfif len(weddingDayMonth)>
    <div class="col">
      <p class="label">Wedding Day</p>
      <p class="val"><cfoutput>#weddingDayMonth#</cfoutput></p>
      <p class="sub"><cfoutput>#weddingYear#</cfoutput></p>
    </div>
    </cfif>
    <cfif len(trim(site.venue_name))>
    <div class="col">
      <p class="label">Venue</p>
      <p class="val"><cfoutput>#HTMLEditFormat(site.venue_name)#</cfoutput></p>
      <cfif len(trim(site.venue_address))><p class="sub" style="font-size:.85rem;opacity:.6;margin-top:4px"><cfoutput>#HTMLEditFormat(site.venue_address)#</cfoutput></p></cfif>
    </div>
    </cfif>
    <cfif len(trim(site.reception_venue_name))>
    <div class="col">
      <p class="label">Reception</p>
      <p class="val"><cfoutput>#HTMLEditFormat(site.reception_venue_name)#</cfoutput></p>
      <cfif len(trim(site.reception_venue_address))><p class="sub" style="font-size:.85rem;opacity:.6;margin-top:4px"><cfoutput>#HTMLEditFormat(site.reception_venue_address)#</cfoutput></p></cfif>
    </div>
    </cfif>
  </div>
  <div class="monogram"><cfoutput>#HTMLEditFormat(monogram)#</cfoutput></div>
</section>

<div class="divider">&#10022; &#10022; &#10022;</div>

<cfif len(trim(site.story))>
<section class="section" id="our_story">
  <div class="section-title"><div class="orn"><div class="line"></div><p>Our Story</p><div class="line"></div></div></div>
  <p class="story"><cfoutput>#HTMLEditFormat(site.story)#</cfoutput></p>
</section>
<div class="divider">&#10022; &#10022; &#10022;</div>
</cfif>

<cfif arrayLen(galleryList)>
<section class="section" id="photos">
  <div class="section-title"><div class="orn"><div class="line"></div><p>Photos</p><div class="line"></div></div></div>
  <div class="photos" id="gallery"></div>
</section>
<div class="divider">&#10022; &#10022; &#10022;</div>
</cfif>

<cfif arrayLen(faqList)>
<section class="section" id="q_and_a">
  <div class="section-title"><div class="orn"><div class="line"></div><p>Q + A</p><div class="line"></div></div></div>
  <div class="faq-list">
    <cfloop array="#faqList#" index="faqItem">
    <div class="faq-item">
      <p class="q"><cfoutput>#HTMLEditFormat(faqItem.question)#</cfoutput></p>
      <p class="a"><cfoutput>#HTMLEditFormat(faqItem.answer)#</cfoutput></p>
    </div>
    </cfloop>
  </div>
</section>
<div class="divider">&#10022; &#10022; &#10022;</div>
</cfif>

<cfif len(trim(site.dress_code))>
<section class="section" id="dress_code" style="text-align:center">
  <div class="section-title"><div class="orn"><div class="line"></div><p>Dress Code</p><div class="line"></div></div></div>
  <p class="text-content"><cfoutput>#HTMLEditFormat(site.dress_code)#</cfoutput></p>
</section>
<div class="divider">&#10022; &#10022; &#10022;</div>
</cfif>

<cfif len(trim(site.travel_info)) OR (structKeyExists(site,"travel_links_json") AND len(trim(site.travel_links_json)))>
<section class="section" id="travel" style="text-align:center">
  <div class="section-title"><div class="orn"><div class="line"></div><p>Travel</p><div class="line"></div></div></div>
  <p class="text-content"><cfoutput>#HTMLEditFormat(site.travel_info)#</cfoutput></p>
  <cfif arrayLen(travelLinks)>
  <div style="display:flex;flex-wrap:wrap;gap:12px;margin-top:24px">
  <cfloop array="#travelLinks#" item="tl">
  <cfoutput><a href="#HTMLEditFormat(tl.url)#" target="_blank" rel="noopener" class="link-btn">#len(trim(tl.label)) ? HTMLEditFormat(tl.label) : "View Link"# &rarr;</a></cfoutput>
  </cfloop>
  </div>
  </cfif>
</section>
<div class="divider">&#10022; &#10022; &#10022;</div>
</cfif>

<cfif len(trim(site.things_to_do)) OR arrayLen(thingsLinks)>
<section class="section" id="things_to_do" style="text-align:center">
  <div class="section-title"><div class="orn"><div class="line"></div><p>Things to Do</p><div class="line"></div></div></div>
  <p class="text-content"><cfoutput>#HTMLEditFormat(site.things_to_do)#</cfoutput></p>
  <cfif arrayLen(thingsLinks)>
  <div style="display:flex;flex-wrap:wrap;gap:12px;margin-top:24px">
  <cfloop array="#thingsLinks#" item="tl">
  <cfoutput><a href="#HTMLEditFormat(tl.url)#" target="_blank" rel="noopener" class="link-btn">#len(trim(tl.label)) ? HTMLEditFormat(tl.label) : "Explore"# &rarr;</a></cfoutput>
  </cfloop>
  </div>
  </cfif>
</section>
<div class="divider">&#10022; &#10022; &#10022;</div>
</cfif>

<section class="rsvp" id="rsvp">
  <p class="label">You're Invited</p>
  <h2>Will You Join Us?</h2>
  <p>Please let us know if you'll be celebrating with us on our special day.</p>
  <cfif len(trim(site.slug)) AND site.slug NEQ "preview">
  <a href="/rsvp.cfm?slug=<cfoutput>#URLEncodedFormat(site.slug)#</cfoutput>" class="btn">RSVP Now</a>
  <cfelse>
  <span class="btn">RSVP Now</span>
  </cfif>
</section>

<footer>
  <div class="orn"><div class="line"></div><span>&#10022;</span><div class="line"></div></div>
  <p class="names"><cfoutput>#HTMLEditFormat(site.couple_name_1)# &amp; #HTMLEditFormat(site.couple_name_2)#</cfoutput></p>
  <cfif len(weddingDateFull)><p class="date"><cfoutput>#weddingDateFull#</cfoutput></p></cfif>
  <p class="credit">digitalweddings.love <span style="color:#e03">&#9829;</span></p>
</footer>

<div id="lightbox">
  <button class="close" onclick="closeLightbox()">&#10005;</button>
  <button class="nav-btn prev" onclick="navLightbox(-1)">&#8249;</button>
  <img id="lightbox-img" src="" alt="">
  <button class="nav-btn next" onclick="navLightbox(1)">&#8250;</button>
  <p class="count" id="lightbox-count"></p>
</div>

<script>
var galleryImages=[<cfloop array="#galleryList#" index="gUrl"><cfoutput>"#JSStringFormat(gUrl)#",</cfoutput></cfloop>];
var currentIdx=0;
var galleryEl=document.getElementById("gallery");
if(galleryEl&&galleryImages.length){
  galleryImages.forEach(function(url,i){
    var div=document.createElement("div");
    div.className="photo";
    div.innerHTML='<img src="'+url+'" alt="" onclick="openLightbox('+i+')">';
    galleryEl.appendChild(div);
  });
}
function openLightbox(i){currentIdx=i;showLightbox();document.getElementById("lightbox").classList.add("show")}
function closeLightbox(){document.getElementById("lightbox").classList.remove("show")}
function navLightbox(dir){currentIdx=Math.max(0,Math.min(galleryImages.length-1,currentIdx+dir));showLightbox()}
function showLightbox(){
  document.getElementById("lightbox-img").src=galleryImages[currentIdx];
  document.getElementById("lightbox-count").textContent=(currentIdx+1)+" / "+galleryImages.length;
}
document.getElementById("lightbox").addEventListener("click",function(e){if(e.target===this)closeLightbox()});
var navLinks=document.querySelectorAll("nav a");
window.addEventListener("scroll",function(){
  var scrollY=window.scrollY+100;
  navLinks.forEach(function(link){
    var id=link.getAttribute("href").replace("##","").replace("#","");
    var el=document.getElementById(id);
    if(el&&el.offsetTop<=scrollY&&el.offsetTop+el.offsetHeight>scrollY){
      navLinks.forEach(function(l){l.classList.remove("active")});
      link.classList.add("active");
    }
  });
},{passive:true});
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
