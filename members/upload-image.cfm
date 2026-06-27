<cfsetting showdebugoutput="false" enablecfoutputonly="false">
<cfcontent type="application/json" reset="true">
<cfinclude template="../includes/auth-check.cfm">

<cfset response = {}>
<cfset response['success'] = false>
<cfset response['url'] = "">
<cfset response['error'] = "">

<cftry>

    <!--- Step 1: Resolve upload directory from webroot using expandPath --->
    <cfset uploadDir = expandPath("/uploads/wedding-images/")>

    <!--- Step 2: Create directory if it doesn't exist --->
    <cfif !directoryExists(uploadDir)>
        <cfdirectory action="create" directory="#uploadDir#">
    </cfif>

    <!--- Step 3: Upload file --->
    <cffile action="upload"
            filefield="imageFile"
            destination="#uploadDir#"
            accept="image/jpeg,image/jpg,image/png,image/gif,image/webp"
            nameconflict="makeunique">

    <!--- Step 4: Verify file was actually created --->
    <cfset fullPath = uploadDir & cffile.serverFile>
    <cfif !fileExists(fullPath)>
        <cfthrow message="File upload failed - file not found on disk at: #fullPath#">
    </cfif>

    <!--- Step 5: Build public URL --->
    <cfset response['success'] = true>
    <cfset response['url'] = "/uploads/wedding-images/" & cffile.serverFile>

<cfcatch>
    <cfset response['success'] = false>
    <cfset response['error'] = cfcatch.message>
</cfcatch>

</cftry>

<cfoutput>#serializeJSON(response)#</cfoutput>