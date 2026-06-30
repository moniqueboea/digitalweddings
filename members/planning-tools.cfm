<cfinclude template="../includes/auth-check.cfm">
<cfset pageTitle = "Planning Tools | digitalweddings.love">
<cfset activePage = "planning-tools">
<cfset userId = session.user.id>
<cfparam name="form.action" default="">

<!--- Add total_budget column if it doesn't exist yet --->
<cftry>
    <cfquery datasource="#application.config.datasource#">
        IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA='dbo' AND TABLE_NAME='Users' AND COLUMN_NAME='total_budget')
            ALTER TABLE dbo.Users ADD total_budget DECIMAL(12,2) NULL
    </cfquery>
    <cfcatch></cfcatch>
</cftry>

<!--- Handle: set total budget --->
<cfif form.action EQ "set_total_budget" && isNumeric(form.totalBudget) && val(form.totalBudget) GTE 0>
    <cfquery datasource="#application.config.datasource#">
        UPDATE dbo.Users SET total_budget = <cfqueryparam value="#val(form.totalBudget)#" cfsqltype="cf_sql_decimal">
        WHERE user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
    </cfquery>
    <cflocation url="planning-tools.cfm" addToken="false">
</cfif>

<!--- Ensure deposit_paid column exists --->
<cftry>
    <cfquery name="qCheckDepositCol" datasource="#application.config.datasource#">
        SELECT COUNT(*) AS cnt FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_SCHEMA='dbo' AND TABLE_NAME='BudgetItems' AND COLUMN_NAME='deposit_paid'
    </cfquery>
    <cfif qCheckDepositCol.cnt EQ 0>
        <cfquery datasource="#application.config.datasource#">
            ALTER TABLE dbo.BudgetItems ADD deposit_paid DECIMAL(12,2) NOT NULL CONSTRAINT DF_BudgetItems_Deposit DEFAULT (0)
        </cfquery>
        <cfquery datasource="#application.config.datasource#">
            UPDATE dbo.BudgetItems SET deposit_paid = CASE WHEN actual_cost > 0 THEN actual_cost ELSE estimated_cost END WHERE paid = 1
        </cfquery>
    </cfif>
    <cfcatch></cfcatch>
</cftry>

<!--- Handle: add budget item --->
<cfif form.action EQ "add_budget">
    <cfif len(trim(form.category)) && len(trim(form.itemName))>
        <cfset newDeposit = val(structKeyExists(form,'depositPaid') ? form.depositPaid : 0)>
        <cfset newEstimated = val(form.estimatedCost)>
        <cfif newDeposit GT newEstimated><cfset newDeposit = newEstimated></cfif>
        <cfif newDeposit LT 0><cfset newDeposit = 0></cfif>
        <cfset newPaid = (newDeposit GTE newEstimated && newEstimated GT 0) ? 1 : 0>
        <cfquery datasource="#application.config.datasource#">
            INSERT INTO dbo.BudgetItems (user_id, category, item_name, estimated_cost, actual_cost, deposit_paid, paid, vendor_name, notes)
            VALUES (
                <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">,
                <cfqueryparam value="#trim(form.category)#" cfsqltype="cf_sql_nvarchar">,
                <cfqueryparam value="#trim(form.itemName)#" cfsqltype="cf_sql_nvarchar">,
                <cfqueryparam value="#newEstimated#" cfsqltype="cf_sql_decimal">,
                <cfqueryparam value="#newEstimated#" cfsqltype="cf_sql_decimal">,
                <cfqueryparam value="#newDeposit#" cfsqltype="cf_sql_decimal">,
                <cfqueryparam value="#newPaid#" cfsqltype="cf_sql_bit">,
                <cfqueryparam value="#trim(form.vendorName)#" cfsqltype="cf_sql_nvarchar" null="#!len(trim(form.vendorName))#">,
                <cfqueryparam value="#trim(form.notes)#" cfsqltype="cf_sql_nvarchar" null="#!len(trim(form.notes))#">
            )
        </cfquery>
    </cfif>
    <cflocation url="planning-tools.cfm" addToken="false">
</cfif>

<!--- Handle: update deposit --->
<cfif form.action EQ "update_deposit" && isNumeric(form.budgetItemId)>
    <cfquery name="qItemForDeposit" datasource="#application.config.datasource#">
        SELECT estimated_cost FROM dbo.BudgetItems
        WHERE budget_item_id = <cfqueryparam value="#form.budgetItemId#" cfsqltype="cf_sql_bigint">
          AND user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
    </cfquery>
    <cfif qItemForDeposit.recordCount>
        <cfset updDeposit = val(form.depositPaid)>
        <cfset updEstimated = qItemForDeposit.estimated_cost>
        <cfif updDeposit LT 0><cfset updDeposit = 0></cfif>
        <cfif updDeposit GT updEstimated><cfset updDeposit = updEstimated></cfif>
        <cfset updPaid = (updDeposit GTE updEstimated && updEstimated GT 0) ? 1 : 0>
        <cfquery datasource="#application.config.datasource#">
            UPDATE dbo.BudgetItems
            SET deposit_paid = <cfqueryparam value="#updDeposit#" cfsqltype="cf_sql_decimal">,
                paid = <cfqueryparam value="#updPaid#" cfsqltype="cf_sql_bit">,
                updated_at = SYSUTCDATETIME()
            WHERE budget_item_id = <cfqueryparam value="#form.budgetItemId#" cfsqltype="cf_sql_bigint">
              AND user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
        </cfquery>
    </cfif>
    <cflocation url="planning-tools.cfm##budget" addToken="false">
</cfif>

<!--- Handle: delete budget item --->
<cfif form.action EQ "delete_budget" && isNumeric(form.budgetItemId)>
    <cfquery datasource="#application.config.datasource#">
        DELETE FROM dbo.BudgetItems WHERE budget_item_id = <cfqueryparam value="#form.budgetItemId#" cfsqltype="cf_sql_bigint"> AND user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
    </cfquery>
    <cflocation url="planning-tools.cfm" addToken="false">
</cfif>

