<cfinclude template="includes/auth-check.cfm">
<cfset pageTitle = "Wedding Day Timeline | digitalweddings.love">
<cfset activePage = "timeline">
<cfset userId = session.user.id>
<cfparam name="form.action" default="">
<cfparam name="form.eventTime" default="">
<cfparam name="form.eventName" default="">
<cfparam name="form.description" default="">
<cfparam name="form.notes" default="">
<cfparam name="form.timelineId" default="0">

<cfif form.action EQ "add_event">
    <cfif len(trim(form.eventName)) && len(trim(form.eventTime))>
        <cfquery datasource="#application.config.datasource#">
            INSERT INTO dbo.WeddingTimelines (user_id, event_time, event_name, description, notes)
            VALUES (
                <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">,
                <cfqueryparam value="#trim(form.eventTime)#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#trim(form.eventName)#" cfsqltype="cf_sql_nvarchar">,
                <cfqueryparam value="#trim(form.description)#" cfsqltype="cf_sql_nvarchar" null="#!len(trim(form.description))#">,
                <cfqueryparam value="#trim(form.notes)#" cfsqltype="cf_sql_nvarchar" null="#!len(trim(form.notes))#">
            )
        </cfquery>
    </cfif>
    <cflocation url="timeline.cfm" addToken="false">
</cfif>

<cfif form.action EQ "delete_event" && isNumeric(form.timelineId) && form.timelineId GT 0>
    <cfquery datasource="#application.config.datasource#">
        DELETE FROM dbo.WeddingTimelines WHERE timeline_id = <cfqueryparam value="#form.timelineId#" cfsqltype="cf_sql_bigint"> AND user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
    </cfquery>
    <cflocation url="timeline.cfm" addToken="false">
</cfif>

<cfquery name="events" datasource="#application.config.datasource#">
    SELECT timeline_id, event_time, event_name, description, notes
    FROM dbo.WeddingTimelines WHERE user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
    ORDER BY event_time
</cfquery>

<cfinclude template="includes/layout-start.cfm">
<section style="padding:60px 0">
<div class="container" style="max-width:800px">
    <div class="page-header">
        <p class="eyebrow">Your Wedding Day</p>
        <h1>Wedding Day <span class="script">Timeline</span></h1>
    </div>

    <div class="panel" style="margin-bottom:32px">
        <p class="panel-title">Add an Event</p>
        <form method="post" action="timeline.cfm">
            <input type="hidden" name="action" value="add_event">
            <div style="display:grid;grid-template-columns:1fr 2fr 2fr auto;gap:12px;align-items:end">
                <div class="field" style="margin-bottom:0">
                    <label>Time</label>
                    <input type="time" name="eventTime" required>
                </div>
                <div class="field" style="margin-bottom:0">
                    <label>Event Name</label>
                    <input type="text" name="eventName" placeholder="e.g. Ceremony Begins" required>
                </div>
                <div class="field" style="margin-bottom:0">
                    <label>Description</label>
                    <input type="text" name="description" placeholder="Optional details">
                </div>
                <button type="submit" class="btn btn-primary">Add</button>
            </div>
        </form>
    </div>

    <cfif events.recordCount>
        <div style="position:relative;padding-left:32px">
            <div style="position:absolute;left:12px;top:0;bottom:0;width:2px;background:var(--gold-light)"></div>
            <cfoutput query="events">
            <div style="position:relative;margin-bottom:24px">
                <div style="position:absolute;left:-26px;top:8px;width:14px;height:14px;border-radius:50%;background:var(--gold);border:2px solid ##fff;box-shadow:0 0 0 2px var(--gold)"></div>
                <div class="card" style="padding:16px 20px">
                    <div style="display:flex;justify-content:space-between;align-items:start">
                        <div>
                            <p style="font-size:12px;color:var(--gold);font-weight:700;letter-spacing:0.1em;margin-bottom:4px">
                                #timeFormat(event_time,'h:mm tt')#
                            </p>
                            <h3 style="font-size:16px;margin-bottom:4px">#HTMLEditFormat(event_name)#</h3>
                            <cfif len(description)><p style="font-size:13px;color:var(--text-muted)">#HTMLEditFormat(description)#</p></cfif>
                            <cfif len(notes)><p style="font-size:12px;color:var(--text-muted);margin-top:4px;font-style:italic">#HTMLEditFormat(notes)#</p></cfif>
                        </div>
                        <form method="post" action="timeline.cfm" style="flex-shrink:0">
                            <input type="hidden" name="action" value="delete_event">
                            <input type="hidden" name="timelineId" value="#timeline_id#">
                            <button type="submit" class="btn btn-ghost btn-sm" onclick="return confirm('Remove this event?')">&times;</button>
                        </form>
                    </div>
                </div>
            </div>
            </cfoutput>
        </div>
    <cfelse>
        <div class="empty-state">
            <div style="font-size:48px;margin-bottom:16px">&#9200;</div>
            <p>No timeline events yet. Start building your wedding day schedule above!</p>
        </div>
    </cfif>
</div>
</section>
<cfinclude template="includes/layout-end.cfm">
