<!---
    Sets emailTheme struct based on qSiteForEmail.template.
    Include this before any cfmail block that needs template-matched styling.
--->
<cfset tpl = lCase(trim(qSiteForEmail.template))>

<cfif tpl EQ "classic_gold">
    <cfset emailTheme = {
        bodyBg:       "##FDFAF5",
        headerBg:     "##2C2C2C",
        headerText:   "##FDFAF5",
        bodyCardBg:   "##FFFFFF",
        bodyText:     "##2C2C2C",
        accentColor:  "##B8860B",
        mutedText:    "##888888",
        dividerColor: "##E8E0D0",
        btnBg:        "##B8860B",
        btnText:      "##FFFFFF",
        btnRadius:    "4px",
        fontStack:    "'Palatino Linotype',Georgia,serif",
        headingFont:  "Georgia,'Times New Roman',serif",
        headingWeight:"700",
        eyebrow:      "You Are Cordially Invited",
        themeImage:   "dark-roses.jpg",
        themeImageBottom:""
    }>

<cfelseif tpl EQ "garden_romance">
    <cfset emailTheme = {
        bodyBg:       "##F2EEE8",
        headerBg:     "##3D5A3E",
        headerText:   "##FFFFFF",
        bodyCardBg:   "##FFFFFF",
        bodyText:     "##2D3A2E",
        accentColor:  "##7BAE7F",
        mutedText:    "##7A8A7B",
        dividerColor: "##D4E4D4",
        btnBg:        "##3D5A3E",
        btnText:      "##FFFFFF",
        btnRadius:    "30px",
        fontStack:    "Georgia,serif",
        headingFont:  "'Didot','Bodoni MT',Georgia,serif",
        headingWeight:"400",
        eyebrow:      "With Great Joy We Invite You",
        themeImage:   "garden-romance.jpg",
        themeImageBottom:""
    }>

<cfelseif tpl EQ "modern_minimal">
    <cfset emailTheme = {
        bodyBg:       "##F5F5F5",
        headerBg:     "##111111",
        headerText:   "##FFFFFF",
        bodyCardBg:   "##FFFFFF",
        bodyText:     "##111111",
        accentColor:  "##C4A265",
        mutedText:    "##888888",
        dividerColor: "##E0E0E0",
        btnBg:        "##111111",
        btnText:      "##FFFFFF",
        btnRadius:    "0px",
        fontStack:    "'Helvetica Neue',Arial,sans-serif",
        headingFont:  "'Helvetica Neue',Arial,sans-serif",
        headingWeight:"300",
        eyebrow:      "You Are Invited",
        themeImage:   "dark-texture.jpg",
        themeImageBottom:""
    }>

<cfelseif tpl EQ "royal_elegance">
    <cfset emailTheme = {
        bodyBg:       "##F8F5F0",
        headerBg:     "##1A0A2E",
        headerText:   "##F5E6C8",
        bodyCardBg:   "##FFFFFF",
        bodyText:     "##1A0A2E",
        accentColor:  "##C9A84C",
        mutedText:    "##888888",
        dividerColor: "##E0D5C0",
        btnBg:        "##1A0A2E",
        btnText:      "##F5E6C8",
        btnRadius:    "4px",
        fontStack:    "Georgia,serif",
        headingFont:  "Georgia,serif",
        headingWeight:"700",
        eyebrow:      "A Royal Invitation",
        themeImage:   "dark-bloom.jpg",
        themeImageBottom:""
    }>

<cfelseif tpl EQ "sunset_bliss">
    <cfset emailTheme = {
        bodyBg:       "##FFF8F0",
        headerBg:     "##E8643C",
        headerText:   "##FFFFFF",
        bodyCardBg:   "##FFFFFF",
        bodyText:     "##3A2010",
        accentColor:  "##E8643C",
        mutedText:    "##999999",
        dividerColor: "##FFD9C0",
        btnBg:        "##E8643C",
        btnText:      "##FFFFFF",
        btnRadius:    "30px",
        fontStack:    "Georgia,serif",
        headingFont:  "Georgia,serif",
        headingWeight:"400",
        eyebrow:      "Join Us to Celebrate",
        themeImage:   "first-light.jpg",
        themeImageBottom:""
    }>

