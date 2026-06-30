<cfif !structKeyExists(session,"user") OR !structKeyExists(session.user,"id") OR !session.user.is_admin>
    <cflocation url="/login.cfm?redirect=/admin/index.cfm" addToken="false">
</cfif>
