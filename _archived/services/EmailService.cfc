component output="false" {

    private string function emailWrapper(required string content, required string preheader) {
        return "
<!DOCTYPE html>
<html lang='en'>
<head>
<meta charset='UTF-8'>
<meta name='viewport' content='width=device-width,initial-scale=1'>
<title>digitalweddings.love</title>
</head>
<body style='margin:0;padding:0;background-color:##F5EDD8;font-family:Georgia,serif'>
<div style='display:none;max-height:0;overflow:hidden;font-size:1px;color:##F5EDD8'>#arguments.preheader#</div>
<table width='100%' cellpadding='0' cellspacing='0' style='background-color:##F5EDD8;padding:40px 16px'>
  <tr><td align='center'>
    <table width='100%' cellpadding='0' cellspacing='0' style='max-width:580px'>

      <!--- Header --->
      <tr>
        <td style='background-color:##1a1a1a;padding:28px 40px;text-align:center;border-radius:8px 8px 0 0'>
          <p style='margin:0 0 4px;font-size:11px;letter-spacing:4px;text-transform:uppercase;color:##b68a35'>Celebrating Love</p>
          <p style='margin:0;font-size:22px;color:##ffffff;font-family:Georgia,serif'>digitalweddings<span style='color:##C9A96A'>.love</span></p>
        </td>
      </tr>

      <!--- Gold bar --->
      <tr><td style='background-color:##b68a35;height:3px;font-size:0;line-height:0'>&nbsp;</td></tr>

      <!--- Body --->
      <tr>
        <td style='background-color:##ffffff;padding:44px 48px;border-radius:0 0 8px 8px'>
          #arguments.content#
          <table width='100%' cellpadding='0' cellspacing='0' style='margin-top:36px'>
            <tr><td style='border-top:1px solid ##e7e1d7;padding-top:24px;text-align:center'>
              <p style='margin:0;font-size:11px;color:##999;font-family:Arial,sans-serif'>
                &copy; digitalweddings.love &mdash; Celebrating Love<br>
                If you did not request this email, please ignore it.
              </p>
            </td></tr>
          </table>
        </td>
      </tr>

    </table>
  </td></tr>
</table>
</body>
</html>
        ";
    }

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

        notifier.validateMailParams(arguments.toEmail, application.config.mailFrom, subject, "sendVerificationEmail");

        var content = "
          <h1 style='margin:0 0 8px;font-size:26px;color:##1a1a1a;font-family:Georgia,serif'>Welcome, #safeName#!</h1>
          <p style='margin:0 0 24px;font-size:13px;letter-spacing:3px;text-transform:uppercase;color:##b68a35;font-family:Arial,sans-serif'>One last step</p>
          <p style='margin:0 0 20px;font-size:16px;line-height:1.7;color:##444;font-family:Arial,sans-serif'>
            Thank you for joining digitalweddings.love. Please verify your email address to activate your account and start planning your dream wedding.
          </p>
          <table width='100%' cellpadding='0' cellspacing='0' style='margin:32px 0'>
            <tr><td align='center'>
              <a href='#HTMLEditFormat(verificationUrl)#'
                 style='display:inline-block;background-color:##b68a35;color:##ffffff;text-decoration:none;padding:16px 40px;border-radius:4px;font-family:Arial,sans-serif;font-size:14px;font-weight:bold;letter-spacing:1px;text-transform:uppercase'>
                Verify My Email
              </a>
            </td></tr>
          </table>
          <p style='margin:0 0 8px;font-size:13px;color:##888;font-family:Arial,sans-serif;text-align:center'>
            This link expires in #application.config.verificationTokenHours# hours.
          </p>
          <p style='margin:24px 0 0;font-size:13px;color:##aaa;font-family:Arial,sans-serif;text-align:center'>
            Or copy and paste this URL into your browser:<br>
            <span style='color:##b68a35;word-break:break-all'>#HTMLEditFormat(verificationUrl)#</span>
          </p>
        ";

        var body = emailWrapper(content, "Verify your email to activate your digitalweddings.love account.");

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

        var content = "
          <h1 style='margin:0 0 8px;font-size:26px;color:##1a1a1a;font-family:Georgia,serif'>Password Reset</h1>
          <p style='margin:0 0 24px;font-size:13px;letter-spacing:3px;text-transform:uppercase;color:##b68a35;font-family:Arial,sans-serif'>Requested for #safeName#</p>
          <p style='margin:0 0 20px;font-size:16px;line-height:1.7;color:##444;font-family:Arial,sans-serif'>
            We received a request to reset the password for your digitalweddings.love account. Click the button below to choose a new password.
          </p>
          <table width='100%' cellpadding='0' cellspacing='0' style='margin:32px 0'>
            <tr><td align='center'>
              <a href='#HTMLEditFormat(resetUrl)#'
                 style='display:inline-block;background-color:##b68a35;color:##ffffff;text-decoration:none;padding:16px 40px;border-radius:4px;font-family:Arial,sans-serif;font-size:14px;font-weight:bold;letter-spacing:1px;text-transform:uppercase'>
                Reset My Password
              </a>
            </td></tr>
          </table>
          <p style='margin:0 0 8px;font-size:13px;color:##888;font-family:Arial,sans-serif;text-align:center'>
            This link expires in #application.config.passwordResetTokenHours# hour(s). If you did not request a password reset, no action is needed.
          </p>
          <p style='margin:24px 0 0;font-size:13px;color:##aaa;font-family:Arial,sans-serif;text-align:center'>
            Or copy and paste this URL into your browser:<br>
            <span style='color:##b68a35;word-break:break-all'>#HTMLEditFormat(resetUrl)#</span>
          </p>
        ";

        var body = emailWrapper(content, "Reset your digitalweddings.love password — link expires soon.");

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
