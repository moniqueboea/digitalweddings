<cfinclude template="includes/auth-check.cfm">
<cfset pageTitle = "Gift Registry | digitalweddings.love">
<cfset activePage = "gift-registry">
<cfset userId = session.user.id>
<cfparam name="form.action" default="">

<cfif form.action EQ "save">
    <cfquery name="existing" datasource="#application.config.datasource#">
        SELECT gift_registry_id FROM dbo.GiftRegistries WHERE user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
    </cfquery>
    <cfif existing.recordCount>
        <cfquery datasource="#application.config.datasource#">
            UPDATE dbo.GiftRegistries SET
                registry_type = <cfqueryparam value="#trim(form.registryType)#" cfsqltype="cf_sql_varchar">,
                physical_registry_link = <cfqueryparam value="#trim(form.registryLink)#" cfsqltype="cf_sql_nvarchar" null="#!len(trim(form.registryLink))#">,
                registry_details = <cfqueryparam value="#trim(form.registryDetails)#" cfsqltype="cf_sql_nvarchar" null="#!len(trim(form.registryDetails))#">,
                updated_at = SYSUTCDATETIME()
            WHERE user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
        </cfquery>
    <cfelse>
        <cfquery datasource="#application.config.datasource#">
            INSERT INTO dbo.GiftRegistries (user_id, registry_type, physical_registry_link, registry_details)
            VALUES (
                <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">,
                <cfqueryparam value="#trim(form.registryType)#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#trim(form.registryLink)#" cfsqltype="cf_sql_nvarchar" null="#!len(trim(form.registryLink))#">,
                <cfqueryparam value="#trim(form.registryDetails)#" cfsqltype="cf_sql_nvarchar" null="#!len(trim(form.registryDetails))#">
            )
        </cfquery>
    </cfif>
    <cflocation url="gift-registry.cfm?saved=1" addToken="false">
</cfif>

<cfquery name="registry" datasource="#application.config.datasource#">
    SELECT registry_type, physical_registry_link, registry_details
    FROM dbo.GiftRegistries WHERE user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
</cfquery>

<cfset saved = structKeyExists(url,"saved") && url.saved EQ "1">

<cfinclude template="includes/layout-start.cfm">
<section style="padding:60px 0">
<div class="container" style="max-width:680px">
    <div class="page-header">
        <p class="eyebrow">Gifts &amp; Registries</p>
        <h1>Gift <span class="script">Registry</span></h1>
    </div>

    <cfif saved><div class="alert alert-success">Registry details saved!</div></cfif>

    <div class="panel">
        <form method="post" action="gift-registry.cfm">
            <input type="hidden" name="action" value="save">
            <div class="field">
                <label for="registryType">Registry Type</label>
                <select id="registryType" name="registryType">
                    <option value="physical_gifts" <cfif registry.recordCount && registry.registry_type EQ "physical_gifts">selected</cfif>>Physical Gifts Registry</option>
                    <option value="honey_fund" <cfif registry.recordCount && registry.registry_type EQ "honey_fund">selected</cfif>>Honeymoon Fund</option>
                </select>
            </div>
            <div class="field">
                <label for="registryLink">Registry Link</label>
                <input type="url" id="registryLink" name="registryLink" placeholder="https://www.amazon.com/registry/..." value="<cfoutput>#registry.recordCount ? HTMLEditFormat(registry.physical_registry_link) : ''#</cfoutput>">
            </div>
            <div class="field">
                <label for="registryDetails">Details &amp; Notes</label>
                <textarea id="registryDetails" name="registryDetails" rows="6" placeholder="Add details about your registry, contribution goals, preferred gifts..."><cfoutput>#registry.recordCount ? HTMLEditFormat(registry.registry_details) : ''#</cfoutput></textarea>
            </div>
            <button type="submit" class="btn btn-primary btn-lg">Save Registry</button>
        </form>
    </div>

    <cfif registry.recordCount && len(registry.physical_registry_link)>
    <div class="panel" style="text-align:center">
        <h3 style="margin-bottom:12px">Your Registry Link</h3>
        <a href="<cfoutput>#HTMLEditFormat(registry.physical_registry_link)#</cfoutput>" target="_blank" rel="noopener" class="btn btn-primary">View Registry</a>
    </div>
    </cfif>
</div>
</section>
<cfinclude template="includes/layout-end.cfm">
