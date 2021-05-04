import requests
import mysecrets


def internet():
    try:
        requests.get("https://www.kernel.org").status_code
        return True
    except:
        return False


def push(msg):
    requests.post(
        url=mysecrets.gotify_url,
        headers={"X-Gotify-Key": mysecrets.gotify_token},
        data={"message": msg, "priority": 1},
    )