<cfelseif tpl EQ "cultural_heritage">
    <cfset emailTheme = {
        bodyBg:       "##FBF6EE",
        headerBg:     "##8B1A1A",
        headerText:   "##FFF5E0",
        bodyCardBg:   "##FFFFFF",
        bodyText:     "##3A1A0A",
        accentColor:  "##C4922A",
        mutedText:    "##888888",
        dividerColor: "##F0DDB0",
        btnBg:        "##8B1A1A",
        btnText:      "##FFF5E0",
        btnRadius:    "4px",
        fontStack:    "Georgia,serif",
        headingFont:  "Georgia,serif",
        headingWeight:"700",
        eyebrow:      "You Are Warmly Invited",
        themeImage:   "dark-bloom.jpg",
        themeImageBottom:""
    }>

<cfelseif tpl EQ "christian_sacred">
    <cfset emailTheme = {
        bodyBg:       "##F9F7F4",
        headerBg:     "##4A3728",
        headerText:   "##F9F7F4",
        bodyCardBg:   "##FFFFFF",
        bodyText:     "##2C2018",
        accentColor:  "##9B8050",
        mutedText:    "##888888",
        dividerColor: "##E8DDD0",
        btnBg:        "##4A3728",
        btnText:      "##F9F7F4",
        btnRadius:    "4px",
        fontStack:    "Georgia,serif",
        headingFont:  "Georgia,serif",
        headingWeight:"700",
        eyebrow:      "Together in God's Grace",
        themeImage:   "pearl-blossom.jpg",
        themeImageBottom:"pearl-bottom.jpg"
    }>

<cfelseif tpl EQ "editorial_noir">
    <cfset emailTheme = {
        bodyBg:       "##1A1A1A",
        headerBg:     "##000000",
        headerText:   "##FFFFFF",
        bodyCardBg:   "##242424",
        bodyText:     "##E0E0E0",
        accentColor:  "##C8A96E",
        mutedText:    "##888888",
        dividerColor: "##333333",
        btnBg:        "##C8A96E",
        btnText:      "##000000",
        btnRadius:    "0px",
        fontStack:    "'Helvetica Neue',Arial,sans-serif",
        headingFont:  "'Helvetica Neue',Arial,sans-serif",
        headingWeight:"300",
        eyebrow:      "An Exclusive Invitation",
        themeImage:   "dark-texture.jpg",
        themeImageBottom:""
    }>

<cfelseif tpl EQ "pride_modern">
    <cfset emailTheme = {
        bodyBg:       "##FFFFFF",
        headerBg:     "##6B3FA0",
        headerText:   "##FFFFFF",
        bodyCardBg:   "##FFFFFF",
        bodyText:     "##2C2C2C",
        accentColor:  "##E040FB",
        mutedText:    "##888888",
        dividerColor: "##E8D8F8",
        btnBg:        "##6B3FA0",
        btnText:      "##FFFFFF",
        btnRadius:    "30px",
        fontStack:    "'Helvetica Neue',Arial,sans-serif",
        headingFont:  "'Helvetica Neue',Arial,sans-serif",
        headingWeight:"700",
        eyebrow:      "Love is Love — You Are Invited",
        themeImage:   "violet-floral-top.jpg",
        themeImageBottom:"violet-floral-bottom.jpg"
    }>

<cfelseif tpl EQ "islamic_elegance">
    <cfset emailTheme = {
        bodyBg:       "##F5F0E8",
        headerBg:     "##1B4332",
        headerText:   "##F5F0E8",
        bodyCardBg:   "##FFFFFF",
        bodyText:     "##1B2820",
        accentColor:  "##C9A84C",
        mutedText:    "##888888",
        dividerColor: "##D8CDBA",
        btnBg:        "##1B4332",
        btnText:      "##F5F0E8",
        btnRadius:    "4px",
        fontStack:    "Georgia,serif",
        headingFont:  "Georgia,serif",
        headingWeight:"700",
        eyebrow:      "Bismillah — You Are Invited",
        themeImage:   "garden-romance.jpg",
        themeImageBottom:""
    }>

