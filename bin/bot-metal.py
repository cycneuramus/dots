import functions
import os
import requests
import secrets

home = os.getenv('HOME')
signal_cli = home + "/bin/signal-cli/bin/signal-cli"

# def get_signal_group:
    # signal_cli receive
    # signal_cli listGroups | awk '/Autistic/{print $2}'

# def signal_send:
    # signal_sender = secrets.phone_number
    # osv.

def get_auth_header():
    client_id = secrets.client_id
    client_secret = secrets.client_secret

    auth_url = "https://accounts.spotify.com/api/token"

    auth_response = requests.post(auth_url, {
        "grant_type": "client_credentials",
        "client_id": client_id,
        "client_secret": client_secret,
    })

    auth_response_data = auth_response.json()
    access_token = auth_response_data["access_token"]

    auth_header = {
        "Authorization": "Bearer {token}".format(token=access_token)
    }

    return auth_header

def get_latest_album(artist_id, auth_header):
    base_url = "https://api.spotify.com/v1/"

    # get latest album
    request = requests.get(base_url + "artists/" + artist_id + "/albums",
                     headers=auth_header,
                     params={"include_groups": "album", "limit": 1, "locale": "SE"})
    request_data = request.json()

    for album in request_data["items"]:
        album_title = album["name"]
        album_date = album["release_date"]
        album_link = album["external_urls"]["spotify"]

    return album_title

def iterate_artists():
    artists = {
        "Adagio": "5QJvZ6s15Hgpjq7UKktjaZ",
        "Allen – Lande": "2hxa4ytcni5FUIK8IR27tX",
        "Arch Echo": "4ilweWzFHh6vrr7OOuDcUh",
        "Ayreon": "2RSApl0SXcVT8Yiy4UaPSt",
        "Beast In Black": "0rEuaTPLMhlViNCJrg3NEH",
        "Blind Guardian": "7jxJ25p0pPjk0MStloN6o6",
        "Devin Townsend": "6uejjWIOshliv2Ho0OJAQN",
        "Devin Townsend Project": "54Xuca1P5nDqfKYZGDfHxl",
        "DGM": "5Rq2C3wWiwL3NqjutXMt8e",
        "Dirty Loops": "5Apl0wL4OwNUDYkx69rMDQ",
        "Dream Theater": "2aaLAng2L2aWD2FClzwiep",
        "Freedom Call": "55RDuy7cQW2Dqrcz3Jjl6F",
        "Frost*": "1Ha9FtCeuoajMbOG4Kz2d7",
        "Haken": "2SRIVGDkdqQnrQdaXxDkJt",
        "Leprous": "4lgrzShsg2FLA89UM2fdO5",
        "Liquid Tension Experiment": "0r1s1XoxdoXECGfyChzb2v",
        "Meshuggah": "3ggwAqZD3lyT2sbovlmfQY",
        "Metallica": "2ye2Wgw4gimLv2eAKyk1NB",
        "Michael Romeo": "1u13Ufesdz3aVSYpL1bFue",
        "Myrath": "72500XOYPw5e7OgFWuW2Gl",
        "Opeth": "0ybFZ2Ab08V8hueghSXm6E",
        "Pain Of Salvation": "1uRpg2s2jNaxbmoNiJDGfd",
        "Plini": "3Gs10XJ4S4OEFrMRqZJcic",
        "Running Wild": "7954VFaZClkL503srfV5PE",
        "Star One": "1W5pfX7IGyw9wCmfARg1pi",
        "Symphony X": "4MnZkh4dpNmTMPxkl4Ev5L",
        "The Rippingtons": "6hjqP9annof75B2TNBE0rO",
        "Thomas Bergersen": "6BF0bXbsdujMSMeFZBGcBq",
        "Twilight Force": "0tO6ALWmduAbneXoHmnl2T",
        "Ulver": "6bYFkBNvayh3nGqxcPp7Sv",
        "Vanden Plas": "1ke5Q2ijh6Tm31kH2HELEe",
        "Vince DiCola": "5Q2nBzXfyXGIEf8KpHqeHn",
        "Wilderun": "0wQmcChWogcmsCThY2SKES"
    }

    log_dir = home + "/log/bot-metal/"

    if not os.path.isdir(log_dir):
        os.makedirs(log_dir)

    auth_header = get_auth_header()

    for artist in artists:
        artist_id = artists[artist]
        latest_album = get_latest_album(artist_id, auth_header)

        log = log_dir + artist + ".log"

        if os.path.isfile(log):
            with open(log, "r") as f:
                latest_log = f.read()

            if latest_album != latest_log:
                msg = "Nytt släpp av " + artist + ": " + latest_album
                functions.push(msg)

        with open(log, "w") as f:
            f.write(latest_album)
        
def main():
    if not functions.internet():
        exit
    iterate_artists()

try:
    main()
except:
    script = os.path.basename(__file__)
    functions.push(script + " stötte på fel")
