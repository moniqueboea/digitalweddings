<cfinclude template="admin-check.cfm">
<cfset pageTitle  = "Vendor Analytics | Admin">
<cfset activePage = "admin">
<cfparam name="url.vendorId" default="0">
<cfparam name="url.days"     default="30">

<!--- Auto-create analytics table if missing --->
<cftry>
<cfquery datasource="#application.config.datasource#">
    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME='VendorAnalytics')
    CREATE TABLE dbo.VendorAnalytics (
        analytics_id bigint IDENTITY(1,1) PRIMARY KEY,
        vendor_id    bigint NOT NULL,
        event_type   varchar(30) NOT NULL,
        event_date   date NOT NULL,
        created_at   datetime2 NOT NULL DEFAULT SYSUTCDATETIME()
    )
</cfquery>
<cfcatch></cfcatch>
</cftry>

<cfset daysBack = isNumeric(url.days) AND url.days GT 0 ? val(url.days) : 30>

<!--- Summary stats per vendor --->
<cfquery name="qSummary" datasource="#application.config.datasource#">
    SELECT v.vendor_id, v.business_name, v.category, v.status,
        SUM(CASE WHEN a.event_type = 'view'          THEN 1 ELSE 0 END) AS profile_views,
        SUM(CASE WHEN a.event_type = 'website_click' THEN 1 ELSE 0 END) AS website_clicks,
        SUM(CASE WHEN a.event_type = 'email_click'   THEN 1 ELSE 0 END) AS email_clicks,
        SUM(CASE WHEN a.event_type = 'phone_click'   THEN 1 ELSE 0 END) AS phone_clicks,
        COUNT(a.analytics_id) AS total_events
    FROM dbo.Vendors v
    LEFT JOIN dbo.VendorAnalytics a ON a.vendor_id = v.vendor_id
        AND a.event_date >= CAST(DATEADD(day, -<cfqueryparam value="#daysBack#" cfsqltype="cf_sql_integer">, SYSUTCDATETIME()) AS date)
    WHERE v.status = 'approved'
    GROUP BY v.vendor_id, v.business_name, v.category, v.status
    ORDER BY total_events DESC, v.business_name
</cfquery>

<!--- Daily trend for selected vendor or all vendors --->
<cfquery name="qTrend" datasource="#application.config.datasource#">
    SELECT a.event_date, a.event_type, COUNT(*) AS cnt
    FROM dbo.VendorAnalytics a
    INNER JOIN dbo.Vendors v ON v.vendor_id = a.vendor_id AND v.status = 'approved'
    WHERE a.event_date >= CAST(DATEADD(day, -<cfqueryparam value="#daysBack#" cfsqltype="cf_sql_integer">, SYSUTCDATETIME()) AS date)
    <cfif isNumeric(url.vendorId) AND url.vendorId GT 0>
        AND a.vendor_id = <cfqueryparam value="#url.vendorId#" cfsqltype="cf_sql_bigint">
    </cfif>
    GROUP BY a.event_date, a.event_type
    ORDER BY a.event_date
</cfquery>

<!--- Totals --->
<cfset totalViews   = 0>
<cfset totalClicks  = 0>
<cfset totalEmails  = 0>
<cfloop query="qSummary">
    <cfset totalViews  = totalViews  + profile_views>
    <cfset totalClicks = totalClicks + website_clicks>
    <cfset totalEmails = totalEmails + email_clicks>
</cfloop>

