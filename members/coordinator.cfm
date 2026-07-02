<cfinclude template="../includes/auth-check.cfm">
<cfset pageTitle = "Wedding Coordinator | digitalweddings.love">
<cfset activePage = "coordinator">
<cfset userId = session.user.id>

<cfparam name="form.action"       default="">
<cfparam name="form.coord_name"   default="">
<cfparam name="form.coord_company" default="">
<cfparam name="form.coord_email"  default="">
<cfparam name="form.coord_phone"  default="">
<cfparam name="url.saved"         default="">
<cfparam name="url.sent"          default="">
<cfparam name="url.selftest"      default="">
<cfparam name="url.error"         default="">

<!--- Load site --->
<cfquery name="qSite" datasource="#application.config.datasource#">
    SELECT wedding_site_id, couple_name_1, couple_name_2, wedding_date, slug,
           coord_name, coord_company, coord_email, coord_phone
    FROM dbo.WeddingSites
    WHERE user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
    ORDER BY created_at DESC
</cfquery>

<!--- Save coordinator info --->
<cfif form.action EQ "save_coordinator" AND qSite.recordCount>
    <cfquery datasource="#application.config.datasource#">
        UPDATE dbo.WeddingSites
        SET coord_name    = <cfqueryparam value="#trim(form.coord_name)#"    cfsqltype="cf_sql_nvarchar" null="#!len(trim(form.coord_name))#">,
            coord_company = <cfqueryparam value="#trim(form.coord_company)#" cfsqltype="cf_sql_nvarchar" null="#!len(trim(form.coord_company))#">,
            coord_email   = <cfqueryparam value="#lCase(trim(form.coord_email))#" cfsqltype="cf_sql_nvarchar" null="#!len(trim(form.coord_email))#">,
            coord_phone   = <cfqueryparam value="#trim(form.coord_phone)#"   cfsqltype="cf_sql_nvarchar" null="#!len(trim(form.coord_phone))#">
        WHERE user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
    </cfquery>
    <cflocation url="coordinator.cfm?saved=1" addToken="false">
</cfif>

