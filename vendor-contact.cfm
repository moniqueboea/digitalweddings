<cfparam name="form.vendorId"    default="0">
<cfparam name="form.senderName"  default="">
<cfparam name="form.senderEmail" default="">
<cfparam name="form.message"     default="">
<cfparam name="url.return"       default="/vendors.cfm">

<!--- Auto-create table if missing --->
<cftry>
<cfquery datasource="#application.config.datasource#">
    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME='VendorMessages')
    CREATE TABLE dbo.VendorMessages (
        message_id   bigint IDENTITY(1,1) PRIMARY KEY,
        vendor_id    bigint NOT NULL,
        sender_name  nvarchar(200) NOT NULL,
        sender_email nvarchar(200) NOT NULL,
        message      nvarchar(MAX) NOT NULL,
        is_read      bit NOT NULL DEFAULT 0,
        created_at   datetime2 NOT NULL DEFAULT SYSUTCDATETIME()
    )
</cfquery>
<cfcatch></cfcatch>
</cftry>

<cfset errors = []>
<cfif NOT (isNumeric(form.vendorId) AND form.vendorId GT 0)>
    <cfset arrayAppend(errors, "Invalid vendor.")>
</cfif>
<cfif NOT len(trim(form.senderName))>
    <cfset arrayAppend(errors, "Please enter your name.")>
</cfif>
<cfif NOT isValid("email", trim(form.senderEmail))>
    <cfset arrayAppend(errors, "Please enter a valid email address.")>
</cfif>
<cfif NOT len(trim(form.message))>
    <cfset arrayAppend(errors, "Please enter a message.")>
</cfif>

<cfif arrayLen(errors) EQ 0>
    <!--- Look up vendor --->
    <cfquery name="qVendor" datasource="#application.config.datasource#">
        SELECT vendor_id, business_name, email FROM dbo.Vendors
        WHERE vendor_id = <cfqueryparam value="#form.vendorId#" cfsqltype="cf_sql_bigint">
          AND status = 'approved'
    </cfquery>

    <cfif qVendor.recordCount>
        <!--- Save message --->
        <cfquery datasource="#application.config.datasource#">
            INSERT INTO dbo.VendorMessages (vendor_id, sender_name, sender_email, message)
            VALUES (
                <cfqueryparam value="#form.vendorId#"           cfsqltype="cf_sql_bigint">,
                <cfqueryparam value="#trim(form.senderName)#"   cfsqltype="cf_sql_nvarchar">,
                <cfqueryparam value="#lCase(trim(form.senderEmail))#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#trim(form.message)#"      cfsqltype="cf_sql_nvarchar">
            )
        </cfquery>

        <!--- Track as inquiry --->
        <cftry>
        <cfquery datasource="#application.config.datasource#">
            INSERT INTO dbo.VendorAnalytics (vendor_id, event_type, event_date)
            VALUES (
                <cfqueryparam value="#form.vendorId#" cfsqltype="cf_sql_bigint">,
                'email_click',
                CAST(SYSUTCDATETIME() AS date)
            )
        </cfquery>
        <cfcatch></cfcatch>
        </cftry>

        <!--- Email notification to vendor if they have an email --->
        <cfif len(trim(qVendor.email))>
            <cftry>
            <cfmail to="#trim(qVendor.email)#"
                    from="#application.config.mailFrom#"
                    replyto="#lCase(trim(form.senderEmail))#"
                    subject="New inquiry from #trim(form.senderName)# via digitalweddings.love"
                    server="localhost" port="25" timeout="60"
                    type="text">
You have a new inquiry from a couple on digitalweddings.love.

From:    #trim(form.senderName)#
Email:   #lCase(trim(form.senderEmail))#

Message:
#trim(form.message)#

---
Reply directly to this email to respond to #trim(form.senderName)#.
            </cfmail>
            <cfcatch></cfcatch>
            </cftry>
        </cfif>

        <cflocation url="#url.return#?contacted=1" addToken="false">
    <cfelse>
        <cflocation url="#url.return#?contacted=error" addToken="false">
    </cfif>
<cfelse>
    <cflocation url="#url.return#?contacted=error" addToken="false">
</cfif>
