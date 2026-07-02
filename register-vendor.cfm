<cfset pageTitle = "Become a Preferred Vendor | digitalweddings.love">
<cfset activePage = "register-vendor">

<cfinclude template="includes/layout-start.cfm">

<style>
.vp-hero        { background:var(--primary-dark,#4a6b4e); color:#fff; padding:80px 0 72px; text-align:center; }
.vp-hero-eyebrow{ font-size:11px; letter-spacing:5px; text-transform:uppercase; color:var(--primary-light,#e8f0e9); font-family:var(--font-body); margin:0 0 16px; opacity:.85; }
.vp-hero h1     { font-size:48px; font-weight:400; font-family:var(--font-heading); margin:0 0 16px; line-height:1.15; }
.vp-hero h1 em  { font-style:italic; color:var(--primary-light,#e8f0e9); }
.vp-hero-sub    { font-size:18px; color:rgba(255,255,255,.82); margin:0 auto 32px; max-width:560px; line-height:1.6; }
.vp-price-badge { display:inline-block; background:#fff; color:var(--primary-dark,#4a6b4e); font-size:22px; font-weight:700; padding:14px 36px; border-radius:40px; margin-bottom:32px; letter-spacing:.02em; }
.vp-checks      { display:flex; justify-content:center; gap:28px; flex-wrap:wrap; margin-bottom:40px; }
.vp-check       { font-size:14px; color:rgba(255,255,255,.8); }
.vp-check strong{ color:#fff; }
.vp-cta-btn     { display:inline-block; background:#fff; color:var(--primary-dark,#4a6b4e); font-size:15px; font-weight:700; letter-spacing:2px; text-transform:uppercase; padding:18px 52px; border-radius:6px; text-decoration:none; transition:background .2s; }
.vp-cta-btn:hover{ background:var(--primary-light,#e8f0e9); }
.vp-section     { padding:72px 0; }
.vp-section-alt { padding:72px 0; background:var(--bg-subtle,#f2f5f2); }
.vp-section h2  { font-size:36px; font-weight:400; font-family:var(--font-heading); color:var(--text,#1e2022); margin:0 0 12px; }
.vp-section p   { font-size:16px; color:var(--text-muted,#6b7280); line-height:1.75; margin:0 0 16px; }
.vp-benefits    { display:grid; grid-template-columns:repeat(3,1fr); gap:24px; margin-top:40px; }
@media(max-width:800px){ .vp-benefits{ grid-template-columns:1fr 1fr; } }
@media(max-width:520px){ .vp-benefits{ grid-template-columns:1fr; } }
.vp-benefit-card{ background:#fff; border:1px solid var(--border,#dde5dd); border-radius:12px; padding:28px 24px; }
.vp-benefit-card p{ margin:0; font-size:15px; color:var(--text-muted,#6b7280); line-height:1.6; }
.vp-cat-grid    { display:grid; grid-template-columns:repeat(3,1fr); gap:10px; margin-top:24px; }
@media(max-width:640px){ .vp-cat-grid{ grid-template-columns:1fr 1fr; } }
.vp-cat-item    { background:#fff; border:1px solid var(--border,#dde5dd); border-radius:8px; padding:12px 16px; font-size:14px; color:var(--text,#1e2022); }
.vp-faq         { margin-top:32px; }
.vp-faq-item    { border-bottom:1px solid var(--border,#dde5dd); padding:24px 0; }
.vp-faq-item:first-child{ border-top:1px solid var(--border,#dde5dd); }
.vp-faq-q       { font-size:17px; font-weight:700; color:var(--text,#1e2022); margin:0 0 10px; }
.vp-faq-a       { font-size:15px; color:var(--text-muted,#6b7280); line-height:1.7; margin:0; }
</style>

<!--- Hero --->
<div class="vp-hero">
    <div class="container">
        <p class="vp-hero-eyebrow">Preferred Vendor Network</p>
        <h1>Grow Your <em>Wedding</em> Business</h1>
        <p class="vp-hero-sub">Connect with couples who are actively planning their weddings on DigitalWeddings.love.</p>
        <div class="vp-price-badge">Only $25 / month</div>
        <div class="vp-checks">
            <span class="vp-check"><strong>&#10003;</strong> No Setup Fees</span>
            <span class="vp-check"><strong>&#10003;</strong> Cancel Anytime</span>
            <span class="vp-check"><strong>&#10003;</strong> Update Your Listing Anytime</span>
        </div>
        <a href="/register-vendor-form.cfm" class="vp-cta-btn">Become a Preferred Vendor</a>
    </div>
</div>

<!--- Why Join --->
<div class="vp-section" style="background:#fff">
    <div class="container" style="max-width:900px">
        <h2>Why Join?</h2>
        <p>Unlike traditional advertising, DigitalWeddings.love connects your business with couples who are already engaged and actively planning their wedding.</p>
        <p>As a Preferred Vendor you'll receive:</p>
        <div class="vp-benefits">
            <div class="vp-benefit-card"><p>Featured Preferred Vendor profile</p></div>
            <div class="vp-benefit-card"><p>Business logo and photos</p></div>
            <div class="vp-benefit-card"><p>Business description</p></div>
            <div class="vp-benefit-card"><p>Contact information</p></div>
            <div class="vp-benefit-card"><p>Website and social media links</p></div>
            <div class="vp-benefit-card"><p>Service areas</p></div>
            <div class="vp-benefit-card"><p>Vendor category listing</p></div>
            <div class="vp-benefit-card"><p>Unlimited profile updates</p></div>
            <div class="vp-benefit-card"><p>Visibility throughout the couple's planning journey</p></div>
        </div>
    </div>
</div>

<!--- Who We Welcome --->
<div class="vp-section-alt">
    <div class="container" style="max-width:900px">
        <h2>Wedding Professionals Welcome</h2>
        <p>We're building a network of exceptional wedding professionals, including:</p>
        <div class="vp-cat-grid">
            <div class="vp-cat-item">Wedding Planners</div>
            <div class="vp-cat-item">Day-of Coordinators</div>
            <div class="vp-cat-item">Venues</div>
            <div class="vp-cat-item">Photographers</div>
            <div class="vp-cat-item">Videographers</div>
            <div class="vp-cat-item">DJs &amp; Musicians</div>
            <div class="vp-cat-item">Caterers</div>
            <div class="vp-cat-item">Bakers &amp; Cake Designers</div>
            <div class="vp-cat-item">Florists</div>
            <div class="vp-cat-item">Decorators</div>
            <div class="vp-cat-item">Hair &amp; Makeup Artists</div>
            <div class="vp-cat-item">Officiants</div>
            <div class="vp-cat-item">Transportation Services</div>
            <div class="vp-cat-item">Rental Companies</div>
            <div class="vp-cat-item">Bridal Boutiques</div>
            <div class="vp-cat-item">Jewelers</div>
            <div class="vp-cat-item">Travel &amp; Honeymoon Specialists</div>
            <div class="vp-cat-item">Photo Booth Providers</div>
            <div class="vp-cat-item">Content Creators</div>
            <div class="vp-cat-item">Live Painters</div>
            <div class="vp-cat-item" style="font-style:italic;color:#888">And many more!</div>
        </div>
        <p style="margin-top:28px">If you help make weddings unforgettable, we'd love to have you.</p>
    </div>
</div>

<!--- Pricing --->
<div class="vp-section" style="background:#fff">
    <div class="container" style="max-width:620px;text-align:center">
        <h2>Simple Pricing</h2>
        <div style="background:var(--bg-card,#f7f9f7);border:2px solid var(--primary,#7A9E7E);border-radius:16px;padding:48px 40px;margin-top:32px">
            <p style="font-size:13px;letter-spacing:4px;text-transform:uppercase;color:var(--primary,#7A9E7E);font-weight:700;margin:0 0 12px">Preferred Vendor Membership</p>
            <p style="font-size:52px;font-weight:700;font-family:var(--font-heading);color:var(--text,#1e2022);margin:0 0 4px;line-height:1">$25</p>
            <p style="font-size:16px;color:#888;margin:0 0 28px">per month</p>
            <p style="font-size:15px;color:#555;line-height:1.75;margin:0 0 32px">Your membership includes everything needed to showcase your business on DigitalWeddings.love. No setup fees, no hidden costs, and no long-term contracts.</p>
            <a href="/register-vendor-form.cfm" class="btn btn-primary" style="font-size:15px;font-weight:700;letter-spacing:2px;text-transform:uppercase;padding:18px 52px;text-decoration:none">Get Started</a>
        </div>
    </div>
</div>

<!--- FAQ --->
<div class="vp-section-alt">
    <div class="container" style="max-width:720px">
        <h2>Frequently Asked Questions</h2>
        <div class="vp-faq">
            <div class="vp-faq-item">
                <p class="vp-faq-q">Is there a contract?</p>
                <p class="vp-faq-a">No. Your membership is month-to-month, and you may cancel at any time.</p>
            </div>
            <div class="vp-faq-item">
                <p class="vp-faq-q">Can I edit my profile?</p>
                <p class="vp-faq-a">Yes. Update your business information, photos, links, and contact details whenever you need.</p>
            </div>
            <div class="vp-faq-item">
                <p class="vp-faq-q">What types of vendors can join?</p>
                <p class="vp-faq-a">Any legitimate wedding-related business is welcome to apply.</p>
            </div>
            <div class="vp-faq-item">
                <p class="vp-faq-q">Are there any setup fees?</p>
                <p class="vp-faq-a">No. Your membership is simply <strong>$25 per month</strong>.</p>
            </div>
        </div>
    </div>
</div>

<cfinclude template="includes/layout-end.cfm">
