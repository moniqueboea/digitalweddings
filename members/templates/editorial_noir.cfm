<!---
  editorial_noir.cfm — requires "site" struct set before cfinclude
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
<title><cfoutput>#HTMLEditFormat(site.couple_name_1)# &amp; #HTMLEditFormat(site.couple_name_2)#</cfoutput> &mdash; Editorial Noir</title>
<style>
*{margin:0;padding:0;box-sizing:border-box}
body{background:#111111;color:#E0E0E0;font-family:'Helvetica Neue',Arial,sans-serif;line-height:1.6}
.hero{display:flex;flex-direction:column;align-items:flex-start;justify-content:flex-end;padding:48px 60px;background:#000;position:relative;overflow:hidden}
.hero::before{content:'';position:absolute;top:0;left:0;right:0;bottom:0;background:linear-gradient(to top,rgba(0,0,0,.9) 0%,rgba(0,0,0,.2) 60%,transparent 100%)}
.hero-bg-text{position:absolute;top:50%;left:50%;transform:translate(-50%,-50%);font-size:clamp(6rem,18vw,16rem);font-weight:900;color:rgba(255,255,255,.025);white-space:nowrap;letter-spacing:-.05em;pointer-events:none;user-select:none}
.hero p.eyebrow{color:#C8A96E;font-size:.65rem;letter-spacing:.5em;text-transform:uppercase;margin-bottom:16px;position:relative}
.hero h1{font-family:'Helvetica Neue',Arial,sans-serif;font-size:clamp(3rem,10vw,8rem);font-weight:900;line-height:.95;color:#fff;letter-spacing:-.03em;position:relative;margin-bottom:32px}
.hero h1 .amp{color:#C8A96E;font-weight:300}
.hero .meta{display:flex;gap:40px;flex-wrap:wrap;position:relative}
.hero .meta-item p.label{font-size:.6rem;letter-spacing:.4em;text-transform:uppercase;color:#C8A96E;margin-bottom:4px}
.hero .meta-item p.val{font-size:.9rem;color:rgba(255,255,255,.7);font-weight:300}
nav{position:sticky;top:0;z-index:100;background:rgba(17,17,17,.97);border-bottom:1px solid #222;backdrop-filter:blur(8px)}
nav .inner{max-width:1100px;margin:0 auto;display:flex;align-items:center;justify-content:center;overflow-x:auto}
nav a{padding:18px 20px;font-size:.7rem;letter-spacing:.15em;color:#888;text-decoration:none;white-space:nowrap;cursor:pointer;border-bottom:2px solid transparent;transition:color .2s;text-transform:uppercase}
nav a:hover{color:#C8A96E}
nav a.active{color:#C8A96E;border-bottom-color:#C8A96E}
.section{padding:80px 60px;max-width:1000px;margin:0 auto}
.section.alt{background:#1A1A1A;max-width:100%}
.section.alt .inner{max-width:1000px;margin:0 auto;padding:80px 60px}
.section-title{margin-bottom:48px;display:flex;align-items:baseline;gap:24px}
.section-title h2{font-size:clamp(2rem,5vw,3.5rem);font-weight:900;letter-spacing:-.03em;color:#fff}
.section-title .line{flex:1;height:1px;background:#222}
.section-title p{color:#C8A96E;font-size:.65rem;letter-spacing:.4em;text-transform:uppercase;white-space:nowrap}
.detail{display:grid;grid-template-columns:repeat(auto-fit,minmax(200px,1fr));gap:1px;background:#222;margin-bottom:60px}
.detail .col{background:#111;padding:40px;text-align:left}
.detail .label{color:#C8A96E;font-size:.6rem;letter-spacing:.4em;text-transform:uppercase;margin-bottom:12px}
.detail .val{font-size:1.4rem;font-weight:300;color:#fff}
.detail .sub{color:#555;font-size:.85rem;margin-top:6px}
.monogram{display:inline-flex;align-items:center;justify-content:center;width:80px;height:80px;border:1px solid #C8A96E;font-size:2rem;color:#C8A96E;margin-top:32px}
.story{line-height:1.9;font-size:1rem;color:#aaa;white-space:pre-wrap;max-width:680px}
.photos{display:grid;grid-template-columns:repeat(auto-fill,minmax(220px,1fr));gap:2px}
.photos .photo{cursor:pointer;aspect-ratio:3/4;overflow:hidden}
.photos img{width:100%;height:100%;object-fit:cover;filter:grayscale(30%);transition:transform .4s,filter .4s}
.photos .photo:hover img{transform:scale(1.05);filter:grayscale(0%)}
.faq-list{display:flex;flex-direction:column}
.faq-item{display:grid;grid-template-columns:1fr 2fr;gap:40px;padding:32px 0;border-bottom:1px solid #222}
.faq-item .q{font-weight:700;font-size:.95rem;color:#fff}
.faq-item .a{color:#888;line-height:1.8}
.text-content{line-height:1.9;font-size:1rem;color:#aaa;white-space:pre-wrap;max-width:680px}
.rsvp{padding:120px 60px;background:#000}
.rsvp .eyebrow{color:#C8A96E;font-size:.65rem;letter-spacing:.5em;text-transform:uppercase;margin-bottom:20px}
.rsvp h2{font-size:clamp(3rem,8vw,6rem);font-weight:900;letter-spacing:-.03em;color:#fff;margin-bottom:24px;line-height:.95}
.rsvp p{color:#555;margin-bottom:48px;max-width:440px;line-height:1.7}
.rsvp .btn{display:inline-block;padding:20px 60px;background:#C8A96E;color:#000;font-size:.75rem;letter-spacing:.3em;text-transform:uppercase;font-weight:700;text-decoration:none;transition:background .2s}
.rsvp .btn:hover{background:#fff}
footer{padding:60px;background:#000;border-top:1px solid #1A1A1A;display:flex;justify-content:space-between;align-items:flex-end;flex-wrap:wrap;gap:24px}
footer .names{font-size:1.5rem;font-weight:900;letter-spacing:-.02em;color:#fff}
footer .names .amp{color:#C8A96E;font-weight:300}
footer .right{text-align:right}
footer .date{font-size:.65rem;letter-spacing:.2em;text-transform:uppercase;color:#333}
footer .credit{font-size:1.1rem;font-weight:500;font-weight:500;color:#222;margin-top:8px}
@media(max-width:768px){.hero{padding:60px 24px}.section{padding:60px 24px}.section.alt .inner{padding:60px 24px}.faq-item{grid-template-columns:1fr}.rsvp{padding:80px 24px}.footer{padding:40px 24px}}
#lightbox{position:fixed;inset:0;background:rgba(0,0,0,.97);z-index:999;display:none;align-items:center;justify-content:center;padding:20px}
#lightbox.show{display:flex}
#lightbox img{max-height:85vh;max-width:90vw;object-fit:contain}
#lightbox button{position:absolute;background:rgba(255,255,255,.08);border:none;color:#fff;border-radius:50%;cursor:pointer}
#lightbox .nav-btn{width:48px;height:48px;font-size:2rem;top:50%;transform:translateY(-50%)}
#lightbox .prev{left:20px}
#lightbox .next{right:20px}
#lightbox .close{top:16px;right:16px;width:40px;height:40px;font-size:1.2rem}
#lightbox .count{position:absolute;bottom:20px;color:rgba(255,255,255,.3);font-size:.8rem}
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
  <a href="/members/wedding-site-edit.cfm?template=editorial_noir" style="padding:8px 20px;background:#B8860B;color:#fff;border-radius:6px;font-weight:600;text-decoration:none;white-space:nowrap">Use This Template &rarr;</a>
  </cfif>
</div>
<div style="height:48px"></div>
</cfif>

  <div class="hero-bg-text"><cfoutput>#HTMLEditFormat(monogram)#</cfoutput></div>
  <p class="eyebrow">An Exclusive Invitation</p>
  <h1><cfoutput>#HTMLEditFormat(site.couple_name_1)#</cfoutput> <span class="amp">&amp;</span> <cfoutput>#HTMLEditFormat(site.couple_name_2)#</cfoutput></h1>
  <div class="meta">
    <cfif len(weddingDateFull)>
    <div class="meta-item">
      <p class="label">Date</p>
      <p class="val"><cfoutput>#weddingDateFull#</cfoutput></p>
    </div>
    </cfif>
    <cfif len(trim(site.venue_name))>
    <div class="meta-item">
      <p class="label">Venue</p>
      <p class="val"><cfoutput>#HTMLEditFormat(site.venue_name)#</cfoutput></p>
    </div>
    </cfif>
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
  <div class="section-title"><h2>Details</h2><div class="line"></div></div>
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
    <div class="col">
      <p class="label">Couple</p>
      <p class="val"><cfoutput>#HTMLEditFormat(monogram)#</cfoutput></p>
    </div>
  </div>
</section>

<cfif len(trim(site.story))>
<section class="section alt" id="our_story">
  <div class="inner">
    <div class="section-title"><h2>Our Story</h2><div class="line"></div></div>
    <p class="story"><cfoutput>#HTMLEditFormat(site.story)#</cfoutput></p>
  </div>
</section>
</cfif>

<cfif arrayLen(galleryList)>
<section class="section" id="photos">
  <div class="section-title"><h2>Photos</h2><div class="line"></div></div>
  <div class="photos" id="gallery"></div>
</section>
</cfif>

<cfif arrayLen(faqList)>
<section class="section alt" id="q_and_a">
  <div class="inner">
    <div class="section-title"><h2>Q + A</h2><div class="line"></div></div>
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
  <div class="section-title"><h2>Dress Code</h2><div class="line"></div></div>
  <p class="text-content"><cfoutput>#HTMLEditFormat(site.dress_code)#</cfoutput></p>
</section>
</cfif>

<cfif len(trim(site.travel_info)) OR (structKeyExists(site,"travel_links_json") AND len(trim(site.travel_links_json)))>
<section class="section alt" id="travel">
  <div class="inner">
    <div class="section-title"><h2>Travel</h2><div class="line"></div></div>
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
  <div class="section-title"><h2>Things to Do</h2><div class="line"></div></div>
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
  <h2>Will You<br>Join Us?</h2>
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
  </div>
  <div class="right">
    <cfif len(weddingDateFull)><p class="date"><cfoutput>#weddingDateFull#</cfoutput></p></cfif>
    <p class="credit">digitalweddings.love <span style="color:#e03">&#9829;</span></p>
  </div>
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
