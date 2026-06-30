<cfinclude template="admin-check.cfm">
<cfset pageTitle  = "Manage Users | Admin">
<cfset activePage = "admin">
<cfparam name="form.action"     default="">
<cfparam name="form.userId"     default="0">
<cfparam name="form.firstName"  default="">
<cfparam name="form.lastName"   default="">
<cfparam name="form.email"      default="">
<cfparam name="form.username"   default="">
<cfparam name="form.role"       default="">
<cfparam name="url.saved"       default="">
<cfparam name="url.error"       default="">

<!--- Update user details --->
<cfif form.action EQ "update_user" AND isNumeric(form.userId)>
    <cfif !len(trim(form.firstName)) OR !len(trim(form.email)) OR !isValid("email", trim(form.email))>
        <cflocation url="users.cfm?error=invalid" addToken="false">
    </cfif>
    <!--- Check email not taken by another user --->
    <cfquery name="qEmailCheck" datasource="#application.config.datasource#">
        SELECT user_id FROM dbo.Users
        WHERE email = <cfqueryparam value="#lCase(trim(form.email))#" cfsqltype="cf_sql_varchar">
          AND user_id <> <cfqueryparam value="#form.userId#" cfsqltype="cf_sql_bigint">
    </cfquery>
    <cfif qEmailCheck.recordCount>
        <cflocation url="users.cfm?error=emailtaken" addToken="false">
    </cfif>
    <cfquery datasource="#application.config.datasource#">
        UPDATE dbo.Users SET
            first_name = <cfqueryparam value="#trim(form.firstName)#"         cfsqltype="cf_sql_nvarchar">,
            last_name  = <cfqueryparam value="#trim(form.lastName)#"          cfsqltype="cf_sql_nvarchar">,
            email      = <cfqueryparam value="#lCase(trim(form.email))#"      cfsqltype="cf_sql_varchar">,
            username   = <cfqueryparam value="#lCase(trim(form.username))#"   cfsqltype="cf_sql_varchar">,
            role       = <cfqueryparam value="#trim(form.role)#"              cfsqltype="cf_sql_varchar"  null="#!len(trim(form.role))#">
        WHERE user_id = <cfqueryparam value="#form.userId#" cfsqltype="cf_sql_bigint">
    </cfquery>
    <cflocation url="users.cfm?saved=1" addToken="false">
</cfif>

<cfif form.action EQ "toggle_admin" AND isNumeric(form.userId) AND form.userId NEQ session.user.id>
    <cfquery datasource="#application.config.datasource#">
        UPDATE dbo.Users SET is_admin = CASE WHEN is_admin=1 THEN 0 ELSE 1 END
        WHERE user_id = <cfqueryparam value="#form.userId#" cfsqltype="cf_sql_bigint">
    </cfquery>
    <cflocation url="users.cfm?saved=1" addToken="false">
</cfif>

<cfif form.action EQ "toggle_active" AND isNumeric(form.userId) AND form.userId NEQ session.user.id>
    <cfquery datasource="#application.config.datasource#">
        UPDATE dbo.Users SET is_active = CASE WHEN is_active=1 THEN 0 ELSE 1 END
        WHERE user_id = <cfqueryparam value="#form.userId#" cfsqltype="cf_sql_bigint">
    </cfquery>
    <cflocation url="users.cfm?saved=1" addToken="false">
</cfif>

<cfquery name="qUsers" datasource="#application.config.datasource#">
    SELECT user_id, first_name, last_name, email, username, role, is_admin, is_active, created_at,
           (SELECT COUNT(*) FROM dbo.WeddingSites WHERE user_id = u.user_id) AS site_count,
           (SELECT COUNT(*) FROM dbo.Guests      WHERE user_id = u.user_id) AS guest_count
    FROM dbo.Users u
    ORDER BY created_at DESC
</cfquery>

