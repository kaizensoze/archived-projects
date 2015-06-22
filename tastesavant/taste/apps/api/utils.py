def redact_email_address(email_address):
    try:
        user, domain = email_address.split("@")
    except ValueError:
        return email_address
    user = user[:3] + "..."
    return "%s@%s" % (user, domain)
