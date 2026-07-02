<cfinclude template="../includes/auth-check.cfm">
<cfset pageTitle = "Wedding Decorator | digitalweddings.love">
<cfset activePage = "decorator">
<cfset userId = session.user.id>

<cfparam name="form.action"                      default="">
<cfparam name="form.decorator_name"              default="">
<cfparam name="form.decorator_company"           default="">
<cfparam name="form.decorator_email"             default="">
<cfparam name="form.decorator_phone"             default="">
<cfparam name="form.decorator_website"           default="">
<cfparam name="form.decorator_notes"             default="">
<cfparam name="form.decorator_color_palette"     default="">
<cfparam name="form.decorator_floral_prefs"      default="">
<cfparam name="form.decorator_ceremony_layout"   default="">
<cfparam name="form.decorator_reception_layout"  default="">
<cfparam name="form.decorator_special_instructions" default="">
<cfparam name="url.tab"    default="info">
<cfparam name="url.saved"  default="">
<cfparam name="url.sent"   default="">
<cfparam name="url.self"   default="">
<cfparam name="url.dsent"  default="">
<cfparam name="url.dself"  default="">
<cfparam name="url.error"  default="">

<!--- ============================================================
  Idempotent DDL - create columns and table if not present
============================================================ --->
<cftry><cfquery datasource="#application.config.datasource#">IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='WeddingSites' AND COLUMN_NAME='decorator_name') ALTER TABLE dbo.WeddingSites ADD decorator_name NVARCHAR(150) NULL</cfquery><cfcatch></cfcatch></cftry>
<cftry><cfquery datasource="#application.config.datasource#">IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='WeddingSites' AND COLUMN_NAME='decorator_company') ALTER TABLE dbo.WeddingSites ADD decorator_company NVARCHAR(150) NULL</cfquery><cfcatch></cfcatch></cftry>
<cftry><cfquery datasource="#application.config.datasource#">IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='WeddingSites' AND COLUMN_NAME='decorator_email') ALTER TABLE dbo.WeddingSites ADD decorator_email NVARCHAR(320) NULL</cfquery><cfcatch></cfcatch></cftry>
<cftry><cfquery datasource="#application.config.datasource#">IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='WeddingSites' AND COLUMN_NAME='decorator_phone') ALTER TABLE dbo.WeddingSites ADD decorator_phone NVARCHAR(30) NULL</cfquery><cfcatch></cfcatch></cftry>
<cftry><cfquery datasource="#application.config.datasource#">IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='WeddingSites' AND COLUMN_NAME='decorator_website') ALTER TABLE dbo.WeddingSites ADD decorator_website NVARCHAR(500) NULL</cfquery><cfcatch></cfcatch></cftry>
<cftry><cfquery datasource="#application.config.datasource#">IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='WeddingSites' AND COLUMN_NAME='decorator_notes') ALTER TABLE dbo.WeddingSites ADD decorator_notes NVARCHAR(MAX) NULL</cfquery><cfcatch></cfcatch></cftry>
<cftry><cfquery datasource="#application.config.datasource#">IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='WeddingSites' AND COLUMN_NAME='decorator_include_notes') ALTER TABLE dbo.WeddingSites ADD decorator_include_notes BIT NOT NULL DEFAULT(1)</cfquery><cfcatch></cfcatch></cftry>
<cftry><cfquery datasource="#application.config.datasource#">IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='WeddingSites' AND COLUMN_NAME='decorator_color_palette') ALTER TABLE dbo.WeddingSites ADD decorator_color_palette NVARCHAR(MAX) NULL</cfquery><cfcatch></cfcatch></cftry>
<cftry><cfquery datasource="#application.config.datasource#">IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='WeddingSites' AND COLUMN_NAME='decorator_floral_prefs') ALTER TABLE dbo.WeddingSites ADD decorator_floral_prefs NVARCHAR(MAX) NULL</cfquery><cfcatch></cfcatch></cftry>
<cftry><cfquery datasource="#application.config.datasource#">IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='WeddingSites' AND COLUMN_NAME='decorator_ceremony_layout') ALTER TABLE dbo.WeddingSites ADD decorator_ceremony_layout NVARCHAR(MAX) NULL</cfquery><cfcatch></cfcatch></cftry>
<cftry><cfquery datasource="#application.config.datasource#">IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='WeddingSites' AND COLUMN_NAME='decorator_reception_layout') ALTER TABLE dbo.WeddingSites ADD decorator_reception_layout NVARCHAR(MAX) NULL</cfquery><cfcatch></cfcatch></cftry>
<cftry><cfquery datasource="#application.config.datasource#">IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='WeddingSites' AND COLUMN_NAME='decorator_special_instructions') ALTER TABLE dbo.WeddingSites ADD decorator_special_instructions NVARCHAR(MAX) NULL</cfquery><cfcatch></cfcatch></cftry>
<cftry>
<cfquery datasource="#application.config.datasource#">
IF OBJECT_ID('dbo.InspirationItems','U') IS NULL
CREATE TABLE dbo.InspirationItems (
    item_id BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    title NVARCHAR(300) NOT NULL,
    category NVARCHAR(100) NOT NULL,
    inspiration_url NVARCHAR(1000) NULL,
    description NVARCHAR(MAX) NULL,
    priority NVARCHAR(30) NOT NULL DEFAULT('Preferred'),
    sort_order INT NOT NULL DEFAULT(0),
    created_at DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_InspirationItems_Users FOREIGN KEY (user_id) REFERENCES dbo.Users(user_id) ON DELETE CASCADE
)
</cfquery>
<cfcatch></cfcatch>
</cftry>

<!--- ============================================================
  Load site
============================================================ --->
<cfquery name="qSite" datasource="#application.config.datasource#">
    SELECT wedding_site_id, couple_name_1, couple_name_2, wedding_date, slug, template,
           venue_name, venue_address, ceremony_start_time, reception_start_time,
           decorator_name, decorator_company, decorator_email, decorator_phone,
           decorator_website, decorator_notes, decorator_include_notes,
           decorator_color_palette, decorator_floral_prefs,
           decorator_ceremony_layout, decorator_reception_layout,
           decorator_special_instructions
    FROM dbo.WeddingSites
    WHERE user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
    ORDER BY created_at DESC
</cfquery>

<!--- ============================================================
  AUTO-SAVE NOTES (AJAX)
============================================================ --->
<cfif form.action EQ "autosave_notes" AND structKeyExists(form,"is_ajax") AND form.is_ajax EQ "1">
    <cfif qSite.recordCount>
        <cfquery datasource="#application.config.datasource#">
            UPDATE dbo.WeddingSites
            SET decorator_notes = <cfqueryparam value="#trim(form.decorator_notes)#" cfsqltype="cf_sql_nvarchar" null="#!len(trim(form.decorator_notes))#">
            WHERE user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
        </cfquery>
    </cfif>
    <cfcontent type="application/json">
    <cfoutput>{"status":"saved"}</cfoutput>
    <cfabort>
</cfif>

<!--- ============================================================
  SAVE DECORATOR INFO
