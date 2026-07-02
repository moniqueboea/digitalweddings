<cfparam name="pageTitle" default="digitalweddings.love">
<cfparam name="activePage" default="">
<cfset isLoggedIn = structKeyExists(session, "user") && structKeyExists(session.user, "id")>
<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title><cfoutput>#HTMLEditFormat(pageTitle)#</cfoutput></title>
    <link rel="icon" type="image/svg+xml" href="/favicon.svg">
    <link rel="shortcut icon" href="/favicon.svg">
    <link rel="stylesheet" href="/assets/site.css?v=19">
</head>
<body>

<nav class="site-nav">
    <div class="container nav-inner">
        <a class="nav-brand" href="/index.cfm" style="display:flex;align-items:center;gap:8px;margin-right:8px;flex-shrink:0"><i data-lucide="heart" style="width:22px;height:22px;color:var(--gold);fill:var(--gold)"></i><span style="color:var(--text)">digitalweddings<span style="color:var(--gold)">.love</span></span></a>
        <div class="nav-links">
            <cfif isLoggedIn>
                <cfset grpPlanning = listFind("planning-tools,timeline,seating,honeymoon,gift-registry", activePage)>
                <cfset grpGuests   = listFind("guests,email-guests,wedding-party,save-the-date,thank-you", activePage)>
                <cfset grpVendors  = listFind("vendors,coordinator,music-playlist,decorator", activePage)>
                <cfset grpSite     = listFind("wedding-sites", activePage)>

                <!--- Planning group --->
                <cfset grpPlanning = listFind("planning-tools,timeline,honeymoon,gift-registry", activePage)>
                <div class="nav-group<cfif grpPlanning> has-active</cfif>">
                    <span class="nav-group-trigger" onclick="toggleNavGroup(this)" tabindex="0">
                        Planning
                        <svg class="chevron" viewBox="0 0 10 10" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M2 3.5L5 6.5L8 3.5" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/></svg>
                    </span>
                    <div class="nav-dropdown">
                        <a href="/members/planning-tools.cfm" class="<cfif activePage EQ 'planning-tools'>active</cfif>">Planning Tools</a>
                        <a href="/members/timeline.cfm"       class="<cfif activePage EQ 'timeline'>active</cfif>">Wedding Day</a>
                        <a href="/members/honeymoon.cfm"      class="<cfif activePage EQ 'honeymoon'>active</cfif>">Honeymoon</a>
                        <a href="/members/gift-registry.cfm"  class="<cfif activePage EQ 'gift-registry'>active</cfif>">Gift Registry</a>
                    </div>
                </div>

                <!--- Guests group --->
                <cfset grpGuests = listFind("guests,email-guests,wedding-party,save-the-date,thank-you,seating", activePage)>
                <div class="nav-group<cfif grpGuests> has-active</cfif>">
                    <span class="nav-group-trigger" onclick="toggleNavGroup(this)" tabindex="0">
                        Guests
                        <svg class="chevron" viewBox="0 0 10 10" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M2 3.5L5 6.5L8 3.5" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/></svg>
                    </span>
                    <div class="nav-dropdown">
                        <a href="/members/guests.cfm"         class="<cfif activePage EQ 'guests'>active</cfif>">Guests &amp; RSVP</a>
                        <a href="/members/email-guests.cfm"   class="<cfif activePage EQ 'email-guests'>active</cfif>">Email Guests</a>
                        <a href="/members/seating-chart.cfm"  class="<cfif activePage EQ 'seating'>active</cfif>">Seating Chart</a>
                        <a href="/members/wedding-party.cfm"  class="<cfif activePage EQ 'wedding-party'>active</cfif>">Wedding Party</a>
                        <a href="/members/save-the-date.cfm"  class="<cfif activePage EQ 'save-the-date'>active</cfif>">Save the Date</a>
                        <a href="/members/thank-you-cards.cfm" class="<cfif activePage EQ 'thank-you'>active</cfif>">Thank You Cards</a>
                    </div>
                </div>

                <!--- Vendors group --->
                <div class="nav-group<cfif grpVendors> has-active</cfif>">
                    <span class="nav-group-trigger" onclick="toggleNavGroup(this)" tabindex="0">
                        Vendors
                        <svg class="chevron" viewBox="0 0 10 10" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M2 3.5L5 6.5L8 3.5" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/></svg>
                    </span>
                    <div class="nav-dropdown">
                        <a href="/members/vendors.cfm"        class="<cfif activePage EQ 'vendors'>active</cfif>">Find a Vendor</a>
                        <a href="/members/coordinator.cfm"    class="<cfif activePage EQ 'coordinator'>active</cfif>">Coordinator</a>
                        <a href="/members/music-playlist.cfm" class="<cfif activePage EQ 'music-playlist'>active</cfif>">Music Playlist</a>
                        <a href="/members/decorator.cfm"      class="<cfif activePage EQ 'decorator'>active</cfif>">Decorator</a>
                    </div>
                </div>

                <!--- My Site (standalone) --->
                <a href="/members/wedding-sites.cfm" class="<cfif activePage EQ 'wedding-sites'>active</cfif>">My Wedding Site</a>

            <cfelse>
                <a href="/plan.cfm" class="<cfif activePage EQ 'plan'>active</cfif>">Plan Your Wedding</a>
                <a href="/vendors.cfm" class="<cfif activePage EQ 'vendors'>active</cfif>">Find a Vendor</a>
                <a href="/register-vendor.cfm" class="<cfif activePage EQ 'register-vendor'>active</cfif>">Register as a Vendor</a>
                <a href="/about.cfm" class="<cfif activePage EQ 'about'>active</cfif>">About</a>
                <a href="/contact.cfm" class="<cfif activePage EQ 'contact'>active</cfif>">Contact</a>
            </cfif>
        </div>
        <div class="nav-actions">
            <cfif isLoggedIn>
                <cfif structKeyExists(session.user,"is_admin") AND session.user.is_admin>
                <a href="/members/admin/index.cfm" class="btn btn-ghost btn-sm" style="border-color:var(--gold);color:var(--gold)">Admin</a>
                </cfif>
                <a href="/logout.cfm" class="btn btn-ghost btn-sm">Sign Out</a>
            <cfelse>
                <a href="/login.cfm" class="btn btn-ghost btn-sm">Sign In</a>
                <a href="/register.cfm" class="btn btn-primary btn-sm">Get Started</a>
            </cfif>
        </div>
        <button class="nav-toggle" onclick="this.querySelector('.icon-menu').classList.toggle('hidden');this.querySelector('.icon-x').classList.toggle('hidden');document.getElementById('mobileMenu').classList.toggle('open')" aria-label="Menu">
            <i data-lucide="menu" class="icon-menu" style="width:24px;height:24px"></i>
            <i data-lucide="x" class="icon-x hidden" style="width:24px;height:24px"></i>
        </button>
    </div>