<cfelseif tpl EQ "romantic_rose">
    <cfset emailTheme = {
        bodyBg:"##FAF0F0",headerBg:"##6B2D35",headerText:"##FDF8F6",bodyCardBg:"##FFFFFF",bodyText:"##3D1F20",
        accentColor:"##C4686A",mutedText:"##9B7B7C",dividerColor:"##F2D6D6",btnBg:"##C4686A",btnText:"##FFFFFF",
        btnRadius:"4px",fontStack:"Georgia,serif",headingFont:"Georgia,serif",headingWeight:"400",eyebrow:"With Love, We Invite You",
        themeImage:"roses-hero.jpeg",
        themeImageBottom:""
    }>

<cfelseif tpl EQ "midnight_rose" OR tpl EQ "midnight_garden" OR tpl EQ "midnight_peony">
    <cfset emailTheme = {
        bodyBg:"##1A1020",headerBg:"##0D0810",headerText:"##F5E6F0",bodyCardBg:"##2A1830",bodyText:"##F5E6F0",
        accentColor:"##C4687A",mutedText:"##A080A0",dividerColor:"##3A2040",btnBg:"##C4687A",btnText:"##FFFFFF",
        btnRadius:"4px",fontStack:"Georgia,serif",headingFont:"Georgia,serif",headingWeight:"400",eyebrow:"You Are Invited",
        themeImage:"midnight-peony.jpg",
        themeImageBottom:""
    }>

<cfelseif tpl EQ "first_light">
    <cfset emailTheme = {
        bodyBg:"##F8F4F0",headerBg:"##2C1810",headerText:"##F8F4F0",bodyCardBg:"##FFFFFF",bodyText:"##2C1810",
        accentColor:"##C4A06A",mutedText:"##888888",dividerColor:"##E8D8C0",btnBg:"##C4A06A",btnText:"##FFFFFF",
        btnRadius:"4px",fontStack:"Georgia,serif",headingFont:"Georgia,serif",headingWeight:"400",eyebrow:"A New Day Begins",
        themeImage:"first-light.jpg",
        themeImageBottom:""
    }>

<cfelseif tpl EQ "crimson_garden">
    <cfset emailTheme = {
        bodyBg:"##FDF8F6",headerBg:"##7B2835",headerText:"##FDFCFB",bodyCardBg:"##FFFFFF",bodyText:"##4A1020",
        accentColor:"##7B2835",mutedText:"##9C8078",dividerColor:"##EDD5D0",btnBg:"##7B2835",btnText:"##FFFFFF",
        btnRadius:"4px",fontStack:"Georgia,serif",headingFont:"Georgia,serif",headingWeight:"400",eyebrow:"With Joy We Invite You",
        themeImage:"rouge-peony-1.jpg",
        themeImageBottom:"rouge-peony-2.jpg"
    }>

<cfelseif tpl EQ "golden_affair">
    <cfset emailTheme = {
        bodyBg:"##FEFDFB",headerBg:"##1E1A14",headerText:"##FEFDFB",bodyCardBg:"##F7F0E3",bodyText:"##1E1A14",
        accentColor:"##C9A242",mutedText:"##9A8C78",dividerColor:"##EDE0C8",btnBg:"##C9A242",btnText:"##FFFFFF",
        btnRadius:"4px",fontStack:"Georgia,serif",headingFont:"Georgia,serif",headingWeight:"400",eyebrow:"A Golden Invitation",
        themeImage:"dark-roses.jpg",
        themeImageBottom:""
    }>

<cfelseif tpl EQ "indigo_bloom">
    <cfset emailTheme = {
        bodyBg:"##F0F0F8",headerBg:"##2A2060",headerText:"##FFFFFF",bodyCardBg:"##FFFFFF",bodyText:"##1A1840",
        accentColor:"##6860C0",mutedText:"##888888",dividerColor:"##D0D0F0",btnBg:"##2A2060",btnText:"##FFFFFF",
        btnRadius:"4px",fontStack:"Georgia,serif",headingFont:"Georgia,serif",headingWeight:"400",eyebrow:"You Are Invited",
        themeImage:"blue-floral-left.jpg",
        themeImageBottom:"blue-floral-right.jpg"
    }>

