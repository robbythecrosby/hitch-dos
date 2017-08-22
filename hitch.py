import os
from flask import json
from flask import Flask, render_template, request
import stripe
import smtplib

app = Flask(__name__)

stripe_keys = {
  'secret_key': 'sk_test_ZnojzdXoXMNHVzioAQvHjZLy',
  'publishable_key': 'pk_test_NChUHegmsfKqqrvMQansdJX2'
}

stripe.api_key = 'sk_test_ZnojzdXoXMNHVzioAQvHjZLy'

@app.route('/charge', methods=['POST'])
def charge():
    json = request.get_json(force=True)
    token = json['token']
    amount = json['amount']
    email = json['email']
    pFrom = json['pFrom']
    pTo = json['pTo']
    paymentID = json['paymentID']
    charge = stripe.Charge.create(
        amount=amount,
        currency="usd",
        description=paymentID,
        source=token,
                                  metadata = { 'from' : pFrom, 'to' : pTo }
        )
    if charge:
        return "Success"
    else:
        return "Error"

@app.route('/email', methods=['POST'])
def email():
    json = request.get_json(force=True)
    code = json['code']
    email = json['email']
    name = json['name']
    sendemail(from_addr    = 'email.hitch@gmail.com',
          to_addr_list = [email],
          cc_addr_list = ['email.hitch@gmail.com'],
          subject      = 'Hitch Verification',
          message      = code,
          login        = 'email.hitch',
          password     = 'northbay1123581321')
    return "Success"


def sendemail(from_addr, to_addr_list, cc_addr_list,
              subject, message,
              login, password,
              smtpserver='smtp.gmail.com:587'):
    header  = 'From: %s\n' % from_addr
    header += 'To: %s\n' % ','.join(to_addr_list)
    header += 'Cc: %s\n' % ','.join(cc_addr_list)
    header += 'Subject: %s\n\n' % subject
    message = header + message
    server = smtplib.SMTP(smtpserver)
    server.ehlo()
    server.starttls()
    server.login(login,password)
    problems = server.sendmail(from_addr, to_addr_list, message)
    server.quit()
    return problems

if __name__ == "__main__":
    app.run(debug = True, host= '0.0.0.0')
