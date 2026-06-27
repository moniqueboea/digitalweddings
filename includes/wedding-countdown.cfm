<!---
  includes/wedding-countdown.cfm
  Reusable wedding countdown hero block.

  Required variables (set before including):
    cdDays        — integer: days until wedding (negative = past)
    cdName1       — string: partner 1 name (HTMLEditFormat already applied)
    cdName2       — string: partner 2 name (HTMLEditFormat already applied)
    cdDate        — string: formatted wedding date, e.g. "September 5, 2027" — or ""
    cdLocation    — string: venue name + address — or ""
    cdHasDate     — boolean: true if wedding date is set
    cdBg          — CSS color for section background
    cdText        — CSS color for text
    cdAccent      — CSS color for the big number and accents
    cdHeadingFont — CSS font-family for headings
--->
<cfoutput>
<div style="background:#cdBg#;padding:52px 20px;text-align:center;border-radius:12px;margin-bottom:40px;position:relative;overflow:hidden">

    <!--- Decorative rings --->
    <div style="position:absolute;top:-60px;left:-60px;width:200px;height:200px;border-radius:50%;border:1px solid #cdAccent#;opacity:0.12"></div>
    <div style="position:absolute;bottom:-40px;right:-40px;width:150px;height:150px;border-radius:50%;border:1px solid #cdAccent#;opacity:0.10"></div>

    <cfif !cdHasDate>
        <!--- No date set --->
        <div style="font-size:48px;margin-bottom:12px">&#128197;</div>
        <p style="color:#cdText#;font-family:#cdHeadingFont#;font-size:22px;font-weight:600;margin:0 0 10px;opacity:0.9">
            Your Wedding Countdown Awaits
        </p>
        <p style="color:#cdText#;font-size:15px;margin:0 0 24px;opacity:0.65;max-width:420px;margin-left:auto;margin-right:auto;line-height:1.7">
            Add your wedding date to see your personalized countdown.
        </p>
        <a href="/members/wedding-sites.cfm" style="display:inline-block;padding:13px 36px;background:#cdAccent#;color:#fff;font-size:13px;font-weight:700;letter-spacing:1.5px;text-transform:uppercase;text-decoration:none;border-radius:4px">
            Add Your Wedding Date
        </a>

    <cfelseif cdDays EQ 0>
        <!--- Wedding day --->
        <div style="font-size:52px;margin-bottom:8px">&#10084;&#65039;</div>
        <p style="color:#cdAccent#;font-family:#cdHeadingFont#;font-size:42px;font-weight:700;margin:0 0 8px;line-height:1.1">
            Today Is Your Wedding Day!
        </p>
        <p style="color:#cdText#;font-size:19px;margin:0;opacity:0.8;font-family:#cdHeadingFont#">
            Congratulations, #cdName1# &amp; #cdName2#! &#127881;
        </p>

    <cfelseif cdDays LT 0>
        <!--- Wedding has passed --->
        <div style="font-size:48px;margin-bottom:12px">&#127881;</div>
        <p style="color:#cdAccent#;font-family:#cdHeadingFont#;font-size:34px;font-weight:700;margin:0 0 8px;line-height:1.1">
            Congratulations on Your Wedding!
        </p>
        <p style="color:#cdText#;font-size:17px;margin:0;opacity:0.75;font-family:#cdHeadingFont#">
            #cdName1# &amp; #cdName2# — wishing you a lifetime of love.
        </p>

    <cfelseif cdDays LTE 30>
        <!--- Under 30 days --->
        <p style="color:#cdAccent#;font-size:11px;letter-spacing:6px;text-transform:uppercase;margin:0 0 8px;opacity:0.9;font-family:Arial,sans-serif">
            &#127881; Almost Time!
        </p>
        <div style="font-family:#cdHeadingFont#;font-size:108px;font-weight:700;color:#cdAccent#;line-height:1;margin:0 0 4px">
            #cdDays#
        </div>
        <p style="color:#cdText#;font-family:#cdHeadingFont#;font-size:26px;font-weight:400;margin:0 0 6px;opacity:0.9">
            #cdDays EQ 1 ? "Day" : "Days"# Until &ldquo;I Do!&rdquo;
        </p>
        <p style="color:#cdText#;font-size:16px;margin:0 0 28px;opacity:0.65;letter-spacing:1px;font-family:Arial,sans-serif">
            #cdName1# &amp; #cdName2#
        </p>

        <cfif len(cdDate) OR len(cdLocation)>
        <div style="display:inline-block;border-top:1px solid #cdAccent#;border-bottom:1px solid #cdAccent#;padding:14px 36px;opacity:0.85">
            <cfif len(cdDate)>
            <p style="color:#cdText#;font-size:17px;font-weight:600;margin:0 0 4px;font-family:#cdHeadingFont#">#cdDate#</p>
            </cfif>
            <cfif len(cdLocation)>
            <p style="color:#cdText#;font-size:14px;margin:0;opacity:0.75;font-family:Arial,sans-serif">#cdLocation#</p>
            </cfif>
        </div>
        </cfif>

    <cfelse>
        <!--- 31+ days away --->
        <p style="color:#cdAccent#;font-size:11px;letter-spacing:6px;text-transform:uppercase;margin:0 0 8px;opacity:0.9;font-family:Arial,sans-serif">
            &#128141; The Big Day
        </p>
        <div style="font-family:#cdHeadingFont#;font-size:108px;font-weight:700;color:#cdAccent#;line-height:1;margin:0 0 4px">
            #cdDays#
        </div>
        <p style="color:#cdText#;font-family:#cdHeadingFont#;font-size:26px;font-weight:400;margin:0 0 6px;opacity:0.9">
            #cdDays EQ 1 ? "Day" : "Days"# Until &ldquo;I Do!&rdquo;
        </p>
        <p style="color:#cdText#;font-size:16px;margin:0 0 28px;opacity:0.65;letter-spacing:1px;font-family:Arial,sans-serif">
            #cdName1# &amp; #cdName2#
        </p>

        <cfif len(cdDate) OR len(cdLocation)>
        <div style="display:inline-block;border-top:1px solid #cdAccent#;border-bottom:1px solid #cdAccent#;padding:14px 36px;opacity:0.85">
            <cfif len(cdDate)>
            <p style="color:#cdText#;font-size:17px;font-weight:600;margin:0 0 4px;font-family:#cdHeadingFont#">#cdDate#</p>
            </cfif>
            <cfif len(cdLocation)>
            <p style="color:#cdText#;font-size:14px;margin:0;opacity:0.75;font-family:Arial,sans-serif">#cdLocation#</p>
            </cfif>
        </div>
        </cfif>
    </cfif>

</div>
</cfoutput>
