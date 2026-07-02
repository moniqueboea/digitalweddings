<!---
  includes/wedding-countdown.cfm
  Compact countdown card styled to match the site's card/gold aesthetic.

  Required variables (set before including):
    cdDays        - integer: days until wedding (negative = past)
    cdName1       - string: partner 1 name (HTMLEditFormat already applied)
    cdName2       - string: partner 2 name (HTMLEditFormat already applied)
    cdDate        - string: formatted wedding date, e.g. "September 5, 2027" - or ""
    cdLocation    - string: venue name + address - or ""
    cdHasDate     - boolean: true if wedding date is set
    cdBg          - (unused in compact style)
    cdText        - (unused in compact style)
    cdAccent      - (unused in compact style)
    cdHeadingFont - (unused in compact style)
--->
<cfoutput>
<div style="background:var(--bg-card);border:1px solid var(--border);border-radius:var(--radius);padding:24px 32px;margin-bottom:32px;display:flex;align-items:center;gap:32px;flex-wrap:wrap">

    <cfif !cdHasDate>
        <div style="display:flex;align-items:center;gap:16px;flex:1;min-width:0">
            <div style="width:44px;height:44px;background:var(--gold-light);border-radius:50%;display:flex;align-items:center;justify-content:center;flex-shrink:0">
                <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="var(--gold)" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
            </div>
            <div>
                <div style="font-family:var(--font-heading);font-size:16px;font-weight:600;color:var(--text);margin-bottom:3px">Add Your Wedding Date</div>
                <div style="font-size:13px;color:var(--text-muted)">Set your date to see a personalized countdown</div>
            </div>
        </div>
        <a href="/members/wedding-sites.cfm" class="btn btn-outline btn-sm" style="flex-shrink:0">Set Date &rarr;</a>

    <cfelseif cdDays EQ 0>
        <div style="display:flex;align-items:center;gap:16px;flex:1;min-width:0">
            <div style="width:44px;height:44px;background:var(--gold-light);border-radius:50%;display:flex;align-items:center;justify-content:center;flex-shrink:0">
                <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="var(--gold)" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z"/></svg>
            </div>
            <div>
                <div style="font-family:var(--font-heading);font-size:16px;font-weight:600;color:var(--gold);margin-bottom:3px">Today Is Your Wedding Day!</div>
                <div style="font-size:13px;color:var(--text-muted)">Congratulations, #cdName1# &amp; #cdName2#!</div>
            </div>
        </div>

    <cfelseif cdDays LT 0>
        <div style="display:flex;align-items:center;gap:16px;flex:1;min-width:0">
            <div style="width:44px;height:44px;background:var(--gold-light);border-radius:50%;display:flex;align-items:center;justify-content:center;flex-shrink:0">
                <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="var(--gold)" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z"/></svg>
            </div>
            <div>
                <div style="font-family:var(--font-heading);font-size:16px;font-weight:600;color:var(--text);margin-bottom:3px">Congratulations on Your Wedding!</div>
                <div style="font-size:13px;color:var(--text-muted)">#cdName1# &amp; #cdName2##len(cdDate) ? " &mdash; " & cdDate : ""#</div>
            </div>
        </div>

    <cfelse>
        <!--- Active countdown --->
        <div style="text-align:center;flex-shrink:0;min-width:80px">
            <div style="font-family:var(--font-display);font-size:52px;font-weight:700;color:var(--gold);line-height:1">#cdDays#</div>
            <div style="font-size:10px;letter-spacing:0.15em;text-transform:uppercase;color:var(--text-muted);margin-top:2px">#cdDays EQ 1 ? "Day" : "Days"# to go</div>
        </div>

        <div style="width:1px;height:52px;background:var(--border);flex-shrink:0"></div>

        <div style="flex:1;min-width:0">
            <div style="font-size:10px;letter-spacing:0.15em;text-transform:uppercase;color:var(--gold);margin-bottom:6px">Wedding Countdown</div>
            <div style="font-family:var(--font-heading);font-size:17px;font-weight:600;color:var(--text);margin-bottom:4px">#cdName1# &amp; #cdName2#</div>
            <div style="font-size:13px;color:var(--text-muted)">
                #len(cdDate) ? cdDate : ""##len(cdDate) && len(cdLocation) ? " &nbsp;&middot;&nbsp; " : ""##len(cdLocation) ? cdLocation : ""#
            </div>
        </div>
    </cfif>

</div>
</cfoutput>
