import requests
import secrets

def internet():
    try:
        requests.get("https://www.kernel.org").status_code
        return True
    except:
        return False
    
def push(msg):
    requests.post(
            url=secrets.gotify_url,
            headers={"X-Gotify-Key": secrets.gotify_token},
            data={
                "message": msg,
                "priority": 1}
            )
