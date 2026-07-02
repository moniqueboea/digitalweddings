<cfscript>
structClear(session);
sessionInvalidate();
</cfscript>
<cflocation url="/index.cfm" addToken="false">