<cfinclude template="../includes/layout-start.cfm">
<style>
.stat-grid { display:grid;grid-template-columns:repeat(3,1fr);gap:16px;margin-bottom:32px }
.stat-box  { background:var(--bg-card,#fff);border:1px solid var(--border);border-radius:10px;padding:20px 24px;text-align:center }
.stat-box .num { font-size:32px;font-weight:700;color:var(--gold);line-height:1 }
.stat-box .lbl { font-size:12px;letter-spacing:.1em;text-transform:uppercase;color:var(--text-muted);margin-top:6px }
@media(max-width:600px){ .stat-grid { grid-template-columns:1fr } }
</style>
<section style="padding:60px 0">
<div class="container">

    <div class="page-header">
        <p class="eyebrow"><a href="/admin/index.cfm" style="color:var(--gold)">Admin</a> &rsaquo; <a href="/admin/vendors.cfm" style="color:var(--gold)">Vendors</a></p>
        <h1>Vendor <span class="script">Analytics</span></h1>
    </div>

    <!--- Date range filter --->
    <cfoutput>
    <div style="display:flex;gap:8px;margin-bottom:28px;flex-wrap:wrap;align-items:center">
        <span style="font-size:13px;color:var(--text-muted)">Period:</span>
        <a href="vendor-analytics.cfm?days=7&vendorId=#url.vendorId#"  class="btn btn-sm #daysBack EQ 7  ? 'btn-primary' : 'btn-ghost'#">7 days</a>
        <a href="vendor-analytics.cfm?days=30&vendorId=#url.vendorId#" class="btn btn-sm #daysBack EQ 30 ? 'btn-primary' : 'btn-ghost'#">30 days</a>
        <a href="vendor-analytics.cfm?days=90&vendorId=#url.vendorId#" class="btn btn-sm #daysBack EQ 90 ? 'btn-primary' : 'btn-ghost'#">90 days</a>
        <cfif isNumeric(url.vendorId) AND url.vendorId GT 0>
            <a href="vendor-analytics.cfm?days=#daysBack#" class="btn btn-sm btn-ghost" style="border-color:var(--gold);color:var(--gold)">Clear vendor filter</a>
        </cfif>
    </div>
    </cfoutput>

    <!--- Overall totals --->
    <div class="stat-grid">
        <div class="stat-box">
            <div class="num"><cfoutput>#numberFormat(totalViews)#</cfoutput></div>
            <div class="lbl">Profile Views</div>
        </div>
        <div class="stat-box">
            <div class="num"><cfoutput>#numberFormat(totalClicks)#</cfoutput></div>
            <div class="lbl">Website Clicks</div>
        </div>
        <div class="stat-box">
            <div class="num"><cfoutput>#numberFormat(totalEmails)#</cfoutput></div>
            <div class="lbl">Email Inquiries</div>
        </div>
    </div>

    <!--- Per-vendor table --->
    <div class="panel" style="padding:0;margin-bottom:32px">
        <div style="padding:16px 20px;border-bottom:1px solid var(--border)">
            <p class="panel-title" style="margin:0">By Vendor - last <cfoutput>#daysBack#</cfoutput> days</p>
        </div>
        <div class="table-wrap">
        <table>
            <thead>
                <tr>
                    <th>Vendor</th>
                    <th>Category</th>
                    <th style="text-align:center">Views</th>
                    <th style="text-align:center">Website Clicks</th>
                    <th style="text-align:center">Email Clicks</th>
                    <th style="text-align:center">Phone Clicks</th>
                    <th></th>
                </tr>
            </thead>
            <tbody>
            <cfoutput query="qSummary">
            <tr>
                <td><strong>#HTMLEditFormat(business_name)#</strong></td>
                <td><span class="badge badge-gray">#HTMLEditFormat(category)#</span></td>
                <td style="text-align:center;font-weight:600">#numberFormat(profile_views)#</td>
                <td style="text-align:center">#numberFormat(website_clicks)#</td>
                <td style="text-align:center">#numberFormat(email_clicks)#</td>
                <td style="text-align:center">#numberFormat(phone_clicks)#</td>
                <td>
                    <a href="vendor-analytics.cfm?days=#daysBack#&vendorId=#vendor_id#" class="btn btn-ghost btn-sm">Filter</a>
                </td>
            </tr>
            </cfoutput>
            </tbody>
        </table>
        </div>
    </div>

    <!--- Daily trend chart --->
    <div class="panel">
        <p class="panel-title">Daily Trend</p>
        <cfif qTrend.recordCount>
        <canvas id="trendChart" height="80"></canvas>
        <cfelse>
        <p style="color:var(--text-muted);font-size:14px">No data yet for this period. Analytics will appear once vendors start receiving visits.</p>
        </cfif>
    </div>

</div>
</section>

<cfif qTrend.recordCount>
<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
<cfoutput>
<script>
var rawData = [
<cfloop query="qTrend">
    { date: "#dateFormat(event_date,'yyyy-mm-dd')#", type: "#JSStringFormat(event_type)#", cnt: #cnt# },
</cfloop>
];

var dateSet = {};
rawData.forEach(function(r){
    if (!dateSet[r.date]) dateSet[r.date] = { view:0, website_click:0, email_click:0, phone_click:0 };
    dateSet[r.date][r.type] = (dateSet[r.date][r.type]||0) + r.cnt;
});
var labels = Object.keys(dateSet).sort();
var views   = labels.map(function(d){ return dateSet[d].view||0; });
var wclicks = labels.map(function(d){ return dateSet[d].website_click||0; });
var eclicks = labels.map(function(d){ return dateSet[d].email_click||0; });

new Chart(document.getElementById('trendChart'), {
    type: 'line',
    data: {
        labels: labels,
        datasets: [
            { label: 'Profile Views',   data: views,   borderColor:'##B8860B', backgroundColor:'rgba(184,134,11,0.08)', tension:0.3, fill:true },
            { label: 'Website Clicks',  data: wclicks, borderColor:'##059669', backgroundColor:'rgba(5,150,105,0.08)',   tension:0.3, fill:true },
            { label: 'Email Clicks',    data: eclicks, borderColor:'##7c3aed', backgroundColor:'rgba(124,58,237,0.08)',  tension:0.3, fill:true }
        ]
    },
    options: {
        responsive: true,
        plugins: { legend: { position: 'top' } },
        scales: { y: { beginAtZero: true, ticks: { stepSize: 1 } } }
    }
});
</script>
</cfoutput>
</cfif>

<cfinclude template="../includes/layout-end.cfm">