============================================================ --->
<cfif form.action EQ "save_decorator" AND qSite.recordCount>
    <cfquery datasource="#application.config.datasource#">
        UPDATE dbo.WeddingSites
        SET decorator_name                = <cfqueryparam value="#trim(form.decorator_name)#"                cfsqltype="cf_sql_nvarchar" null="#!len(trim(form.decorator_name))#">,
            decorator_company             = <cfqueryparam value="#trim(form.decorator_company)#"             cfsqltype="cf_sql_nvarchar" null="#!len(trim(form.decorator_company))#">,
            decorator_email               = <cfqueryparam value="#lCase(trim(form.decorator_email))#"        cfsqltype="cf_sql_nvarchar" null="#!len(trim(form.decorator_email))#">,
            decorator_phone               = <cfqueryparam value="#trim(form.decorator_phone)#"               cfsqltype="cf_sql_nvarchar" null="#!len(trim(form.decorator_phone))#">,
            decorator_website             = <cfqueryparam value="#trim(form.decorator_website)#"             cfsqltype="cf_sql_nvarchar" null="#!len(trim(form.decorator_website))#">,
            decorator_notes               = <cfqueryparam value="#trim(form.decorator_notes)#"               cfsqltype="cf_sql_nvarchar" null="#!len(trim(form.decorator_notes))#">,
            decorator_include_notes       = <cfqueryparam value="#(structKeyExists(form,'include_notes') AND form.include_notes EQ 'on') ? 1 : 0#" cfsqltype="cf_sql_bit">,
            decorator_color_palette       = <cfqueryparam value="#trim(form.decorator_color_palette)#"       cfsqltype="cf_sql_nvarchar" null="#!len(trim(form.decorator_color_palette))#">,
            decorator_floral_prefs        = <cfqueryparam value="#trim(form.decorator_floral_prefs)#"        cfsqltype="cf_sql_nvarchar" null="#!len(trim(form.decorator_floral_prefs))#">,
            decorator_ceremony_layout     = <cfqueryparam value="#trim(form.decorator_ceremony_layout)#"     cfsqltype="cf_sql_nvarchar" null="#!len(trim(form.decorator_ceremony_layout))#">,
            decorator_reception_layout    = <cfqueryparam value="#trim(form.decorator_reception_layout)#"    cfsqltype="cf_sql_nvarchar" null="#!len(trim(form.decorator_reception_layout))#">,
            decorator_special_instructions= <cfqueryparam value="#trim(form.decorator_special_instructions)#" cfsqltype="cf_sql_nvarchar" null="#!len(trim(form.decorator_special_instructions))#">
        WHERE user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
    </cfquery>
    <cflocation url="decorator.cfm?saved=1&tab=info" addToken="false">
</cfif>

<!--- ============================================================
  ADD INSPIRATION ITEM
============================================================ --->
<cfif form.action EQ "add_inspiration" AND len(trim(form.title))>
    <cfquery name="qMaxSort" datasource="#application.config.datasource#">
        SELECT ISNULL(MAX(sort_order),0)+1 AS nextSort FROM dbo.InspirationItems
        WHERE user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
    </cfquery>
    <cfquery datasource="#application.config.datasource#">
        INSERT INTO dbo.InspirationItems (user_id, title, category, inspiration_url, description, priority, sort_order)
        VALUES (
            <cfqueryparam value="#userId#"                      cfsqltype="cf_sql_bigint">,
            <cfqueryparam value="#trim(form.title)#"            cfsqltype="cf_sql_nvarchar">,
            <cfqueryparam value="#trim(form.category)#"         cfsqltype="cf_sql_nvarchar">,
            <cfqueryparam value="#trim(form.inspiration_url)#"  cfsqltype="cf_sql_nvarchar" null="#!len(trim(form.inspiration_url))#">,
            <cfqueryparam value="#trim(form.description)#"      cfsqltype="cf_sql_nvarchar" null="#!len(trim(form.description))#">,
            <cfqueryparam value="#trim(form.priority)#"         cfsqltype="cf_sql_nvarchar">,
            <cfqueryparam value="#qMaxSort.nextSort#"           cfsqltype="cf_sql_integer">
        )
    </cfquery>
    <cflocation url="decorator.cfm?tab=inspiration" addToken="false">
</cfif>

<!--- ============================================================
  EDIT INSPIRATION ITEM
============================================================ --->
<cfif form.action EQ "edit_inspiration" AND isNumeric(form.item_id) AND len(trim(form.title))>
    <cfquery datasource="#application.config.datasource#">
        UPDATE dbo.InspirationItems
        SET title           = <cfqueryparam value="#trim(form.title)#"           cfsqltype="cf_sql_nvarchar">,
            category        = <cfqueryparam value="#trim(form.category)#"        cfsqltype="cf_sql_nvarchar">,
            inspiration_url = <cfqueryparam value="#trim(form.inspiration_url)#" cfsqltype="cf_sql_nvarchar" null="#!len(trim(form.inspiration_url))#">,
            description     = <cfqueryparam value="#trim(form.description)#"     cfsqltype="cf_sql_nvarchar" null="#!len(trim(form.description))#">,
            priority        = <cfqueryparam value="#trim(form.priority)#"        cfsqltype="cf_sql_nvarchar">,
            updated_at      = SYSUTCDATETIME()
        WHERE item_id = <cfqueryparam value="#val(form.item_id)#" cfsqltype="cf_sql_bigint">
          AND user_id = <cfqueryparam value="#userId#"            cfsqltype="cf_sql_bigint">
    </cfquery>
    <cflocation url="decorator.cfm?tab=inspiration" addToken="false">
</cfif>

<!--- ============================================================
  DELETE INSPIRATION ITEM
============================================================ --->
<cfif form.action EQ "delete_inspiration" AND isNumeric(form.item_id)>
    <cfquery datasource="#application.config.datasource#">
        DELETE FROM dbo.InspirationItems
        WHERE item_id = <cfqueryparam value="#val(form.item_id)#" cfsqltype="cf_sql_bigint">
          AND user_id = <cfqueryparam value="#userId#"            cfsqltype="cf_sql_bigint">
    </cfquery>
    <cflocation url="decorator.cfm?tab=inspiration" addToken="false">
</cfif>

<!--- ============================================================
  MOVE INSPIRATION ITEM (up/down)
============================================================ --->
<cfif form.action EQ "move_inspiration" AND isNumeric(form.item_id) AND listFind("up,down",form.direction)>
    <cfquery name="qThis" datasource="#application.config.datasource#">
        SELECT item_id, sort_order FROM dbo.InspirationItems
        WHERE item_id = <cfqueryparam value="#val(form.item_id)#" cfsqltype="cf_sql_bigint">
          AND user_id = <cfqueryparam value="#userId#"            cfsqltype="cf_sql_bigint">
    </cfquery>
    <cfif qThis.recordCount>
        <cfif form.direction EQ "up">
            <cfquery name="qSwap" datasource="#application.config.datasource#">
                SELECT TOP 1 item_id, sort_order FROM dbo.InspirationItems
                WHERE user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
                  AND sort_order < <cfqueryparam value="#qThis.sort_order#" cfsqltype="cf_sql_integer">
                ORDER BY sort_order DESC
            </cfquery>
        <cfelse>
            <cfquery name="qSwap" datasource="#application.config.datasource#">
                SELECT TOP 1 item_id, sort_order FROM dbo.InspirationItems
                WHERE user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
                  AND sort_order > <cfqueryparam value="#qThis.sort_order#" cfsqltype="cf_sql_integer">
                ORDER BY sort_order ASC
            </cfquery>
        </cfif>
        <cfif qSwap.recordCount>
            <cfquery datasource="#application.config.datasource#">UPDATE dbo.InspirationItems SET sort_order = <cfqueryparam value="#qSwap.sort_order#" cfsqltype="cf_sql_integer"> WHERE item_id = <cfqueryparam value="#qThis.item_id#" cfsqltype="cf_sql_bigint"> AND user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint"></cfquery>
            <cfquery datasource="#application.config.datasource#">UPDATE dbo.InspirationItems SET sort_order = <cfqueryparam value="#qThis.sort_order#" cfsqltype="cf_sql_integer"> WHERE item_id = <cfqueryparam value="#qSwap.item_id#" cfsqltype="cf_sql_bigint"> AND user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint"></cfquery>
        </cfif>
    </cfif>
    <cflocation url="decorator.cfm?tab=inspiration" addToken="false">
