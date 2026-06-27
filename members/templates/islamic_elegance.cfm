<!---
  islamic_elegance.cfm — requires "site" struct set before cfinclude
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
<title><cfoutput>#HTMLEditFormat(site.couple_name_1)# &amp; #HTMLEditFormat(site.couple_name_2)#</cfoutput> &mdash; Islamic Elegance</title>
<style>
*{margin:0;padding:0;box-sizing:border-box}
body{background:#FAF6EF;color:#1A1208;font-family:'Palatino Linotype',Palatino,Georgia,serif;line-height:1.8}
.hero{min-height:65vh;display:flex;flex-direction:column;align-items:center;justify-content:center;text-align:center;padding:100px 24px 80px;background:#FAF6EF;position:relative;overflow:hidden}
.hero::before{content:'';position:absolute;inset:0;background:url("data:image/svg+xml,%3Csvg width='120' height='120' viewBox='0 0 120 120' xmlns='http://www.w3.org/2000/svg'%3E%3Cg fill='%23C9A84C' fill-opacity='0.07'%3E%3Cpath d='M60 10 L67 35 L92 35 L72 52 L80 77 L60 62 L40 77 L48 52 L28 35 L53 35 Z'/%3E%3Ccircle cx='60' cy='60' r='45' fill='none' stroke='%23C9A84C' stroke-opacity='0.06' stroke-width='1'/%3E%3Ccircle cx='60' cy='60' r='55' fill='none' stroke='%23C9A84C' stroke-opacity='0.04' stroke-width='1'/%3E%3C/g%3E%3C/svg%3E")}
.hero p.bismillah{color:#C9A84C;font-size:1rem;letter-spacing:.2em;margin-bottom:24px;font-style:italic;position:relative}
.hero p.eyebrow{color:#C9A84C;font-size:.65rem;letter-spacing:.5em;text-transform:uppercase;margin-bottom:20px;position:relative}
.hero h1{font-family:'Palatino Linotype',Palatino,Georgia,serif;font-size:clamp(2.8rem,8vw,5.5rem);font-weight:700;color:#1A1208;line-height:1.1;position:relative}
.hero p.and{color:#C9A84C;letter-spacing:.4em;font-size:.85rem;text-transform:uppercase;margin:12px 0;position:relative}
.hero .geo-divider{display:flex;align-items:center;justify-content:center;gap:12px;margin:28px 0;position:relative}
.hero .geo-divider .line{width:60px;height:1px;background:rgba(201,168,76,.5)}
.hero .geo-divider span{color:#C9A84C;font-size:1.2rem}
.hero p.date{color:#1A1208;font-size:.82rem;letter-spacing:.25em;text-transform:uppercase;position:relative;opacity:.75}
.hero p.venue{color:#C9A84C;font-size:.75rem;letter-spacing:.12em;text-transform:uppercase;margin-top:8px;position:relative}
nav{position:sticky;top:0;z-index:100;background:rgba(250,246,239,.97);border-bottom:1px solid rgba(201,168,76,.4);backdrop-filter:blur(8px)}
nav .inner{max-width:960px;margin:0 auto;display:flex;align-items:center;justify-content:center;overflow-x:auto}
nav a{padding:18px 20px;font-size:.78rem;letter-spacing:.1em;color:#1A1208;text-decoration:none;white-space:nowrap;cursor:pointer;border-bottom:2px solid transparent;transition:color .2s}
nav a:hover{color:#C9A84C}
nav a.active{color:#C9A84C;border-bottom-color:#C9A84C;font-weight:600}
.section{padding:80px 24px 60px;max-width:860px;margin:0 auto}
.section.alt{background:#F3ECD8;max-width:100%}
.section.alt .inner{max-width:860px;margin:0 auto;padding:80px 24px 60px}
.section-title{text-align:center;margin-bottom:48px}
.section-title .orn{display:flex;align-items:center;justify-content:center;gap:16px;margin-bottom:12px}
.section-title .line{height:1px;width:60px;background:linear-gradient(to right,transparent,#C9A84C,transparent)}
.section-title span{color:#C9A84C;font-size:1.1rem}
.section-title p{color:#C9A84C;letter-spacing:.35em;font-size:.68rem;text-transform:uppercase;font-weight:600}
.detail{display:flex;justify-content:center;flex-wrap:wrap;gap:0;margin-bottom:48px;border:1px solid rgba(201,168,76,.3);background:#fff}
.detail .col{padding:36px 48px;border-right:1px solid rgba(201,168,76,.3);text-align:center;flex:1;min-width:160px}
.detail .col:last-child{border-right:none}
.detail .label{color:#C9A84C;font-size:.65rem;letter-spacing:.35em;text-transform:uppercase;margin-bottom:12px;font-weight:600}
.detail .val{font-family:'Palatino Linotype',Palatino,Georgia,serif;font-size:1.5rem;font-weight:700;color:#1A1208}
.detail .sub{color:#888;font-size:.85rem;margin-top:6px}
.monogram{display:inline-flex;align-items:center;justify-content:center;width:80px;height:80px;border-radius:50%;border:2px solid #C9A84C;font-family:'Palatino Linotype',Palatino,Georgia,serif;font-size:1.8rem;color:#C9A84C;margin-top:24px}
.story{line-height:2;font-size:1.05rem;opacity:.85;white-space:pre-wrap;max-width:680px;margin:0 auto;text-align:center}
.photos{display:grid;grid-template-columns:repeat(auto-fill,minmax(200px,1fr));gap:8px}
.photos .photo{cursor:pointer;aspect-ratio:1;overflow:hidden;border-radius:4px}
.photos img{width:100%;height:100%;object-fit:cover;transition:transform .3s}
.photos .photo:hover img{transform:scale(1.05)}
.faq-list{max-width:680px;margin:0 auto;display:flex;flex-direction:column;gap:0}
.faq-item{padding:24px 0;border-bottom:1px solid rgba(201,168,76,.3)}
.faq-item .q{font-weight:700;margin-bottom:8px;color:#1A1208}
.faq-item .a{opacity:.75;line-height:1.8}
.text-content{line-height:1.9;font-size:1.05rem;opacity:.85;white-space:pre-wrap;max-width:640px;margin:0 auto;text-align:center}
.rsvp{text-align:center;padding:80px 24px;background:#F3ECD8}
.rsvp .eyebrow{color:#C9A84C;font-size:.68rem;letter-spacing:.5em;text-transform:uppercase;margin-bottom:16px}
.rsvp h2{font-family:'Palatino Linotype',Palatino,Georgia,serif;font-size:clamp(2rem,5vw,3rem);font-weight:400;margin-bottom:16px;color:#1A1208}
.rsvp p{color:rgba(26,18,8,.6);margin-bottom:40px;max-width:440px;margin-left:auto;margin-right:auto;line-height:1.7}
.rsvp .btn{display:inline-block;padding:16px 52px;background:#C9A84C;color:#fff;font-size:.85rem;letter-spacing:.2em;text-transform:uppercase;border-radius:4px;font-weight:700;text-decoration:none;transition:background .2s}
.rsvp .btn:hover{background:#D9B85C}
footer{text-align:center;padding:60px 24px;border-top:1px solid rgba(201,168,76,.3);background:#F3ECD8;color:#1A1208}
footer .names{font-family:'Palatino Linotype',Palatino,Georgia,serif;font-size:1.8rem;font-style:italic;color:#C9A84C;margin-bottom:8px}
footer .date{font-size:.75rem;opacity:.4;letter-spacing:.2em;text-transform:uppercase}
footer .barakah{font-style:italic;font-size:.85rem;color:rgba(201,168,76,.6);margin-top:12px}
footer .credit{font-size:1.1rem;font-weight:500;font-weight:500;opacity:.3;margin-top:20px}
#lightbox{position:fixed;inset:0;background:rgba(0,0,0,.93);z-index:999;display:none;align-items:center;justify-content:center;padding:20px}
#lightbox.show{display:flex}
#lightbox img{max-height:85vh;max-width:90vw;border-radius:4px;object-fit:contain}
#lightbox button{position:absolute;background:rgba(255,255,255,.12);border:none;color:#fff;border-radius:50%;cursor:pointer}
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
  <a href="/members/wedding-site-edit.cfm?template=islamic_elegance" style="padding:8px 20px;background:#B8860B;color:#fff;border-radius:6px;font-weight:600;text-decoration:none;white-space:nowrap">Use This Template &rarr;</a>
  </cfif>
</div>
<div style="height:48px"></div>
</cfif>

  <p class="bismillah">Bismillah ir-Rahman ir-Rahim</p>
  <p class="eyebrow">Walimah Invitation</p>
  <h1><cfoutput>#HTMLEditFormat(site.couple_name_1)#</cfoutput></h1>
  <p class="and">&amp;</p>
  <h1><cfoutput>#HTMLEditFormat(site.couple_name_2)#</cfoutput></h1>
  <div class="geo-divider"><div class="line"></div><span>&#10024;</span><div class="line"></div></div>
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
    <div class="section-title"><div class="orn"><div class="line"></div><span>&#10024;</span><div class="line"></div></div><p>Our Story</p></div>
    <p class="story"><cfoutput>#HTMLEditFormat(site.story)#</cfoutput></p>
  </div>
</section>
</cfif>

<cfif arrayLen(galleryList)>
<section class="section" id="photos">
  <div class="section-title"><div class="orn"><div class="line"></div><span>&#10024;</span><div class="line"></div></div><p>Photos</p></div>
  <div class="photos" id="gallery"></div>
</section>
</cfif>

<cfif arrayLen(faqList)>
<section class="section alt" id="q_and_a">
  <div class="inner">
    <div class="section-title"><div class="orn"><div class="line"></div><span>&#10024;</span><div class="line"></div></div><p>Q + A</p></div>
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
  <div class="section-title"><div class="orn"><div class="line"></div><span>&#10024;</span><div class="line"></div></div><p>Dress Code</p></div>
  <p class="text-content"><cfoutput>#HTMLEditFormat(site.dress_code)#</cfoutput></p>
</section>
</cfif>

<cfif len(trim(site.travel_info)) OR (structKeyExists(site,"travel_links_json") AND len(trim(site.travel_links_json)))>
<section class="section alt" id="travel" style="text-align:center">
  <div class="inner">
    <div class="section-title"><div class="orn"><div class="line"></div><span>&#10024;</span><div class="line"></div></div><p>Travel</p></div>
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
  <div class="section-title"><div class="orn"><div class="line"></div><span>&#10024;</span><div class="line"></div></div><p>Things to Do</p></div>
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
  <p>Please let us know if you will be joining us to celebrate this blessed occasion.</p>
  <cfif len(trim(site.slug)) AND site.slug NEQ "preview">
  <a href="/rsvp.cfm?slug=<cfoutput>#URLEncodedFormat(site.slug)#</cfoutput>" class="btn">RSVP Now</a>
  <cfelse>
  <span class="btn">RSVP Now</span>
  </cfif>
</section>

<footer>
  <p class="names"><cfoutput>#HTMLEditFormat(site.couple_name_1)# &amp; #HTMLEditFormat(site.couple_name_2)#</cfoutput></p>
  <cfif len(weddingDateFull)><p class="date"><cfoutput>#weddingDateFull#</cfoutput></p></cfif>
  <p class="barakah">Barakallahu lakuma wa baraka 'alaykuma</p>
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
