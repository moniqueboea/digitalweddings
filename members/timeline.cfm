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

<!--- ── Send to myself (preview) ── --->
<cfif form.action EQ "send_self">
    <cfquery name="qSelfSite" datasource="#application.config.datasource#">
        SELECT couple_name_1, couple_name_2, wedding_date, slug, coord_name, coord_email
        FROM dbo.WeddingSites
        WHERE user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
        ORDER BY created_at DESC
    </cfquery>
    <cfif NOT qSelfSite.recordCount>
        <cflocation url="timeline.cfm?error=selfsendfail" addToken="false">
    </cfif>
    <cfquery name="qTimelineForSelf" datasource="#application.config.datasource#">
        SELECT event_time, event_name, description
        FROM dbo.WeddingTimelines
        WHERE user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
        ORDER BY event_time
    </cfquery>
    <cfset coordSite    = qSelfSite>
    <cfset coordSection = "Wedding Day Schedule">
    <cfset coordSentAt  = dateTimeFormat(now(), "mmmm d, yyyy h:mm tt")>
    <cfset coordSiteUrl = len(trim(qSelfSite.slug)) ? "https://digitalweddings.love/site.cfm?slug=#URLEncodedFormat(trim(qSelfSite.slug))#" : "">
    <cfsavecontent variable="coordBodyHtml">
        <cfoutput>
        <cfif qTimelineForSelf.recordCount>
        <table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0" style="border-collapse:collapse">
            <tr style="background:##e8f0e9">
                <th style="padding:8px 10px;text-align:left;font-size:12px;color:##3a5e3e;font-family:Arial,sans-serif;border-bottom:1px solid ##b2cbb5">Time</th>
                <th style="padding:8px 10px;text-align:left;font-size:12px;color:##3a5e3e;font-family:Arial,sans-serif;border-bottom:1px solid ##b2cbb5">Event</th>
                <th style="padding:8px 10px;text-align:left;font-size:12px;color:##3a5e3e;font-family:Arial,sans-serif;border-bottom:1px solid ##b2cbb5">Details</th>
            </tr>
            <cfloop query="qTimelineForSelf">
            <tr>
                <td style="padding:8px 10px;font-size:13px;color:##333;font-family:Arial,sans-serif;border-bottom:1px solid ##eee;white-space:nowrap">#timeFormat(event_time,'h:mm tt')#</td>
                <td style="padding:8px 10px;font-size:13px;color:##333;font-family:Arial,sans-serif;border-bottom:1px solid ##eee">#HTMLEditFormat(event_name)#</td>
                <td style="padding:8px 10px;font-size:13px;color:##333;font-family:Arial,sans-serif;border-bottom:1px solid ##eee">#HTMLEditFormat(description)#</td>
            </tr>
            </cfloop>
        </table>
        <cfelse>
        <p style="color:##888;font-size:13px;font-family:Arial,sans-serif;font-style:italic">No information added yet.</p>
        </cfif>
        </cfoutput>
    </cfsavecontent>
    <cftry>
        <cfset coordSubject = "Wedding Day Schedule - " & trim(qSelfSite.couple_name_1) & " & " & trim(qSelfSite.couple_name_2)>
        <cfmail to="#session.user.email#"
                from="#application.config.mailFrom#"
                server="localhost" port="25"
                subject="#coordSubject#"
                type="html" timeout="60"><cfinclude template="email-coordinator-body.cfm"></cfmail>
        <cflocation url="timeline.cfm?selftest=1" addToken="false">
    <cfcatch>
        <cflocation url="timeline.cfm?error=selfsendfail" addToken="false">
    </cfcatch>
    </cftry>
</cfif>