<!--- Handle: add checklist item --->
<cfif form.action EQ "add_checklist" && len(trim(form.title))>
    <cfquery datasource="#application.config.datasource#">
        INSERT INTO dbo.ChecklistItems (user_id, title, description, due_date, priority, category)
        VALUES (
            <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">,
            <cfqueryparam value="#trim(form.title)#" cfsqltype="cf_sql_nvarchar">,
            <cfqueryparam value="#trim(form.description)#" cfsqltype="cf_sql_nvarchar" null="#!len(trim(form.description))#">,
            <cfqueryparam value="#trim(form.dueDate)#" cfsqltype="cf_sql_date" null="#!len(trim(form.dueDate))#">,
            <cfqueryparam value="#len(trim(form.priority)) ? trim(form.priority) : 'medium'#" cfsqltype="cf_sql_varchar">,
            <cfqueryparam value="#len(trim(form.category)) ? trim(form.category) : 'Other'#" cfsqltype="cf_sql_nvarchar">
        )
    </cfquery>
    <cflocation url="planning-tools.cfm##checklist" addToken="false">
</cfif>

<!--- Handle: toggle checklist --->
<cfif form.action EQ "toggle_checklist" && isNumeric(form.checklistItemId)>
    <cfquery datasource="#application.config.datasource#">
        UPDATE dbo.ChecklistItems SET completed = ~completed, updated_at = SYSUTCDATETIME()
        WHERE checklist_item_id = <cfqueryparam value="#form.checklistItemId#" cfsqltype="cf_sql_bigint"> AND user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
    </cfquery>
    <cflocation url="planning-tools.cfm##checklist" addToken="false">
</cfif>

<!--- Handle: delete checklist --->
<cfif form.action EQ "delete_checklist" && isNumeric(form.checklistItemId)>
    <cfquery datasource="#application.config.datasource#">
        DELETE FROM dbo.ChecklistItems WHERE checklist_item_id = <cfqueryparam value="#form.checklistItemId#" cfsqltype="cf_sql_bigint"> AND user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
    </cfquery>
    <cflocation url="planning-tools.cfm##checklist" addToken="false">
</cfif>

<!--- Handle: bulk add prebuilt checklist items --->
<cfif form.action EQ "add_prebuilt" && structKeyExists(form, "prebuiltItems")>
    <cfloop list="#form.prebuiltItems#" index="taskTitle" delimiters=",">
        <cfif len(trim(taskTitle))>
            <cfquery datasource="#application.config.datasource#">
                INSERT INTO dbo.ChecklistItems (user_id, title, category, priority)
                VALUES (
                    <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">,
                    <cfqueryparam value="#trim(taskTitle)#" cfsqltype="cf_sql_nvarchar">,
                    'Other',
                    'medium'
                )
            </cfquery>
        </cfif>
    </cfloop>
    <cflocation url="planning-tools.cfm##checklist" addToken="false">
</cfif>

<!--- Prebuilt timeline data --->
<cfset prebuiltTimeline = [
    {label:"12+ Months Before", items:["Set wedding budget","Create preliminary guest list","Choose wedding date","Decide on wedding style/theme","Hire wedding planner (if applicable)","Select ceremony venue","Select reception venue","Create wedding website","Take engagement photos","Announce engagement"]},
    {label:"9-12 Months Before", items:["Send Save the Dates (destination wedding)","Send Save the Dates (holiday weekend wedding)","Book photographer","Book videographer","Book caterer","Book DJ or band","Book officiant","Reserve hotel room blocks","Select wedding party","Shop for wedding dress","Begin researching honeymoon options","Book transportation","Send Save the Dates (out-of-state guests)"]},
    {label:"6-9 Months Before", items:["Order wedding dress","Select bridesmaid dresses","Select groom and groomsmen attire","Register for gifts","Book florist","Book cake baker","Book hair and makeup artists","Plan rehearsal dinner","Send Save the Dates (local wedding)"]},
    {label:"4-6 Months Before", items:["Finalize guest list","Order invitations","Schedule dress fittings","Plan ceremony details","Choose wedding rings","Purchase wedding accessories","Book rental items","Select wedding favors","Plan honeymoon itinerary"]},
    {label:"2-4 Months Before", items:["Mail invitations","Schedule premarital counseling","Create seating chart draft","Meet with vendors","Finalize menu","Finalize floral selections","Obtain marriage license requirements","Purchase gifts for wedding party"]},
    {label:"1 Month Before", items:["Confirm RSVPs","Finalize seating chart","Confirm vendor timelines","Final dress fitting","Write vows","Prepare wedding day emergency kit","Confirm transportation schedule","Create wedding day timeline","Pay final vendor balances"]},
    {label:"1 Week Before", items:["Pick up attire","Confirm vendor arrivals","Pack for honeymoon","Prepare tip envelopes","Give vendor contact list to coordinator","Practice vows","Get manicure/pedicure"]},
    {label:"Wedding Day", items:["Eat breakfast","Hair and makeup","Exchange gifts/letters","Ceremony","Photos","Reception","Final vendor payments/tips","Depart for honeymoon"]},
    {label:"Destination Wedding", items:["Book hotel","Book flights","Book cruise"]}
]>

<cfset selectedTimeline = structKeyExists(url,'timeline') ? url.timeline : "">

<!--- Fetch data --->
<cfquery name="userRow" datasource="#application.config.datasource#">
    SELECT total_budget FROM dbo.Users WHERE user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
</cfquery>
<cfset totalBudget = val(userRow.total_budget)>

<cfquery name="budgetItems" datasource="#application.config.datasource#">
    SELECT budget_item_id, category, item_name, estimated_cost, actual_cost,
           ISNULL(deposit_paid, 0) AS deposit_paid, paid, vendor_name, notes
    FROM dbo.BudgetItems WHERE user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
    ORDER BY category, item_name
</cfquery>

<cfquery name="checklistItems" datasource="#application.config.datasource#">
    SELECT checklist_item_id, title, description, due_date, completed, priority, category
    FROM dbo.ChecklistItems WHERE user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
    ORDER BY completed, priority DESC, due_date
</cfquery>

<!--- Compute totals --->
<cfset totalEstimated = 0>
<cfset totalDeposits = 0>
<cfset totalFullyPaid = 0>
<cfset totalRemaining = 0>
<cfloop query="budgetItems">
    <cfset totalEstimated += estimated_cost>
    <cfset totalDeposits += deposit_paid>
    <cfif paid><cfset totalFullyPaid += estimated_cost></cfif>
    <cfset totalRemaining += (estimated_cost - deposit_paid)>
