import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
import config

'''
Sends an email using configured credentials. 
'''
def send_email(subject, body, recipient=config.SEND_TO):
    msg = MIMEMultipart()
    msg['From'] = config.SMTP_USER
    msg['To'] = recipient
    msg['Subject'] = subject
    msg.attach(MIMEText(body, 'plain'))

    try:
        print(f"Sending email to: {recipient}")
        with smtplib.SMTP(config.SMTP_SERVER, config.SMTP_PORT) as server:
            server.ehlo()
            # Add if needed:
            # server.starttls()
            server.login(config.SMTP_USER, config.SMTP_PASS)
            server.sendmail(config.SMTP_USER, recipient, msg.as_string())

    except Exception as e:
        print(f"Error sending email: {e}")
