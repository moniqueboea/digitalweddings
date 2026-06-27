<cfif !structKeyExists(session, "user") || !structKeyExists(session.user, "id")>
    <cflocation url="/login.cfm?redirect=#urlEncodedFormat(cgi.script_name)#" addToken="false">
</cfif>