</cfloop>
<cfset remaining = totalBudget - totalEstimated>
<cfset budgetPct = totalBudget GT 0 ? min(100, int((totalEstimated / totalBudget) * 100)) : 0>
<cfset checklistDone = 0>
<cfloop query="checklistItems"><cfif completed><cfset checklistDone++></cfif></cfloop>
<cfset checklistPct = checklistItems.recordCount GT 0 ? int((checklistDone / checklistItems.recordCount) * 100) : 0>

<!--- Wedding site + countdown --->
<cfquery name="qSiteCD" datasource="#application.config.datasource#">
    SELECT couple_name_1, couple_name_2, wedding_date, venue_name, venue_address, template
    FROM dbo.WeddingSites
    WHERE user_id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_bigint">
    ORDER BY created_at DESC
</cfquery>

<cfset cdHasDate    = false>
<cfset cdDays       = 0>
<cfset cdName1      = "">
<cfset cdName2      = "">
<cfset cdDate       = "">
<cfset cdLocation   = "">
<cfset cdBg         = "##2C2C2C">
<cfset cdText       = "##FFFFFF">
<cfset cdAccent     = "##B8860B">
<cfset cdHeadingFont= "Georgia,serif">

<cfif qSiteCD.recordCount>
    <cfset cdName1 = HTMLEditFormat(trim(qSiteCD.couple_name_1))>
    <cfset cdName2 = HTMLEditFormat(trim(qSiteCD.couple_name_2))>

    <cfif len(trim(qSiteCD.wedding_date))>
        <cfset cdHasDate  = true>
        <cfset cdDate     = dateFormat(qSiteCD.wedding_date, "mmmm d, yyyy")>
        <cfset cdToday    = createDate(year(now()), month(now()), day(now()))>
        <cfset cdDays     = dateDiff("d", cdToday, qSiteCD.wedding_date)>
    </cfif>

    <cfif len(trim(qSiteCD.venue_name))>
        <cfset cdLocation = HTMLEditFormat(trim(qSiteCD.venue_name))>
        <cfif len(trim(qSiteCD.venue_address))>
            <cfset cdLocation &= " &mdash; " & HTMLEditFormat(trim(qSiteCD.venue_address))>
        </cfif>
    </cfif>

    <!--- Map template to theme colors --->
    <cfset tpl = lCase(trim(qSiteCD.template))>
    <cfif tpl EQ "classic_gold">
        <cfset cdBg="##2C2C2C"><cfset cdText="##FDFAF5"><cfset cdAccent="##B8860B"><cfset cdHeadingFont="Georgia,'Times New Roman',serif">
    <cfelseif tpl EQ "garden_romance">
        <cfset cdBg="##3D5A3E"><cfset cdText="##FFFFFF"><cfset cdAccent="##A8D4AC"><cfset cdHeadingFont="'Didot','Bodoni MT',Georgia,serif">
    <cfelseif tpl EQ "modern_minimal">
        <cfset cdBg="##111111"><cfset cdText="##FFFFFF"><cfset cdAccent="##C4A265"><cfset cdHeadingFont="'Helvetica Neue',Arial,sans-serif">
    <cfelseif tpl EQ "royal_elegance">
        <cfset cdBg="##1A0A2E"><cfset cdText="##F5E6C8"><cfset cdAccent="##C9A84C"><cfset cdHeadingFont="Georgia,serif">
    <cfelseif tpl EQ "sunset_bliss">
        <cfset cdBg="##E8643C"><cfset cdText="##FFFFFF"><cfset cdAccent="##FFD4B8"><cfset cdHeadingFont="Georgia,serif">
    <cfelseif tpl EQ "cultural_heritage">
        <cfset cdBg="##8B1A1A"><cfset cdText="##FFF5E0"><cfset cdAccent="##C4922A"><cfset cdHeadingFont="Georgia,serif">
    <cfelseif tpl EQ "christian_sacred">
        <cfset cdBg="##4A3728"><cfset cdText="##F9F7F4"><cfset cdAccent="##C8A86A"><cfset cdHeadingFont="Georgia,serif">
    <cfelseif tpl EQ "editorial_noir">
        <cfset cdBg="##000000"><cfset cdText="##FFFFFF"><cfset cdAccent="##C8A96E"><cfset cdHeadingFont="'Helvetica Neue',Arial,sans-serif">
    <cfelseif tpl EQ "pride_modern">
        <cfset cdBg="##6B3FA0"><cfset cdText="##FFFFFF"><cfset cdAccent="##E8A0FF"><cfset cdHeadingFont="'Helvetica Neue',Arial,sans-serif">
    <cfelseif tpl EQ "islamic_elegance">
        <cfset cdBg="##1B4332"><cfset cdText="##F5F0E8"><cfset cdAccent="##C9A84C"><cfset cdHeadingFont="Georgia,serif">
    <cfelseif tpl EQ "midnight_rose" OR tpl EQ "midnight_garden" OR tpl EQ "midnight_peony">
        <cfset cdBg="##0D0810"><cfset cdText="##F5E6F0"><cfset cdAccent="##C4687A"><cfset cdHeadingFont="Georgia,serif">
    <cfelseif tpl EQ "romantic_rose" OR tpl EQ "rose_garden" OR tpl EQ "crimson_garden">
        <cfset cdBg="##6B2D35"><cfset cdText="##FDF8F6"><cfset cdAccent="##E8A8A0"><cfset cdHeadingFont="Georgia,serif">
    <cfelseif tpl EQ "indigo_bloom">
        <cfset cdBg="##2A2060"><cfset cdText="##FFFFFF"><cfset cdAccent="##A8A0F0"><cfset cdHeadingFont="Georgia,serif">
    <cfelseif tpl EQ "velvet_peony">
        <cfset cdBg="##111B2E"><cfset cdText="##F8F0EC"><cfset cdAccent="##C4A35A"><cfset cdHeadingFont="Georgia,serif">
    <cfelseif tpl EQ "violet_garden">
        <cfset cdBg="##3D2060"><cfset cdText="##FFFFFF"><cfset cdAccent="##C8B0E8"><cfset cdHeadingFont="Georgia,serif">
    <cfelseif tpl EQ "sage_wreath">
        <cfset cdBg="##4A6650"><cfset cdText="##FFFFFF"><cfset cdAccent="##B0D4A8"><cfset cdHeadingFont="Georgia,serif">
    <cfelseif tpl EQ "golden_affair">
        <cfset cdBg="##1E1A14"><cfset cdText="##FEFDFB"><cfset cdAccent="##C9A242"><cfset cdHeadingFont="Georgia,serif">
    <cfelseif tpl EQ "delta_inspired">
        <cfset cdBg="##CC0000"><cfset cdText="##FFFFFF"><cfset cdAccent="##FFCCCC"><cfset cdHeadingFont="Georgia,serif">
    <cfelseif tpl EQ "aka_inspired">
        <cfset cdBg="##1A6B3C"><cfset cdText="##FFFFFF"><cfset cdAccent="##F8A0CC"><cfset cdHeadingFont="Georgia,serif">
    <cfelseif tpl EQ "sapphire_rose">
        <cfset cdBg="##020408"><cfset cdText="##E8EEF4"><cfset cdAccent="##6090D0"><cfset cdHeadingFont="Georgia,serif">
    <cfelseif tpl EQ "blush_pearl">
        <cfset cdBg="##2C1A14"><cfset cdText="##FDFAF7"><cfset cdAccent="##C8A870"><cfset cdHeadingFont="Georgia,serif">
    <cfelse>
        <cfset cdBg="##2C2C2C"><cfset cdText="##FFFFFF"><cfset cdAccent="##B8860B"><cfset cdHeadingFont="Georgia,serif">
    </cfif>
