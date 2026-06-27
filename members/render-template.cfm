<cfinclude template="../includes/auth-check.cfm">
<cfparam name="url.template" default="classic_gold">
<cfparam name="url.siteId" default="0">
<cfparam name="url.preview" default="0">
<cfset tplId = lCase(reReplace(trim(url.template),"[^a-z_]","","all"))>

<cfinclude template="../includes/template-list.cfm">
<cfif !listFind(application.templates, tplId)><cfset tplId = "classic_gold"></cfif>

<!--- Sample site data struct --->
<cfset site = {
    couple_name_1:      "Aisha",
    couple_name_2:      "Marcus",
    wedding_date:       "2025-09-20",
    venue_name:         "The Grand Ballroom",
    venue_address:      "Atlanta, Georgia",
    story:              "We met at a rooftop gallery opening on a warm summer evening. Marcus was the one who caught my eye across the room — and the rest, as they say, is history. After three years of adventures, stolen moments, and too many late-night conversations to count, we're finally making it official.",
    dress_code:         "Black Tie Optional. We encourage our guests to celebrate in their finest attire — feel free to incorporate cultural dress and rich jewel tones.",
    travel_info:        "For out-of-town guests, we recommend the Grand Hyatt Atlanta (just 5 minutes from the venue). Hartsfield-Jackson Airport is 25 minutes away.",
    things_to_do:       "Atlanta has so much to offer! Visit the National Center for Civil and Human Rights, explore Ponce City Market, or take a stroll through Piedmont Park.",
    scripture:          "Two are better than one, because they have a good return for their labor. — Ecclesiastes 4:9",
    hero_image_url:     "",
    couple_photo_url:   "/assets/couple-placeholder.jpg",
    slug:               "preview",
    gallery_images_json:'["/assets/photos/hero-couple.jpg","/assets/photos/couple-portrait.jpg","/assets/photos/bride-groom-planning.jpg","/assets/photos/couple-celebration.jpg"]',
    faq_json:           '[{"question":"Is there parking at the venue?","answer":"Yes! Complimentary valet parking is available for all guests."},{"question":"Are children welcome?","answer":"We love your little ones, but we have chosen to make this an adults-only celebration."},{"question":"What time should I arrive?","answer":"Doors open at 5:30 PM. The ceremony begins promptly at 6:00 PM."}]',
    reception_venue_name:    "The Rose Garden Pavilion",
    reception_venue_address: "Atlanta, Georgia",
    travel_links_json:       '[{"label":"View on Google Maps","url":"https://maps.google.com/"},{"label":"Book the Grand Hyatt","url":"https://www.hyatt.com/"}]',
    things_links_json:       '[{"label":"Visit Ponce City Market","url":"https://poncecitymarket.com/"},{"label":"Explore Piedmont Park","url":"https://www.piedmontpark.org/"}]',
    is_preview:              true,
    back_url:                "/members/wedding-sites.cfm",
    registry_url:            "https://www.amazon.com/wedding"
}>

<div style="position:fixed;top:0;left:0;right:0;z-index:99999;background:#1a1a1a;color:#fff;display:flex;align-items:center;justify-content:space-between;padding:10px 20px;font-family:Arial,sans-serif;font-size:13px">
  <a href="/members/wedding-sites.cfm" style="color:#aaa;text-decoration:none;font-size:13px;display:flex;align-items:center;gap:6px">&larr; Back</a>
  <span style="opacity:.6">Previewing: <strong style="color:#fff"><cfoutput>#replace(tplId,"_"," ","all")#</cfoutput></strong> &mdash; sample data</span>
  <a href="/members/wedding-sites.cfm" style="display:inline-flex;align-items:center;justify-content:center;width:32px;height:32px;background:rgba(255,255,255,.12);color:#fff;border-radius:50%;text-decoration:none;font-size:18px;line-height:1" title="Close preview">&times;</a>
</div>
<div style="height:44px"></div>
<cfinclude template="templates/#tplId#.cfm">
