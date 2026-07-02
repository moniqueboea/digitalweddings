</main>
<footer class="footer">
    <div class="container">
        <div class="footer-grid">
            <div>
                <div class="footer-brand">digitalweddings<span>.love</span></div>
                <p style="max-width:260px;line-height:1.7;font-size:14px">Celebrating love and the beauty of forever.</p>
            </div>
            <div>
                <h4>Plan</h4>
                <a href="/plan.cfm">Plan Your Wedding</a>
                <a href="/vendors.cfm">Find a Vendor</a>
                <a href="/register.cfm">Create an Account</a>
            </div>
            <div>
                <h4>Company</h4>
                <a href="/about.cfm">About Us</a>
                <a href="/contact.cfm">Contact</a>
                <a href="/register-vendor.cfm">Vendor Registration</a>
            </div>
            <div>
                <h4>Account</h4>
                <a href="/login.cfm">Sign In</a>
                <a href="/register.cfm">Get Started Free</a>
            </div>
        </div>
        <div class="footer-bottom">
            <cfoutput>&copy; #year(now())# digitalweddings.love. All rights reserved.</cfoutput>
        </div>
    </div>
</footer>
<script src="https://unpkg.com/lucide@latest/dist/umd/lucide.min.js"></script>
<script>lucide.createIcons();</script>
<script>
function toggleNavGroup(btn) {
    var group = btn.closest('.nav-group');
    var isOpen = group.classList.contains('open');
    document.querySelectorAll('.nav-group.open').forEach(function(g) { g.classList.remove('open'); });
    if (!isOpen) group.classList.add('open');
}
document.addEventListener('click', function(e) {
    if (!e.target.closest('.nav-group')) {
        document.querySelectorAll('.nav-group.open').forEach(function(g) { g.classList.remove('open'); });
    }
});
</script>
</body>
</html>
