<cfinclude template="admin-check.cfm">
<cfset pageTitle  = "Manage Vendors | Admin">
<cfset activePage = "admin">
<cfparam name="form.action"   default="">
<cfparam name="form.vendorId" default="0">
<cfparam name="url.saved"     default="">
<cfparam name="url.filter"    default="all">

<cfif form.action EQ "approve" AND isNumeric(form.vendorId)>
    <cfquery datasource="#application.config.datasource#">
        UPDATE dbo.Vendors SET status='active', updated_at=SYSUTCDATETIME()
        WHERE vendor_id = <cfqueryparam value="#form.vendorId#" cfsqltype="cf_sql_bigint">
    </cfquery>
    <cflocation url="vendors.cfm?saved=approved&filter=pending" addToken="false">
</cfif>

<cfif form.action EQ "reject" AND isNumeric(form.vendorId)>
    <cfquery datasource="#application.config.datasource#">
        UPDATE dbo.Vendors SET status='rejected', updated_at=SYSUTCDATETIME()
        WHERE vendor_id = <cfqueryparam value="#form.vendorId#" cfsqltype="cf_sql_bigint">
    </cfquery>
    <cflocation url="vendors.cfm?saved=rejected&filter=#URLEncodedFormat(url.filter)#" addToken="false">
</cfif>

<cfif form.action EQ "delete" AND isNumeric(form.vendorId)>
    <cfquery datasource="#application.config.datasource#">
        DELETE FROM dbo.Vendors WHERE vendor_id = <cfqueryparam value="#form.vendorId#" cfsqltype="cf_sql_bigint">
    </cfquery>
    <cflocation url="vendors.cfm?saved=deleted&filter=#URLEncodedFormat(url.filter)#" addToken="false">
</cfif>

<cfif url.filter EQ "pending">
    <cfset statusFilter = "pending">
<cfelseif url.filter EQ "active">
    <cfset statusFilter = "active">
<cfelseif url.filter EQ "rejected">
    <cfset statusFilter = "rejected">
<cfelse>
    <cfset statusFilter = "all">
</cfif>

<cfquery name="qVendors" datasource="#application.config.datasource#">
    SELECT vendor_id, business_name, category, location, email, phone, website, price_range, status, complimentary, created_at, description
    FROM dbo.Vendors
    <cfif statusFilter NEQ "all">
    WHERE status = <cfqueryparam value="#statusFilter#" cfsqltype="cf_sql_varchar">
    </cfif>
    ORDER BY CASE status WHEN 'invited' THEN 0 WHEN 'pending' THEN 1 WHEN 'active' THEN 2 ELSE 3 END, created_at DESC
</cfquery>

<cfquery name="qCounts" datasource="#application.config.datasource#">
    SELECT
        COUNT(*)                                       AS total,
        SUM(CASE WHEN status='pending'  THEN 1 ELSE 0 END) AS pending,
        SUM(CASE WHEN status='active'   THEN 1 ELSE 0 END) AS active,
        SUM(CASE WHEN status='rejected' THEN 1 ELSE 0 END) AS rejected
    FROM dbo.Vendors
</cfquery>