</cfif>

<!--- ============================================================
  SEND WELCOME EMAIL (to decorator or self)
============================================================ --->
<cfif (form.action EQ "send_welcome" OR form.action EQ "send_welcome_self") AND qSite.recordCount>
    <cfset decIsTest = (form.action EQ "send_welcome_self")>
    <cfif NOT decIsTest AND NOT len(trim(qSite.decorator_email))>
        <cflocation url="decorator.cfm?error=noemail&tab=send" addToken="false">
    </cfif>
    <cfset sendTo = decIsTest ? session.user.email : trim(qSite.decorator_email)>
    <cfset qSiteForEmail = qSite>
    <cfinclude template="email-theme-helper.cfm">
    <cftry>
        <cfset wSubject = decIsTest ? "[TEST] You've Been Added as Our Wedding Decorator" : "You've Been Added as Our Wedding Decorator">
        <cfmail to="#sendTo#"
                from="#application.config.mailFrom#"
                replyto="#session.user.email#"
                server="localhost" port="25"
                subject="#wSubject#"
                type="html" timeout="60"><cfinclude template="email-decorator-welcome-body.cfm"></cfmail>
        <cfif decIsTest>
            <cflocation url="decorator.cfm?self=1&tab=send" addToken="false">
        <cfelse>
            <cflocation url="decorator.cfm?sent=1&tab=send" addToken="false">
        </cfif>
    <cfcatch>
        <cflocation url="decorator.cfm?error=sendfail&tab=send" addToken="false">
    </cfcatch>
    </cftry>
</cfif>

<!--- ============================================================
  SEND DETAILS EMAIL (to decorator or self)
