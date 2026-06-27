<!---
  pride_modern.cfm — requires "site" struct set before cfinclude
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
<title><cfoutput>#HTMLEditFormat(site.couple_name_1)# &amp; #HTMLEditFormat(site.couple_name_2)#</cfoutput> &mdash; Pride Modern</title>
<style>
*{margin:0;padding:0;box-sizing:border-box}
body{background:#fff;color:#1A1A2E;font-family:'Helvetica Neue',Arial,sans-serif;line-height:1.6}
.hero{min-height:70vh;display:flex;flex-direction:column;align-items:center;justify-content:center;text-align:center;padding:100px 24px 80px;background:linear-gradient(135deg,#6B3FA0 0%,#9B27AF 35%,#E040FB 65%,#FF6B9D 100%);position:relative;overflow:hidden}
.hero::before{content:'';position:absolute;inset:0;background:radial-gradient(circle at 30% 70%,rgba(255,255,255,.08),transparent 60%)}
.rainbow-bar{height:6px;background:linear-gradient(to right,#FF0000,#FF7F00,#FFFF00,#00FF00,#0000FF,#8B00FF);width:100%;position:absolute;top:0;left:0}
.hero p.eyebrow{color:rgba(255,255,255,.85);font-size:.7rem;letter-spacing:.5em;text-transform:uppercase;margin-bottom:20px}
.hero h1{font-family:'Helvetica Neue',Arial,sans-serif;font-size:clamp(3rem,9vw,6rem);font-weight:900;color:#fff;line-height:1;letter-spacing:-.03em;margin-bottom:8px}
.hero p.and{color:rgba(255,255,255,.7);letter-spacing:.4em;font-size:.85rem;text-transform:uppercase;margin:12px 0}
.hero .divider{width:60px;height:3px;background:rgba(255,255,255,.4);margin:28px auto;border-radius:3px}
.hero p.date{color:rgba(255,255,255,.9);font-size:.85rem;letter-spacing:.2em;text-transform:uppercase}
.hero p.venue{color:rgba(255,255,255,.6);font-size:.78rem;letter-spacing:.12em;text-transform:uppercase;margin-top:8px}
nav{position:sticky;top:0;z-index:100;background:rgba(255,255,255,.97);border-bottom:4px solid transparent;border-image:linear-gradient(to right,#FF0000,#FF7F00,#FFFF00,#00CC00,#0000FF,#8B00FF) 1;backdrop-filter:blur(8px)}
nav .inner{max-width:960px;margin:0 auto;display:flex;align-items:center;justify-content:center;overflow-x:auto}
nav a{padding:18px 20px;font-size:.78rem;letter-spacing:.08em;color:#1A1A2E;text-decoration:none;white-space:nowrap;cursor:pointer;border-bottom:3px solid transparent;transition:color .2s}
nav a:hover{color:#6B3FA0}
nav a.active{color:#6B3FA0;border-bottom:3px solid;border-image:linear-gradient(to right,#FF0000,#FF7F00,#FFFF00,#00CC00,#0000FF,#8B00FF) 1;font-weight:700}
.rainbow-divider{height:5px;background:linear-gradient(to right,#FF0000,#FF7F00,#FFFF00,#00CC00,#0000FF,#8B00FF);border-radius:3px;margin:0 auto 48px;width:120px}
.section{padding:80px 24px 60px;max-width:860px;margin:0 auto}
.section.alt{background:#F8F4FF;max-width:100%}
.section.alt .inner{max-width:860px;margin:0 auto;padding:80px 24px 60px}
.section-title{text-align:center;margin-bottom:16px}
.section-title p{background:linear-gradient(to right,#FF0000,#FF7F00,#FFFF00,#00CC00,#0000FF,#8B00FF);-webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text;letter-spacing:.35em;font-size:.75rem;text-transform:uppercase;font-weight:900;margin-bottom:4px}
.detail{display:flex;justify-content:center;flex-wrap:wrap;gap:32px;text-align:center;margin-bottom:48px}
.detail .col{background:#fff;border-radius:16px;padding:32px 40px;border-top:4px solid transparent;border-image:linear-gradient(to right,#FF0000,#FF7F00,#FFFF00,#00CC00,#0000FF,#8B00FF) 1;box-shadow:0 4px 24px rgba(107,63,160,.1);min-width:160px}
.detail .label{background:linear-gradient(to right,#6B3FA0,#E040FB);-webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text;font-size:.65rem;letter-spacing:.3em;text-transform:uppercase;margin-bottom:10px;font-weight:700}
.detail .val{font-size:1.4rem;font-weight:700;color:#1A1A2E}
.detail .sub{color:#888;font-size:.85rem;margin-top:4px}
.monogram{display:inline-flex;align-items:center;justify-content:center;width:80px;height:80px;border-radius:50%;background:linear-gradient(135deg,#FF0000,#FF7F00,#FFFF00,#00CC00,#0000FF,#8B00FF);font-size:1.8rem;color:#fff;font-weight:900;margin-top:24px}
.story{line-height:2;font-size:1.05rem;opacity:.85;white-space:pre-wrap;max-width:680px;margin:0 auto;text-align:center}
.photos{display:grid;grid-template-columns:repeat(auto-fill,minmax(200px,1fr));gap:12px}
.photos .photo{cursor:pointer;aspect-ratio:1;overflow:hidden;border-radius:12px}
.photos img{width:100%;height:100%;object-fit:cover;transition:transform .3s}
.photos .photo:hover img{transform:scale(1.06)}
.faq-list{max-width:680px;margin:0 auto;display:flex;flex-direction:column;gap:16px}
.faq-item{background:#fff;border-radius:12px;padding:24px 28px;border-left:5px solid transparent;border-image:linear-gradient(to bottom,#FF0000,#FF7F00,#FFFF00,#00CC00,#0000FF,#8B00FF) 1;box-shadow:0 2px 12px rgba(107,63,160,.08)}
.faq-item .q{font-weight:700;margin-bottom:8px;color:#6B3FA0}
.faq-item .a{opacity:.75;line-height:1.7}
.text-content{line-height:1.9;font-size:1.05rem;opacity:.85;white-space:pre-wrap;max-width:640px;margin:0 auto;text-align:center}
.rsvp{text-align:center;padding:100px 24px;background:linear-gradient(135deg,#FF0000 0%,#FF7F00 20%,#FFDD00 40%,#00CC00 60%,#0000FF 80%,#8B00FF 100%)}
.rsvp .eyebrow{color:rgba(255,255,255,.9);font-size:.7rem;letter-spacing:.45em;text-transform:uppercase;margin-bottom:16px}
.rsvp h2{font-family:'Helvetica Neue',Arial,sans-serif;font-size:clamp(2rem,5vw,3.5rem);font-weight:900;margin-bottom:16px;color:#fff;text-shadow:0 2px 8px rgba(0,0,0,.3)}
.rsvp p{color:rgba(255,255,255,.85);margin-bottom:40px;max-width:440px;margin-left:auto;margin-right:auto;line-height:1.7}
.rsvp .btn{display:inline-block;padding:18px 56px;background:#fff;color:#6B3FA0;font-size:.85rem;letter-spacing:.15em;text-transform:uppercase;border-radius:50px;font-weight:900;text-decoration:none;transition:transform .2s,box-shadow .2s;box-shadow:0 8px 24px rgba(0,0,0,.2)}
.rsvp .btn:hover{transform:translateY(-2px);box-shadow:0 12px 32px rgba(0,0,0,.3)}
footer{text-align:center;padding:60px 24px;background:#1A1A2E;color:#fff}
footer .rainbow{height:5px;background:linear-gradient(to right,#FF0000,#FF7F00,#FFFF00,#00CC00,#0000FF,#8B00FF);margin:0 auto 32px;border-radius:3px;width:200px}
footer .names{font-size:1.8rem;font-weight:900;letter-spacing:-.02em;margin-bottom:8px}
footer .date{font-size:.75rem;opacity:.35;letter-spacing:.2em;text-transform:uppercase}
footer .credit{font-size:1.1rem;font-weight:500;font-weight:500;opacity:.2;margin-top:20px}
#lightbox{position:fixed;inset:0;background:rgba(0,0,0,.92);z-index:999;display:none;align-items:center;justify-content:center;padding:20px}
#lightbox.show{display:flex}
#lightbox img{max-height:85vh;max-width:90vw;border-radius:12px;object-fit:contain}
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
  <a href="/members/wedding-site-edit.cfm?template=pride_modern" style="padding:8px 20px;background:#B8860B;color:#fff;border-radius:6px;font-weight:600;text-decoration:none;white-space:nowrap">Use This Template &rarr;</a>
  </cfif>
</div>
<div style="height:48px"></div>
</cfif>

  <div class="rainbow-bar"></div>
  <p class="eyebrow">Love is Love &mdash; You Are Invited</p>
  <h1><cfoutput>#HTMLEditFormat(site.couple_name_1)#</cfoutput></h1>
  <p class="and">&amp;</p>
  <h1><cfoutput>#HTMLEditFormat(site.couple_name_2)#</cfoutput></h1>
  <div class="divider"></div>
  <cfif len(weddingDateFull)><p class="date"><cfoutput>#weddingDateFull#</cfoutput></p></cfif>
  <cfif len(trim(site.venue_name))><p class="venue"><cfoutput>#HTMLEditFormat(site.venue_name)#</cfoutput></p></cfif>
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
      <cfif len(trim(site.venue_address))><p class="sub"><cfoutput>#HTMLEditFormat(site.venue_address)#</cfoutput></p></cfif>
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

<cfif len(trim(site.story))>
<section class="section alt" id="our_story">
  <div class="inner">
    <div class="section-title"><p>Our Story</p></div><div class="rainbow-divider"></div>
    <p class="story"><cfoutput>#HTMLEditFormat(site.story)#</cfoutput></p>
  </div>
</section>
</cfif>

<cfif arrayLen(galleryList)>
<section class="section" id="photos">
  <div class="section-title"><p>Photos</p></div><div class="rainbow-divider"></div>
  <div class="photos" id="gallery"></div>
</section>
</cfif>

<cfif arrayLen(faqList)>
<section class="section alt" id="q_and_a">
  <div class="inner">
    <div class="section-title"><p>Q + A</p></div><div class="rainbow-divider"></div>
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
<section class="section" id="dress_code" style="text-align:center">
  <div class="section-title"><p>Dress Code</p></div><div class="rainbow-divider"></div>
  <p class="text-content"><cfoutput>#HTMLEditFormat(site.dress_code)#</cfoutput></p>
</section>
</cfif>

<cfif len(trim(site.travel_info)) OR (structKeyExists(site,"travel_links_json") AND len(trim(site.travel_links_json)))>
<section class="section alt" id="travel" style="text-align:center">
  <div class="inner">
    <div class="section-title"><p>Travel</p></div><div class="rainbow-divider"></div>
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
<section class="section" id="things_to_do" style="text-align:center">
  <div class="section-title"><p>Things to Do</p></div><div class="rainbow-divider"></div>
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
  <p class="eyebrow">You Are Invited</p>
  <h2>Will You Join Us?</h2>
  <p>Please let us know if you&rsquo;ll be celebrating love with us on our special day.</p>
  <cfif len(trim(site.slug)) AND site.slug NEQ "preview">
  <a href="/rsvp.cfm?slug=<cfoutput>#URLEncodedFormat(site.slug)#</cfoutput>" class="btn">RSVP Now</a>
  <cfelse>
  <span class="btn">RSVP Now</span>
  </cfif>
</section>

<footer>
  <div class="rainbow"></div>
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
    var div=document.createElement("div");div.className="photo";
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