<cfinclude template="../includes/layout-start.cfm">
<section style="padding:60px 0">
<div class="container">

    <div class="page-header">
        <p class="eyebrow"><a href="/admin/index.cfm" style="color:var(--gold)">Admin</a></p>
        <h1>Manage <span class="script">Vendors</span></h1>
    </div>

    <cfif url.saved EQ "approved"><div class="alert alert-success" style="margin-bottom:24px">Vendor approved and now live.</div></cfif>
    <cfif url.saved EQ "rejected"><div class="alert alert-error" style="margin-bottom:24px">Vendor rejected.</div></cfif>
    <cfif url.saved EQ "deleted"><div class="alert alert-error" style="margin-bottom:24px">Vendor deleted.</div></cfif>

    <!--- Filter tabs --->
    <cfoutput>
    <div style="display:flex;gap:8px;margin-bottom:24px;flex-wrap:wrap">
        <a href="vendors.cfm?filter=all"      class="btn #url.filter EQ 'all'      ? 'btn-primary' : 'btn-ghost'# btn-sm">All (#qCounts.total#)</a>
        <a href="vendors.cfm?filter=pending"  class="btn #url.filter EQ 'pending'  ? 'btn-primary' : 'btn-ghost'# btn-sm" style="#qCounts.pending GT 0 ? 'border-color:##d97706;color:##d97706' : ''#">Pending (#qCounts.pending#)</a>
        <a href="vendors.cfm?filter=active"   class="btn #url.filter EQ 'active'   ? 'btn-primary' : 'btn-ghost'# btn-sm">Active (#qCounts.active#)</a>
        <a href="vendors.cfm?filter=rejected" class="btn #url.filter EQ 'rejected' ? 'btn-primary' : 'btn-ghost'# btn-sm">Rejected (#qCounts.rejected#)</a>
    </div>
    </cfoutput>

    <cfif qVendors.recordCount>
    <div class="panel" style="padding:0">
    <div class="table-wrap">
    <table>
        <thead>
            <tr><th>Business</th><th>Category</th><th>Location</th><th>Email</th><th>Price</th><th>Status</th><th>Type</th><th>Submitted</th><th></th></tr>
        </thead>
        <tbody>
        <cfoutput query="qVendors">
        <tr>
            <td>
                <strong>#HTMLEditFormat(business_name)#</strong>
                <cfif len(trim(website))><br><a href="#HTMLEditFormat(trim(website))#" target="_blank" style="font-size:11px;color:var(--gold)">website</a></cfif>
            </td>
            <td><span class="badge badge-gray">#HTMLEditFormat(category)#</span></td>
            <td style="font-size:13px">#HTMLEditFormat(location)#</td>
            <td style="font-size:13px"><a href="mailto:#HTMLEditFormat(email)#">#HTMLEditFormat(email)#</a></td>
            <td style="text-align:center">#HTMLEditFormat(price_range)#</td>
            <td>
                <cfif status EQ "active">  <span class="badge badge-green">Active</span>
                <cfelseif status EQ "pending">  <span class="badge badge-amber">Pending</span>
                <cfelse><span class="badge badge-gray">Rejected</span>
                </cfif>
            </td>
            <td style="text-align:center">
                <cfif complimentary><span class="badge badge-green" title="Invited via complimentary listing">Gift</span><cfelse><span class="badge badge-gray">Open</span></cfif>
            </td>
            <td style="font-size:12px;color:var(--text-muted)">#dateFormat(created_at,'mmm d, yyyy')#</td>
            <td style="white-space:nowrap">
                <cfif status EQ "pending">
                <form method="post" action="/admin/vendors.cfm?filter=pending" style="display:inline">
                    <input type="hidden" name="action"   value="approve">
                    <input type="hidden" name="vendorId" value="#vendor_id#">
                    <button type="submit" class="btn btn-primary btn-sm" style="margin-right:4px">Approve</button>
                </form>
                <form method="post" action="/admin/vendors.cfm?filter=pending" style="display:inline">
                    <input type="hidden" name="action"   value="reject">
                    <input type="hidden" name="vendorId" value="#vendor_id#">
                    <button type="submit" class="btn btn-ghost btn-sm" onclick="return confirm('Reject #JSStringFormat(business_name)#?')">Reject</button>
                </form>
                <cfelseif status EQ "rejected">
                <form method="post" action="/admin/vendors.cfm" style="display:inline">
                    <input type="hidden" name="action"   value="approve">
                    <input type="hidden" name="vendorId" value="#vendor_id#">
                    <button type="submit" class="btn btn-ghost btn-sm" style="margin-right:4px">Approve</button>
                </form>
                </cfif>
                <form method="post" action="/admin/vendors.cfm?filter=#URLEncodedFormat(url.filter)#" style="display:inline">
                    <input type="hidden" name="action"   value="delete">
                    <input type="hidden" name="vendorId" value="#vendor_id#">
                    <button type="submit" class="btn btn-danger btn-sm" onclick="return confirm('Permanently delete #JSStringFormat(business_name)#?')">&times;</button>
                </form>
            </td>
        </tr>
        </cfoutput>
        </tbody>
    </table>
    </div>
    </div>
    <cfelse>
    <div class="empty-state"><p>No vendors in this category.</p></div>
    </cfif>

</div>
</section>
<cfinclude template="../includes/layout-end.cfm">
