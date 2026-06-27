<cfinclude template="../includes/auth-check.cfm">
<cfparam name="url.template" default="classic_gold">
<cflocation url="/members/render-template.cfm?template=#URLEncodedFormat(url.template)#" addtoken="false">