</nav>

<div class="mobile-menu" id="mobileMenu">
    <cfif isLoggedIn>
        <span class="mobile-group-label">Planning</span>
        <a href="/members/planning-tools.cfm" class="mobile-sub">Planning Tools</a>
        <a href="/members/timeline.cfm"       class="mobile-sub">Wedding Day</a>
        <a href="/members/honeymoon.cfm"      class="mobile-sub">Honeymoon</a>
        <a href="/members/gift-registry.cfm"  class="mobile-sub">Gift Registry</a>
        <div class="mobile-group-divider"></div>
        <span class="mobile-group-label">Guests</span>
        <a href="/members/guests.cfm"         class="mobile-sub">Guests &amp; RSVP</a>
        <a href="/members/email-guests.cfm"   class="mobile-sub">Email Guests</a>
        <a href="/members/seating-chart.cfm"  class="mobile-sub">Seating Chart</a>
        <a href="/members/wedding-party.cfm"  class="mobile-sub">Wedding Party</a>
        <a href="/members/save-the-date.cfm"  class="mobile-sub">Save the Date</a>
        <a href="/members/thank-you-cards.cfm" class="mobile-sub">Thank You Cards</a>
        <div class="mobile-group-divider"></div>
        <span class="mobile-group-label">Vendors</span>
        <a href="/members/vendors.cfm"        class="mobile-sub">Find a Vendor</a>
        <a href="/members/coordinator.cfm"    class="mobile-sub">Coordinator</a>
        <a href="/members/music-playlist.cfm" class="mobile-sub">Music Playlist</a>
        <a href="/members/decorator.cfm"      class="mobile-sub">Decorator</a>
        <div class="mobile-group-divider"></div>
        <a href="/members/wedding-sites.cfm">My Wedding Site</a>
        <div class="mobile-menu-actions">
            <cfif structKeyExists(session.user,"is_admin") AND session.user.is_admin>
            <a href="/members/admin/index.cfm" class="btn btn-ghost btn-full" style="border-color:var(--gold);color:var(--gold)">Admin</a>
            </cfif>
            <a href="/logout.cfm" class="btn btn-ghost btn-full">Sign Out</a>
        </div>
    <cfelse>
        <a href="/plan.cfm">Plan Your Wedding</a>
        <a href="/vendors.cfm">Find a Vendor</a>
        <a href="/register-vendor.cfm">Register as a Vendor</a>
        <a href="/about.cfm">About</a>
        <a href="/contact.cfm">Contact</a>
        <div class="mobile-menu-actions">
            <a href="/login.cfm" class="btn btn-ghost btn-full">Sign In</a>
            <a href="/register.cfm" class="btn btn-primary btn-full">Get Started</a>
        </div>
    </cfif>
</div>

<main>