<cfinclude template="../includes/layout-start.cfm">
<section style="padding:60px 0">
<div class="container">

    <div class="page-header" style="display:flex;justify-content:space-between;align-items:flex-start;flex-wrap:wrap;gap:16px">
        <div>
            <p class="eyebrow"><a href="/admin/index.cfm" style="color:var(--gold)">Admin</a></p>
            <h1>Manage <span class="script">Users</span></h1>
        </div>
        <cfoutput><span style="font-size:14px;color:var(--text-muted);margin-top:16px">#qUsers.recordCount# total users</span></cfoutput>
    </div>

    <cfif url.saved EQ "1">
    <div class="alert alert-success" style="margin-bottom:24px">User updated successfully.</div>
    </cfif>
    <cfif url.error EQ "emailtaken">
    <div class="alert alert-error" style="margin-bottom:24px">That email address is already in use by another account.</div>
    </cfif>
    <cfif url.error EQ "invalid">
    <div class="alert alert-error" style="margin-bottom:24px">Please provide a valid first name and email address.</div>
    </cfif>

    <div class="panel" style="padding:0">
    <div class="table-wrap">
    <table>
        <thead>
            <tr><th>Name</th><th>Email</th><th>Joined</th><th>Sites</th><th>Guests</th><th>Admin</th><th>Status</th><th>Role</th><th></th></tr>
        </thead>
        <tbody>
        <cfoutput query="qUsers">
        <tr>
            <td><strong>#HTMLEditFormat(trim(first_name & ' ' & last_name))#</strong><br><span style="font-size:11px;color:var(--text-muted)">@#HTMLEditFormat(username)#</span></td>
            <td>#HTMLEditFormat(email)#</td>
            <td style="font-size:12px;color:var(--text-muted)">#dateFormat(created_at,'mmm d, yyyy')#</td>
            <td style="text-align:center">#site_count#</td>
            <td style="text-align:center">#guest_count#</td>
            <td style="text-align:center">
                <cfif user_id EQ session.user.id>
                    <span class="badge badge-gold">You</span>
                <cfelse>
                    <form method="post" action="/admin/users.cfm" style="display:inline">
                        <input type="hidden" name="action"  value="toggle_admin">
                        <input type="hidden" name="userId" value="#user_id#">
                        <button type="submit" class="btn btn-sm #is_admin ? 'btn-primary' : 'btn-ghost'#"
                                onclick="return confirm('#is_admin ? 'Remove admin from' : 'Make admin'# #JSStringFormat(trim(first_name & ' ' & last_name))#?')">
                            #is_admin ? 'Admin' : 'User'#
                        </button>
                    </form>
                </cfif>
            </td>
            <td>
                <cfif user_id EQ session.user.id>
                    <span class="badge badge-green">Active</span>
                <cfelse>
                    <form method="post" action="/admin/users.cfm" style="display:inline">
                        <input type="hidden" name="action"  value="toggle_active">
                        <input type="hidden" name="userId" value="#user_id#">
                        <button type="submit" class="btn btn-sm #is_active ? 'btn-ghost' : 'btn-danger'#"
                                onclick="return confirm('#is_active ? 'Deactivate' : 'Reactivate'# #JSStringFormat(trim(first_name & ' ' & last_name))#?')">
                            #is_active ? 'Active' : 'Inactive'#
                        </button>
                    </form>
                </cfif>
            </td>
            <td style="font-size:12px;color:var(--text-muted)">#HTMLEditFormat(role)#</td>
            <td>
                <button type="button" class="btn btn-ghost btn-sm"
                    onclick="openUserModal(#user_id#,'#JSStringFormat(first_name)#','#JSStringFormat(last_name)#','#JSStringFormat(email)#','#JSStringFormat(username)#','#JSStringFormat(role)#')">
                    Edit
                </button>
            </td>
        </tr>
        </cfoutput>
        </tbody>
    </table>
    </div>
    </div>

</div>
</section>
<!--- Edit User Modal --->
<div id="editUserModal" style="display:none;position:fixed;inset:0;z-index:1000;background:rgba(0,0,0,.5);overflow-y:auto;padding:40px 16px">
<div style="background:#fff;border-radius:12px;max-width:500px;margin:0 auto;padding:32px">
    <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:24px">
        <h2 style="margin:0;font-size:20px">Edit User</h2>
        <button type="button" onclick="closeUserModal()" style="background:none;border:none;font-size:22px;cursor:pointer;color:var(--text-muted)">&times;</button>
    </div>
    <form method="post" action="/admin/users.cfm">
        <input type="hidden" name="action" value="update_user">
        <input type="hidden" name="userId" id="editUserId">
        <div style="display:grid;grid-template-columns:1fr 1fr;gap:12px">
            <div class="field">
                <label>First Name *</label>
                <input type="text" name="firstName" id="editFirstName" required>
            </div>
            <div class="field">
                <label>Last Name</label>
                <input type="text" name="lastName" id="editLastName">
            </div>
        </div>
        <div class="field">
            <label>Email *</label>
            <input type="email" name="email" id="editUserEmail" required>
        </div>
        <div class="field">
            <label>Username</label>
            <input type="text" name="username" id="editUsername">
        </div>
        <div class="field">
            <label>Role</label>
            <select name="role" id="editRole">
                <option value="">- none -</option>
                <option value="user">user</option>
                <option value="vendor">vendor</option>
                <option value="admin">admin</option>
            </select>
        </div>
        <div style="display:flex;gap:12px;margin-top:8px">
            <button type="submit" class="btn btn-primary" style="flex:1">Save Changes</button>
            <button type="button" onclick="closeUserModal()" class="btn btn-ghost" style="flex:1">Cancel</button>
        </div>
    </form>
</div>
</div>

<script>
function openUserModal(id, firstName, lastName, email, username, role) {
    document.getElementById('editUserId').value      = id;
    document.getElementById('editFirstName').value   = firstName;
    document.getElementById('editLastName').value    = lastName;
    document.getElementById('editUserEmail').value   = email;
    document.getElementById('editUsername').value    = username;
    var roleSel = document.getElementById('editRole');
    for (var i = 0; i < roleSel.options.length; i++) {
        roleSel.options[i].selected = (roleSel.options[i].value === role);
    }
    document.getElementById('editUserModal').style.display = 'block';
    document.body.style.overflow = 'hidden';
}
function closeUserModal() {
    document.getElementById('editUserModal').style.display = 'none';
    document.body.style.overflow = '';
}
document.getElementById('editUserModal').addEventListener('click', function(e) {
    if (e.target === this) closeUserModal();
});
</script>

<cfinclude template="../includes/layout-end.cfm">