</cfif>

<cfset budgetCategories = ["Venue","Catering","Photography","Videography","Flowers","Music / DJ","Attire","Cake","Invitations","Decor","Transportation","Favors","Beauty","Officiant","Other"]>
<cfset checklistCategories = ["Venue","Catering","Attire","Flowers","Music","Photography","Invitations","Decor","Transportation","Honeymoon","Legal","Other"]>

<cfset showBudgetForm = structKeyExists(url,'addBudget') && url.addBudget EQ 1>
<cfset showChecklistForm = structKeyExists(url,'addTask') && url.addTask EQ 1>
<cfset editBudget = structKeyExists(url,'editBudget') && url.editBudget EQ 1>

<cfinclude template="../includes/layout-start.cfm">
<section style="padding:60px 0">
<div class="container">
    <div class="page-header">
        <p class="eyebrow">Your Dashboard</p>
        <h1>Planning <span class="script">Tools</span></h1>
    </div>

    <!--- Wedding Countdown --->
    <cfinclude template="../includes/wedding-countdown.cfm">

    <!--- 5 Summary Cards --->
    <div class="stats-row" style="margin-bottom:40px;grid-template-columns:repeat(auto-fit,minmax(180px,1fr))">

        <!--- Total Budget Card --->
        <div class="stat-card" style="position:relative">
            <div style="display:flex;align-items:center;justify-content:space-between;margin-bottom:10px">
                <div style="display:flex;align-items:center;gap:8px">
                    <i data-lucide="wallet" style="width:18px;height:18px;color:var(--gold)"></i>
                    <span style="font-size:10px;letter-spacing:0.15em;text-transform:uppercase;color:var(--text-muted)">Wedding Budget</span>
                </div>
                <a href="planning-tools.cfm?editBudget=1" style="color:var(--text-muted);line-height:1" title="Edit budget"><i data-lucide="pencil" style="width:13px;height:13px"></i></a>
            </div>
            <cfif editBudget>
                <form method="post" action="/members/planning-tools.cfm" style="display:flex;align-items:center;gap:6px">
                    <input type="hidden" name="action" value="set_total_budget">
                    <span style="color:var(--text-muted);font-size:20px">$</span>
                    <input type="number" name="totalBudget" value="<cfoutput>#totalBudget#</cfoutput>" min="0" step="100" autofocus
                        style="width:100%;font-size:22px;font-weight:700;border:none;border-bottom:2px solid var(--gold);background:transparent;outline:none;color:var(--text)">
                    <button type="submit" class="btn btn-primary btn-sm">Save</button>
                </form>
            <cfelse>
                <cfif totalBudget GT 0>
                    <div class="stat-num"><cfoutput>$#numberFormat(totalBudget,'999,999')#</cfoutput></div>
                <cfelse>
                    <a href="planning-tools.cfm?editBudget=1" style="font-size:16px;color:var(--text-muted);text-decoration:none">Set budget &rarr;</a>
                </cfif>
                <p style="font-size:11px;color:var(--text-muted);margin-top:4px">Click pencil to edit</p>
            </cfif>
        </div>

        <!--- Total Budgeted Expenses Card --->
        <div class="stat-card">
            <div style="display:flex;align-items:center;gap:8px;margin-bottom:10px">
                <i data-lucide="list" style="width:18px;height:18px;color:var(--gold)"></i>
                <span style="font-size:10px;letter-spacing:0.15em;text-transform:uppercase;color:var(--text-muted)">Budgeted</span>
            </div>
            <div class="stat-num"><cfoutput>$#numberFormat(totalEstimated,'999,999')#</cfoutput></div>
            <cfif totalBudget GT 0>
                <div style="margin-top:10px;background:var(--border);border-radius:4px;height:6px;overflow:hidden">
                    <div style="height:6px;border-radius:4px;background:<cfoutput><cfif budgetPct GTE 100>##dc2626<cfelse>var(--gold)</cfif></cfoutput>;width:<cfoutput>#budgetPct#</cfoutput>%"></div>
                </div>
                <p style="font-size:11px;color:var(--text-muted);margin-top:4px"><cfoutput>#budgetPct#</cfoutput>% of budget allocated</p>
            </cfif>
        </div>

        <!--- Total Deposits Paid Card --->
        <div class="stat-card">
            <div style="display:flex;align-items:center;gap:8px;margin-bottom:10px">
                <i data-lucide="credit-card" style="width:18px;height:18px;color:var(--gold)"></i>
                <span style="font-size:10px;letter-spacing:0.15em;text-transform:uppercase;color:var(--text-muted)">Deposits Paid</span>
            </div>
            <cfoutput><div class="stat-num" style="color:##059669">$#numberFormat(totalDeposits,'999,999')#</div></cfoutput>
            <p style="font-size:11px;color:var(--text-muted);margin-top:4px">Total paid to date</p>
        </div>

        <!--- Total Remaining Balances Card --->
        <div class="stat-card">
            <div style="display:flex;align-items:center;gap:8px;margin-bottom:10px">
                <i data-lucide="clock" style="width:18px;height:18px;color:var(--gold)"></i>
                <span style="font-size:10px;letter-spacing:0.15em;text-transform:uppercase;color:var(--text-muted)">Still Owed</span>
            </div>
            <div class="stat-num" style="<cfoutput><cfif totalRemaining GT 0>color:##d97706</cfif></cfoutput>"><cfoutput>$#numberFormat(totalRemaining,'999,999')#</cfoutput></div>
            <p style="font-size:11px;color:var(--text-muted);margin-top:4px">Remaining balances</p>
        </div>

        <!--- Remaining Budget Available Card --->
        <div class="stat-card" style="<cfoutput><cfif totalBudget GT 0 && totalEstimated GT totalBudget>border-color:##fca5a5</cfif></cfoutput>">
            <div style="display:flex;align-items:center;gap:8px;margin-bottom:10px">
                <i data-lucide="dollar-sign" style="width:18px;height:18px;color:<cfoutput><cfif totalBudget GT 0 && remaining LT 0>##dc2626<cfelse>##059669</cfif></cfoutput>"></i>
                <span style="font-size:10px;letter-spacing:0.15em;text-transform:uppercase;color:var(--text-muted)">Budget Left</span>
            </div>
            <cfif totalBudget GT 0>
                <div class="stat-num" style="color:<cfoutput><cfif remaining LT 0>##dc2626<cfelse>##059669</cfif></cfoutput>">
                    <cfoutput><cfif remaining LT 0>-</cfif>$#numberFormat(abs(remaining),'999,999')#</cfoutput>
                </div>
                <p style="font-size:11px;color:var(--text-muted);margin-top:4px">Unallocated budget</p>
            <cfelse>
                <div class="stat-num" style="color:var(--text-muted)">&mdash;</div>
                <p style="font-size:11px;color:var(--text-muted);margin-top:4px">Set a budget above</p>
            </cfif>
        </div>
    </div>

    <!--- Tasks progress bar (compact) --->
    <div style="display:flex;align-items:center;gap:12px;margin-bottom:32px;padding:14px 20px;background:var(--bg-card);border:1px solid var(--border);border-radius:var(--radius)">
        <i data-lucide="check-square" style="width:18px;height:18px;color:var(--gold);flex-shrink:0"></i>
        <span style="font-size:12px;font-weight:600;letter-spacing:0.1em;text-transform:uppercase;color:var(--text-muted);flex-shrink:0">Tasks</span>
        <div style="flex:1;background:var(--border);border-radius:4px;height:6px;overflow:hidden">
            <div style="height:6px;border-radius:4px;background:var(--gold);width:<cfoutput>#checklistPct#</cfoutput>%"></div>
        </div>
        <span style="font-size:12px;color:var(--text-muted);flex-shrink:0"><cfoutput>#checklistDone#/#checklistItems.recordCount# complete</cfoutput></span>
    </div>

    <!--- ===== BUDGET SECTION ===== --->
    <div class="panel" style="margin-bottom:32px">
        <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:20px;padding-bottom:14px;border-bottom:1px solid var(--border)">
            <h2 style="font-size:20px;font-family:var(--font-heading)">
                <i data-lucide="dollar-sign" style="width:20px;height:20px;color:var(--gold);vertical-align:middle;margin-right:6px"></i>Budget Items
            </h2>
            <a href="planning-tools.cfm?addBudget=1##budget" class="btn btn-primary btn-sm">
                <i data-lucide="plus" style="width:14px;height:14px;vertical-align:middle;margin-right:4px"></i>Add Item
            </a>
        </div>

        <cfif showBudgetForm>
        <div style="background:var(--bg-card);border:1px solid var(--border);border-radius:var(--radius);padding:24px;margin-bottom:24px" id="budget">
            <h3 style="font-size:16px;margin-bottom:16px">Add Budget Item</h3>
            <form method="post" action="/members/planning-tools.cfm">
                <input type="hidden" name="action" value="add_budget">
                <div style="display:grid;grid-template-columns:1fr 1fr;gap:16px;margin-bottom:16px">
                    <div class="field">
                        <label>Category *</label>
                        <select name="category" required>
                            <option value="">Select a category</option>
                            <cfoutput><cfloop array="#budgetCategories#" index="cat">
                                <option value="#HTMLEditFormat(cat)#">#HTMLEditFormat(cat)#</option>
                            </cfloop></cfoutput>
                        </select>
                    </div>
                    <div class="field">
                        <label>Item Name *</label>
                        <input type="text" name="itemName" placeholder="e.g. Reception Hall" required>
                    </div>
                    <div class="field">
                        <label>Budget Amount ($)</label>
                        <input type="number" name="estimatedCost" min="0" step="0.01" value="0" id="newBudgetAmt">
                    </div>
                    <div class="field">
                        <label>Deposit Paid ($) <span style="font-size:11px;color:var(--text-muted);font-weight:400">optional</span></label>
                        <input type="number" name="depositPaid" min="0" step="0.01" value="0" id="newDepositAmt">
                    </div>
                    <div class="field">
                        <label>Vendor Name</label>
                        <input type="text" name="vendorName" placeholder="Optional">
                    </div>
                    <div class="field">
                        <label>Notes</label>
                        <input type="text" name="notes" placeholder="Optional">
                    </div>
                </div>
                <script>
                document.getElementById('newDepositAmt').addEventListener('blur', function() {
                    var budget = parseFloat(document.getElementById('newBudgetAmt').value) || 0;
                    var deposit = parseFloat(this.value) || 0;
                    if (deposit > budget) this.value = budget;
                    if (deposit < 0) this.value = 0;
                });
                </script>
                <div style="display:flex;gap:10px">
                    <button type="submit" class="btn btn-primary">Add Item</button>
                    <a href="planning-tools.cfm" class="btn btn-ghost">Cancel</a>
                </div>
            </form>
        </div>
        </cfif>

        <!--- Column headers --->
        <cfif budgetItems.recordCount>
        <div>
            <div class="budget-col-headers" style="display:grid;grid-template-columns:1fr 110px 110px 110px 90px 80px;gap:8px;padding:6px 16px;margin-bottom:4px">
                <span style="font-size:10px;font-weight:700;letter-spacing:0.12em;text-transform:uppercase;color:var(--text-muted)">Item</span>
                <span style="font-size:10px;font-weight:700;letter-spacing:0.12em;text-transform:uppercase;color:var(--text-muted);text-align:right">Budget</span>
                <span style="font-size:10px;font-weight:700;letter-spacing:0.12em;text-transform:uppercase;color:var(--text-muted);text-align:right">Deposit Paid</span>
                <span style="font-size:10px;font-weight:700;letter-spacing:0.12em;text-transform:uppercase;color:var(--text-muted);text-align:right">Remaining</span>
                <span style="font-size:10px;font-weight:700;letter-spacing:0.12em;text-transform:uppercase;color:var(--text-muted);text-align:center">Status</span>
                <span></span>
            </div>

            <cfset lastCat = "">
            <cfset editDepositId = structKeyExists(url,'editDeposit') && isNumeric(url.editDeposit) ? val(url.editDeposit) : 0>
            <cfoutput query="budgetItems">
                <cfset itemRemaining = estimated_cost - deposit_paid>
                <cfif deposit_paid GTE estimated_cost && estimated_cost GT 0>
                    <cfset payStatus = "Paid">
                    <cfset statusStyle = "background:##d1fae5;color:##059669">
                <cfelseif deposit_paid GT 0>
                    <cfset payStatus = "Partially Paid">
                    <cfset statusStyle = "background:##fef3c7;color:##d97706">
                <cfelse>
                    <cfset payStatus = "Not Paid">
                    <cfset statusStyle = "background:##fee2e2;color:##dc2626">
                </cfif>

                <cfif category NEQ lastCat>
                    <cfif lastCat NEQ ""><div style="height:8px"></div></cfif>
                    <p style="font-size:10px;font-weight:700;letter-spacing:0.2em;text-transform:uppercase;color:var(--text-muted);margin-bottom:6px;padding:0 16px">#HTMLEditFormat(category)#</p>
                    <cfset lastCat = category>
                </cfif>

                <div style="border:1px solid var(--border);border-radius:var(--radius);margin-bottom:6px;background:var(--bg-card);overflow:hidden">
                    <!--- Desktop row --->
                    <div class="budget-desktop-row" style="display:grid;grid-template-columns:1fr 110px 110px 110px 90px 80px;gap:8px;padding:12px 16px;align-items:center">
                        <div style="min-width:0">
                            <p style="font-size:14px;font-weight:500;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;#payStatus EQ 'Paid' ? 'text-decoration:line-through;opacity:0.6;' : ''#">#HTMLEditFormat(item_name)#</p>
                            <p style="font-size:11px;color:var(--text-muted)">#HTMLEditFormat(category)#<cfif len(vendor_name)> &middot; #HTMLEditFormat(vendor_name)#</cfif></p>
                        </div>
                        <div style="text-align:right">
                            <p style="font-size:14px;font-weight:600;font-family:var(--font-display)">$#numberFormat(estimated_cost,'999,999.00')#</p>
                        </div>
                        <div style="text-align:right">
                            <a href="planning-tools.cfm?editDeposit=#budget_item_id###budget" style="font-size:14px;font-weight:600;font-family:var(--font-display);color:<cfif deposit_paid GT 0>##059669<cfelse>var(--text-muted)</cfif>;text-decoration:none" title="Click to edit deposit">
                                $#numberFormat(deposit_paid,'999,999.00')#
                            </a>
                        </div>
                        <div style="text-align:right">
                            <p style="font-size:14px;font-weight:600;font-family:var(--font-display);color:<cfif itemRemaining EQ 0>##059669<cfelse>var(--text)</cfif>">$#numberFormat(itemRemaining,'999,999.00')#</p>
                        </div>
                        <div style="text-align:center">
                            <span style="font-size:10px;padding:3px 8px;border-radius:20px;font-weight:600;white-space:nowrap;#statusStyle#">#payStatus#</span>
                        </div>
                        <div style="display:flex;align-items:center;gap:4px;justify-content:flex-end">
                            <a href="planning-tools.cfm?editDeposit=#budget_item_id###budget" title="Record payment" style="background:none;border:none;cursor:pointer;color:var(--text-muted);padding:4px;line-height:1;text-decoration:none">
                                <i data-lucide="pencil" style="width:14px;height:14px"></i>
                            </a>
                            <form method="post" action="/members/planning-tools.cfm" style="margin:0">
                                <input type="hidden" name="action" value="delete_budget">
                                <input type="hidden" name="budgetItemId" value="#budget_item_id#">
                                <button type="submit" onclick="return confirm('Delete this budget item?')" style="background:none;border:none;cursor:pointer;color:var(--text-muted);padding:4px" title="Delete">
                                    <i data-lucide="trash-2" style="width:14px;height:14px"></i>
                                </button>
                            </form>
                        </div>
                    </div>
                    <!--- Mobile card --->
                    <div class="budget-mobile-card" style="display:none;padding:14px 16px">
                        <div style="display:flex;justify-content:space-between;align-items:flex-start;margin-bottom:10px">
                            <div>
                                <p style="font-size:14px;font-weight:600;#payStatus EQ 'Paid' ? 'text-decoration:line-through;opacity:0.6;' : ''#">#HTMLEditFormat(item_name)#</p>
                                <p style="font-size:11px;color:var(--text-muted);margin-top:2px">#HTMLEditFormat(category)#<cfif len(vendor_name)> &middot; #HTMLEditFormat(vendor_name)#</cfif></p>
                            </div>
                            <div style="display:flex;align-items:center;gap:4px;flex-shrink:0;margin-left:8px">
                                <span style="font-size:10px;padding:3px 8px;border-radius:20px;font-weight:600;#statusStyle#">#payStatus#</span>
                                <a href="planning-tools.cfm?editDeposit=#budget_item_id###budget" title="Edit deposit" style="color:var(--text-muted);padding:4px;line-height:1;text-decoration:none">
                                    <i data-lucide="pencil" style="width:14px;height:14px"></i>
                                </a>
                                <form method="post" action="/members/planning-tools.cfm" style="margin:0">
                                    <input type="hidden" name="action" value="delete_budget">
                                    <input type="hidden" name="budgetItemId" value="#budget_item_id#">
                                    <button type="submit" onclick="return confirm('Delete this budget item?')" style="background:none;border:none;cursor:pointer;color:var(--text-muted);padding:4px" title="Delete">
                                        <i data-lucide="trash-2" style="width:14px;height:14px"></i>
                                    </button>
                                </form>
                            </div>
                        </div>
                        <div style="display:grid;grid-template-columns:1fr 1fr 1fr;gap:8px;border-top:1px solid var(--border);padding-top:10px">
                            <div>
                                <p style="font-size:10px;font-weight:700;letter-spacing:0.1em;text-transform:uppercase;color:var(--text-muted);margin-bottom:3px">Budget</p>
                                <p style="font-size:14px;font-weight:600;font-family:var(--font-display)">$#numberFormat(estimated_cost,'999,999.00')#</p>
                            </div>
                            <div>
                                <p style="font-size:10px;font-weight:700;letter-spacing:0.1em;text-transform:uppercase;color:var(--text-muted);margin-bottom:3px">Deposit</p>
                                <a href="planning-tools.cfm?editDeposit=#budget_item_id###budget" style="font-size:14px;font-weight:600;font-family:var(--font-display);color:<cfif deposit_paid GT 0>##059669<cfelse>var(--text-muted)</cfif>;text-decoration:none">
                                    $#numberFormat(deposit_paid,'999,999.00')#
                                </a>
                            </div>
                            <div>
                                <p style="font-size:10px;font-weight:700;letter-spacing:0.1em;text-transform:uppercase;color:var(--text-muted);margin-bottom:3px">Remaining</p>
                                <p style="font-size:14px;font-weight:600;font-family:var(--font-display);color:<cfif itemRemaining EQ 0>##059669<cfelse>var(--text)</cfif>">$#numberFormat(itemRemaining,'999,999.00')#</p>
                            </div>
                        </div>
                    </div>
                    <!--- Inline deposit edit form --->
                    <cfif editDepositId EQ budget_item_id>
                    <div style="border-top:1px solid var(--border);padding:14px 16px;background:var(--bg)">
                        <form method="post" action="/members/planning-tools.cfm" style="display:flex;align-items:flex-end;gap:12px;flex-wrap:wrap">
                            <input type="hidden" name="action" value="update_deposit">
                            <input type="hidden" name="budgetItemId" value="#budget_item_id#">
                            <div class="field" style="margin:0;flex:1;min-width:180px">
                                <label style="font-size:11px">Deposit Paid ($) <span style="color:var(--text-muted);font-weight:400">max $#numberFormat(estimated_cost,'999,999.00')#</span></label>
                                <input type="number" name="depositPaid" value="#deposit_paid#" min="0" max="#estimated_cost#" step="0.01" autofocus
                                    style="font-size:15px;font-weight:600" required>
                            </div>
                            <div style="display:flex;gap:8px;padding-bottom:2px">
                                <button type="submit" class="btn btn-primary btn-sm">Save</button>
                                <a href="planning-tools.cfm##budget" class="btn btn-ghost btn-sm">Cancel</a>
                            </div>
                        </form>
                    </div>
                    </cfif>
                </div>
            </cfoutput>
        </div>
        <cfelse>
            <div class="empty-state">
                <i data-lucide="dollar-sign" style="width:40px;height:40px;color:var(--border);margin-bottom:12px"></i>
                <p>No budget items yet. Start tracking your wedding expenses!</p>
            </div>
        </cfif>
    </div>

    <!--- ===== PREBUILT CHECKLIST PANEL ===== --->
    <div class="panel" style="margin-bottom:32px">
        <div style="display:flex;align-items:center;gap:10px;margin-bottom:16px">
            <i data-lucide="list-checks" style="width:20px;height:20px;color:var(--gold)"></i>
            <h2 style="font-size:20px;font-family:var(--font-heading)">Prebuilt Wedding Checklist</h2>
        </div>

        <div style="background:var(--gold-light);border:1px solid rgba(182,138,53,0.2);border-radius:var(--radius);padding:16px;margin-bottom:20px">
            <p style="font-size:13px;font-weight:600;margin-bottom:8px">How it works:</p>
            <ol style="font-size:13px;color:var(--text-muted);padding-left:18px;line-height:1.9">
                <li>Choose a <strong style="color:var(--text)">timeline period</strong> from the dropdown below (e.g. "12+ Months Before").</li>
                <li>A list of suggested tasks will appear &mdash; <strong style="color:var(--text)">check the ones you want</strong>, or click "Select All".</li>
                <li>Click <strong style="color:var(--text)">"Add Tasks to My Checklist"</strong> and they'll appear in your checklist below.</li>
                <li>Repeat for each timeline period as your wedding date approaches.</li>
                <li>Use the <strong style="color:var(--text)">checklist below</strong> to mark tasks complete as you go!</li>
            </ol>
        </div>

        <!--- Timeline selector --->
        <form method="get" action="planning-tools.cfm" style="margin-bottom:16px">
            <div class="field" style="max-width:400px;margin-bottom:0">
                <label for="timeline">Select a Timeline Period</label>
                <select id="timeline" name="timeline" onchange="this.form.submit()">
                    <option value="">Choose a timeline period...</option>
                    <cfoutput><cfloop array="#prebuiltTimeline#" index="period">
                        <option value="#HTMLEditFormat(period.label)#" <cfif selectedTimeline EQ period.label>selected</cfif>>#HTMLEditFormat(period.label)#</option>
                    </cfloop></cfoutput>
                </select>
            </div>
        </form>

        <!--- Task checkboxes for selected period --->
        <cfif len(selectedTimeline)>
            <cfset currentPeriod = {}>
            <cfloop array="#prebuiltTimeline#" index="period">
                <cfif period.label EQ selectedTimeline>
                    <cfset currentPeriod = period>
                </cfif>
            </cfloop>
            <cfif structCount(currentPeriod)>
                <form method="post" action="/members/planning-tools.cfm">
                    <input type="hidden" name="action" value="add_prebuilt">
                    <div style="display:flex;gap:16px;margin-bottom:12px">
                        <button type="button" onclick="document.querySelectorAll('.prebuilt-cb').forEach(cb=>cb.checked=true)" style="background:none;border:none;cursor:pointer;font-size:12px;color:var(--gold);font-weight:600">Select All</button>
                        <button type="button" onclick="document.querySelectorAll('.prebuilt-cb').forEach(cb=>cb.checked=false)" style="background:none;border:none;cursor:pointer;font-size:12px;color:var(--text-muted)">Clear</button>
                    </div>
                    <div style="max-height:280px;overflow-y:auto;border:1px solid var(--border);border-radius:var(--radius);padding:8px;margin-bottom:16px">
                        <cfoutput><cfloop array="#currentPeriod.items#" index="taskTitle">
                        <label style="display:flex;align-items:center;gap:10px;padding:8px 10px;border-radius:6px;cursor:pointer;font-size:13px">
                            <input type="checkbox" name="prebuiltItems" value="#HTMLEditFormat(taskTitle)#" class="prebuilt-cb" style="width:16px;height:16px;accent-color:var(--gold);flex-shrink:0">
                            #HTMLEditFormat(taskTitle)#
                        </label>
                        </cfloop></cfoutput>
                    </div>
                    <button type="submit" class="btn btn-primary" style="width:100%">
                        <i data-lucide="plus" style="width:14px;height:14px;vertical-align:middle;margin-right:6px"></i>Add Selected Tasks to My Checklist
                    </button>
                </form>
            </cfif>
        </cfif>
    </div>

    <!--- ===== CHECKLIST SECTION ===== --->
    <div class="panel" id="checklist">
        <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:20px;padding-bottom:14px;border-bottom:1px solid var(--border)">
            <h2 style="font-size:20px;font-family:var(--font-heading)">
                <i data-lucide="check-square" style="width:20px;height:20px;color:var(--gold);vertical-align:middle;margin-right:6px"></i>Wedding Checklist
            </h2>
            <a href="planning-tools.cfm?addTask=1##checklist" class="btn btn-primary btn-sm">
                <i data-lucide="plus" style="width:14px;height:14px;vertical-align:middle;margin-right:4px"></i>Add Task
            </a>
        </div>

        <cfif showChecklistForm>
        <div style="background:var(--bg-card);border:1px solid var(--border);border-radius:var(--radius);padding:24px;margin-bottom:24px">
            <h3 style="font-size:16px;margin-bottom:16px">Add Task</h3>
            <form method="post" action="/members/planning-tools.cfm">
                <input type="hidden" name="action" value="add_checklist">
                <div style="display:grid;grid-template-columns:2fr 1fr 1fr 1fr;gap:16px;margin-bottom:16px">
                    <div class="field">
                        <label>Task Title *</label>
                        <input type="text" name="title" placeholder="e.g. Book the venue" required>
                    </div>
                    <div class="field">
                        <label>Category</label>
                        <select name="category">
                            <cfoutput><cfloop array="#checklistCategories#" index="cat">
                                <option value="#HTMLEditFormat(cat)#">#HTMLEditFormat(cat)#</option>
                            </cfloop></cfoutput>
                        </select>
                    </div>
                    <div class="field">
                        <label>Due Date</label>
                        <input type="date" name="dueDate">
                    </div>
                    <div class="field">
                        <label>Priority</label>
                        <select name="priority">
                            <option value="high">High</option>
                            <option value="medium" selected>Medium</option>
                            <option value="low">Low</option>
                        </select>
                    </div>
                </div>
                <div class="field">
                    <label>Description</label>
                    <input type="text" name="description" placeholder="Optional details">
                </div>
                <div style="display:flex;gap:10px">
                    <button type="submit" class="btn btn-primary">Add Task</button>
                    <a href="planning-tools.cfm##checklist" class="btn btn-ghost">Cancel</a>
                </div>
            </form>
        </div>
        </cfif>

        <cfif checklistItems.recordCount>
            <cfset lastCat = "">
            <cfoutput query="checklistItems">
                <cfif category NEQ lastCat>
                    <cfif lastCat NEQ ""><div style="height:8px"></div></cfif>
                    <p style="font-size:10px;font-weight:700;letter-spacing:0.2em;text-transform:uppercase;color:var(--text-muted);margin-bottom:8px">#HTMLEditFormat(category)#</p>
                    <cfset lastCat = category>
                </cfif>
                <div style="display:flex;align-items:center;gap:12px;padding:12px 16px;border-radius:var(--radius);background:<cfif completed>var(--bg-card)<cfelse>##fff</cfif>;border:1px solid var(--border);margin-bottom:8px">
                    <form method="post" action="/members/planning-tools.cfm" style="flex-shrink:0">
                        <input type="hidden" name="action" value="toggle_checklist">
                        <input type="hidden" name="checklistItemId" value="#checklist_item_id#">
                        <button type="submit" style="width:20px;height:20px;border-radius:4px;border:2px solid <cfif completed>var(--gold)<cfelse>var(--border)</cfif>;background:<cfif completed>var(--gold)<cfelse>##fff</cfif>;cursor:pointer;display:flex;align-items:center;justify-content:center;padding:0">
                            <cfif completed><span style="color:##fff;font-size:12px">&##10003;</span></cfif>
                        </button>
                    </form>
                    <div style="flex:1;min-width:0">
                        <p style="font-size:14px;font-weight:500;<cfif completed>text-decoration:line-through;color:var(--text-muted);</cfif>">#HTMLEditFormat(title)#</p>
                        <div style="display:flex;align-items:center;gap:8px;margin-top:2px">
                            <cfset priorityColors = {high:'background:##fee2e2;color:##dc2626',medium:'background:##fef3c7;color:##d97706',low:'background:##d1fae5;color:##059669'}>
                            <span style="font-size:10px;padding:1px 8px;border-radius:20px;font-weight:600;#priorityColors[priority]#">#priority#</span>
                            <span style="font-size:11px;color:var(--text-muted)">#HTMLEditFormat(category)#</span>
                            <cfif len(due_date)><span style="font-size:11px;color:var(--text-muted)">&middot; Due #dateFormat(due_date,'mmm d, yyyy')#</span></cfif>
                        </div>
                    </div>
                    <form method="post" action="/members/planning-tools.cfm" style="flex-shrink:0">
                        <input type="hidden" name="action" value="delete_checklist">
                        <input type="hidden" name="checklistItemId" value="#checklist_item_id#">
                        <button type="submit" onclick="return confirm('Delete this task?')" style="background:none;border:none;cursor:pointer;color:var(--text-muted);padding:4px" title="Delete">
                            <i data-lucide="trash-2" style="width:15px;height:15px"></i>
                        </button>
                    </form>
                </div>
            </cfoutput>
        <cfelse>
            <div class="empty-state">
                <i data-lucide="check-square" style="width:40px;height:40px;color:var(--border);margin-bottom:12px"></i>
                <p>No tasks yet. Start building your wedding checklist!</p>
            </div>
        </cfif>
    </div>

</div>
</section>
<cfinclude template="../includes/layout-end.cfm">
