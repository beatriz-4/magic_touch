const { onRequest } = require("firebase-functions/v2/https");
const { get } = require("firebase-functions/params");
const nodemailer = require("nodemailer");

// Get Gmail credentials from Firebase environment parameters
const gmailEmail = get("gmail.email");
const gmailPassword = get("gmail.password");

// Create the transporter
const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: gmailEmail,
    pass: gmailPassword,
  },
});

// Cloud Function to send email
exports.sendNotificationEmail = onRequest(async (req, res) => {
  const { recipient, subject, message } = req.body;

  if (!recipient || !subject || !message) {
    return res.status(400).send("Missing parameters");
  }

  try {
    await transporter.sendMail({
      from: gmailEmail,
      to: recipient,
      subject: subject,
      text: message,
    });

    console.log(`Email sent to ${recipient}`);
    res.status(200).send("Email sent successfully!");
  } catch (err) {
    console.error(err);
    res.status(500).send("Error sending email: " + err.message);
  }
});