============================================================ --->
<cfif (form.action EQ "send_details" OR form.action EQ "send_details_self") AND qSite.recordCount>
    <cfset decIsTest = (form.action EQ "send_details_self")>
    <cfif NOT decIsTest AND NOT len(trim(qSite.decorator_email))>
        <cflocation url="decorator.cfm?error=noemail&tab=send" addToken="false">
    </cfif>
    <cfset sendTo  = decIsTest ? session.user.email : trim(qSite.decorator_email)>
    <cfset decSentAt = dateTimeFormat(now(),"mmmm d, yyyy h:mm tt")>

    <!--- Determine which sections were checked --->
    <cfset incVenue      = structKeyExists(form,"inc_venue")>
    <cfset incGuestCount = structKeyExists(form,"inc_guest_count")>
    <cfset incSeating    = structKeyExists(form,"inc_seating")>
    <cfset incTables     = structKeyExists(form,"inc_tables")>
    <cfset incParty      = structKeyExists(form,"inc_party")>
    <cfset incTimeline   = structKeyExists(form,"inc_timeline")>
    <cfset incColorPal   = structKeyExists(form,"inc_color_palette")>
    <cfset incFloral     = structKeyExists(form,"inc_floral")>
    <cfset incCeremonyL  = structKeyExists(form,"inc_ceremony_layout")>
    <cfset incReceptionL = structKeyExists(form,"inc_reception_layout")>
    <cfset incInspiration= structKeyExists(form,"inc_inspiration")>
    <cfset incDecNotes   = structKeyExists(form,"inc_decorator_notes")>
    <cfset incSpecial    = structKeyExists(form,"inc_special_instructions")>
    <cfset customNotes   = structKeyExists(form,"custom_notes") ? trim(form.custom_notes) : "">

    <!--- Query needed data --->
    <cfif incGuestCount OR incTables>
        <cfquery name="qGuests" datasource="#application.config.datasource#">
            SELECT guest_id, name, rsvp_status, plus_one, plus_one_name, table_number
            FROM dbo.Guests
            WHERE user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
            ORDER BY name
        </cfquery>
    </cfif>
    <cfif incSeating OR incTables>
        <cfquery name="qTables" datasource="#application.config.datasource#">
            SELECT t.reception_table_id, t.table_number, t.table_name, t.capacity,
                   g.name AS guest_name, g.plus_one, g.plus_one_name
            FROM dbo.ReceptionTables t
            LEFT JOIN dbo.Guests g ON g.user_id = t.user_id AND g.table_number = t.table_number
            WHERE t.user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
            ORDER BY t.table_number, g.name
        </cfquery>
    </cfif>
    <cfif incParty>
        <cfquery name="qParty" datasource="#application.config.datasource#">
            SELECT name, party_role, party_side, email, phone
            FROM dbo.WeddingPartyMembers
            WHERE user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
            ORDER BY party_side, party_role, name
        </cfquery>
    </cfif>
    <cfif incTimeline>
        <cfquery name="qTimeline" datasource="#application.config.datasource#">
            SELECT event_time, event_name, description
            FROM dbo.WeddingTimelines
            WHERE user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
            ORDER BY event_time
        </cfquery>
    </cfif>
    <cfif incInspiration>
        <cfquery name="qInspirationForEmail" datasource="#application.config.datasource#">
            SELECT item_id, title, category, inspiration_url, description, priority
            FROM dbo.InspirationItems
            WHERE user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
            ORDER BY sort_order
        </cfquery>
    </cfif>

    <!--- Build email body --->
    <cfsavecontent variable="decBodyHtml">
    <cfoutput>

    <!--- Section helper styles --->
    <cfset hStyle = "margin:28px 0 12px 0;color:##2c3e2e;font-size:15px;font-weight:700;font-family:Arial,Helvetica,sans-serif;border-bottom:2px solid ##7A9E7E;padding-bottom:8px">
    <cfset tTh    = "padding:7px 10px;text-align:left;font-size:11px;color:##3a5e3e;font-family:Arial,sans-serif;border-bottom:1px solid ##b2cbb5;background:##e8f0e9">
    <cfset tTd    = "padding:7px 10px;font-size:13px;color:##333;font-family:Arial,sans-serif;border-bottom:1px solid ##eee;vertical-align:top">
    <cfset tMuted = "padding:7px 10px;font-size:12px;color:##666;font-family:Arial,sans-serif;border-bottom:1px solid ##eee;vertical-align:top">

    <!--- Venue / Wedding Info --->
    <cfif incVenue>
    <p style="#hStyle#">Wedding Information</p>
    <table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0" style="border-collapse:collapse;margin-bottom:8px">
      <cfif len(trim(qSite.wedding_date))><tr><td style="padding:5px 0;font-size:13px;font-weight:700;color:##666;font-family:Arial,sans-serif;width:36%;vertical-align:top">Wedding Date</td><td style="padding:5px 0;font-size:13px;color:##333;font-family:Arial,sans-serif">#dateFormat(qSite.wedding_date,'mmmm d, yyyy')#</td></tr></cfif>
      <cfif len(trim(qSite.ceremony_start_time))><tr><td style="padding:5px 0;font-size:13px;font-weight:700;color:##666;font-family:Arial,sans-serif;vertical-align:top">Ceremony</td><td style="padding:5px 0;font-size:13px;color:##333;font-family:Arial,sans-serif">#HTMLEditFormat(trim(qSite.ceremony_start_time))#</td></tr></cfif>
      <cfif len(trim(qSite.reception_start_time))><tr><td style="padding:5px 0;font-size:13px;font-weight:700;color:##666;font-family:Arial,sans-serif;vertical-align:top">Reception</td><td style="padding:5px 0;font-size:13px;color:##333;font-family:Arial,sans-serif">#HTMLEditFormat(trim(qSite.reception_start_time))#</td></tr></cfif>
      <cfif len(trim(qSite.venue_name))><tr><td style="padding:5px 0;font-size:13px;font-weight:700;color:##666;font-family:Arial,sans-serif;vertical-align:top">Venue</td><td style="padding:5px 0;font-size:13px;color:##333;font-family:Arial,sans-serif">#HTMLEditFormat(trim(qSite.venue_name))#<cfif len(trim(qSite.venue_address))><br>#HTMLEditFormat(trim(qSite.venue_address))#</cfif></td></tr></cfif>
    </table>
    </cfif>

    <!--- Guest Count --->
    <cfif incGuestCount AND structKeyExists(variables,"qGuests")>
    <p style="#hStyle#">Guest Count</p>
    <cfset gAttending = 0><cfset gDeclined = 0><cfset gPending = 0>
    <cfloop query="qGuests">
      <cfif rsvp_status EQ "attending"><cfset gAttending++><cfif plus_one><cfset gAttending++></cfif>
      <cfelseif rsvp_status EQ "declined"><cfset gDeclined++>
      <cfelse><cfset gPending++></cfif>
    </cfloop>
    <p style="font-size:14px;color:##333;font-family:Arial,sans-serif;margin:0 0 4px 0">Total Guests: <strong>#qGuests.recordCount#</strong></p>
    <p style="font-size:13px;color:##666;font-family:Arial,sans-serif;margin:0 0 4px 0">Attending: #gAttending# &nbsp;|&nbsp; Declined: #gDeclined# &nbsp;|&nbsp; Pending: #gPending#</p>
    </cfif>

    <!--- Seating Chart --->
    <cfif incSeating AND structKeyExists(variables,"qTables") AND qTables.recordCount>
    <p style="#hStyle#">Seating Chart</p>
    <cfset lastTbl = 0>
    <cfloop query="qTables">
      <cfif reception_table_id NEQ lastTbl>
        <cfif lastTbl NEQ 0></table><br></cfif>
        <p style="margin:0 0 4px 0;font-size:13px;font-weight:700;color:##2c3e2e;font-family:Arial,sans-serif">Table #table_number# - #HTMLEditFormat(table_name)# (capacity: #capacity#)</p>
        <table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0" style="border-collapse:collapse">
        <tr><th style="#tTh#">Guest</th><th style="#tTh#">Plus One</th></tr>
        <cfset lastTbl = reception_table_id>
      </cfif>
      <cfif len(trim(guest_name))>
      <tr>
        <td style="#tTd#">#HTMLEditFormat(guest_name)#</td>
        <td style="#tTd#"><cfif plus_one>Yes<cfif len(trim(plus_one_name))> - #HTMLEditFormat(plus_one_name)#</cfif><cfelse>-</cfif></td>
      </tr>
      <cfelse>
      <tr><td colspan="2" style="#tMuted#"><em>No guests assigned yet</em></td></tr>
      </cfif>
    </cfloop>
    </table>
    </cfif>

    <!--- Wedding Party --->
    <cfif incParty AND structKeyExists(variables,"qParty") AND qParty.recordCount>
    <p style="#hStyle#">Wedding Party</p>
    <table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0" style="border-collapse:collapse;margin-bottom:8px">
      <tr><th style="#tTh#">Name</th><th style="#tTh#">Role</th><th style="#tTh#">Side</th><th style="#tTh#">Contact</th></tr>
      <cfloop query="qParty">
      <tr>
        <td style="#tTd#">#HTMLEditFormat(name)#</td>
        <td style="#tTd#">#HTMLEditFormat(party_role)#</td>
        <td style="#tTd#">#HTMLEditFormat(party_side)#</td>
        <td style="#tTd#"><cfif len(trim(email))>#HTMLEditFormat(email)#</cfif><cfif len(trim(phone))><br>#HTMLEditFormat(phone)#</cfif></td>
      </tr>
      </cfloop>
    </table>
    </cfif>

    <!--- Wedding Timeline --->
    <cfif incTimeline AND structKeyExists(variables,"qTimeline") AND qTimeline.recordCount>
    <p style="#hStyle#">Wedding Day Timeline</p>
    <table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0" style="border-collapse:collapse;margin-bottom:8px">
      <tr><th style="#tTh#">Time</th><th style="#tTh#">Event</th><th style="#tTh#">Details</th></tr>
      <cfloop query="qTimeline">
      <tr>
        <td style="#tTd#;white-space:nowrap">#timeFormat(event_time,'h:mm tt')#</td>
        <td style="#tTd#">#HTMLEditFormat(event_name)#</td>
        <td style="#tMuted#">#HTMLEditFormat(description)#</td>
      </tr>
      </cfloop>
    </table>
    </cfif>

    <!--- Color Palette --->
    <cfif incColorPal AND len(trim(qSite.decorator_color_palette))>
    <p style="#hStyle#">Color Palette</p>
    <p style="font-size:14px;color:##333;font-family:Arial,sans-serif;line-height:1.7;white-space:pre-wrap;margin:0 0 8px 0">#HTMLEditFormat(trim(qSite.decorator_color_palette))#</p>
    </cfif>

    <!--- Floral Preferences --->
    <cfif incFloral AND len(trim(qSite.decorator_floral_prefs))>
    <p style="#hStyle#">Floral Preferences</p>
    <p style="font-size:14px;color:##333;font-family:Arial,sans-serif;line-height:1.7;white-space:pre-wrap;margin:0 0 8px 0">#HTMLEditFormat(trim(qSite.decorator_floral_prefs))#</p>
    </cfif>

    <!--- Ceremony Layout --->
    <cfif incCeremonyL AND len(trim(qSite.decorator_ceremony_layout))>
    <p style="#hStyle#">Ceremony Layout</p>
    <p style="font-size:14px;color:##333;font-family:Arial,sans-serif;line-height:1.7;white-space:pre-wrap;margin:0 0 8px 0">#HTMLEditFormat(trim(qSite.decorator_ceremony_layout))#</p>
    </cfif>

    <!--- Reception Layout --->
    <cfif incReceptionL AND len(trim(qSite.decorator_reception_layout))>
    <p style="#hStyle#">Reception Layout</p>
    <p style="font-size:14px;color:##333;font-family:Arial,sans-serif;line-height:1.7;white-space:pre-wrap;margin:0 0 8px 0">#HTMLEditFormat(trim(qSite.decorator_reception_layout))#</p>
    </cfif>

    <!--- Design Inspiration --->
    <cfif incInspiration AND structKeyExists(variables,"qInspirationForEmail") AND qInspirationForEmail.recordCount>
    <p style="#hStyle#">Design Inspiration</p>
    <cfloop query="qInspirationForEmail">
    <table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0" style="border-collapse:collapse;margin-bottom:18px;border:1px solid ##e8f0e9;border-radius:6px">
      <tr><td style="padding:12px 16px;background:##e8f0e9">
        <p style="margin:0;font-size:14px;font-weight:700;color:##2c3e2e;font-family:Arial,sans-serif">#HTMLEditFormat(title)#</p>
        <p style="margin:4px 0 0 0;font-size:12px;color:##5f8464;font-family:Arial,sans-serif">
          Category: #HTMLEditFormat(category)# &nbsp;|&nbsp; Priority: #HTMLEditFormat(priority)#
        </p>
      </td></tr>
      <cfif len(trim(inspiration_url))>
      <tr><td style="padding:8px 16px;border-top:1px solid ##e8f0e9">
        <p style="margin:0;font-size:13px;font-family:Arial,sans-serif;color:##333">Inspiration Link: <a href="#HTMLEditFormat(trim(inspiration_url))#" style="color:##7A9E7E">#HTMLEditFormat(trim(inspiration_url))#</a></p>
      </td></tr>
      </cfif>
      <cfif len(trim(description))>
      <tr><td style="padding:8px 16px;border-top:1px solid ##e8f0e9">
        <p style="margin:0;font-size:13px;color:##555;font-family:Arial,sans-serif;line-height:1.6">Notes: #HTMLEditFormat(trim(description))#</p>
      </td></tr>
      </cfif>
    </table>
    </cfloop>
    </cfif>

    <!--- Decorator Notes --->
    <cfif incDecNotes AND len(trim(qSite.decorator_notes))>
    <p style="#hStyle#">Decorator Notes</p>
    <p style="font-size:14px;color:##333;font-family:Arial,sans-serif;line-height:1.75;white-space:pre-wrap;margin:0 0 8px 0">#HTMLEditFormat(trim(qSite.decorator_notes))#</p>
    </cfif>

    <!--- Special Instructions --->
    <cfif incSpecial AND len(trim(qSite.decorator_special_instructions))>
    <p style="#hStyle#">Special Instructions</p>
    <p style="font-size:14px;color:##333;font-family:Arial,sans-serif;line-height:1.75;white-space:pre-wrap;margin:0 0 8px 0">#HTMLEditFormat(trim(qSite.decorator_special_instructions))#</p>
    </cfif>

    <!--- Additional Custom Notes --->
    <cfif len(customNotes)>
    <p style="#hStyle#">Additional Notes</p>
    <p style="font-size:14px;color:##333;font-family:Arial,sans-serif;line-height:1.75;white-space:pre-wrap;margin:0 0 8px 0">#HTMLEditFormat(customNotes)#</p>
    </cfif>

    </cfoutput>
    </cfsavecontent>

    <!--- Send the email --->
    <cfset qSiteForEmail = qSite>
    <cfinclude template="email-theme-helper.cfm">
    <cftry>
        <cfset dSubject = decIsTest ? "[TEST] Wedding Planning Details - " : "Wedding Planning Details - ">
        <cfset dSubject = dSubject & trim(qSite.couple_name_1) & " & " & trim(qSite.couple_name_2)>
        <cfmail to="#sendTo#"
                from="#application.config.mailFrom#"
                replyto="#session.user.email#"
                server="localhost" port="25"
                subject="#dSubject#"
                type="html" timeout="60"><cfinclude template="email-decorator-details-body.cfm"></cfmail>
        <cfif decIsTest>
            <cflocation url="decorator.cfm?dself=1&tab=send" addToken="false">
        <cfelse>
            <cflocation url="decorator.cfm?dsent=1&tab=send" addToken="false">
        </cfif>
    <cfcatch>
        <cflocation url="decorator.cfm?error=detailsfail&tab=send" addToken="false">
    </cfcatch>
    </cftry>