<cfelseif tpl EQ "velvet_peony">
    <cfset emailTheme = {
        bodyBg:"##F8F0EC",headerBg:"##111B2E",headerText:"##F8F0EC",bodyCardBg:"##FFFFFF",bodyText:"##111B2E",
        accentColor:"##C4A35A",mutedText:"##9A8878",dividerColor:"##EEE0D8",btnBg:"##7D2235",btnText:"##FFFFFF",
        btnRadius:"4px",fontStack:"Georgia,serif",headingFont:"Georgia,serif",headingWeight:"400",eyebrow:"You Are Invited",
        themeImage:"peony-top.jpg",
        themeImageBottom:"peony-bottom.jpg"
    }>

<cfelseif tpl EQ "violet_garden">
    <cfset emailTheme = {
        bodyBg:"##F5F0F8",headerBg:"##3D2060",headerText:"##FFFFFF",bodyCardBg:"##FFFFFF",bodyText:"##2A1840",
        accentColor:"##8060B0",mutedText:"##888888",dividerColor:"##D8C8F0",btnBg:"##3D2060",btnText:"##FFFFFF",
        btnRadius:"4px",fontStack:"Georgia,serif",headingFont:"Georgia,serif",headingWeight:"400",eyebrow:"With Joy We Invite You",
        themeImage:"violet-floral-top.jpg",
        themeImageBottom:"violet-floral-bottom.jpg"
    }>

<cfelseif tpl EQ "sage_wreath">
    <cfset emailTheme = {
        bodyBg:"##F5F8F4",headerBg:"##4A6650",headerText:"##FFFFFF",bodyCardBg:"##FFFFFF",bodyText:"##2C3A2E",
        accentColor:"##7A9B6A",mutedText:"##7A8A7B",dividerColor:"##C8DCC0",btnBg:"##4A6650",btnText:"##FFFFFF",
        btnRadius:"4px",fontStack:"Georgia,serif",headingFont:"Georgia,serif",headingWeight:"400",eyebrow:"With Great Joy We Invite You",
        themeImage:"sage-wreath.jpg",
        themeImageBottom:""
    }>

<cfelseif tpl EQ "blush_silk">
    <cfset emailTheme = {
        bodyBg:"##FDF8F6",headerBg:"##7A3D42",headerText:"##FDF8F6",bodyCardBg:"##FFFFFF",bodyText:"##4A1F24",
        accentColor:"##C06070",mutedText:"##998080",dividerColor:"##F0D8D8",btnBg:"##7A3D42",btnText:"##FFFFFF",
        btnRadius:"4px",fontStack:"Georgia,serif",headingFont:"Georgia,serif",headingWeight:"400",eyebrow:"You Are Invited",
        themeImage:"blush-silk.jpg",
        themeImageBottom:""
    }>

<cfelseif tpl EQ "rouge_peony">
    <cfset emailTheme = {
        bodyBg:"##FDF5F5",headerBg:"##801828",headerText:"##FFFFFF",bodyCardBg:"##FFFFFF",bodyText:"##3A1020",
        accentColor:"##C0304A",mutedText:"##998080",dividerColor:"##F0C8C8",btnBg:"##801828",btnText:"##FFFFFF",
        btnRadius:"4px",fontStack:"Georgia,serif",headingFont:"Georgia,serif",headingWeight:"400",eyebrow:"You Are Invited",
        themeImage:"rouge-peony-2.jpg",
        themeImageBottom:""
    }>

<cfelseif tpl EQ "rose_garden">
    <cfset emailTheme = {
        bodyBg:"##FFF0F3",headerBg:"##9C1C4A",headerText:"##FFFFFF",bodyCardBg:"##FFFFFF",bodyText:"##3A1525",
        accentColor:"##D63670",mutedText:"##A0687E",dividerColor:"##F9D0DF",btnBg:"##D63670",btnText:"##FFFFFF",
        btnRadius:"4px",fontStack:"Georgia,serif",headingFont:"Georgia,serif",headingWeight:"400",eyebrow:"Together Forever",
        themeImage:"rose-scatter.jpg",
        themeImageBottom:""
    }>

