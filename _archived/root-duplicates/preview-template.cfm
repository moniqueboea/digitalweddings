<cfparam name="url.template" default="classic_gold">
<cfset tplId = lCase(reReplace(trim(url.template),"[^a-z_]","","all"))>

<!--- Sample data for preview --->
<cfset sample = {
    couple_name_1: "Aisha",
    couple_name_2: "Marcus",
    wedding_date: "2025-09-20",
    venue_name: "The Grand Ballroom",
    venue_address: "1234 Elegance Ave, Atlanta, GA",
    story: "We met at a friend's birthday party in the summer of 2019. Marcus walked in and Aisha couldn't take her eyes off him. They talked all night and exchanged numbers, and the rest - as they say - is history. After five beautiful years together, he got down on one knee at the same rooftop where they had their first real date.",
    dress_code: "Black tie optional. We encourage our guests to wear earth tones and jewel colors to complement our wedding palette.",
    travel_info: "We have reserved a room block at the Marriott Downtown at a special rate of $189/night. Use code AISHA-MARCUS when booking. The venue is 10 minutes from Hartsfield-Jackson Atlanta International Airport.",
    things_to_do: "Atlanta has so much to offer! Visit the National Center for Civil and Human Rights, stroll through Piedmont Park, or explore the Atlanta BeltLine. We recommend the Old Fourth Ward neighborhood for dining.",
    hero_image_url: "",
    scripture: "Two are better than one, because they have a good return for their labor. - Ecclesiastes 4:9",
    slug: "preview",
    published: 1
}>

<cfset gallery = [
    "/assets/photos/hero-couple.jpg",
    "/assets/photos/couple-portrait.jpg",
    "/assets/photos/bride-groom-planning.jpg",
    "/assets/photos/couple-celebration.jpg"
]>

<cfset faqItems = [
    {question:"Is there parking at the venue?", answer:"Yes! Complimentary valet parking is available for all guests."},
    {question:"Are children welcome?", answer:"We love your little ones, but we've chosen to make this an adults-only celebration. We hope you can arrange childcare and join us!"},
    {question:"What time should I arrive?", answer:"Doors open at 5:00 PM. The ceremony begins promptly at 6:00 PM."}
]>

<cfset themes = {
    classic_gold:      {bg:"##FDFAF5", text:"##2C2C2C", accent:"##B8860B", light:"##F5EDD8", navBg:"rgba(253,250,245,0.97)", divider:"##D4AF37", headingFont:"Georgia,'Times New Roman',serif",    bodyFont:"'Palatino Linotype',Georgia,serif",             divSymbol:"&##10022; &##10022; &##10022;"},
    garden_romance:    {bg:"##F2EEE8", text:"##2D3A2E", accent:"##4A7C59", light:"##E4EDE5", navBg:"rgba(242,238,232,0.97)", divider:"##7BAF8A", headingFont:"Georgia,serif",                       bodyFont:"Georgia,serif",                                 divSymbol:"&##10022; &##10022; &##10022;"},
    modern_minimal:    {bg:"##FFFFFF", text:"##111111", accent:"##C4A265", light:"##F8F8F8", navBg:"rgba(255,255,255,0.97)", divider:"##E0E0E0", headingFont:"'Helvetica Neue',Arial,sans-serif",   bodyFont:"'Helvetica Neue',Arial,sans-serif",             divSymbol:"&mdash;"},
    royal_elegance:    {bg:"##0D0620", text:"##F5EFE6", accent:"##D4AF37", light:"##160930", navBg:"rgba(13,6,32,0.97)",    divider:"##D4AF37", headingFont:"Georgia,'Times New Roman',serif",    bodyFont:"Georgia,serif",                                 divSymbol:"&##10022; &##10022; &##10022;"},
    sunset_bliss:      {bg:"##FFF8F2", text:"##4A2C1A", accent:"##C96A2A", light:"##FDEBD0", navBg:"rgba(255,248,242,0.97)", divider:"##E8A87C", headingFont:"'Palatino Linotype',Georgia,serif", bodyFont:"Georgia,serif",                                 divSymbol:"&##10022; &##10022; &##10022;"},
    cultural_heritage: {bg:"##0E0A02", text:"##F5EFD6", accent:"##D4AF37", light:"##1A1402", navBg:"rgba(14,10,2,0.97)",   divider:"##D4AF37", headingFont:"Georgia,serif",                       bodyFont:"Georgia,serif",                                 divSymbol:"&##10022; &##10022; &##10022;"},
    christian_sacred:  {bg:"##F8F5F0", text:"##2D2D2D", accent:"##D4AF37", light:"##F0EBE3", navBg:"rgba(248,245,240,0.97)", divider:"##D4AF37", headingFont:"Georgia,'Times New Roman',serif",  bodyFont:"Georgia,'Times New Roman',serif",               divSymbol:"&##10022; &##10022; &##10022;"},
    editorial_noir:    {bg:"##121212", text:"##F0EDE8", accent:"##F0EDE8", light:"##1A1A1A", navBg:"rgba(18,18,18,0.97)",  divider:"##333333", headingFont:"Georgia,'Times New Roman',serif",    bodyFont:"'Courier New',Courier,monospace",               divSymbol:"&mdash;&mdash;&mdash;"},
    pride_modern:      {bg:"##FFFFFF", text:"##1A1A1A", accent:"##004DFF", light:"##F8F8F8", navBg:"rgba(255,255,255,0.97)", divider:"##E5E5E5", headingFont:"Georgia,'Times New Roman',serif",  bodyFont:"'Helvetica Neue',Arial,sans-serif",             divSymbol:"&mdash;"},
    islamic_elegance:  {bg:"##FAF6EF", text:"##1A1208", accent:"##C9A84C", light:"##F3ECD8", navBg:"rgba(250,246,239,0.97)", divider:"##C9A84C", headingFont:"'Palatino Linotype',Palatino,Georgia,serif", bodyFont:"Georgia,'Times New Roman',serif", divSymbol:"&##10022; &##10022; &##10022;"}
}>

