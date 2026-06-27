<cfparam name="pageTitle" default="digitalweddings.love">
<cfparam name="activePage" default="">
<cfset isLoggedIn = structKeyExists(session, "user") && structKeyExists(session.user, "id")>
<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title><cfoutput>#HTMLEditFormat(pageTitle)#</cfoutput></title>
    <link rel="stylesheet" href="/assets/site.css?v=15">
</head>
<body<cfoutput><cfif isLoggedIn> class="nav-tall"</cfif></cfoutput>>

<nav class="site-nav">
    <div class="container nav-inner">
        <a class="nav-brand" href="/index.cfm" style="display:flex;align-items:center;gap:8px;margin-right:8px;flex-shrink:0"><i data-lucide="heart" style="width:22px;height:22px;color:var(--gold);fill:var(--gold)"></i><span style="color:var(--text)">digitalweddings<span style="color:var(--gold)">.love</span></span></a>
        <div class="nav-links">
            <cfif isLoggedIn>
                <a href="/members/planning-tools.cfm" class="<cfif activePage EQ 'planning-tools'>active</cfif>">Planning Tools</a>
                <a href="/members/guests.cfm" class="<cfif activePage EQ 'guests'>active</cfif>">Guests &amp; RSVP</a>
                <a href="/members/email-guests.cfm" class="<cfif activePage EQ 'email-guests'>active</cfif>">Email Guests</a>
                <a href="/members/seating-chart.cfm" class="<cfif activePage EQ 'seating'>active</cfif>">Seating Chart</a>
                <a href="/members/timeline.cfm" class="<cfif activePage EQ 'timeline'>active</cfif>">Wedding Day</a>
                <a href="/members/honeymoon.cfm" class="<cfif activePage EQ 'honeymoon'>active</cfif>">Honeymoon</a>
                <a href="/members/gift-registry.cfm" class="<cfif activePage EQ 'gift-registry'>active</cfif>">Gift Registry</a>
                <a href="/vendors.cfm" class="<cfif activePage EQ 'vendors'>active</cfif>">Find a Vendor</a>
                <a href="/members/wedding-sites.cfm" class="<cfif activePage EQ 'wedding-sites'>active</cfif>">My Wedding Site</a>
                <a href="/members/wedding-party.cfm" class="<cfif activePage EQ 'wedding-party'>active</cfif>">Wedding Party</a>
                <a href="/members/save-the-date.cfm" class="<cfif activePage EQ 'save-the-date'>active</cfif>">Save the Date</a>
                <a href="/members/thank-you-cards.cfm" class="<cfif activePage EQ 'thank-you'>active</cfif>">Thank You Cards</a>
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
                <a href="/admin/index.cfm" class="btn btn-ghost btn-sm" style="border-color:var(--gold);color:var(--gold)">Admin</a>
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
        <a href="/members/planning-tools.cfm">Planning Tools</a>
        <a href="/members/guests.cfm">Guests &amp; RSVP</a>
        <a href="/members/email-guests.cfm">Email Guests</a>
        <a href="/members/seating-chart.cfm">Seating Chart</a>
        <a href="/members/timeline.cfm">Wedding Day</a>
        <a href="/members/honeymoon.cfm">Honeymoon</a>
        <a href="/members/gift-registry.cfm">Gift Registry</a>
        <a href="/vendors.cfm">Find a Vendor</a>
        <a href="/members/wedding-sites.cfm">My Wedding Site</a>
        <a href="/members/wedding-party.cfm">Wedding Party</a>
        <a href="/members/save-the-date.cfm">Save the Date</a>
        <a href="/members/thank-you-cards.cfm">Thank You Cards</a>
        <div class="mobile-menu-actions">
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
