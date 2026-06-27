<cfinclude template="../includes/auth-check.cfm">
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

<cfinclude template="../includes/layout-start.cfm">
<section style="padding:60px 0">
<div class="container" style="max-width:680px">
    <div class="page-header">
        <p class="eyebrow">Gifts &amp; Registries</p>
        <h1>Gift <span class="script">Registry</span></h1>
    </div>

    <cfif saved><div class="alert alert-success">Registry details saved!</div></cfif>

    <div class="panel" style="margin-bottom:24px;background:var(--surface-alt,##faf8f4);border-left:3px solid var(--gold)">
        <p style="margin:0 0 10px;font-weight:600;color:var(--text)">Choose the type of registry you&rsquo;d like to display on your wedding website.</p>
        <ul style="margin:0;padding-left:20px;color:var(--text-muted);line-height:1.8">
            <li><strong>Honeyfund / Cash Registry</strong> &ndash; Enter the link to your Honeyfund or other cash gift registry.</li>
            <li><strong>Gift Registry</strong> &ndash; Enter the link to your registry from Amazon, Target, Walmart, or any other retailer.</li>
        </ul>
        <p style="margin:12px 0 0;font-size:13px;color:var(--text-muted)"><strong>Note:</strong> The registry link you provide will be displayed on your wedding website. When guests click the Wedding Registry button, they will be taken directly to your registry.</p>
    </div>

    <div class="panel">
        <form method="post" action="/members/gift-registry.cfm">
            <input type="hidden" name="action" value="save">
            <div class="field">
                <label for="registryType">Registry Type</label>
                <select id="registryType" name="registryType">
                    <option value="physical_gifts" <cfif registry.recordCount && registry.registry_type EQ "physical_gifts">selected</cfif>>Gift Registry (Amazon, Target, Walmart, etc.)</option>
                    <option value="honey_fund" <cfif registry.recordCount && registry.registry_type EQ "honey_fund">selected</cfif>>Honeyfund / Cash Registry</option>
                </select>
            </div>
            <div class="field">
                <label for="registryLink">Registry Link</label>
                <input type="url" id="registryLink" name="registryLink" placeholder="https://www.amazon.com/registry/..." value="<cfoutput>#registry.recordCount ? HTMLEditFormat(registry.physical_registry_link) : ''#</cfoutput>">
            </div>
            <div class="field">
                <label for="registryDetails">Details &amp; Notes <span style="font-weight:400;text-transform:none;letter-spacing:0">(optional - shown to guests alongside your registry link)</span></label>
                <textarea id="registryDetails" name="registryDetails" rows="4" placeholder="e.g. We&apos;re saving for our honeymoon in Italy! Any contribution is greatly appreciated."><cfoutput>#registry.recordCount ? HTMLEditFormat(registry.registry_details) : ''#</cfoutput></textarea>
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
<cfinclude template="../includes/layout-end.cfm">
