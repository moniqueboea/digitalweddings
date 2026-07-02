<!---
    Auto-builds the valid template list from files present in members/templates/.
    Adding or removing a .cfm file there automatically updates availability.
    Sets application.templates as a comma-separated list of template IDs (no .cfm extension).
--->
<cfdirectory action="list"
             directory="#expandPath('/members/templates')#"
             name="_qTpls"
             filter="*.cfm"
             type="file"
             sort="name asc">
<cfset application.templates = "">
<cfloop query="_qTpls">
    <cfset _tplId = lCase(listFirst(_qTpls.name, "."))>
    <cfif len(_tplId)>
        <cfset application.templates = listAppend(application.templates, _tplId)>
    </cfif>
</cfloop>