<cfif !structKeyExists(themes, tplId)><cfset tplId = "classic_gold"></cfif>
<cfset T = themes[tplId]>
<cfset weddingDateFormatted = dateFormat(sample.wedding_date,"mmmm d, yyyy")>
<cfset weddingDateShort = dateFormat(sample.wedding_date,"mmmm d")>
<cfset monogram = left(sample.couple_name_1,1) & left(sample.couple_name_2,1)>
<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Template Preview - digitalweddings.love</title>
    <style>
        * { margin:0;padding:0;box-sizing:border-box; }
        html { scroll-behavior:smooth; }
        body { font-family:sans-serif; }
        img { max-width:100%;display:block; }
        .preview-bar { position:fixed;top:0;left:0;right:0;z-index:9999;background:#1a1a1a;color:#fff;display:flex;align-items:center;justify-content:space-between;padding:10px 20px;font-size:13px;font-family:sans-serif; }
        .preview-bar a { color:#D4AF37;text-decoration:none;padding:6px 14px;border:1px solid ##D4AF37;border-radius:4px;font-size:12px;font-weight:600;letter-spacing:0.05em; }
        .site-nav { position:sticky;top:44px;z-index:100;overflow-x:auto;scrollbar-width:none;transition:box-shadow 0.3s; }
        .site-nav::-webkit-scrollbar { display:none; }
        .site-nav-inner { max-width:960px;margin:0 auto;display:flex;align-items:center;justify-content:center; }
        .nav-sec-btn { padding:16px 18px;font-size:0.75rem;letter-spacing:0.12em;text-transform:uppercase;background:none;border:none;border-bottom:2px solid transparent;cursor:pointer;white-space:nowrap; }
        .section-title-row { display:flex;align-items:center;justify-content:center;gap:16px;margin-bottom:44px; }
        .section-title-line { height:1px;width:60px; }
        .section-title-text { letter-spacing:0.3em;font-size:0.7rem;text-transform:uppercase; }
        .gallery-grid { display:grid;grid-template-columns:repeat(auto-fill,minmax(180px,1fr));gap:10px; }
        .gallery-item { aspect-ratio:1;overflow:hidden;border-radius:4px; }
        .gallery-item img { width:100%;height:100%;object-fit:cover;transition:transform 0.3s; }
        .gallery-item:hover img { transform:scale(1.05); }
        body { padding-top: 44px; }
    </style>
</head>
<body>

<div class="preview-bar">
    <span>&##128064; Template Preview - <strong><cfoutput>#replace(tplId,'_',' ','all')#</cfoutput></strong> (sample data)</span>
    <a href="/members/wedding-sites.cfm?mode=edit&template=<cfoutput>#URLEncodedFormat(tplId)#</cfoutput>">Use This Template &rarr;</a>
</div>

<cfoutput>

<div style="min-height:55vh;display:flex;flex-direction:column;align-items:center;justify-content:center;text-align:center;position:relative;overflow:hidden;background:#HTMLEditFormat(T.bg)#">
    <cfif tplId EQ "classic_gold">
        <div style="position:absolute;top:0;left:0;width:35%;opacity:0.4;pointer-events:none"><img src="/assets/photos/floral-left.jpg" alt="" style="width:100%;filter:saturate(0.5) sepia(0.3)"></div>
        <div style="position:absolute;top:0;right:0;width:30%;opacity:0.35;pointer-events:none"><img src="/assets/photos/floral-right.jpg" alt="" style="width:100%;transform:scaleX(-1);filter:saturate(0.4) sepia(0.2)"></div>
    </cfif>
    <cfif tplId EQ "pride_modern">
        <div style="position:absolute;top:0;left:0;right:0;height:8px;background:linear-gradient(to right,##E40303,##FF8C00,##FFED00,##008026,##004DFF,##750787)"></div>
    </cfif>
    <cfif tplId EQ "cultural_heritage">
        <div style="position:absolute;inset:0;background:repeating-linear-gradient(45deg,rgba(212,175,55,0.04) 0px,rgba(212,175,55,0.04) 2px,transparent 2px,transparent 20px);pointer-events:none"></div>
    </cfif>
    <div style="position:relative;z-index:1;padding:80px 24px 60px">
        <p style="font-family:#HTMLEditFormat(T.bodyFont)#;font-size:1.2rem;color:#HTMLEditFormat(T.accent)#;font-style:italic;margin-bottom:16px">The Wedding of</p>
        <div style="display:flex;align-items:center;justify-content:center;gap:12px;margin-bottom:20px">
            <div style="height:1px;width:80px;background:#HTMLEditFormat(T.divider)#"></div>
            <span style="color:#HTMLEditFormat(T.accent)#">&##10022;</span>
            <div style="height:1px;width:80px;background:#HTMLEditFormat(T.divider)#"></div>
        </div>
        <h1 style="font-family:#HTMLEditFormat(T.headingFont)#;font-size:clamp(2.5rem,8vw,5.5rem);color:#HTMLEditFormat(T.text)#;font-weight:700;line-height:1.05;text-transform:uppercase;margin-bottom:28px">
            #HTMLEditFormat(sample.couple_name_1)#<br>
            <span style="color:#HTMLEditFormat(T.accent)#;font-size:0.45em;letter-spacing:0.45em">&amp;</span><br>
            #HTMLEditFormat(sample.couple_name_2)#
        </h1>
        <p style="color:#HTMLEditFormat(T.text)#;font-size:0.85rem;letter-spacing:0.25em;text-transform:uppercase;margin-bottom:6px">#HTMLEditFormat(weddingDateFormatted)#</p>
        <p style="color:#HTMLEditFormat(T.accent)#;font-size:0.8rem;letter-spacing:0.2em;text-transform:uppercase">#HTMLEditFormat(sample.venue_name)#</p>
    </div>
</div>

<nav class="site-nav" style="background:#HTMLEditFormat(T.navBg)#;border-bottom:1px solid #HTMLEditFormat(T.divider)#30">
    <div class="site-nav-inner">
        <span class="nav-sec-btn" style="color:#HTMLEditFormat(T.accent)#;border-bottom-color:#HTMLEditFormat(T.accent)#;font-family:#HTMLEditFormat(T.bodyFont)#;font-weight:600">Home</span>
        <span class="nav-sec-btn" style="color:#HTMLEditFormat(T.text)#;font-family:#HTMLEditFormat(T.bodyFont)#">Our Story</span>
        <span class="nav-sec-btn" style="color:#HTMLEditFormat(T.text)#;font-family:#HTMLEditFormat(T.bodyFont)#">Photos</span>
        <span class="nav-sec-btn" style="color:#HTMLEditFormat(T.text)#;font-family:#HTMLEditFormat(T.bodyFont)#">Q + A</span>
        <span class="nav-sec-btn" style="color:#HTMLEditFormat(T.text)#;font-family:#HTMLEditFormat(T.bodyFont)#">Dress Code</span>
        <span class="nav-sec-btn" style="color:#HTMLEditFormat(T.text)#;font-family:#HTMLEditFormat(T.bodyFont)#">Travel</span>
        <span class="nav-sec-btn" style="color:#HTMLEditFormat(T.text)#;font-family:#HTMLEditFormat(T.bodyFont)#">RSVP</span>
    </div>
</nav>

<section style="padding:80px 24px 60px;text-align:center;max-width:860px;margin:0 auto;background:#HTMLEditFormat(T.bg)#">
    <div style="display:flex;justify-content:center;align-items:stretch;gap:0;flex-wrap:wrap;margin-bottom:56px">
        <div style="padding:0 48px;border-right:1px solid #HTMLEditFormat(T.divider)#40">
            <p style="color:#HTMLEditFormat(T.accent)#;font-size:0.7rem;letter-spacing:0.3em;text-transform:uppercase;margin-bottom:10px">Wedding Day</p>
            <p style="font-family:#HTMLEditFormat(T.headingFont)#;font-size:1.8rem;font-weight:700;text-transform:uppercase;color:#HTMLEditFormat(T.text)#">#HTMLEditFormat(weddingDateShort)#</p>
            <p style="font-family:#HTMLEditFormat(T.headingFont)#;font-size:1rem;opacity:0.6;color:#HTMLEditFormat(T.text)#">2025</p>
        </div>
        <div style="padding:0 48px">
            <p style="color:#HTMLEditFormat(T.accent)#;font-size:0.7rem;letter-spacing:0.3em;text-transform:uppercase;margin-bottom:10px">Venue</p>
            <p style="font-family:#HTMLEditFormat(T.headingFont)#;font-size:1.8rem;font-weight:700;text-transform:uppercase;color:#HTMLEditFormat(T.text)#">#HTMLEditFormat(sample.venue_name)#</p>
            <p style="font-size:0.85rem;opacity:0.6;margin-top:4px;color:#HTMLEditFormat(T.text)#">#HTMLEditFormat(sample.venue_address)#</p>
        </div>
    </div>
    <div style="display:inline-flex;align-items:center;justify-content:center;width:76px;height:76px;border-radius:50%;border:2px solid #HTMLEditFormat(T.divider)#;font-family:#HTMLEditFormat(T.headingFont)#;font-size:1.7rem;color:#HTMLEditFormat(T.accent)#">#HTMLEditFormat(monogram)#</div>
</section>

<div style="text-align:center;padding:16px 0;color:#HTMLEditFormat(T.divider)#;font-size:1rem;letter-spacing:0.6em;opacity:0.7;background:#HTMLEditFormat(T.bg)#">#T.divSymbol#</div>

<section style="padding:80px 24px 60px;max-width:860px;margin:0 auto;background:#HTMLEditFormat(T.bg)#">
    <div class="section-title-row">
        <div class="section-title-line" style="background:#HTMLEditFormat(T.divider)#"></div>
        <p class="section-title-text" style="color:#HTMLEditFormat(T.accent)#;font-family:#HTMLEditFormat(T.bodyFont)#">Our Story</p>
        <div class="section-title-line" style="background:#HTMLEditFormat(T.divider)#"></div>
    </div>
    <p style="line-height:1.95;font-size:1.05rem;text-align:center;opacity:0.85;max-width:640px;margin:0 auto;font-family:#HTMLEditFormat(T.bodyFont)#;color:#HTMLEditFormat(T.text)#">#HTMLEditFormat(sample.story)#</p>
</section>

<div style="text-align:center;padding:16px 0;color:#HTMLEditFormat(T.divider)#;font-size:1rem;letter-spacing:0.6em;opacity:0.7;background:#HTMLEditFormat(T.bg)#">#T.divSymbol#</div>

<section style="padding:80px 24px 60px;max-width:860px;margin:0 auto;background:#HTMLEditFormat(T.bg)#">
    <div class="section-title-row">
        <div class="section-title-line" style="background:#HTMLEditFormat(T.divider)#"></div>
        <p class="section-title-text" style="color:#HTMLEditFormat(T.accent)#;font-family:#HTMLEditFormat(T.bodyFont)#">Photos</p>
        <div class="section-title-line" style="background:#HTMLEditFormat(T.divider)#"></div>
    </div>
    <div class="gallery-grid">
        <cfloop array="#gallery#" index="g">
        <div class="gallery-item"><img src="#HTMLEditFormat(g)#" alt="Gallery" loading="lazy"></div>
        </cfloop>
    </div>
</section>

<div style="text-align:center;padding:16px 0;color:#HTMLEditFormat(T.divider)#;font-size:1rem;letter-spacing:0.6em;opacity:0.7;background:#HTMLEditFormat(T.bg)#">#T.divSymbol#</div>

<section style="padding:80px 24px 60px;max-width:860px;margin:0 auto;background:#HTMLEditFormat(T.bg)#">
    <div class="section-title-row">
        <div class="section-title-line" style="background:#HTMLEditFormat(T.divider)#"></div>
        <p class="section-title-text" style="color:#HTMLEditFormat(T.accent)#;font-family:#HTMLEditFormat(T.bodyFont)#">Q + A</p>
        <div class="section-title-line" style="background:#HTMLEditFormat(T.divider)#"></div>
    </div>
    <div style="max-width:640px;margin:0 auto;display:flex;flex-direction:column;gap:28px">
        <cfloop array="#faqItems#" index="fi">
        <div style="border-bottom:1px solid #HTMLEditFormat(T.divider)#30;padding-bottom:24px">
            <p style="font-weight:700;font-size:1rem;margin-bottom:8px;font-family:#HTMLEditFormat(T.headingFont)#;color:#HTMLEditFormat(T.text)#">#HTMLEditFormat(fi.question)#</p>
            <p style="opacity:0.75;line-height:1.7;font-family:#HTMLEditFormat(T.bodyFont)#;color:#HTMLEditFormat(T.text)#">#HTMLEditFormat(fi.answer)#</p>
        </div>
        </cfloop>
    </div>
</section>

<div style="text-align:center;padding:16px 0;color:#HTMLEditFormat(T.divider)#;font-size:1rem;letter-spacing:0.6em;opacity:0.7;background:#HTMLEditFormat(T.bg)#">#T.divSymbol#</div>

<section style="padding:80px 24px 60px;max-width:860px;margin:0 auto;text-align:center;background:#HTMLEditFormat(T.bg)#">
    <div class="section-title-row">
        <div class="section-title-line" style="background:#HTMLEditFormat(T.divider)#"></div>
        <p class="section-title-text" style="color:#HTMLEditFormat(T.accent)#;font-family:#HTMLEditFormat(T.bodyFont)#">Dress Code</p>
        <div class="section-title-line" style="background:#HTMLEditFormat(T.divider)#"></div>
    </div>
    <p style="line-height:1.9;font-size:1.05rem;opacity:0.85;max-width:640px;margin:0 auto;font-family:#HTMLEditFormat(T.bodyFont)#;color:#HTMLEditFormat(T.text)#">#HTMLEditFormat(sample.dress_code)#</p>
</section>

<div style="text-align:center;padding:16px 0;color:#HTMLEditFormat(T.divider)#;font-size:1rem;letter-spacing:0.6em;opacity:0.7;background:#HTMLEditFormat(T.bg)#">#T.divSymbol#</div>

<div style="text-align:center;padding:80px 24px;background:#HTMLEditFormat(T.light)#">
    <p style="font-family:#HTMLEditFormat(T.bodyFont)#;font-size:0.72rem;letter-spacing:0.35em;text-transform:uppercase;color:#HTMLEditFormat(T.accent)#;margin-bottom:16px">You're Invited</p>
    <h2 style="font-family:#HTMLEditFormat(T.headingFont)#;font-size:clamp(2rem,5vw,3rem);color:#HTMLEditFormat(T.text)#;font-weight:400;margin-bottom:24px">Will You Join Us?</h2>
    <a href="/members/wedding-sites.cfm?mode=edit&template=#URLEncodedFormat(tplId)#" style="display:inline-block;padding:16px 48px;background:#HTMLEditFormat(T.accent)#;color:##fff;font-family:#HTMLEditFormat(T.bodyFont)#;font-size:0.9rem;letter-spacing:0.15em;text-transform:uppercase;border-radius:4px;font-weight:600">
        Use This Template
    </a>
</div>

<footer style="text-align:center;padding:48px 24px;border-top:1px solid #HTMLEditFormat(T.divider)#40;background:#HTMLEditFormat(T.light)#">
    <p style="font-family:#HTMLEditFormat(T.headingFont)#;font-size:1.5rem;color:#HTMLEditFormat(T.accent)#;font-style:italic">#HTMLEditFormat(sample.couple_name_1)# &amp; #HTMLEditFormat(sample.couple_name_2)#</p>
    <p style="font-size:0.75rem;opacity:0.5;letter-spacing:0.2em;text-transform:uppercase;margin-top:8px;color:#HTMLEditFormat(T.text)#">#HTMLEditFormat(weddingDateFormatted)#</p>
    <p style="font-size:0.7rem;opacity:0.35;margin-top:16px;color:#HTMLEditFormat(T.text)#">Created with &hearts; on digitalweddings.love</p>
</footer>

</cfoutput>
</body>
</html>
