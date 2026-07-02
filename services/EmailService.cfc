component output="false" {

    /**
     * Sends a verification email.
     * Validates To/From/Subject before attempting. Notifies admin on failure.
     */
    public void function sendVerificationEmail(
        required string toEmail,
        required string firstName,
        required string token
    ) {
        var notifier = new services.ErrorNotifier();
        var fromAddr = application.config.mailFromName & " <" & application.config.mailFrom & ">";
        var subject  = "Verify your digitalweddings.love account";
        var verificationUrl = application.config.frontendUrl & "/verify-email.cfm?token=" & urlEncodedFormat(arguments.token);
        var safeName = HTMLEditFormat(arguments.firstName);

        // Validate before building or sending
        notifier.validateMailParams(arguments.toEmail, application.config.mailFrom, subject, "sendVerificationEmail");

        var body = "
            <div style='font-family:Arial,sans-serif;line-height:1.6;color:##231f20;max-width:600px;margin:auto'>
                <h2 style='color:##b68a35'>Welcome to digitalweddings.love</h2>
                <p>Hello #safeName#,</p>
                <p>Please verify your email address to activate your free account.</p>
                <p>
                    <a href='#HTMLEditFormat(verificationUrl)#'
                       style='display:inline-block;padding:12px 24px;background:##b68a35;color:white;text-decoration:none;border-radius:4px;font-weight:bold'>
                        Verify My Email
                    </a>
                </p>
                <p>This link expires in #application.config.verificationTokenHours# hours.</p>
                <p>If you did not create this account, you can ignore this email.</p>
                <hr style='border:0;border-top:1px solid ##e7e1d7;margin:24px 0'>
                <p style='font-size:12px;color:##888'>digitalweddings.love &mdash; Celebrating Love</p>
            </div>
        ";

        try {
            cfmail(
                to      = arguments.toEmail,
                from    = fromAddr,
                subject = subject,
                type    = "html",
                server  = "localhost",
                port    = 25,
                timeout = 60
            ) { writeOutput(body); }
        } catch(any e) {
            notifier.notify(e, "sendVerificationEmail failed. TO=" & arguments.toEmail);
            rethrow;
        }
    }

    /**
     * Sends a password reset email.
     * Validates To/From/Subject before attempting. Notifies admin on failure.
     */
    public void function sendPasswordResetEmail(
        required string toEmail,
        required string firstName,
        required string token
    ) {
        var notifier = new services.ErrorNotifier();
        var fromAddr = application.config.mailFromName & " <" & application.config.mailFrom & ">";
        var subject  = "Reset your digitalweddings.love password";
        var resetUrl = application.config.frontendUrl & "/reset-password.cfm?token=" & urlEncodedFormat(arguments.token);
        var safeName = HTMLEditFormat(arguments.firstName);

        notifier.validateMailParams(arguments.toEmail, application.config.mailFrom, subject, "sendPasswordResetEmail");

        var body = "
            <div style='font-family:Arial,sans-serif;line-height:1.6;color:##231f20;max-width:600px;margin:auto'>
                <h2 style='color:##b68a35'>Reset Your Password</h2>
                <p>Hello #safeName#,</p>
                <p>We received a request to reset your digitalweddings.love password.</p>
                <p>
                    <a href='#HTMLEditFormat(resetUrl)#'
                       style='display:inline-block;padding:12px 24px;background:##b68a35;color:white;text-decoration:none;border-radius:4px;font-weight:bold'>
                        Reset My Password
                    </a>
                </p>
                <p>This link expires in #application.config.passwordResetTokenHours# hour(s).</p>
                <p>If you did not request this change, you can ignore this email.</p>
                <hr style='border:0;border-top:1px solid ##e7e1d7;margin:24px 0'>
                <p style='font-size:12px;color:##888'>digitalweddings.love &mdash; Celebrating Love</p>
            </div>
        ";

        try {
            cfmail(
                to      = arguments.toEmail,
                from    = fromAddr,
                subject = subject,
                type    = "html",
                server  = "localhost",
                port    = 25,
                timeout = 60
            ) { writeOutput(body); }
        } catch(any e) {
            notifier.notify(e, "sendPasswordResetEmail failed. TO=" & arguments.toEmail);
            rethrow;
        }
    }

    /**
     * Sends a guest invite email (used by guests.cfm / EmailService path).
     * Validates To/From/Subject before attempting. Notifies admin on failure.
     */
    public void function sendGuestEmail(
        required string toEmail,
        required string recipientName,
        required string subject,
        required string message
    ) {
        var notifier = new services.ErrorNotifier();
        var fromAddr = application.config.mailFromName & " <" & application.config.mailFrom & ">";

        notifier.validateMailParams(arguments.toEmail, application.config.mailFrom, arguments.subject, "sendGuestEmail");

        var safeMsg = HTMLEditFormat(arguments.message);
        safeMsg = replace(safeMsg, chr(10), "<br>", "all");

        var body = "
            <div style='font-family:Arial,sans-serif;line-height:1.65;color:##231f20;max-width:640px;margin:auto'>
                #safeMsg#
                <hr style='margin:28px 0 16px;border:0;border-top:1px solid ##e7e1d7'>
                <p style='font-size:12px;color:##888'>Sent through digitalweddings.love</p>
            </div>
        ";

        try {
            cfmail(
                to      = arguments.toEmail,
                from    = fromAddr,
                subject = arguments.subject,
                type    = "html",
                server  = "localhost",
                port    = 25,
                timeout = 60
            ) { writeOutput(body); }
        } catch(any e) {
            notifier.notify(e, "sendGuestEmail failed. TO=" & arguments.toEmail & " SUBJECT=" & arguments.subject);
            rethrow;
        }
    }
}
