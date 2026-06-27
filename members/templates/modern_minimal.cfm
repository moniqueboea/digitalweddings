<!---
  modern_minimal.cfm — requires "site" struct set before cfinclude
--->
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
<title><cfoutput>#HTMLEditFormat(site.couple_name_1)# &amp; #HTMLEditFormat(site.couple_name_2)#</cfoutput> &mdash; Modern Minimal</title>
<style>
*{margin:0;padding:0;box-sizing:border-box}
body{background:#FFFFFF;color:#111111;font-family:'Helvetica Neue',Arial,sans-serif;line-height:1.6}
.hero{min-height:50vh;display:grid;grid-template-columns:1fr 1fr;overflow:hidden}
.hero .left{background:#111;display:flex;align-items:center;justify-content:center;padding:60px}
.hero .left .content{max-width:480px}
.hero .left .label{color:#C4A265;letter-spacing:.4em;font-size:.65rem;text-transform:uppercase;margin-bottom:32px}
.hero .left h1{font-family:'Helvetica Neue',Arial,sans-serif;font-size:clamp(2.5rem,6vw,5rem);color:#fff;font-weight:300;line-height:1.1;letter-spacing:-.02em;margin-bottom:40px}
.hero .left h1 .amp{color:#C4A265}
.hero .left .date{color:rgba(255,255,255,.5);font-size:.8rem;letter-spacing:.25em;text-transform:uppercase}
.hero .right{background:#C4A265;display:flex;align-items:center;justify-content:center;padding:60px;color:#111}
.hero .right .label{font-size:.65rem;letter-spacing:.4em;text-transform:uppercase;margin-bottom:24px;opacity:.7}
.hero .right .label2{font-size:.65rem;letter-spacing:.3em;text-transform:uppercase;opacity:.6;margin-bottom:6px}
.hero .right .val{font-family:'Helvetica Neue',Arial,sans-serif;font-size:1.5rem;font-weight:300}
.hero .right .sub{opacity:.7;font-size:.85rem;margin-top:4px}
.hero .right .group{margin-bottom:32px}
nav{position:sticky;top:0;z-index:100;background:rgba(255,255,255,.97);border-bottom:1px solid #E0E0E0;backdrop-filter:blur(8px)}
nav .inner{max-width:960px;margin:0 auto;display:flex;align-items:center;justify-content:center;overflow-x:auto}
nav a{padding:18px 20px;font-size:.78rem;letter-spacing:.1em;color:#111;text-decoration:none;white-space:nowrap;cursor:pointer;border-bottom:2px solid transparent;transition:color .2s}
nav a:hover{color:#C4A265}
nav a.active{color:#C4A265;border-bottom-color:#C4A265;font-weight:600}
.section{padding:80px 60px;max-width:860px;margin:0 auto}
.section.alt{background:#F8F8F8;max-width:100%}
.section.alt .inner{max-width:860px;margin:0 auto}
.section-title{margin-bottom:48px}
.section-title p{color:#C4A265;letter-spacing:.4em;font-size:.65rem;text-transform:uppercase;margin-bottom:12px}
.section-title .line{height:2px;width:40px;background:#C4A265}
.detail{display:grid;grid-template-columns:1fr 1fr 1fr;gap:48px}
.detail .label{color:#C4A265;font-size:.65rem;letter-spacing:.4em;text-transform:uppercase;margin-bottom:12px}
.detail .uline{height:2px;width:30px;background:#C4A265;margin-bottom:16px}
.detail .val{font-weight:300;font-size:1.1rem;line-height:1.5}
.detail .sub{opacity:.55;font-size:.85rem;margin-top:6px}
.detail .amp{color:#C4A265;font-size:.75rem;margin:4px 0}
.story{line-height:1.9;font-size:1rem;opacity:.8;white-space:pre-wrap;max-width:580px}
.photos{display:grid;grid-template-columns:repeat(auto-fill,minmax(180px,1fr));gap:4px}
.photos .photo{cursor:pointer;aspect-ratio:1;overflow:hidden}
.photos img{width:100%;height:100%;object-fit:cover;filter:grayscale(20%);transition:transform .4s,filter .4s}
.photos .photo:hover img{transform:scale(1.06);filter:grayscale(0%)}
.faq-list{display:flex;flex-direction:column}
.faq-item{display:grid;grid-template-columns:1fr 2fr;gap:32px;padding:28px 0;border-bottom:1px solid #E0E0E0}
.faq-item .q{font-weight:600;font-size:.95rem}
.faq-item .a{opacity:.7;line-height:1.7}
.text-content{line-height:1.9;font-size:1rem;opacity:.8;white-space:pre-wrap;max-width:580px}
.rsvp{text-align:center;padding:80px 24px;background:#F8F8F8}
.rsvp .label{font-size:.72rem;letter-spacing:.35em;text-transform:uppercase;color:#C4A265;margin-bottom:16px}
.rsvp h2{font-family:'Helvetica Neue',Arial,sans-serif;font-size:clamp(2rem,5vw,3rem);font-weight:400;margin-bottom:16px}
.rsvp p{opacity:.6;margin-bottom:32px;max-width:400px;margin-left:auto;margin-right:auto;line-height:1.7}
.rsvp .btn{display:inline-block;padding:16px 48px;background:#C4A265;color:#fff;font-size:.9rem;letter-spacing:.15em;text-transform:uppercase;border-radius:4px;font-weight:600}
footer{padding:48px 60px;background:#111;color:#fff;display:flex;justify-content:space-between;align-items:center;flex-wrap:wrap;gap:16px}
footer .names{font-family:'Helvetica Neue',Arial,sans-serif;font-size:1.3rem;font-weight:300}
footer .names .amp{color:#C4A265}
footer .date{font-size:.7rem;opacity:.35;letter-spacing:.2em;text-transform:uppercase;margin-top:4px}
footer .credit{font-size:1.1rem;font-weight:500;font-weight:500;opacity:.25}
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
  <a href="/members/wedding-site-edit.cfm?template=modern_minimal" style="padding:8px 20px;background:#B8860B;color:#fff;border-radius:6px;font-weight:600;text-decoration:none;white-space:nowrap">Use This Template &rarr;</a>
  </cfif>
</div>
<div style="height:48px"></div>
</cfif>

  <div class="left">
    <div class="content">
      <p class="label">The Wedding of</p>
      <h1><cfoutput>#HTMLEditFormat(site.couple_name_1)#</cfoutput><br><span class="amp">&amp;</span><br><cfoutput>#HTMLEditFormat(site.couple_name_2)#</cfoutput></h1>
      <cfif len(weddingDateFull)><p class="date"><cfoutput>#weddingDateFull#</cfoutput></p></cfif>
    </div>
  </div>
  <div class="right">
    <div>
      <p class="label">Details</p>
      <cfif len(trim(site.venue_name))>
      <div class="group">
        <p class="label2">Ceremony</p>
        <p class="val"><cfoutput>#HTMLEditFormat(site.venue_name)#</cfoutput></p>
        <cfif len(trim(site.venue_address))><p class="sub"><cfoutput>#HTMLEditFormat(site.venue_address)#</cfoutput></p></cfif>
      </div>
      </cfif>
      <cfif len(trim(site.reception_venue_name))>
      <div class="group">
        <p class="label2">Reception</p>
        <p class="val"><cfoutput>#HTMLEditFormat(site.reception_venue_name)#</cfoutput></p>
        <cfif len(trim(site.reception_venue_address))><p class="sub"><cfoutput>#HTMLEditFormat(site.reception_venue_address)#</cfoutput></p></cfif>
      </div>
      </cfif>
      <cfif len(weddingDateFull)>
      <div>
        <p class="label2">Date</p>
        <p class="val"><cfoutput>#weddingDateFull#</cfoutput></p>
      </div>
      </cfif>
    </div>
  </div>
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

<section class="section" id="home_detail">
  <div class="detail">
    <cfif len(trim(site.venue_name))>
    <div>
      <p class="label">Ceremony</p>
      <div class="uline"></div>
      <p class="val"><cfoutput>#HTMLEditFormat(site.venue_name)#</cfoutput></p>
      <cfif len(trim(site.venue_address))><p class="sub"><cfoutput>#HTMLEditFormat(site.venue_address)#</cfoutput></p></cfif>
    </div>
    </cfif>
    <cfif len(trim(site.reception_venue_name))>
    <div>
      <p class="label">Reception</p>
      <div class="uline"></div>
      <p class="val"><cfoutput>#HTMLEditFormat(site.reception_venue_name)#</cfoutput></p>
      <cfif len(trim(site.reception_venue_address))><p class="sub"><cfoutput>#HTMLEditFormat(site.reception_venue_address)#</cfoutput></p></cfif>
    </div>
    </cfif>
    <cfif len(weddingDayMonth)>
    <div>
      <p class="label">Date</p>
      <div class="uline"></div>
      <p class="val"><cfoutput>#weddingDayMonth#</cfoutput></p>
      <p class="sub"><cfoutput>#weddingYear#</cfoutput></p>
    </div>
    </cfif>
    <div>
      <p class="label">Couple</p>
      <div class="uline"></div>
      <p class="val"><cfoutput>#HTMLEditFormat(site.couple_name_1)#</cfoutput></p>
      <p class="amp">&amp;</p>
      <p class="val"><cfoutput>#HTMLEditFormat(site.couple_name_2)#</cfoutput></p>
    </div>
  </div>
</section>

<cfif len(trim(site.story))>
<section class="section alt" id="our_story">
  <div class="inner">
    <div class="section-title"><p>Our Story</p><div class="line"></div></div>
    <p class="story"><cfoutput>#HTMLEditFormat(site.story)#</cfoutput></p>
  </div>
</section>
</cfif>

<cfif arrayLen(galleryList)>
<section class="section" id="photos">
  <div class="section-title"><p>Photos</p><div class="line"></div></div>
  <div class="photos" id="gallery"></div>
</section>
</cfif>

<cfif arrayLen(faqList)>
<section class="section alt" id="q_and_a">
  <div class="inner">
    <div class="section-title"><p>Q + A</p><div class="line"></div></div>
    <div class="faq-list">
      <cfloop array="#faqList#" index="faqItem">
      <div class="faq-item">
        <p class="q"><cfoutput>#HTMLEditFormat(faqItem.question)#</cfoutput></p>
        <p class="a"><cfoutput>#HTMLEditFormat(faqItem.answer)#</cfoutput></p>
      </div>
      </cfloop>
    </div>
  </div>
</section>
</cfif>

<cfif len(trim(site.dress_code))>
<section class="section" id="dress_code">
  <div class="section-title"><p>Dress Code</p><div class="line"></div></div>
  <p class="text-content"><cfoutput>#HTMLEditFormat(site.dress_code)#</cfoutput></p>
</section>
</cfif>

<cfif len(trim(site.travel_info)) OR (structKeyExists(site,"travel_links_json") AND len(trim(site.travel_links_json)))>
<section class="section alt" id="travel">
  <div class="inner">
    <div class="section-title"><p>Travel</p><div class="line"></div></div>
    <p class="text-content"><cfoutput>#HTMLEditFormat(site.travel_info)#</cfoutput></p>
  <cfif arrayLen(travelLinks)>
  <div style="display:flex;flex-wrap:wrap;gap:12px;margin-top:24px">
  <cfloop array="#travelLinks#" item="tl">
  <cfoutput><a href="#HTMLEditFormat(tl.url)#" target="_blank" rel="noopener" class="link-btn">#len(trim(tl.label)) ? HTMLEditFormat(tl.label) : "View Link"# &rarr;</a></cfoutput>
  </cfloop>
  </div>
  </cfif>
  </div>
</section>
</cfif>

<cfif len(trim(site.things_to_do)) OR arrayLen(thingsLinks)>
<section class="section" id="things_to_do">
  <div class="section-title"><p>Things to Do</p><div class="line"></div></div>
  <p class="text-content"><cfoutput>#HTMLEditFormat(site.things_to_do)#</cfoutput></p>
  <cfif arrayLen(thingsLinks)>
  <div style="display:flex;flex-wrap:wrap;gap:12px;margin-top:24px">
  <cfloop array="#thingsLinks#" item="tl">
  <cfoutput><a href="#HTMLEditFormat(tl.url)#" target="_blank" rel="noopener" class="link-btn">#len(trim(tl.label)) ? HTMLEditFormat(tl.label) : "Explore"# &rarr;</a></cfoutput>
  </cfloop>
  </div>
  </cfif>
</section>
</cfif>

<section class="rsvp" id="rsvp">
  <p class="label">You&rsquo;re Invited</p>
  <h2>Will You Join Us?</h2>
  <p>Please let us know if you&rsquo;ll be celebrating with us on our special day.</p>
  <cfif len(trim(site.slug)) AND site.slug NEQ "preview">
  <a href="/rsvp.cfm?slug=<cfoutput>#URLEncodedFormat(site.slug)#</cfoutput>" class="btn">RSVP Now</a>
  <cfelse>
  <span class="btn">RSVP Now</span>
  </cfif>
</section>

<footer>
  <div>
    <p class="names"><cfoutput>#HTMLEditFormat(site.couple_name_1)#</cfoutput> <span class="amp">&amp;</span> <cfoutput>#HTMLEditFormat(site.couple_name_2)#</cfoutput></p>
    <cfif len(weddingDateFull)><p class="date"><cfoutput>#weddingDateFull#</cfoutput></p></cfif>
  </div>
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
if(galleryEl){
  galleryImages.forEach(function(url,i){
    var div=document.createElement("div");
    div.className="photo";
    div.innerHTML='<img src="'+url+'" alt="" onclick="openLightbox('+i+')">';
    galleryEl.appendChild(div);
  });
}
function openLightbox(i){currentIdx=i;showLightbox();document.getElementById("lightbox").classList.add("show");}
function closeLightbox(){document.getElementById("lightbox").classList.remove("show");}
function navLightbox(dir){currentIdx=Math.max(0,Math.min(galleryImages.length-1,currentIdx+dir));showLightbox();}
function showLightbox(){
  document.getElementById("lightbox-img").src=galleryImages[currentIdx];
  document.getElementById("lightbox-count").textContent=(currentIdx+1)+" / "+galleryImages.length;
}
document.getElementById("lightbox").addEventListener("click",function(e){if(e.target===this)closeLightbox();});
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