<!--- ── Send to coordinator ── --->
<cfif form.action EQ "send_coordinator">
    <cfquery name="qCoordSite" datasource="#application.config.datasource#">
        SELECT couple_name_1, couple_name_2, wedding_date, slug, coord_name, coord_email
        FROM dbo.WeddingSites
        WHERE user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
        ORDER BY created_at DESC
    </cfquery>
    <cfif NOT qCoordSite.recordCount OR NOT len(trim(qCoordSite.coord_email))>
        <cflocation url="timeline.cfm?error=noemail" addToken="false">
    </cfif>
    <cfquery name="qTimelineForCoord" datasource="#application.config.datasource#">
        SELECT event_time, event_name, description
        FROM dbo.WeddingTimelines
        WHERE user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
        ORDER BY event_time
    </cfquery>
    <cfset coordSite    = qCoordSite>
    <cfset coordSection = "Wedding Day Schedule">
    <cfset coordSentAt  = dateTimeFormat(now(), "mmmm d, yyyy h:mm tt")>
    <cfset coordSiteUrl = len(trim(qCoordSite.slug)) ? "https://digitalweddings.love/site.cfm?slug=#URLEncodedFormat(trim(qCoordSite.slug))#" : "">
    <cfsavecontent variable="coordBodyHtml">
        <cfoutput>
        <cfif qTimelineForCoord.recordCount>
        <table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0" style="border-collapse:collapse">
            <tr style="background:##e8f0e9">
                <th style="padding:8px 10px;text-align:left;font-size:12px;color:##3a5e3e;font-family:Arial,sans-serif;border-bottom:1px solid ##b2cbb5">Time</th>
                <th style="padding:8px 10px;text-align:left;font-size:12px;color:##3a5e3e;font-family:Arial,sans-serif;border-bottom:1px solid ##b2cbb5">Event</th>
                <th style="padding:8px 10px;text-align:left;font-size:12px;color:##3a5e3e;font-family:Arial,sans-serif;border-bottom:1px solid ##b2cbb5">Details</th>
            </tr>
            <cfloop query="qTimelineForCoord">
            <tr>
                <td style="padding:8px 10px;font-size:13px;color:##333;font-family:Arial,sans-serif;border-bottom:1px solid ##eee;white-space:nowrap">#timeFormat(event_time,'h:mm tt')#</td>
                <td style="padding:8px 10px;font-size:13px;color:##333;font-family:Arial,sans-serif;border-bottom:1px solid ##eee">#HTMLEditFormat(event_name)#</td>
                <td style="padding:8px 10px;font-size:13px;color:##333;font-family:Arial,sans-serif;border-bottom:1px solid ##eee">#HTMLEditFormat(description)#</td>
            </tr>
            </cfloop>
        </table>
        <cfelse>
        <p style="color:##888;font-size:13px;font-family:Arial,sans-serif;font-style:italic">No information added yet.</p>
        </cfif>
        </cfoutput>
    </cfsavecontent>
    <cftry>
        <cfset coordSubject = "Wedding Day Schedule - " & trim(qCoordSite.couple_name_1) & " & " & trim(qCoordSite.couple_name_2)>
        <cfmail to="#trim(qCoordSite.coord_email)#"
                from="#application.config.mailFrom#"
                replyto="#session.user.email#"
                server="localhost" port="25"
                subject="#coordSubject#"
                type="html" timeout="60"><cfinclude template="email-coordinator-body.cfm"></cfmail>
        <cflocation url="timeline.cfm?coordsent=1" addToken="false">
    <cfcatch>
        <cflocation url="timeline.cfm?error=sendfail" addToken="false">
    </cfcatch>
    </cftry>
</cfif>

<cfquery name="events" datasource="#application.config.datasource#">
    SELECT timeline_id, event_time, event_name, description
    FROM dbo.WeddingTimelines WHERE user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
    ORDER BY event_time
</cfquery>

<cfparam name="url.coordsent" default="">
<cfparam name="url.selftest"  default="">
<cfparam name="url.error"     default="">

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
    <div class="page-header" style="display:flex;justify-content:space-between;align-items:flex-start;flex-wrap:wrap;gap:16px">
        <div>
            <p class="eyebrow">Your Wedding Day</p>
            <h1>Wedding Day <span class="script">Timeline</span></h1>
        </div>
        <div style="display:flex;gap:8px;margin-top:8px;flex-wrap:wrap">
            <form method="post" action="/members/timeline.cfm">
                <input type="hidden" name="action" value="send_self">
                <button type="submit" class="btn btn-ghost btn-sm">&#128140; Send to Myself</button>
            </form>
            <form method="post" action="/members/timeline.cfm">
                <input type="hidden" name="action" value="send_coordinator">
                <button type="submit" class="btn btn-ghost btn-sm">&#128140; Send to Coordinator</button>
            </form>
        </div>
    </div>

    <cfif url.coordsent EQ "1">
    <div class="alert alert-success" style="margin-bottom:24px">Wedding Day Schedule sent to your coordinator!</div>
    </cfif>
    <cfif url.selftest EQ "1">
    <div class="alert alert-success" style="margin-bottom:24px">Wedding Day Schedule preview sent to <cfoutput>#HTMLEditFormat(session.user.email)#</cfoutput> - check your inbox!</div>
    </cfif>
    <cfif url.error EQ "noemail">
    <div class="alert alert-error" style="margin-bottom:24px">Please add your wedding coordinator&rsquo;s email address before sending information. <a href="/members/coordinator.cfm">Add coordinator &rarr;</a></div>
    </cfif>
    <cfif url.error EQ "sendfail" OR url.error EQ "selfsendfail">
    <div class="alert alert-error" style="margin-bottom:24px">There was a problem sending the email. Please try again.</div>
    </cfif>

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