<cfelseif tpl EQ "dusty_rose">
    <cfset emailTheme = {
        bodyBg:"##FEF9F8",headerBg:"##7A4050",headerText:"##FEF9F8",bodyCardBg:"##FFFFFF",bodyText:"##3A2028",
        accentColor:"##C07080",mutedText:"##998888",dividerColor:"##F0D8D8",btnBg:"##7A4050",btnText:"##FFFFFF",
        btnRadius:"4px",fontStack:"Georgia,serif",headingFont:"Georgia,serif",headingWeight:"400",eyebrow:"You Are Invited",
        themeImage:"dusty-rose.jpg",
        themeImageBottom:""
    }>

<cfelseif tpl EQ "blush_bouquet">
    <cfset emailTheme = {
        bodyBg:"##FDF8F8",headerBg:"##8A3848",headerText:"##FDF8F8",bodyCardBg:"##FFFFFF",bodyText:"##3A1820",
        accentColor:"##C06878",mutedText:"##998888",dividerColor:"##F0D0D0",btnBg:"##8A3848",btnText:"##FFFFFF",
        btnRadius:"30px",fontStack:"Georgia,serif",headingFont:"Georgia,serif",headingWeight:"400",eyebrow:"With Love We Invite You",
        themeImage:"blush-bouquet.jpg",
        themeImageBottom:""
    }>

<cfelseif tpl EQ "scarlet_rose" OR tpl EQ "bordeaux_rose" OR tpl EQ "blushing_rose">
    <cfset emailTheme = {
        bodyBg:"##FDF5F5",headerBg:"##6B1020",headerText:"##FFFFFF",bodyCardBg:"##FFFFFF",bodyText:"##3A0810",
        accentColor:"##B02030",mutedText:"##997080",dividerColor:"##F0C0C0",btnBg:"##6B1020",btnText:"##FFFFFF",
        btnRadius:"4px",fontStack:"Georgia,serif",headingFont:"Georgia,serif",headingWeight:"400",eyebrow:"You Are Invited",
        themeImage:"scarlet-rose.jpg",
        themeImageBottom:""
    }>

<cfelseif tpl EQ "velvet_rouge">
    <cfset emailTheme = {
        bodyBg:"##F8F0EE",headerBg:"##5A2020",headerText:"##F8F0EE",bodyCardBg:"##FFFFFF",bodyText:"##3A1818",
        accentColor:"##B06040",mutedText:"##998878",dividerColor:"##E8D0C8",btnBg:"##5A2020",btnText:"##FFFFFF",
        btnRadius:"4px",fontStack:"Georgia,serif",headingFont:"Georgia,serif",headingWeight:"400",eyebrow:"You Are Invited",
        themeImage:"velvet-rouge.jpg",
        themeImageBottom:""
    }>

<cfelseif tpl EQ "rose_wood">
    <cfset emailTheme = {
        bodyBg:"##F8F0EE",headerBg:"##5A2020",headerText:"##F8F0EE",bodyCardBg:"##FFFFFF",bodyText:"##3A1818",
        accentColor:"##B06040",mutedText:"##998878",dividerColor:"##E8D0C8",btnBg:"##5A2020",btnText:"##FFFFFF",
        btnRadius:"4px",fontStack:"Georgia,serif",headingFont:"Georgia,serif",headingWeight:"400",eyebrow:"You Are Invited",
        themeImage:"rose-wood.jpg",
        themeImageBottom:""
    }>

<cfelseif tpl EQ "copper_rose">
    <cfset emailTheme = {
        bodyBg:"##F8F0EE",headerBg:"##5A2020",headerText:"##F8F0EE",bodyCardBg:"##FFFFFF",bodyText:"##3A1818",
        accentColor:"##B06040",mutedText:"##998878",dividerColor:"##E8D0C8",btnBg:"##5A2020",btnText:"##FFFFFF",
        btnRadius:"4px",fontStack:"Georgia,serif",headingFont:"Georgia,serif",headingWeight:"400",eyebrow:"You Are Invited",
        themeImage:"copper-rose.jpg",
        themeImageBottom:""
    }>