</cfif>

<!--- ============================================================
  Load inspiration items
============================================================ --->
<cfquery name="qInspirations" datasource="#application.config.datasource#">
    SELECT item_id, title, category, inspiration_url, description, priority, sort_order
    FROM dbo.InspirationItems
    WHERE user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
    ORDER BY sort_order
</cfquery>

<!--- Validate tab --->
<cfif NOT listFind("info,inspiration,send", url.tab)>
    <cfset url.tab = "info">
</cfif>

<cfset inspCategories = "Ceremony,Reception,Sweetheart Table,Head Table,Guest Tables,Centerpieces,Floral Arrangements,Arch/Altar,Aisle Decor,Lounge Area,Dance Floor,Cake Table,Welcome Table,Signage,Lighting,Ceiling Decor,Photo Booth,Cocktail Hour,Bar Setup,Other">
<cfset inspPriorities = "Must Have,Preferred,Nice to Have">

<cfinclude template="../includes/layout-start.cfm">
<style>
.dec-tab-bar { display:flex; gap:0; border-bottom:2px solid var(--border); margin-bottom:32px; }
.dec-tab { padding:12px 24px; font-size:14px; font-weight:600; color:var(--text-muted); text-decoration:none; border-bottom:3px solid transparent; margin-bottom:-2px; transition:color .15s; white-space:nowrap; }
.dec-tab:hover { color:var(--text); }
.dec-tab.active { color:var(--gold); border-bottom-color:var(--gold); }
.insp-card { border:1px solid var(--border); border-radius:10px; padding:18px 20px; margin-bottom:16px; background:var(--surface,#fff); }
.insp-title { font-size:15px; font-weight:700; color:var(--text); margin-bottom:4px; }
.insp-meta { font-size:13px; color:var(--text-muted); margin-bottom:6px; }
.insp-link { font-size:13px; color:var(--gold); word-break:break-all; }
.insp-notes { font-size:13px; color:var(--text-muted); margin-top:6px; }
.pri-must { display:inline-block; padding:2px 10px; border-radius:20px; font-size:11px; font-weight:700; background:#fef2f2; color:#991b1b; border:1px solid #fca5a5; }
.pri-preferred { display:inline-block; padding:2px 10px; border-radius:20px; font-size:11px; font-weight:700; background:#fffbeb; color:#92400e; border:1px solid #fcd34d; }
.pri-nice { display:inline-block; padding:2px 10px; border-radius:20px; font-size:11px; font-weight:700; background:#f0fdf4; color:#166534; border:1px solid #86efac; }
.insp-actions { display:flex; gap:6px; margin-top:12px; flex-wrap:wrap; }
.autosave-status { font-size:12px; color:var(--text-muted); margin-left:8px; vertical-align:middle; }
.send-checklist label { display:flex; align-items:center; gap:8px; font-size:14px; padding:6px 0; cursor:pointer; }
.send-checklist input[type=checkbox] { width:16px; height:16px; flex-shrink:0; accent-color:var(--gold); }
@media (max-width:640px) {
    .dec-tab { padding:10px 14px; font-size:13px; }
    .dec-grid-2 { grid-template-columns:1fr !important; }
}
</style>

<section style="padding:60px 0">
<div class="container" style="max-width:900px">

    <div class="page-header" style="margin-bottom:32px">
        <p class="eyebrow">Planning Tools</p>
        <h1>Wedding <span class="script">Decorator</span></h1>
        <p style="color:var(--text-muted);font-size:15px;margin-top:8px;max-width:600px">Manage your decorator's contact information, share design inspiration, and send a professional planning package directly to your decorator.</p>
    </div>

    <!--- Flash messages --->
    <cfif url.saved EQ "1"><div class="alert alert-success" style="margin-bottom:24px">Decorator information saved!</div></cfif>
    <cfif url.sent EQ "1"><div class="alert alert-success" style="margin-bottom:24px">Welcome email sent to your decorator at <cfoutput>#HTMLEditFormat(qSite.decorator_email)#</cfoutput>!</div></cfif>
    <cfif url.self EQ "1"><div class="alert alert-success" style="margin-bottom:24px">Test welcome email sent to <cfoutput>#HTMLEditFormat(session.user.email)#</cfoutput> - check your inbox!</div></cfif>
    <cfif url.dsent EQ "1"><div class="alert alert-success" style="margin-bottom:24px">Details email sent to your decorator at <cfoutput>#HTMLEditFormat(qSite.decorator_email)#</cfoutput>!</div></cfif>
    <cfif url.dself EQ "1"><div class="alert alert-success" style="margin-bottom:24px">Test details email sent to <cfoutput>#HTMLEditFormat(session.user.email)#</cfoutput> - check your inbox!</div></cfif>
    <cfif url.error EQ "noemail"><div class="alert alert-error" style="margin-bottom:24px">Please add your decorator's email address before sending. <a href="?tab=info">Add decorator info &rarr;</a></div></cfif>
    <cfif url.error EQ "sendfail" OR url.error EQ "detailsfail"><div class="alert alert-error" style="margin-bottom:24px">There was a problem sending the email. Please try again.</div></cfif>

    <!--- Tab navigation --->
    <cfset tabInfo  = (url.tab EQ "info") ? "dec-tab active" : "dec-tab">
    <cfset tabInsp  = (url.tab EQ "inspiration") ? "dec-tab active" : "dec-tab">
    <cfset tabSend  = (url.tab EQ "send") ? "dec-tab active" : "dec-tab">
    <div class="dec-tab-bar">
        <a href="?tab=info"        class="<cfoutput>#tabInfo#</cfoutput>">&#127968; Decorator Info</a>
        <a href="?tab=inspiration" class="<cfoutput>#tabInsp#</cfoutput>">&#128161; Design Inspiration</a>
        <a href="?tab=send"        class="<cfoutput>#tabSend#</cfoutput>">&#128231; Send to Decorator</a>
    </div>

    <!--- ====================================================
      TAB: INFO & NOTES
    ==================================================== --->
    <cfif url.tab EQ "info">
    <cfoutput>
    <div style="display:grid;grid-template-columns:1fr 1fr;gap:28px;align-items:start" class="dec-grid-2">

        <!--- Contact Info --->
        <div>
            <div class="panel">
                <p class="panel-title">Decorator Contact</p>
                <form method="post" action="/members/decorator.cfm" id="decoratorInfoForm">
                    <input type="hidden" name="action" value="save_decorator">
                    <div class="field">
                        <label>Decorator Name</label>
                        <input type="text" name="decorator_name" maxlength="150"
                               value="#HTMLEditFormat(qSite.recordCount ? trim(qSite.decorator_name) : '')#"
                               placeholder="e.g. Jane Smith">
                    </div>
                    <div class="field">
                        <label>Company Name</label>
                        <input type="text" name="decorator_company" maxlength="150"
                               value="#HTMLEditFormat(qSite.recordCount ? trim(qSite.decorator_company) : '')#"
                               placeholder="e.g. Blooms &amp; Bliss Decor">
                    </div>
                    <div class="field">
                        <label>Email Address</label>
                        <input type="email" name="decorator_email" maxlength="320"
                               value="#HTMLEditFormat(qSite.recordCount ? trim(qSite.decorator_email) : '')#"
                               placeholder="decorator@example.com">
                    </div>
                    <div class="field">
                        <label>Phone Number</label>
                        <input type="tel" name="decorator_phone" maxlength="30"
                               value="#HTMLEditFormat(qSite.recordCount ? trim(qSite.decorator_phone) : '')#"
                               placeholder="(555) 555-5555">
                    </div>
                    <div class="field">
                        <label>Website or Instagram</label>
                        <input type="text" name="decorator_website" maxlength="500"
                               value="#HTMLEditFormat(qSite.recordCount ? trim(qSite.decorator_website) : '')#"
                               placeholder="https://... or @handle">
                    </div>

                    <hr style="border:0;border-top:1px solid var(--border);margin:20px 0">
                    <p class="panel-title" style="margin-bottom:16px">Planning Details</p>

                    <div class="field">
                        <label>Color Palette</label>
                        <input type="text" name="decorator_color_palette" maxlength="500"
                               value="#HTMLEditFormat(qSite.recordCount ? trim(qSite.decorator_color_palette) : '')#"
                               placeholder="e.g. Dusty rose, sage green, ivory, gold">
                    </div>
                    <div class="field">
                        <label>Floral Preferences</label>
                        <textarea name="decorator_floral_prefs" rows="3" placeholder="e.g. Peonies, garden roses, eucalyptus, greenery accent...">#HTMLEditFormat(qSite.recordCount ? trim(qSite.decorator_floral_prefs) : '')#</textarea>
                    </div>
                    <div class="field">
                        <label>Ceremony Layout</label>
                        <textarea name="decorator_ceremony_layout" rows="3" placeholder="Describe your ceremony layout, aisle setup, seating arrangement...">#HTMLEditFormat(qSite.recordCount ? trim(qSite.decorator_ceremony_layout) : '')#</textarea>
                    </div>
                    <div class="field">
                        <label>Reception Layout</label>
                        <textarea name="decorator_reception_layout" rows="3" placeholder="Describe your reception layout, table arrangements, head table, etc...">#HTMLEditFormat(qSite.recordCount ? trim(qSite.decorator_reception_layout) : '')#</textarea>
                    </div>
                    <div class="field">
                        <label>Special Instructions</label>
                        <textarea name="decorator_special_instructions" rows="3" placeholder="Any special setup instructions or notes for your decorator...">#HTMLEditFormat(qSite.recordCount ? trim(qSite.decorator_special_instructions) : '')#</textarea>
                    </div>

                    <!--- Notes section inside form so it saves together --->
                    <hr style="border:0;border-top:1px solid var(--border);margin:20px 0">
                    <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:8px">
                        <p class="panel-title" style="margin:0">Decorator Notes</p>
                        <span id="saveStatus" class="autosave-status"></span>
                    </div>
                    <p style="font-size:13px;color:var(--text-muted);margin-bottom:10px">Personal notes for your decorator. Auto-saves as you type.</p>
                    <textarea id="decoratorNotes" name="decorator_notes" rows="6"
                              placeholder="Share any additional notes, ideas, or instructions for your decorator..."
                              style="margin-bottom:12px">#HTMLEditFormat(qSite.recordCount ? trim(qSite.decorator_notes) : '')#</textarea>
                    <div style="display:flex;align-items:center;gap:10px;margin-bottom:16px">
                        <input type="checkbox" name="include_notes" id="includeNotes"
                               <cfif qSite.recordCount AND val(qSite.decorator_include_notes)>checked</cfif>>
                        <label for="includeNotes" style="font-size:14px;color:var(--text);cursor:pointer;margin:0">Include Decorator Notes in Email</label>
                    </div>

                    <button type="submit" class="btn btn-primary">Save All Information</button>
                </form>
            </div>
        </div>

        <!--- Quick status card --->
        <div>
            <div class="panel">
                <p class="panel-title">Quick Summary</p>
                <cfif qSite.recordCount AND len(trim(qSite.decorator_name))>
                <p style="font-size:14px;color:var(--text);margin-bottom:6px"><strong>#HTMLEditFormat(trim(qSite.decorator_name))#</strong></p>
                <cfif len(trim(qSite.decorator_company))><p style="font-size:13px;color:var(--text-muted);margin-bottom:4px">#HTMLEditFormat(trim(qSite.decorator_company))#</p></cfif>
                <cfif len(trim(qSite.decorator_email))><p style="font-size:13px;color:var(--text-muted);margin-bottom:4px">&##128231; #HTMLEditFormat(trim(qSite.decorator_email))#</p></cfif>
                <cfif len(trim(qSite.decorator_phone))><p style="font-size:13px;color:var(--text-muted);margin-bottom:4px">&##128222; #HTMLEditFormat(trim(qSite.decorator_phone))#</p></cfif>
                <cfif len(trim(qSite.decorator_website))><p style="font-size:13px;margin-bottom:4px"><a href="#HTMLEditFormat(trim(qSite.decorator_website))#" target="_blank" rel="noopener noreferrer" style="color:var(--gold)">&##127760; #HTMLEditFormat(trim(qSite.decorator_website))#</a></p></cfif>
                <cfelse>
                <p style="font-size:14px;color:var(--text-muted);font-style:italic">No decorator added yet. Fill in the form to get started.</p>
                </cfif>
                <hr style="border:0;border-top:1px solid var(--border);margin:16px 0">
                <p style="font-size:13px;color:var(--text-muted);margin-bottom:10px">Inspiration items saved: <strong>#qInspirations.recordCount#</strong></p>
                <a href="?tab=inspiration" class="btn btn-ghost btn-sm">&##128161; Manage Inspiration &rarr;</a>
            </div>

            <div class="panel" style="margin-top:20px;background:var(--surface-alt,##faf9f7);border-left:4px solid var(--gold)">
                <p style="font-size:13px;color:var(--text-muted);line-height:1.75;margin:0">
                    <strong>Tip:</strong> Fill in your planning details, add design inspiration, then use the <a href="?tab=send" style="color:var(--gold)">Send to Decorator</a> tab to share everything in a beautifully formatted email.
                </p>
            </div>
        </div>

    </div>
    </cfoutput>
    </cfif>

    <!--- ====================================================
      TAB: DESIGN INSPIRATION
    ==================================================== --->
    <cfif url.tab EQ "inspiration">
    <cfoutput>

    <div style="display:flex;justify-content:space-between;align-items:center;flex-wrap:wrap;gap:12px;margin-bottom:24px">
        <div>
            <p style="font-size:14px;color:var(--text-muted);margin:0">#qInspirations.recordCount# inspiration item<cfif qInspirations.recordCount NEQ 1>s</cfif> saved</p>
        </div>
        <div style="display:flex;gap:8px;flex-wrap:wrap">
            <button type="button" class="btn btn-ghost btn-sm" onclick="openAllLinks()">&##128279; Open All Inspiration Links</button>
        </div>
    </div>

    <!--- Existing items --->
    <cfif qInspirations.recordCount>
        <cfloop query="qInspirations">
        <div class="insp-card" id="insp-card-#item_id#" data-inspiration-url="#HTMLEditFormat(trim(inspiration_url))#">
            <div style="display:flex;justify-content:space-between;align-items:start;gap:12px">
                <div style="flex:1;min-width:0">
                    <div class="insp-title">#HTMLEditFormat(title)#</div>
                    <div class="insp-meta">
                        #HTMLEditFormat(category)# &nbsp;
                        <cfif priority EQ "Must Have"><span class="pri-must">Must Have</span>
                        <cfelseif priority EQ "Preferred"><span class="pri-preferred">Preferred</span>
                        <cfelse><span class="pri-nice">Nice to Have</span></cfif>
                    </div>
                    <cfif len(trim(inspiration_url))>
                    <a href="#HTMLEditFormat(trim(inspiration_url))#" target="_blank" rel="noopener noreferrer" class="insp-link">&##128279; #HTMLEditFormat(trim(inspiration_url))#</a>
                    </cfif>
                    <cfif len(trim(description))>
                    <div class="insp-notes">#HTMLEditFormat(description)#</div>
                    </cfif>
                </div>
                <div style="display:flex;flex-direction:column;gap:4px;flex-shrink:0">
                    <form method="post" action="/members/decorator.cfm" style="margin:0">
                        <input type="hidden" name="action" value="move_inspiration">
                        <input type="hidden" name="item_id" value="#item_id#">
                        <input type="hidden" name="direction" value="up">
                        <button type="submit" class="btn btn-ghost btn-sm" style="width:32px;height:32px;padding:0" title="Move up">&##8593;</button>
                    </form>
                    <form method="post" action="/members/decorator.cfm" style="margin:0">
                        <input type="hidden" name="action" value="move_inspiration">
                        <input type="hidden" name="item_id" value="#item_id#">
                        <input type="hidden" name="direction" value="down">
                        <button type="submit" class="btn btn-ghost btn-sm" style="width:32px;height:32px;padding:0" title="Move down">&##8595;</button>
                    </form>
                </div>
            </div>
            <div class="insp-actions">
                <button type="button" class="btn btn-ghost btn-sm" onclick="toggleEdit('iedit-#item_id#')">Edit</button>
                <form method="post" action="/members/decorator.cfm" style="margin:0">
                    <input type="hidden" name="action" value="delete_inspiration">
                    <input type="hidden" name="item_id" value="#item_id#">
                    <button type="submit" class="btn btn-ghost btn-sm" onclick="return confirm('Remove this inspiration item?')">&times; Delete</button>
                </form>
            </div>

            <!--- Inline edit form --->
            <div id="iedit-#item_id#" style="display:none;margin-top:16px;padding-top:16px;border-top:1px solid var(--border)">
                <form method="post" action="/members/decorator.cfm">
                    <input type="hidden" name="action" value="edit_inspiration">
                    <input type="hidden" name="item_id" value="#item_id#">
                    <div style="display:grid;grid-template-columns:1fr 1fr;gap:10px;margin-bottom:10px" class="dec-grid-2">
                        <div class="field" style="margin-bottom:0">
                            <label style="font-size:12px">Title *</label>
                            <input type="text" name="title" value="#HTMLEditFormat(title)#" required>
                        </div>
                        <div class="field" style="margin-bottom:0">
                            <label style="font-size:12px">Category</label>
                            <select name="category">
                                <cfloop list="#inspCategories#" index="cat">
                                <option value="#HTMLEditFormat(cat)#" <cfif category EQ cat>selected</cfif>>#HTMLEditFormat(cat)#</option>
                                </cfloop>
                            </select>
                        </div>
                    </div>
                    <div style="display:grid;grid-template-columns:1fr 1fr;gap:10px;margin-bottom:10px" class="dec-grid-2">
                        <div class="field" style="margin-bottom:0">
                            <label style="font-size:12px">Priority</label>
                            <select name="priority">
                                <cfloop list="#inspPriorities#" index="pri">
                                <option value="#HTMLEditFormat(pri)#" <cfif priority EQ pri>selected</cfif>>#HTMLEditFormat(pri)#</option>
                                </cfloop>
                            </select>
                        </div>
                        <div class="field" style="margin-bottom:0">
                            <label style="font-size:12px">Inspiration URL</label>
                            <input type="url" name="inspiration_url" value="#HTMLEditFormat(trim(inspiration_url))#" placeholder="Pinterest, Instagram, etc.">
                        </div>
                    </div>
                    <div class="field" style="margin-bottom:10px">
                        <label style="font-size:12px">Description / Notes</label>
                        <textarea name="description" rows="2">#HTMLEditFormat(trim(description))#</textarea>
                    </div>
                    <div style="display:flex;gap:8px">
                        <button type="submit" class="btn btn-primary btn-sm">Save</button>
                        <button type="button" class="btn btn-ghost btn-sm" onclick="toggleEdit('iedit-#item_id#')">Cancel</button>
                    </div>
                </form>
            </div>
        </div>
        </cfloop>
    <cfelse>
        <div class="empty-state" style="margin-bottom:32px">
            <div style="font-size:48px;margin-bottom:16px">&##128161;</div>
            <p>No inspiration items yet. Add your first one below!</p>
        </div>
    </cfif>

    <!--- Add new inspiration item --->
    <div class="panel" style="margin-top:8px;background:var(--surface-alt,##faf9f7)">
        <p class="panel-title">Add Inspiration Item</p>
        <form method="post" action="/members/decorator.cfm">
            <input type="hidden" name="action" value="add_inspiration">
            <div style="display:grid;grid-template-columns:1fr 1fr;gap:10px;margin-bottom:10px" class="dec-grid-2">
                <div class="field" style="margin-bottom:0">
                    <label>Title *</label>
                    <input type="text" name="title" placeholder="e.g. Ceremony Arch" required>
                </div>
                <div class="field" style="margin-bottom:0">
                    <label>Category</label>
                    <select name="category">
                        <cfloop list="#inspCategories#" index="cat">
                        <option value="#HTMLEditFormat(cat)#">#HTMLEditFormat(cat)#</option>
                        </cfloop>
                    </select>
                </div>
            </div>
            <div style="display:grid;grid-template-columns:1fr 1fr;gap:10px;margin-bottom:10px" class="dec-grid-2">
                <div class="field" style="margin-bottom:0">
                    <label>Priority</label>
                    <select name="priority">
                        <cfloop list="#inspPriorities#" index="pri">
                        <option value="#HTMLEditFormat(pri)#">#HTMLEditFormat(pri)#</option>
                        </cfloop>
                    </select>
                </div>
                <div class="field" style="margin-bottom:0">
                    <label>Inspiration URL</label>
                    <input type="url" name="inspiration_url" placeholder="Pinterest, Instagram, TikTok, Etsy...">
                </div>
            </div>
            <div class="field" style="margin-bottom:16px">
                <label>Description / Notes</label>
                <textarea name="description" rows="2" placeholder="Describe what you love about this, color variations, sizing notes, etc."></textarea>
            </div>
            <button type="submit" class="btn btn-primary">+ Add Inspiration Item</button>
        </form>
    </div>

    </cfoutput>
    </cfif>

    <!--- ====================================================
      TAB: SEND TO DECORATOR
    ==================================================== --->
    <cfif url.tab EQ "send">
    <cfoutput>
    <div style="display:grid;grid-template-columns:1fr 1fr;gap:28px;align-items:start" class="dec-grid-2">

        <!--- Welcome email panel --->
        <div>
            <div class="panel">
                <p class="panel-title">Welcome Email</p>
                <p style="color:var(--text-muted);font-size:14px;margin-bottom:16px;line-height:1.6">
                    Let your decorator know they've been selected. Sends a branded welcome email with your wedding date, time, and location.
                </p>
                <form method="post" action="/members/decorator.cfm" style="margin-bottom:10px">
                    <input type="hidden" name="action" value="send_welcome_self">
                    <button type="submit" class="btn btn-ghost" style="width:100%">&##128140; Send Test Email to Myself</button>
                </form>
                <cfif qSite.recordCount AND len(trim(qSite.decorator_email))>
                <p style="font-size:12px;color:var(--text-muted);margin-bottom:10px">Will be sent to: <strong>#HTMLEditFormat(trim(qSite.decorator_email))#</strong></p>
                <form method="post" action="/members/decorator.cfm">
                    <input type="hidden" name="action" value="send_welcome">
                    <button type="submit" class="btn btn-secondary" style="width:100%">&##128231; Send Welcome Email to Decorator</button>
                </form>
                <cfelse>
                <div style="background:var(--light);border-radius:8px;padding:12px 14px;font-size:13px;color:var(--text-muted)">
                    &##128274; Add your decorator's email address to enable sending.
                </div>
                </cfif>
            </div>
        </div>

        <!--- Details email panel with checklist --->
        <div>
            <div class="panel">
                <p class="panel-title">Send Details to Decorator</p>
                <p style="color:var(--text-muted);font-size:14px;margin-bottom:20px;line-height:1.6">
                    Choose what to include and send a complete planning package to your decorator.
                </p>

                <form method="post" action="/members/decorator.cfm" id="detailsForm">
                    <input type="hidden" name="action" id="detailsAction" value="send_details_self">

                    <div class="send-checklist" style="margin-bottom:20px">
                        <p style="font-size:12px;font-weight:700;letter-spacing:2px;text-transform:uppercase;color:var(--text-muted);margin-bottom:10px">Select Sections to Include</p>
                        <label><input type="checkbox" name="inc_venue" checked> Venue Information</label>
                        <label><input type="checkbox" name="inc_guest_count" checked> Guest Count</label>
                        <label><input type="checkbox" name="inc_seating" checked> Seating Chart</label>
                        <label><input type="checkbox" name="inc_party" checked> Wedding Party</label>
                        <label><input type="checkbox" name="inc_timeline" checked> Wedding Day Timeline</label>
                        <label><input type="checkbox" name="inc_color_palette" checked> Color Palette</label>
                        <label><input type="checkbox" name="inc_floral" checked> Floral Preferences</label>
                        <label><input type="checkbox" name="inc_ceremony_layout" checked> Ceremony Layout</label>
                        <label><input type="checkbox" name="inc_reception_layout" checked> Reception Layout</label>
                        <label><input type="checkbox" name="inc_inspiration" checked> Design Inspiration Links</label>
                        <label><input type="checkbox" name="inc_decorator_notes" <cfif qSite.recordCount AND val(qSite.decorator_include_notes)>checked</cfif>> Decorator Notes</label>
                        <label><input type="checkbox" name="inc_special_instructions" checked> Special Instructions</label>
                    </div>

                    <div class="field" style="margin-bottom:20px">
                        <label style="font-size:13px">Additional Custom Notes</label>
                        <textarea name="custom_notes" rows="3" placeholder="Any extra notes to include in this email only..."></textarea>
                    </div>

                    <div style="display:flex;flex-direction:column;gap:10px">
                        <button type="button" class="btn btn-ghost" style="width:100%"
                                onclick="document.getElementById('detailsAction').value='send_details_self';document.getElementById('detailsForm').submit()">
                            &##128140; Send Test Details to Myself
                        </button>
                        <cfif qSite.recordCount AND len(trim(qSite.decorator_email))>
                        <p style="font-size:12px;color:var(--text-muted);margin:0">Will be sent to: <strong>#HTMLEditFormat(trim(qSite.decorator_email))#</strong></p>
                        <button type="button" class="btn btn-primary" style="width:100%"
                                onclick="document.getElementById('detailsAction').value='send_details';document.getElementById('detailsForm').submit()">
                            &##127968; Send Details to Decorator
                        </button>
                        <cfelse>
                        <div style="background:var(--light);border-radius:8px;padding:12px 14px;font-size:13px;color:var(--text-muted)">
                            &##128274; Add your decorator's email address to enable sending.
                        </div>
                        </cfif>
                    </div>
                </form>
            </div>
        </div>

    </div>
    </cfoutput>
    </cfif>

</div>
</section>

<script>
function toggleEdit(id) {
    var el = document.getElementById(id);
    el.style.display = el.style.display === 'none' ? 'block' : 'none';
}

function openAllLinks() {
    var cards = document.querySelectorAll('[data-inspiration-url]');
    var opened = 0;
    cards.forEach(function(el) {
        var url = el.getAttribute('data-inspiration-url');
        if (url && url.length > 0) { window.open(url, '_blank'); opened++; }
    });
    if (opened === 0) alert('No inspiration links saved yet.');
}

// Auto-save decorator notes
(function() {
    var textarea = document.getElementById('decoratorNotes');
    var status   = document.getElementById('saveStatus');
    if (!textarea || !status) return;
    var timer = null;
    textarea.addEventListener('input', function() {
        clearTimeout(timer);
        status.textContent = 'Unsaved...';
        timer = setTimeout(function() {
            status.textContent = 'Saving...';
            var fd = new FormData();
            fd.append('action', 'autosave_notes');
            fd.append('is_ajax', '1');
            fd.append('decorator_notes', textarea.value);
            fetch('/members/decorator.cfm', { method: 'POST', body: fd })
                .then(function(r) { return r.json(); })
                .then(function(d) { status.textContent = d.status === 'saved' ? 'Saved' : ''; })
                .catch(function() { status.textContent = 'Save failed'; });
        }, 1500);
    });
})();
</script>

<cfinclude template="../includes/layout-end.cfm">