<!--- Send complete package --->
<cfif form.action EQ "send_package_self" AND qSite.recordCount>
    <!--- Wedding party --->
    <cfquery name="qParty" datasource="#application.config.datasource#">
        SELECT name, party_role, party_side, email, phone
        FROM dbo.WeddingPartyMembers
        WHERE user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
        ORDER BY party_side, party_role, name
    </cfquery>
    <!--- Guests --->
    <cfquery name="qGuests" datasource="#application.config.datasource#">
        SELECT name, email, rsvp_status, plus_one, plus_one_name, dietary_restrictions, guest_group
        FROM dbo.Guests
        WHERE user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
        ORDER BY name
    </cfquery>
    <!--- Tables + seated guests --->
    <cfquery name="qTables" datasource="#application.config.datasource#">
        SELECT t.reception_table_id, t.table_number, t.table_name, t.capacity,
               g.name AS guest_name, g.plus_one, g.plus_one_name
        FROM dbo.ReceptionTables t
        LEFT JOIN dbo.Guests g ON g.user_id = t.user_id AND g.table_number = t.table_number
        WHERE t.user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
        ORDER BY t.table_number, g.name
    </cfquery>
    <!--- Timeline --->
    <cfquery name="qTimeline" datasource="#application.config.datasource#">
        SELECT event_time, event_name, description
        FROM dbo.WeddingTimelines
        WHERE user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
        ORDER BY event_time
    </cfquery>
    <cfset coordSite    = qSite>
    <cfset coordSection = "Complete Wedding Planning Package">
    <cfset coordSentAt  = dateTimeFormat(now(), "mmmm d, yyyy h:mm tt")>
    <cfset coordSiteUrl = len(trim(qSite.slug)) ? "https://digitalweddings.love/site.cfm?slug=#URLEncodedFormat(trim(qSite.slug))#" : "">
    <cfsavecontent variable="coordBodyHtml">
        <cfoutput>
        <h2 style="margin:0 0 12px 0;color:##2c3e2e;font-size:16px;font-family:Arial,Helvetica,sans-serif;border-bottom:2px solid ##7A9E7E;padding-bottom:8px">Wedding Party</h2>
        <cfif qParty.recordCount>
        <table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0" style="border-collapse:collapse;margin-bottom:32px">
            <tr style="background:##e8f0e9">
                <th style="padding:8px 10px;text-align:left;font-size:12px;color:##3a5e3e;font-family:Arial,sans-serif;border-bottom:1px solid ##b2cbb5">Name</th>
                <th style="padding:8px 10px;text-align:left;font-size:12px;color:##3a5e3e;font-family:Arial,sans-serif;border-bottom:1px solid ##b2cbb5">Role</th>
                <th style="padding:8px 10px;text-align:left;font-size:12px;color:##3a5e3e;font-family:Arial,sans-serif;border-bottom:1px solid ##b2cbb5">Side</th>
                <th style="padding:8px 10px;text-align:left;font-size:12px;color:##3a5e3e;font-family:Arial,sans-serif;border-bottom:1px solid ##b2cbb5">Email</th>
                <th style="padding:8px 10px;text-align:left;font-size:12px;color:##3a5e3e;font-family:Arial,sans-serif;border-bottom:1px solid ##b2cbb5">Phone</th>
            </tr>
            <cfloop query="qParty">
            <tr style="background:##fff<cfif qParty.currentRow MOD 2>;background:##f9fafb</cfif>">
                <td style="padding:8px 10px;font-size:13px;color:##333;font-family:Arial,sans-serif;border-bottom:1px solid ##eee">#HTMLEditFormat(name)#</td>
                <td style="padding:8px 10px;font-size:13px;color:##333;font-family:Arial,sans-serif;border-bottom:1px solid ##eee">#HTMLEditFormat(party_role)#</td>
                <td style="padding:8px 10px;font-size:13px;color:##333;font-family:Arial,sans-serif;border-bottom:1px solid ##eee">#HTMLEditFormat(party_side)#</td>
                <td style="padding:8px 10px;font-size:13px;color:##333;font-family:Arial,sans-serif;border-bottom:1px solid ##eee">#HTMLEditFormat(email)#</td>
                <td style="padding:8px 10px;font-size:13px;color:##333;font-family:Arial,sans-serif;border-bottom:1px solid ##eee">#HTMLEditFormat(phone)#</td>
            </tr>
            </cfloop>
        </table>
        <cfelse>
        <p style="color:##888;font-size:13px;font-family:Arial,sans-serif;margin:0 0 32px 0;font-style:italic">No information added yet.</p>
        </cfif>
        <h2 style="margin:0 0 12px 0;color:##2c3e2e;font-size:16px;font-family:Arial,Helvetica,sans-serif;border-bottom:2px solid ##7A9E7E;padding-bottom:8px">Guests (#qGuests.recordCount# total)</h2>
        <cfif qGuests.recordCount>
        <table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0" style="border-collapse:collapse;margin-bottom:32px">
            <tr style="background:##e8f0e9">
                <th style="padding:8px 10px;text-align:left;font-size:12px;color:##3a5e3e;font-family:Arial,sans-serif;border-bottom:1px solid ##b2cbb5">Name</th>
                <th style="padding:8px 10px;text-align:left;font-size:12px;color:##3a5e3e;font-family:Arial,sans-serif;border-bottom:1px solid ##b2cbb5">RSVP</th>
                <th style="padding:8px 10px;text-align:left;font-size:12px;color:##3a5e3e;font-family:Arial,sans-serif;border-bottom:1px solid ##b2cbb5">Plus One</th>
                <th style="padding:8px 10px;text-align:left;font-size:12px;color:##3a5e3e;font-family:Arial,sans-serif;border-bottom:1px solid ##b2cbb5">Dietary</th>
                <th style="padding:8px 10px;text-align:left;font-size:12px;color:##3a5e3e;font-family:Arial,sans-serif;border-bottom:1px solid ##b2cbb5">Group</th>
            </tr>
            <cfloop query="qGuests">
            <tr>
                <td style="padding:8px 10px;font-size:13px;color:##333;font-family:Arial,sans-serif;border-bottom:1px solid ##eee">#HTMLEditFormat(name)#</td>
                <td style="padding:8px 10px;font-size:13px;color:##333;font-family:Arial,sans-serif;border-bottom:1px solid ##eee">#HTMLEditFormat(rsvp_status)#</td>
                <td style="padding:8px 10px;font-size:13px;color:##333;font-family:Arial,sans-serif;border-bottom:1px solid ##eee"><cfif plus_one>Yes<cfif len(trim(plus_one_name))> - #HTMLEditFormat(plus_one_name)#</cfif><cfelse>No</cfif></td>
                <td style="padding:8px 10px;font-size:13px;color:##333;font-family:Arial,sans-serif;border-bottom:1px solid ##eee">#HTMLEditFormat(dietary_restrictions)#</td>
                <td style="padding:8px 10px;font-size:13px;color:##333;font-family:Arial,sans-serif;border-bottom:1px solid ##eee">#HTMLEditFormat(guest_group)#</td>
            </tr>
            </cfloop>
        </table>
        <cfelse>
        <p style="color:##888;font-size:13px;font-family:Arial,sans-serif;margin:0 0 32px 0;font-style:italic">No information added yet.</p>
        </cfif>
        <h2 style="margin:0 0 12px 0;color:##2c3e2e;font-size:16px;font-family:Arial,Helvetica,sans-serif;border-bottom:2px solid ##7A9E7E;padding-bottom:8px">Seating Chart</h2>
        <cfif qTables.recordCount>
            <cfset lastTable = 0>
            <cfloop query="qTables">
                <cfif reception_table_id NEQ lastTable>
                    <cfif lastTable NEQ 0></table></cfif>
                    <p style="margin:0 0 6px 0;font-size:13px;font-weight:700;color:##2c3e2e;font-family:Arial,sans-serif">Table #table_number# - #HTMLEditFormat(table_name)# (capacity: #capacity#)</p>
                    <table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0" style="border-collapse:collapse;margin-bottom:16px">
                    <tr style="background:##e8f0e9">
                        <th style="padding:6px 10px;text-align:left;font-size:12px;color:##3a5e3e;font-family:Arial,sans-serif;border-bottom:1px solid ##b2cbb5">Guest</th>
                        <th style="padding:6px 10px;text-align:left;font-size:12px;color:##3a5e3e;font-family:Arial,sans-serif;border-bottom:1px solid ##b2cbb5">Plus One</th>
                    </tr>
                    <cfset lastTable = reception_table_id>
                </cfif>
                <cfif len(trim(guest_name))>
                <tr>
                    <td style="padding:6px 10px;font-size:13px;color:##333;font-family:Arial,sans-serif;border-bottom:1px solid ##eee">#HTMLEditFormat(guest_name)#</td>
                    <td style="padding:6px 10px;font-size:13px;color:##333;font-family:Arial,sans-serif;border-bottom:1px solid ##eee"><cfif plus_one>Yes<cfif len(trim(plus_one_name))> - #HTMLEditFormat(plus_one_name)#</cfif><cfelse>-</cfif></td>
                </tr>
                <cfelse>
                <tr><td colspan="2" style="padding:6px 10px;font-size:13px;color:##aaa;font-family:Arial,sans-serif;font-style:italic;border-bottom:1px solid ##eee">No guests assigned yet</td></tr>
                </cfif>
            </cfloop>
            </table>
        <p style="margin:0 0 32px 0"></p>
        <cfelse>
        <p style="color:##888;font-size:13px;font-family:Arial,sans-serif;margin:0 0 32px 0;font-style:italic">No information added yet.</p>
        </cfif>
        <h2 style="margin:0 0 12px 0;color:##2c3e2e;font-size:16px;font-family:Arial,Helvetica,sans-serif;border-bottom:2px solid ##7A9E7E;padding-bottom:8px">Wedding Day Schedule</h2>
        <cfif qTimeline.recordCount>
        <table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0" style="border-collapse:collapse;margin-bottom:32px">
            <tr style="background:##e8f0e9">
                <th style="padding:8px 10px;text-align:left;font-size:12px;color:##3a5e3e;font-family:Arial,sans-serif;border-bottom:1px solid ##b2cbb5">Time</th>
                <th style="padding:8px 10px;text-align:left;font-size:12px;color:##3a5e3e;font-family:Arial,sans-serif;border-bottom:1px solid ##b2cbb5">Event</th>
                <th style="padding:8px 10px;text-align:left;font-size:12px;color:##3a5e3e;font-family:Arial,sans-serif;border-bottom:1px solid ##b2cbb5">Details</th>
            </tr>
            <cfloop query="qTimeline">
            <tr>
                <td style="padding:8px 10px;font-size:13px;color:##333;font-family:Arial,sans-serif;border-bottom:1px solid ##eee;white-space:nowrap">#timeFormat(event_time,'h:mm tt')#</td>
                <td style="padding:8px 10px;font-size:13px;color:##333;font-family:Arial,sans-serif;border-bottom:1px solid ##eee">#HTMLEditFormat(event_name)#</td>
                <td style="padding:8px 10px;font-size:13px;color:##333;font-family:Arial,sans-serif;border-bottom:1px solid ##eee">#HTMLEditFormat(description)#</td>
            </tr>
            </cfloop>
        </table>
        <cfelse>
        <p style="color:##888;font-size:13px;font-family:Arial,sans-serif;margin:0 0 32px 0;font-style:italic">No information added yet.</p>
        </cfif>
        </cfoutput>
    </cfsavecontent>
    <cftry>
        <cfset coordSubject = "Wedding Planning Package - " & trim(qSite.couple_name_1) & " & " & trim(qSite.couple_name_2)>
        <cfif len(trim(qSite.wedding_date))>
            <cfset coordSubject = coordSubject & " - " & dateFormat(qSite.wedding_date,'mmmm d, yyyy')>
        </cfif>
        <cfmail to="#session.user.email#"
                from="#application.config.mailFrom#"
                server="localhost" port="25"
                subject="#coordSubject#"
                type="html" timeout="60"><cfinclude template="email-coordinator-body.cfm"></cfmail>
        <cflocation url="coordinator.cfm?selftest=1" addToken="false">
    <cfcatch>
        <cflocation url="coordinator.cfm?error=selfsendfail" addToken="false">
    </cfcatch>
    </cftry>
</cfif>

<cfif form.action EQ "send_package" AND qSite.recordCount>
    <cfif NOT len(trim(qSite.coord_email))>
        <cflocation url="coordinator.cfm?error=noemail" addToken="false">
    </cfif>

    <!--- Wedding party --->
    <cfquery name="qParty" datasource="#application.config.datasource#">
        SELECT name, party_role, party_side, email, phone
        FROM dbo.WeddingPartyMembers
        WHERE user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
        ORDER BY party_side, party_role, name
    </cfquery>

    <!--- Guests --->
    <cfquery name="qGuests" datasource="#application.config.datasource#">
        SELECT name, email, rsvp_status, plus_one, plus_one_name, dietary_restrictions, guest_group
        FROM dbo.Guests
        WHERE user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
        ORDER BY name
    </cfquery>

    <!--- Tables + seated guests --->
    <cfquery name="qTables" datasource="#application.config.datasource#">
        SELECT t.reception_table_id, t.table_number, t.table_name, t.capacity,
               g.name AS guest_name, g.plus_one, g.plus_one_name
        FROM dbo.ReceptionTables t
        LEFT JOIN dbo.Guests g ON g.user_id = t.user_id AND g.table_number = t.table_number
        WHERE t.user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
        ORDER BY t.table_number, g.name
    </cfquery>

    <!--- Timeline --->
    <cfquery name="qTimeline" datasource="#application.config.datasource#">
        SELECT event_time, event_name, description
        FROM dbo.WeddingTimelines
        WHERE user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
        ORDER BY event_time
    </cfquery>

    <cfset coordSite    = qSite>
    <cfset coordSection = "Complete Wedding Planning Package">
    <cfset coordSentAt  = dateTimeFormat(now(), "mmmm d, yyyy h:mm tt")>
    <cfset coordSiteUrl = len(trim(qSite.slug)) ? "https://digitalweddings.love/site.cfm?slug=#URLEncodedFormat(trim(qSite.slug))#" : "">

    <!--- Build HTML body --->
    <cfsavecontent variable="coordBodyHtml">
        <cfoutput>

        <!--- Wedding Party --->
        <h2 style="margin:0 0 12px 0;color:##2c3e2e;font-size:16px;font-family:Arial,Helvetica,sans-serif;border-bottom:2px solid ##7A9E7E;padding-bottom:8px">Wedding Party</h2>
        <cfif qParty.recordCount>
        <table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0" style="border-collapse:collapse;margin-bottom:32px">
            <tr style="background:##e8f0e9">
                <th style="padding:8px 10px;text-align:left;font-size:12px;color:##3a5e3e;font-family:Arial,sans-serif;border-bottom:1px solid ##b2cbb5">Name</th>
                <th style="padding:8px 10px;text-align:left;font-size:12px;color:##3a5e3e;font-family:Arial,sans-serif;border-bottom:1px solid ##b2cbb5">Role</th>
                <th style="padding:8px 10px;text-align:left;font-size:12px;color:##3a5e3e;font-family:Arial,sans-serif;border-bottom:1px solid ##b2cbb5">Side</th>
                <th style="padding:8px 10px;text-align:left;font-size:12px;color:##3a5e3e;font-family:Arial,sans-serif;border-bottom:1px solid ##b2cbb5">Email</th>
                <th style="padding:8px 10px;text-align:left;font-size:12px;color:##3a5e3e;font-family:Arial,sans-serif;border-bottom:1px solid ##b2cbb5">Phone</th>
            </tr>
            <cfloop query="qParty">
            <tr style="background:##fff<cfif qParty.currentRow MOD 2>;background:##f9fafb</cfif>">
                <td style="padding:8px 10px;font-size:13px;color:##333;font-family:Arial,sans-serif;border-bottom:1px solid ##eee">#HTMLEditFormat(name)#</td>
                <td style="padding:8px 10px;font-size:13px;color:##333;font-family:Arial,sans-serif;border-bottom:1px solid ##eee">#HTMLEditFormat(party_role)#</td>
                <td style="padding:8px 10px;font-size:13px;color:##333;font-family:Arial,sans-serif;border-bottom:1px solid ##eee">#HTMLEditFormat(party_side)#</td>
                <td style="padding:8px 10px;font-size:13px;color:##333;font-family:Arial,sans-serif;border-bottom:1px solid ##eee">#HTMLEditFormat(email)#</td>
                <td style="padding:8px 10px;font-size:13px;color:##333;font-family:Arial,sans-serif;border-bottom:1px solid ##eee">#HTMLEditFormat(phone)#</td>
            </tr>
            </cfloop>
        </table>
        <cfelse>
        <p style="color:##888;font-size:13px;font-family:Arial,sans-serif;margin:0 0 32px 0;font-style:italic">No information added yet.</p>
        </cfif>

        <!--- Guests --->
        <h2 style="margin:0 0 12px 0;color:##2c3e2e;font-size:16px;font-family:Arial,Helvetica,sans-serif;border-bottom:2px solid ##7A9E7E;padding-bottom:8px">Guests (#qGuests.recordCount# total)</h2>
        <cfif qGuests.recordCount>
        <table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0" style="border-collapse:collapse;margin-bottom:32px">
            <tr style="background:##e8f0e9">
                <th style="padding:8px 10px;text-align:left;font-size:12px;color:##3a5e3e;font-family:Arial,sans-serif;border-bottom:1px solid ##b2cbb5">Name</th>
                <th style="padding:8px 10px;text-align:left;font-size:12px;color:##3a5e3e;font-family:Arial,sans-serif;border-bottom:1px solid ##b2cbb5">RSVP</th>
                <th style="padding:8px 10px;text-align:left;font-size:12px;color:##3a5e3e;font-family:Arial,sans-serif;border-bottom:1px solid ##b2cbb5">Plus One</th>
                <th style="padding:8px 10px;text-align:left;font-size:12px;color:##3a5e3e;font-family:Arial,sans-serif;border-bottom:1px solid ##b2cbb5">Dietary</th>
                <th style="padding:8px 10px;text-align:left;font-size:12px;color:##3a5e3e;font-family:Arial,sans-serif;border-bottom:1px solid ##b2cbb5">Group</th>
            </tr>
            <cfloop query="qGuests">
            <tr>
                <td style="padding:8px 10px;font-size:13px;color:##333;font-family:Arial,sans-serif;border-bottom:1px solid ##eee">#HTMLEditFormat(name)#</td>
                <td style="padding:8px 10px;font-size:13px;color:##333;font-family:Arial,sans-serif;border-bottom:1px solid ##eee">#HTMLEditFormat(rsvp_status)#</td>
                <td style="padding:8px 10px;font-size:13px;color:##333;font-family:Arial,sans-serif;border-bottom:1px solid ##eee"><cfif plus_one>Yes<cfif len(trim(plus_one_name))> - #HTMLEditFormat(plus_one_name)#</cfif><cfelse>No</cfif></td>
                <td style="padding:8px 10px;font-size:13px;color:##333;font-family:Arial,sans-serif;border-bottom:1px solid ##eee">#HTMLEditFormat(dietary_restrictions)#</td>
                <td style="padding:8px 10px;font-size:13px;color:##333;font-family:Arial,sans-serif;border-bottom:1px solid ##eee">#HTMLEditFormat(guest_group)#</td>
            </tr>
            </cfloop>
        </table>
        <cfelse>
        <p style="color:##888;font-size:13px;font-family:Arial,sans-serif;margin:0 0 32px 0;font-style:italic">No information added yet.</p>
        </cfif>

        <!--- Seating Chart --->
        <h2 style="margin:0 0 12px 0;color:##2c3e2e;font-size:16px;font-family:Arial,Helvetica,sans-serif;border-bottom:2px solid ##7A9E7E;padding-bottom:8px">Seating Chart</h2>
        <cfif qTables.recordCount>
            <cfset lastTable = 0>
            <cfloop query="qTables">
                <cfif reception_table_id NEQ lastTable>
                    <cfif lastTable NEQ 0></table></cfif>
                    <p style="margin:0 0 6px 0;font-size:13px;font-weight:700;color:##2c3e2e;font-family:Arial,sans-serif">Table #table_number# - #HTMLEditFormat(table_name)# (capacity: #capacity#)</p>
                    <table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0" style="border-collapse:collapse;margin-bottom:16px">
                    <tr style="background:##e8f0e9">
                        <th style="padding:6px 10px;text-align:left;font-size:12px;color:##3a5e3e;font-family:Arial,sans-serif;border-bottom:1px solid ##b2cbb5">Guest</th>
                        <th style="padding:6px 10px;text-align:left;font-size:12px;color:##3a5e3e;font-family:Arial,sans-serif;border-bottom:1px solid ##b2cbb5">Plus One</th>
                    </tr>
                    <cfset lastTable = reception_table_id>
                </cfif>
                <cfif len(trim(guest_name))>
                <tr>
                    <td style="padding:6px 10px;font-size:13px;color:##333;font-family:Arial,sans-serif;border-bottom:1px solid ##eee">#HTMLEditFormat(guest_name)#</td>
                    <td style="padding:6px 10px;font-size:13px;color:##333;font-family:Arial,sans-serif;border-bottom:1px solid ##eee"><cfif plus_one>Yes<cfif len(trim(plus_one_name))> - #HTMLEditFormat(plus_one_name)#</cfif><cfelse>-</cfif></td>
                </tr>
                <cfelse>
                <tr><td colspan="2" style="padding:6px 10px;font-size:13px;color:##aaa;font-family:Arial,sans-serif;font-style:italic;border-bottom:1px solid ##eee">No guests assigned yet</td></tr>
                </cfif>
            </cfloop>
            </table>
        <p style="margin:0 0 32px 0"></p>
        <cfelse>
        <p style="color:##888;font-size:13px;font-family:Arial,sans-serif;margin:0 0 32px 0;font-style:italic">No information added yet.</p>
        </cfif>

        <!--- Timeline --->
        <h2 style="margin:0 0 12px 0;color:##2c3e2e;font-size:16px;font-family:Arial,Helvetica,sans-serif;border-bottom:2px solid ##7A9E7E;padding-bottom:8px">Wedding Day Schedule</h2>
        <cfif qTimeline.recordCount>
        <table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0" style="border-collapse:collapse;margin-bottom:32px">
            <tr style="background:##e8f0e9">
                <th style="padding:8px 10px;text-align:left;font-size:12px;color:##3a5e3e;font-family:Arial,sans-serif;border-bottom:1px solid ##b2cbb5">Time</th>
                <th style="padding:8px 10px;text-align:left;font-size:12px;color:##3a5e3e;font-family:Arial,sans-serif;border-bottom:1px solid ##b2cbb5">Event</th>
                <th style="padding:8px 10px;text-align:left;font-size:12px;color:##3a5e3e;font-family:Arial,sans-serif;border-bottom:1px solid ##b2cbb5">Details</th>
            </tr>
            <cfloop query="qTimeline">
            <tr>
                <td style="padding:8px 10px;font-size:13px;color:##333;font-family:Arial,sans-serif;border-bottom:1px solid ##eee;white-space:nowrap">#timeFormat(event_time,'h:mm tt')#</td>
                <td style="padding:8px 10px;font-size:13px;color:##333;font-family:Arial,sans-serif;border-bottom:1px solid ##eee">#HTMLEditFormat(event_name)#</td>
                <td style="padding:8px 10px;font-size:13px;color:##333;font-family:Arial,sans-serif;border-bottom:1px solid ##eee">#HTMLEditFormat(description)#</td>
            </tr>
            </cfloop>
        </table>
        <cfelse>
        <p style="color:##888;font-size:13px;font-family:Arial,sans-serif;margin:0 0 32px 0;font-style:italic">No information added yet.</p>
        </cfif>

        </cfoutput>
    </cfsavecontent>

    <cftry>
        <cfset coordSubject = "Wedding Planning Package - " & trim(qSite.couple_name_1) & " & " & trim(qSite.couple_name_2)>
        <cfif len(trim(qSite.wedding_date))>
            <cfset coordSubject = coordSubject & " - " & dateFormat(qSite.wedding_date,'mmmm d, yyyy')>
        </cfif>
        <cfmail to="#trim(qSite.coord_email)#"
                from="#application.config.mailFrom#"
                replyto="#session.user.email#"
                server="localhost"
                port="25"
                subject="#coordSubject#"
                type="html"
                timeout="60"><cfinclude template="email-coordinator-body.cfm"></cfmail>
        <cflocation url="coordinator.cfm?sent=1" addToken="false">
    <cfcatch>
        <cflocation url="coordinator.cfm?error=sendfail" addToken="false">
    </cfcatch>
    </cftry>
</cfif>

<!--- Re-load after save --->
<cfquery name="qSite" datasource="#application.config.datasource#">
    SELECT wedding_site_id, couple_name_1, couple_name_2, wedding_date, slug,
           coord_name, coord_company, coord_email, coord_phone
    FROM dbo.WeddingSites
    WHERE user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
    ORDER BY created_at DESC
</cfquery>

<cfinclude template="../includes/layout-start.cfm">
<section style="padding:60px 0">
<div class="container">

    <div class="page-header">
        <p class="eyebrow">Manage Your Day</p>
        <h1>Wedding <span class="script">Coordinator</span></h1>
    </div>

    <cfif url.saved EQ "1">
    <div class="alert alert-success">Coordinator information saved successfully.</div>
    </cfif>
    <cfif url.sent EQ "1">
    <div class="alert alert-success">Complete wedding package sent to your coordinator!</div>
    </cfif>
    <cfif url.selftest EQ "1">
    <div class="alert alert-success">Complete wedding package preview sent to <cfoutput>#HTMLEditFormat(session.user.email)#</cfoutput> - check your inbox!</div>
    </cfif>
    <cfif url.error EQ "noemail">
    <div class="alert alert-error">Please add your wedding coordinator&rsquo;s email address before sending information.</div>
    </cfif>
    <cfif url.error EQ "sendfail" OR url.error EQ "selfsendfail">
    <div class="alert alert-error">There was a problem sending the email. Please try again or contact support.</div>
    </cfif>

    <div class="grid-2" style="gap:32px;align-items:start">

        <!--- Coordinator Info Form --->
        <div>
            <div class="panel">
                <p class="panel-title">Coordinator Information</p>
                <form method="post" action="/members/coordinator.cfm">
                    <input type="hidden" name="action" value="save_coordinator">
                    <div class="field">
                        <label>Coordinator Name</label>
                        <input type="text" name="coord_name" maxlength="100"
                               value="<cfoutput>#HTMLEditFormat(qSite.recordCount ? qSite.coord_name : '')#</cfoutput>"
                               placeholder="e.g. Jane Smith">
                    </div>
                    <div class="field">
                        <label>Company Name</label>
                        <input type="text" name="coord_company" maxlength="150"
                               value="<cfoutput>#HTMLEditFormat(qSite.recordCount ? qSite.coord_company : '')#</cfoutput>"
                               placeholder="e.g. Perfect Day Events">
                    </div>
                    <div class="field">
                        <label>Email Address</label>
                        <input type="email" name="coord_email" maxlength="200"
                               value="<cfoutput>#HTMLEditFormat(qSite.recordCount ? qSite.coord_email : '')#</cfoutput>"
                               placeholder="coordinator@example.com">
                    </div>
                    <div class="field">
                        <label>Phone Number</label>
                        <input type="text" name="coord_phone" maxlength="30"
                               value="<cfoutput>#HTMLEditFormat(qSite.recordCount ? qSite.coord_phone : '')#</cfoutput>"
                               placeholder="e.g. (555) 555-5555">
                    </div>
                    <button type="submit" class="btn btn-primary">Save Coordinator Info</button>
                </form>
            </div>
        </div>

        <!--- Send Complete Package --->
        <div>
            <div class="panel">
                <p class="panel-title">Send Complete Package</p>
                <p style="color:var(--text-muted);font-size:14px;margin-bottom:20px">Send all available wedding information to your coordinator in one email - Wedding Party, Guests, Seating Chart, and Wedding Day Schedule.</p>
                <form method="post" action="/members/coordinator.cfm" style="margin-bottom:10px">
                    <input type="hidden" name="action" value="send_package_self">
                    <button type="submit" class="btn btn-ghost">&#128140; Send to Myself</button>
                </form>
                <cfif qSite.recordCount AND len(trim(qSite.coord_email))>
                <p style="font-size:13px;color:var(--text-muted);margin-bottom:16px">
                    Will be sent to: <strong><cfoutput>#HTMLEditFormat(qSite.coord_email)#</cfoutput></strong>
                    <cfif len(trim(qSite.coord_name))> (<cfoutput>#HTMLEditFormat(qSite.coord_name)#</cfoutput>)</cfif>
                </p>
                <form method="post" action="/members/coordinator.cfm">
                    <input type="hidden" name="action" value="send_package">
                    <button type="submit" class="btn btn-primary">Send Complete Package &rarr;</button>
                </form>
                <cfelse>
                <div style="background:var(--light);border-radius:8px;padding:14px 16px;font-size:14px;color:var(--text-muted)">
                    &#128274; Add your coordinator&rsquo;s email address above to enable sending.
                </div>
                </cfif>
            </div>

            <!--- Quick Send Links --->
            <div class="panel" style="margin-top:20px">
                <p class="panel-title">Send Individual Sections</p>
                <p style="color:var(--text-muted);font-size:14px;margin-bottom:16px">Send a single section directly from its page.</p>
                <div style="display:flex;flex-direction:column;gap:10px">
                    <a href="/members/wedding-party.cfm" class="btn btn-ghost btn-sm">&#127939; Wedding Party</a>
                    <a href="/members/guests.cfm" class="btn btn-ghost btn-sm">&#128101; Guests &amp; RSVP</a>
                    <a href="/members/seating-chart.cfm" class="btn btn-ghost btn-sm">&#127960; Seating Chart</a>
                    <a href="/members/timeline.cfm" class="btn btn-ghost btn-sm">&#128197; Wedding Day Schedule</a>
                </div>
            </div>
        </div>

    </div>
</div>
</section>
<cfinclude template="../includes/layout-end.cfm">