<cfelseif tpl EQ "petal_glow">
    <cfset emailTheme = {
        bodyBg:"##FDF8F8",headerBg:"##7A4858",headerText:"##FFFFFF",bodyCardBg:"##FFFFFF",bodyText:"##3A2030",
        accentColor:"##C07888",mutedText:"##998888",dividerColor:"##F0D8E0",btnBg:"##7A4858",btnText:"##FFFFFF",
        btnRadius:"30px",fontStack:"Georgia,serif",headingFont:"Georgia,serif",headingWeight:"400",eyebrow:"You Are Invited",
        themeImage:"petal-glow.jpg",
        themeImageBottom:""
    }>

<cfelseif tpl EQ "pearl_wreath" OR tpl EQ "pearl_garden">
    <cfset emailTheme = {
        bodyBg:"##FDF8F8",headerBg:"##7A4858",headerText:"##FFFFFF",bodyCardBg:"##FFFFFF",bodyText:"##3A2030",
        accentColor:"##C07888",mutedText:"##998888",dividerColor:"##F0D8E0",btnBg:"##7A4858",btnText:"##FFFFFF",
        btnRadius:"30px",fontStack:"Georgia,serif",headingFont:"Georgia,serif",headingWeight:"400",eyebrow:"You Are Invited",
        themeImage:"pearl-wreath.jpg",
        themeImageBottom:"pearl-bottom.jpg"
    }>

<cfelseif tpl EQ "tulle_rose">
    <cfset emailTheme = {
        bodyBg:"##FDF5F5",headerBg:"##8A2030",headerText:"##FFFFFF",bodyCardBg:"##FFFFFF",bodyText:"##3A1020",
        accentColor:"##C03040",mutedText:"##998080",dividerColor:"##F0C8C8",btnBg:"##8A2030",btnText:"##FFFFFF",
        btnRadius:"4px",fontStack:"Georgia,serif",headingFont:"Georgia,serif",headingWeight:"400",eyebrow:"You Are Invited",
        themeImage:"tulle-rose.jpg",
        themeImageBottom:""
    }>

<cfelseif tpl EQ "crimson_frame">
    <cfset emailTheme = {
        bodyBg:"##FDF5F5",headerBg:"##8A2030",headerText:"##FFFFFF",bodyCardBg:"##FFFFFF",bodyText:"##3A1020",
        accentColor:"##C03040",mutedText:"##998080",dividerColor:"##F0C8C8",btnBg:"##8A2030",btnText:"##FFFFFF",
        btnRadius:"4px",fontStack:"Georgia,serif",headingFont:"Georgia,serif",headingWeight:"400",eyebrow:"You Are Invited",
        themeImage:"crimson-frame.jpg",
        themeImageBottom:""
    }>

<cfelseif tpl EQ "bloom_frame">
    <cfset emailTheme = {
        bodyBg:"##FDF5F5",headerBg:"##8A2030",headerText:"##FFFFFF",bodyCardBg:"##FFFFFF",bodyText:"##3A1020",
        accentColor:"##C03040",mutedText:"##998080",dividerColor:"##F0C8C8",btnBg:"##8A2030",btnText:"##FFFFFF",
        btnRadius:"4px",fontStack:"Georgia,serif",headingFont:"Georgia,serif",headingWeight:"400",eyebrow:"You Are Invited",
        themeImage:"bloom-frame.jpg",
        themeImageBottom:""
    }>

<cfelseif tpl EQ "peach_silk">
    <cfset emailTheme = {
        bodyBg:"##FFF5F0",headerBg:"##8A4030",headerText:"##FFFFFF",bodyCardBg:"##FFFFFF",bodyText:"##3A2018",
        accentColor:"##D07848",mutedText:"##998878",dividerColor:"##F8D8C8",btnBg:"##8A4030",btnText:"##FFFFFF",
        btnRadius:"30px",fontStack:"Georgia,serif",headingFont:"Georgia,serif",headingWeight:"400",eyebrow:"You Are Invited",
        themeImage:"peach-silk.jpg",
        themeImageBottom:""
    }>

<cfelseif tpl EQ "rose_cascade">
    <cfset emailTheme = {
        bodyBg:"##FFF5F0",headerBg:"##8A4030",headerText:"##FFFFFF",bodyCardBg:"##FFFFFF",bodyText:"##3A2018",
        accentColor:"##D07848",mutedText:"##998878",dividerColor:"##F8D8C8",btnBg:"##8A4030",btnText:"##FFFFFF",
        btnRadius:"30px",fontStack:"Georgia,serif",headingFont:"Georgia,serif",headingWeight:"400",eyebrow:"You Are Invited",
        themeImage:"rose-cascade.jpg",
        themeImageBottom:""
    }>

