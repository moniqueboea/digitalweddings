/**
 * ErrorNotifier.cfc
 *
 * Central error-notification service for digitalweddings.love.
 * Every caught exception anywhere in the app should call notify().
 *
 * Fallback chain:
 *   1. Detailed HTML email to ADMIN_EMAIL
 *   2. Plain-text fallback email to ADMIN_EMAIL
 *   3. cflog to digitalweddings_errors (wrapped so it cannot propagate)
 *
 * Usage (CFML tag):
 *   <cfset notifier = new services.ErrorNotifier()>
 *   <cfset notifier.notify(cfcatch, "Context description")>
 *
 * Usage (cfscript):
 *   var notifier = new services.ErrorNotifier();
 *   notifier.notify(e, "Context description");
 */
component output="false" {

    variables.ADMIN_EMAIL  = "moniqueboea@gmail.com";
    variables.FROM_EMAIL   = "no-reply@digitalweddings.love";
    variables.APP_NAME     = "digitalweddings.love";

    // =========================================================
    // PUBLIC: notify()
    //
    // Sends a detailed error report to the admin.
    // Never throws - all failure paths are caught internally.
    // =========================================================
    public void function notify(
        required any exception,
        string context = "",
        string page    = ""
    ) {
        var errorTime  = now();
        var pageName   = len(trim(arguments.page)) ? arguments.page : CGI.SCRIPT_NAME;
        var shortMsg   = left(arguments.exception.message, 100);
        var subject    = "[" & variables.APP_NAME & " ERROR] " & pageName & " - " & shortMsg;

        // --- Tier 1: full HTML diagnostic email ---
        try {
            var body = buildErrorHTML(arguments.exception, arguments.context, errorTime, pageName);
            cfmail(
                to        = variables.ADMIN_EMAIL,
                from      = variables.FROM_EMAIL,
                replyto   = variables.ADMIN_EMAIL,
                subject   = subject,
                type      = "html",
                server    = "localhost",
                port      = 25,
                timeout   = 30
            ) { writeOutput(body); }
            return; // success - done
        } catch(any mailErr1) {}

        // --- Tier 2: plain-text fallback email ---
        try {
            var st = structKeyExists(arguments.exception, "stacktrace") ? arguments.exception.stacktrace : "N/A";
            cfmail(
                to      = variables.ADMIN_EMAIL,
                from    = variables.FROM_EMAIL,
                subject = "[FALLBACK] " & left(subject, 120),
                type    = "text",
                server  = "localhost",
                port    = 25,
                timeout = 20
            ) {
                writeOutput(
                    "TIME:       " & errorTime                          & chr(13) & chr(10) &
                    "PAGE:       " & pageName                           & chr(13) & chr(10) &
                    "CONTEXT:    " & arguments.context                  & chr(13) & chr(10) &
                    "TYPE:       " & arguments.exception.type           & chr(13) & chr(10) &
                    "MESSAGE:    " & arguments.exception.message        & chr(13) & chr(10) &
                    "DETAIL:     " & arguments.exception.detail         & chr(13) & chr(10) &
                    "STACKTRACE: " & left(st, 2000)                    & chr(13) & chr(10) &
                    "REMOTE_ADDR:" & CGI.REMOTE_ADDR                   & chr(13) & chr(10) &
                    "USER_AGENT: " & CGI.HTTP_USER_AGENT               & chr(13) & chr(10)
                );
            }
            return;
        } catch(any mailErr2) {}

        // --- Tier 3: cflog (last resort - wrapped so it cannot propagate) ---
        try {
            cflog(
                file = "digitalweddings_errors",
                type = "error",
                text = "PAGE=" & pageName
                     & " CTX="    & arguments.context
                     & " ERR="    & arguments.exception.message
                     & " DETAIL=" & left(arguments.exception.detail, 500)
            );
        } catch(any logErr) {
            // Truly nothing more we can do - swallow silently
        }
    }

    // =========================================================
    // PUBLIC: validateMailParams()
    //
    // Call before every cfmail. Throws MailValidation if any
    // required field is missing so the error is caught + reported
    // rather than silently sending a broken email.
    // =========================================================
    public void function validateMailParams(
        required string toEmail,
        required string fromEmail,
        required string subject,
        string context = ""
    ) {
        if (!len(trim(arguments.toEmail))) {
            throw(
                type    = "MailValidation",
                message = "Email 'To' address is empty or missing.",
                detail  = "Context: " & arguments.context & ". A recipient is required before cfmail can be called."
            );
        }
        if (!len(trim(arguments.fromEmail))) {
            throw(
                type    = "MailValidation",
                message = "Email 'From' address is empty or missing.",
                detail  = "Context: " & arguments.context & ". A sender is required before cfmail can be called."
            );
        }
        if (!len(trim(arguments.subject))) {
            throw(
                type    = "MailValidation",
                message = "Email 'Subject' is empty or missing.",
                detail  = "Context: " & arguments.context & ". A subject is required before cfmail can be called."
            );
        }
    }

    // =========================================================
    // PRIVATE: buildErrorHTML()
    // =========================================================
    private string function buildErrorHTML(
        required any    exception,
        required string context,
        required date   errorTime,
        required string pageName
    ) {
        // --- Safe URL ---
        var safeURL = "";
        try { safeURL = CGI.HTTP_HOST & CGI.SCRIPT_NAME & (len(CGI.QUERY_STRING) ? "?" & CGI.QUERY_STRING : ""); }
        catch(any e) { safeURL = "unavailable"; }

        // --- Safe session snapshot (no passwords) ---
        var sessionHTML = "";
        try {
            if (isDefined("session") && structKeyExists(session, "user") && isStruct(session.user)) {
                var safeFields = ["id","email","first_name","last_name","role","is_verified","is_vendor"];
                for (var f in safeFields) {
                    if (structKeyExists(session.user, f)) {
                        sessionHTML &= tr2("user." & f, HTMLEditFormat(session.user[f]));
                    }
                }
            }
        } catch(any e) {
            sessionHTML = tr2("session error", HTMLEditFormat(e.message));
        }
        if (!len(sessionHTML)) { sessionHTML = tr2("(no session user)", ""); }

        // --- FORM variables (mask sensitive fields) ---
        var formHTML = "";
        try {
            var sensitiveFields = "password,confirm_password,newpassword,currentpassword,pass,pwd,token,secret,pin";
            for (var k in form) {
                var displayVal = listFindNoCase(sensitiveFields, k) ? "<em style='color:##888'>*** MASKED ***</em>" : HTMLEditFormat(form[k]);
                formHTML &= tr2(HTMLEditFormat(k), displayVal);
            }
        } catch(any e) { formHTML = tr2("form error", HTMLEditFormat(e.message)); }

        // --- URL variables ---
        var urlHTML = "";
        try {
            for (var k in url) {
                urlHTML &= tr2(HTMLEditFormat(k), HTMLEditFormat(url[k]));
            }
        } catch(any e) { urlHTML = tr2("url error", HTMLEditFormat(e.message)); }

        // --- Tag context (line numbers) ---
        var tagContextRows = "";
        try {
            if (structKeyExists(arguments.exception, "tagContext") && isArray(arguments.exception.tagContext)) {
                for (var i = 1; i <= arrayLen(arguments.exception.tagContext); i++) {
                    var tc = arguments.exception.tagContext[i];
                    var tpl  = structKeyExists(tc, "template") ? HTMLEditFormat(tc.template) : "";
                    var ln   = structKeyExists(tc, "line")     ? tc.line                     : "";
                    var tcId = structKeyExists(tc, "id")       ? HTMLEditFormat(tc.id)        : "";
                    tagContextRows &= "<tr><td style='padding:4px 8px;border-bottom:1px solid ##eee;color:##999'>" & i & "</td>"
                        & "<td style='padding:4px 8px;border-bottom:1px solid ##eee;word-break:break-all'>" & tpl  & "</td>"
                        & "<td style='padding:4px 8px;border-bottom:1px solid ##eee'><strong>" & ln & "</strong></td>"
                        & "<td style='padding:4px 8px;border-bottom:1px solid ##eee;color:##666'>" & tcId & "</td></tr>";
                }
            }
        } catch(any e) { tagContextRows = ""; }

        // --- SQL fields ---
        var sqlHTML = "";
        try {
            if (structKeyExists(arguments.exception, "sql") && len(trim(arguments.exception.sql))) {
                sqlHTML &= tr2("SQL", "<pre style='margin:0;font-size:11px;white-space:pre-wrap'>" & HTMLEditFormat(arguments.exception.sql) & "</pre>");
            }
            if (structKeyExists(arguments.exception, "queryError") && len(trim(arguments.exception.queryError))) {
                sqlHTML &= tr2("SQL Error", "<span style='color:##8B0000'>" & HTMLEditFormat(arguments.exception.queryError) & "</span>");
            }
            if (structKeyExists(arguments.exception, "nativeErrorCode") && len(trim(arguments.exception.nativeErrorCode))) {
                sqlHTML &= tr2("Native Error Code", HTMLEditFormat(arguments.exception.nativeErrorCode));
            }
            if (structKeyExists(arguments.exception, "sqlState") && len(trim(arguments.exception.sqlState))) {
                sqlHTML &= tr2("SQL State", HTMLEditFormat(arguments.exception.sqlState));
            }
        } catch(any e) {}

        // --- Stacktrace ---
        var stackHTML = "";
        try {
            if (structKeyExists(arguments.exception, "stacktrace") && len(trim(arguments.exception.stacktrace))) {
                stackHTML = "<pre style='background:##f5f5f5;border-left:4px solid ##8B0000;padding:12px;"
                    & "border-radius:0 4px 4px 0;font-size:11px;overflow-x:auto;white-space:pre-wrap;margin:0'>"
                    & HTMLEditFormat(arguments.exception.stacktrace) & "</pre>";
            }
        } catch(any e) {}

        // ======= Assemble HTML =======
        var h = "<!DOCTYPE html><html><head><meta charset='UTF-8'></head>"
            & "<body style='font-family:Arial,sans-serif;font-size:14px;color:##333;background:##f0f0f0;margin:0;padding:20px'>"
            & "<div style='max-width:900px;margin:auto;background:white;border-radius:6px;"
            & "box-shadow:0 2px 8px rgba(0,0,0,.15);overflow:hidden'>";

        // Header bar
        h &= "<div style='background:##8B0000;color:white;padding:20px 28px'>"
            & "<h1 style='margin:0 0 4px;font-size:18px'>digitalweddings.love - Error Report</h1>"
            & "<p style='margin:0;opacity:.75;font-size:12px'>" & errorTime & " &nbsp;|&nbsp; " & HTMLEditFormat(pageName) & "</p>"
            & "</div><div style='padding:24px 28px'>";

        // Overview
        h &= section("Overview",
              tr2("Page",    HTMLEditFormat(pageName))
            & tr2("Full URL", HTMLEditFormat(safeURL))
            & tr2("Context", HTMLEditFormat(arguments.context))
            & tr2("Time",    errorTime)
        );

        // Exception
        h &= section("Exception Details",
              tr2("Type",    "<code>" & HTMLEditFormat(arguments.exception.type) & "</code>")
            & tr2("Message", "<strong style='color:##8B0000'>" & HTMLEditFormat(arguments.exception.message) & "</strong>")
            & tr2("Detail",  HTMLEditFormat(arguments.exception.detail))
            & sqlHTML
        );

        // Stack trace
        if (len(stackHTML)) {
            h &= "<h3 style='font-size:12px;text-transform:uppercase;letter-spacing:1px;color:##555;margin:22px 0 8px'>Stack Trace</h3>";
            h &= stackHTML;
        }

        // Tag context
        if (len(tagContextRows)) {
            h &= "<h3 style='font-size:12px;text-transform:uppercase;letter-spacing:1px;color:##555;margin:22px 0 8px'>Tag Context (Line Numbers)</h3>";
            h &= "<table width='100%' cellpadding='0' cellspacing='0' style='border:1px solid ##ddd;border-radius:4px;font-size:12px'>"
               & "<tr style='background:##f5f5f5'><th style='padding:6px 8px;text-align:left'>##</th>"
               & "<th style='padding:6px 8px;text-align:left'>Template</th>"
               & "<th style='padding:6px 8px;text-align:left'>Line</th>"
               & "<th style='padding:6px 8px;text-align:left'>Tag ID</th></tr>"
               & tagContextRows & "</table>";
        }

        // CGI
        h &= section("CGI Variables",
              tr2("REMOTE_ADDR",     CGI.REMOTE_ADDR)
            & tr2("REQUEST_METHOD",  CGI.REQUEST_METHOD)
            & tr2("HTTP_USER_AGENT", HTMLEditFormat(CGI.HTTP_USER_AGENT))
            & tr2("QUERY_STRING",    HTMLEditFormat(CGI.QUERY_STRING))
            & tr2("HTTP_REFERER",    HTMLEditFormat(CGI.HTTP_REFERER))
            & tr2("HTTP_HOST",       HTMLEditFormat(CGI.HTTP_HOST))
            & tr2("SERVER_NAME",     HTMLEditFormat(CGI.SERVER_NAME))
            & tr2("SCRIPT_NAME",     HTMLEditFormat(CGI.SCRIPT_NAME))
        );

        // FORM
        if (len(formHTML)) { h &= section("FORM Variables (passwords masked)", formHTML); }

        // URL
        if (len(urlHTML)) { h &= section("URL Variables", urlHTML); }

        // Session
        h &= section("Session (safe fields only - no passwords)", sessionHTML);

        h &= "</div></div></body></html>";
        return h;
    }

    // =========================================================
    // PRIVATE helpers
    // =========================================================
    private string function section(required string title, required string rows) {
        return "<h3 style='font-size:12px;text-transform:uppercase;letter-spacing:1px;color:##555;margin:22px 0 8px'>"
            & HTMLEditFormat(arguments.title) & "</h3>"
            & "<table width='100%' cellpadding='0' cellspacing='0' style='border:1px solid ##ddd;border-radius:4px;font-size:13px'>"
            & "<tbody>" & arguments.rows & "</tbody></table>";
    }

    private string function tr2(required string label, required string value) {
        return "<tr>"
            & "<td width='200' style='padding:6px 12px;border-bottom:1px solid ##eee;font-weight:bold;white-space:nowrap;vertical-align:top'>"
            & HTMLEditFormat(arguments.label) & "</td>"
            & "<td style='padding:6px 12px;border-bottom:1px solid ##eee;word-break:break-word'>"
            & arguments.value & "</td></tr>";
    }
}
