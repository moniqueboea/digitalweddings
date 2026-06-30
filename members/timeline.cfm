<cfinclude template="../includes/auth-check.cfm">
<cfset pageTitle = "Wedding Day Timeline | digitalweddings.love">
<cfset activePage = "timeline">
<cfset userId = session.user.id>
<cfparam name="form.action" default="">

<cfif form.action EQ "add_event">
    <cfif len(trim(form.eventName)) && len(trim(form.eventTime))>
        <cfquery datasource="#application.config.datasource#">
            INSERT INTO dbo.WeddingTimelines (user_id, event_time, event_name, description)
            VALUES (
                <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">,
                <cfqueryparam value="#trim(form.eventTime)#" cfsqltype="cf_sql_time">,
                <cfqueryparam value="#trim(form.eventName)#" cfsqltype="cf_sql_nvarchar">,
                <cfqueryparam value="#trim(form.description)#" cfsqltype="cf_sql_nvarchar" null="#!len(trim(form.description))#">
            )
        </cfquery>
    </cfif>
    <cflocation url="timeline.cfm" addToken="false">
</cfif>

<cfif form.action EQ "delete_event" && isNumeric(form.timelineId)>
    <cfquery datasource="#application.config.datasource#">
        DELETE FROM dbo.WeddingTimelines WHERE timeline_id = <cfqueryparam value="#form.timelineId#" cfsqltype="cf_sql_bigint"> AND user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
    </cfquery>
    <cflocation url="timeline.cfm" addToken="false">
</cfif>

<cfquery name="events" datasource="#application.config.datasource#">
    SELECT timeline_id, event_time, event_name, description
    FROM dbo.WeddingTimelines WHERE user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
    ORDER BY event_time
</cfquery>

<cfinclude template="../includes/layout-start.cfm">
<style>
@media (max-width:768px) {
    .mfr { grid-template-columns: 1fr !important; }
    .mfr input, .mfr select, .mfr textarea, .mfr button[type=submit] {
        display: block !important;
        width: 100% !important;
        min-width: 0 !important;
        max-width: 100% !important;
        box-sizing: border-box !important;
    }
    .mfr input[type="date"],
    .mfr input[type="time"] {
        -webkit-appearance: none !important;
        appearance: none !important;
        display: block !important;
        width: 100% !important;
        min-width: 0 !important;
        max-width: 100% !important;
        box-sizing: border-box !important;
    }
}
</style>
<section style="padding:60px 0">
<div class="container" style="max-width:800px">
    <div class="page-header">
        <p class="eyebrow">Your Wedding Day</p>
        <h1>Wedding Day <span class="script">Timeline</span></h1>
    </div>

    <div class="panel" style="margin-bottom:32px;background:var(--surface-alt,#faf9f7);border-left:4px solid var(--gold)">
        <p style="font-size:14px;color:var(--text-muted);line-height:1.75;margin-bottom:16px">Your Wedding Day Timeline helps keep your special day organized from start to finish. Add each event in the order it will happen, including the time, title, location (if needed), and any notes or special instructions. From getting ready in the morning to your grand exit at the end of the night, this timeline serves as your day-of schedule.</p>
        <p style="font-size:13px;font-weight:600;color:var(--text);margin-bottom:10px">Include important moments such as:</p>
        <ul style="font-size:13px;color:var(--text-muted);line-height:2;list-style:none;padding:0;columns:2;gap:24px;margin-bottom:16px">
            <li>&#10022;&nbsp; Hair &amp; makeup appointments</li>
            <li>&#10022;&nbsp; Photographer &amp; videographer arrival</li>
            <li>&#10022;&nbsp; First look</li>
            <li>&#10022;&nbsp; Wedding party photos</li>
            <li>&#10022;&nbsp; Ceremony</li>
            <li>&#10022;&nbsp; Cocktail hour</li>
            <li>&#10022;&nbsp; Reception entrance</li>
            <li>&#10022;&nbsp; Dinner</li>
            <li>&#10022;&nbsp; Toasts and speeches</li>
            <li>&#10022;&nbsp; First dance</li>
            <li>&#10022;&nbsp; Cake cutting</li>
            <li>&#10022;&nbsp; Bouquet &amp; garter toss (optional)</li>
            <li>&#10022;&nbsp; Dancing and entertainment</li>
            <li>&#10022;&nbsp; Grand exit</li>
        </ul>
        <p style="font-size:13px;color:var(--text-muted);line-height:1.75">For the best experience, review your timeline with your wedding party, planner, vendors, and anyone helping coordinate your wedding. A well-planned timeline ensures everyone knows where they need to be and helps your wedding day run smoothly.</p>
    </div>

    <div class="panel" style="margin-bottom:32px">
        <p class="panel-title">Add an Event</p>
        <form method="post" action="/members/timeline.cfm">
            <input type="hidden" name="action" value="add_event">
            <div class="mfr" style="display:grid;grid-template-columns:1fr 2fr 2fr auto;gap:12px;align-items:end">
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
                        </div>
                        <form method="post" action="/members/timeline.cfm" style="flex-shrink:0">
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
<cfinclude template="../includes/layout-end.cfm">