<cfelseif tpl EQ "sapphire_rose">
    <cfset emailTheme = {
        bodyBg:       "##F0F4FA",
        headerBg:     "##020408",
        headerText:   "##E8EEF4",
        bodyCardBg:   "##FFFFFF",
        bodyText:     "##0D1520",
        accentColor:  "##2B5FA8",
        mutedText:    "##6A7A8C",
        dividerColor: "##D0DCF0",
        btnBg:        "##2B5FA8",
        btnText:      "##FFFFFF",
        btnRadius:    "4px",
        fontStack:    "Georgia,serif",
        headingFont:  "Georgia,serif",
        headingWeight:"400",
        eyebrow:      "With Love We Invite You",
        themeImage:   "sapphire-rose.jpg",
        themeImageBottom:""
    }>

<cfelseif tpl EQ "blush_pearl">
    <cfset emailTheme = {
        bodyBg:       "##FDFAF7",
        headerBg:     "##2C1A14",
        headerText:   "##FDFAF7",
        bodyCardBg:   "##FFFFFF",
        bodyText:     "##2C1A14",
        accentColor:  "##B8945A",
        mutedText:    "##8C7A6A",
        dividerColor: "##EDE4D8",
        btnBg:        "##B8945A",
        btnText:      "##FFFFFF",
        btnRadius:    "4px",
        fontStack:    "Georgia,serif",
        headingFont:  "Georgia,serif",
        headingWeight:"400",
        eyebrow:      "With Love We Invite You",
        themeImage:   "blush-pearl.jpg",
        themeImageBottom:""
    }>

<cfelseif tpl EQ "delta_inspired">
    <cfset emailTheme = {
        bodyBg:       "##FDF8F6",
        headerBg:     "##CC0000",
        headerText:   "##FFFFFF",
        bodyCardBg:   "##FFFFFF",
        bodyText:     "##1A0A0A",
        accentColor:  "##CC0000",
        mutedText:    "##888888",
        dividerColor: "##F0D0D0",
        btnBg:        "##CC0000",
        btnText:      "##FFFFFF",
        btnRadius:    "4px",
        fontStack:    "Georgia,serif",
        headingFont:  "Georgia,serif",
        headingWeight:"400",
        eyebrow:      "With Love We Invite You",
        themeImage:   "delta-inspired.jpg",
        themeImageBottom:""
    }>

<cfelseif tpl EQ "aka_inspired">
    <cfset emailTheme = {
        bodyBg:       "##FDF5F8",
        headerBg:     "##1A6B3C",
        headerText:   "##FFFFFF",
        bodyCardBg:   "##FFFFFF",
        bodyText:     "##1A3A2A",
        accentColor:  "##D4478A",
        mutedText:    "##7A8A7E",
        dividerColor: "##F0D0E0",
        btnBg:        "##D4478A",
        btnText:      "##FFFFFF",
        btnRadius:    "30px",
        fontStack:    "Georgia,serif",
        headingFont:  "Georgia,serif",
        headingWeight:"400",
        eyebrow:      "With Love We Invite You",
        themeImage:   "aka-inspired.jpg",
        themeImageBottom:""
    }>

<cfelse>
    <!--- Default fallback --->
    <cfset emailTheme = {
        bodyBg:       "##F5F5F5",
        headerBg:     "##2C2C2C",
        headerText:   "##FFFFFF",
        bodyCardBg:   "##FFFFFF",
        bodyText:     "##2C2C2C",
        accentColor:  "##B8860B",
        mutedText:    "##888888",
        dividerColor: "##E0E0E0",
        btnBg:        "##B8860B",
        btnText:      "##FFFFFF",
        btnRadius:    "4px",
        fontStack:    "Georgia,serif",
        headingFont:  "Georgia,serif",
        headingWeight:"700",
        eyebrow:      "You Are Invited",
        themeImage:   "roses-hero.jpeg",
        themeImageBottom:""
    }>
</cfif>
