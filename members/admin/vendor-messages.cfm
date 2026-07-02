<cfinclude template="admin-check.cfm">
<cfset pageTitle  = "Vendor Messages | Admin">
<cfset activePage = "admin">
<cfparam name="url.vendorId" default="0">
<cfparam name="form.action"  default="">
<cfparam name="form.msgId"   default="0">

<!--- Mark as read --->
<cfif form.action EQ "mark_read" AND isNumeric(form.msgId)>
    <cfquery datasource="#application.config.datasource#">
        UPDATE dbo.VendorMessages SET is_read=1
        WHERE message_id = <cfqueryparam value="#form.msgId#" cfsqltype="cf_sql_bigint">
    </cfquery>
    <cflocation url="vendor-messages.cfm?vendorId=#url.vendorId#" addToken="false">
</cfif>

<!--- Delete message --->
<cfif form.action EQ "delete" AND isNumeric(form.msgId)>
    <cfquery datasource="#application.config.datasource#">
        DELETE FROM dbo.VendorMessages
        WHERE message_id = <cfqueryparam value="#form.msgId#" cfsqltype="cf_sql_bigint">
    </cfquery>
    <cflocation url="vendor-messages.cfm?vendorId=#url.vendorId#" addToken="false">
</cfif>

<cfquery name="qMessages" datasource="#application.config.datasource#">
    SELECT m.message_id, m.vendor_id, m.sender_name, m.sender_email,
           m.message, m.is_read, m.created_at,
           v.business_name, v.category
    FROM dbo.VendorMessages m
    INNER JOIN dbo.Vendors v ON v.vendor_id = m.vendor_id
    <cfif isNumeric(url.vendorId) AND url.vendorId GT 0>
    WHERE m.vendor_id = <cfqueryparam value="#url.vendorId#" cfsqltype="cf_sql_bigint">
    </cfif>
    ORDER BY m.is_read ASC, m.created_at DESC
</cfquery>

<cfquery name="qVendors" datasource="#application.config.datasource#">
    SELECT DISTINCT v.vendor_id, v.business_name
    FROM dbo.Vendors v
    INNER JOIN dbo.VendorMessages m ON m.vendor_id = v.vendor_id
    ORDER BY v.business_name
</cfquery>

<cfset unreadCount = 0>
<cfloop query="qMessages">
    <cfif NOT is_read><cfset unreadCount++></cfif>
</cfloop>

<cfinclude template="../../includes/layout-start.cfm">
<section style="padding:60px 0">
<div class="container">

    <div class="page-header">
        <p class="eyebrow"><a href="/admin/index.cfm" style="color:var(--gold)">Admin</a> &rsaquo; <a href="/admin/vendors.cfm" style="color:var(--gold)">Vendors</a></p>
        <h1>Vendor <span class="script">Messages</span></h1>
    </div>

    <div style="display:flex;gap:12px;margin-bottom:24px;flex-wrap:wrap;align-items:center">
        <a href="/admin/vendors.cfm" class="btn btn-ghost btn-sm">Manage Vendors</a>
        <a href="/admin/vendor-analytics.cfm" class="btn btn-ghost btn-sm">Analytics</a>
        <cfif unreadCount GT 0>
        <span class="badge badge-amber"><cfoutput>#unreadCount#</cfoutput> unread</span>
        </cfif>
    </div>

    <!--- Vendor filter --->
    <cfif qVendors.recordCount GT 1>
    <div style="display:flex;gap:8px;margin-bottom:24px;flex-wrap:wrap;align-items:center">
        <span style="font-size:13px;color:var(--text-muted)">Filter:</span>
        <a href="vendor-messages.cfm" class="btn btn-sm <cfoutput>#NOT (isNumeric(url.vendorId) AND url.vendorId GT 0) ? 'btn-primary' : 'btn-ghost'#</cfoutput>">All Vendors</a>
        <cfoutput query="qVendors">
        <a href="vendor-messages.cfm?vendorId=#vendor_id#" class="btn btn-sm #url.vendorId EQ vendor_id ? 'btn-primary' : 'btn-ghost'#">#HTMLEditFormat(business_name)#</a>
        </cfoutput>
    </div>
    </cfif>

    <cfif qMessages.recordCount>
    <div style="display:flex;flex-direction:column;gap:12px">
    <cfoutput query="qMessages">
        <div class="panel" style="padding:20px;border-left:4px solid #is_read ? 'var(--border)' : 'var(--gold)'#">
            <div style="display:flex;justify-content:space-between;align-items:start;margin-bottom:10px;gap:12px">
                <div>
                    <p style="font-weight:700;font-size:15px;margin-bottom:2px">
                        #HTMLEditFormat(sender_name)#
                        <cfif NOT is_read><span class="badge badge-amber" style="margin-left:6px;font-size:10px">New</span></cfif>
                    </p>
                    <p style="font-size:13px;color:var(--text-muted);margin-bottom:2px"><a href="mailto:#HTMLEditFormat(sender_email)#" style="color:var(--gold)">#HTMLEditFormat(sender_email)#</a></p>
                    <p style="font-size:12px;color:var(--text-muted)">To: <strong>#HTMLEditFormat(business_name)#</strong> &bull; #dateFormat(created_at,'mmmm d, yyyy')# at #timeFormat(created_at,'h:mm tt')#</p>
                </div>
                <div style="display:flex;gap:6px;flex-shrink:0">
                    <cfif NOT is_read>
                    <form method="post" action="/admin/vendor-messages.cfm?vendorId=#url.vendorId#" style="display:inline">
                        <input type="hidden" name="action" value="mark_read">
                        <input type="hidden" name="msgId"  value="#message_id#">
                        <button type="submit" class="btn btn-ghost btn-sm">Mark Read</button>
                    </form>
                    </cfif>
                    <form method="post" action="/admin/vendor-messages.cfm?vendorId=#url.vendorId#" style="display:inline">
                        <input type="hidden" name="action" value="delete">
                        <input type="hidden" name="msgId"  value="#message_id#">
                        <button type="submit" class="btn btn-danger btn-sm" onclick="return confirm('Delete this message?')">&times;</button>
                    </form>
                </div>
            </div>
            <p style="font-size:14px;line-height:1.7;white-space:pre-wrap;color:var(--text)">#HTMLEditFormat(message)#</p>
            <div style="margin-top:12px">
                <a href="mailto:#HTMLEditFormat(sender_email)#?subject=Re: Your inquiry about #HTMLEditFormat(business_name)#" class="btn btn-primary btn-sm">Reply via Email</a>
            </div>
        </div>
    </cfoutput>
    </div>
    <cfelse>
        <div class="empty-state"><p>No messages yet.</p></div>
    </cfif>

</div>
</section>
<cfinclude template="../../includes/layout-end.cfm">
