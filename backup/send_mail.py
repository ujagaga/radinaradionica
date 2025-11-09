#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
import config
import sys

def send_email(body, subject=config.SUBJECT, recipient=config.SEND_TO):
    msg = MIMEMultipart()
    msg['From'] = config.SMTP_USER
    msg['To'] = recipient
    msg['Subject'] = subject
    msg.attach(MIMEText(body, 'plain'))

    try:
        print(f"Sending email to: {recipient}")
        with smtplib.SMTP(config.SMTP_SERVER, config.SMTP_PORT) as server:
            server.ehlo()
            if config.USE_TLS:
                server.starttls()
            server.login(config.SMTP_USER, config.SMTP_PASS)
            server.sendmail(config.SMTP_USER, recipient, msg.as_string())
        print("Email sent successfully!")
    except Exception as e:
        print(f"Error sending email: {e}")


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python email.py 'Email body here'")
        sys.exit(1)

    body_text = sys.argv[1]
    send_email(body_text)
