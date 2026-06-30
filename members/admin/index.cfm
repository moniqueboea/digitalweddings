<cfinclude template="admin-check.cfm">
<cfset pageTitle = "Admin | digitalweddings.love">
<cfset activePage = "admin">

<cfquery name="qStats" datasource="#application.config.datasource#">
    SELECT
        (SELECT COUNT(*) FROM dbo.Users)                          AS totalUsers,
        (SELECT COUNT(*) FROM dbo.Vendors)                        AS totalVendors,
        (SELECT COUNT(*) FROM dbo.Vendors WHERE status='pending') AS pendingVendors,
        (SELECT COUNT(*) FROM dbo.Vendors WHERE status='active')  AS activeVendors,
        (SELECT COUNT(*) FROM dbo.WeddingSites WHERE published=1) AS publishedSites,
        (SELECT COUNT(*) FROM dbo.Guests)                         AS totalGuests
</cfquery>

<cfinclude template="../includes/layout-start.cfm">
<section style="padding:60px 0">
<div class="container">

    <div class="page-header">
        <p class="eyebrow">Admin Portal</p>
        <h1>Dashboard <span class="script">Overview</span></h1>
    </div>

    <cfoutput>
    <div class="stats-row" style="margin-bottom:40px">
        <div class="stat-card"><div class="stat-num">#qStats.totalUsers#</div><div class="stat-label">Total Users</div></div>
        <div class="stat-card"><div class="stat-num">#qStats.totalVendors#</div><div class="stat-label">Total Vendors</div></div>
        <div class="stat-card"><div class="stat-num" style="color:##d97706">#qStats.pendingVendors#</div><div class="stat-label">Pending Vendors</div></div>
        <div class="stat-card"><div class="stat-num" style="color:##059669">#qStats.activeVendors#</div><div class="stat-label">Active Vendors</div></div>
        <div class="stat-card"><div class="stat-num">#qStats.publishedSites#</div><div class="stat-label">Wedding Sites</div></div>
        <div class="stat-card"><div class="stat-num">#qStats.totalGuests#</div><div class="stat-label">Total Guests</div></div>
    </div>
    </cfoutput>

    <div style="display:grid;grid-template-columns:1fr 1fr;gap:20px">
        <a href="/admin/users.cfm" style="text-decoration:none">
            <div class="panel" style="cursor:pointer;transition:border-color .2s" onmouseover="this.style.borderColor='var(--gold)'" onmouseout="this.style.borderColor=''">
                <p class="panel-title" style="font-size:18px">&#128101; Manage Users</p>
                <p style="color:var(--text-muted);margin:0">View all registered users, toggle admin access, deactivate accounts.</p>
            </div>
        </a>
        <a href="/admin/vendors.cfm" style="text-decoration:none">
            <div class="panel" style="cursor:pointer;transition:border-color .2s" onmouseover="this.style.borderColor='var(--gold)'" onmouseout="this.style.borderColor=''">
                <p class="panel-title" style="font-size:18px">&#127981; Manage Vendors</p>
                <p style="color:var(--text-muted);margin:0">Approve, reject, or edit vendor listings. View pending submissions.</p>
            </div>
        </a>
        <a href="/admin/vendor-invite.cfm" style="text-decoration:none">
            <div class="panel" style="cursor:pointer;transition:border-color .2s" onmouseover="this.style.borderColor='var(--gold)'" onmouseout="this.style.borderColor=''">
                <p class="panel-title" style="font-size:18px">&#128140; Send Vendor Invite</p>
                <p style="color:var(--text-muted);margin:0">Send a complimentary registration invitation to a vendor.</p>
            </div>
        </a>
        <a href="/admin/db.cfm" style="text-decoration:none">
            <div class="panel" style="cursor:pointer;transition:border-color .2s" onmouseover="this.style.borderColor='var(--gold)'" onmouseout="this.style.borderColor=''">
                <p class="panel-title" style="font-size:18px">&#128451; Database Tool</p>
                <p style="color:var(--text-muted);margin:0">Run SQL queries and browse database tables directly.</p>
            </div>
        </a>
    </div>

</div>
</section>
<cfinclude template="../includes/layout-end.cfm">
