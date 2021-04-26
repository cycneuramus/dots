#!/usr/bin/env python3

import datetime
import functions
import os
import random
import requests
import secrets
import subprocess

home_dir = os.getenv("HOME")
bin_dir = os.path.join(home_dir, "bin")
log_dir = os.path.join(home_dir, "log")

signal_cli = os.path.join(bin_dir, "signal-cli/bin/signal-cli")
api_base_url = "https://api.spotify.com/v1/"


def get_signal_recipient():
    # safe mode (send to self)
    signal_recipient = secrets.phone_number
    recipient_type = "contact"
    return signal_recipient, recipient_type
    
    cmd = [signal_cli, "listGroups"]
    result = subprocess.run(cmd, capture_output=True, text=True)
    signal_groups = result.stdout

    for line in signal_groups.splitlines():
        cols = line.split()
        if secrets.signal_target_group in line:
            signal_group_id = cols[1]
            break

    if signal_group_id:
        signal_recipient = signal_group_id 
        recipient_type = "group"
    else:
        signal_recipient = secrets.phone_number
        recipient_type = "contact"
        
    return signal_recipient, recipient_type


def signal_send(msg):
    signal_sender = secrets.phone_number
    signal_recipient, recipient_type = get_signal_recipient()

    if recipient_type == "contact":
        cmd = [signal_cli, "-u", signal_sender, "send", "-m", msg, signal_recipient]
    elif recipient_type == "group":
        cmd = [signal_cli, "-u", signal_sender, "send", "-m", msg, "-g", signal_recipient]

    subprocess.run(cmd, stdout=subprocess.DEVNULL)


def get_random_emoji():
    emojis_file = os.path.join(bin_dir, "emojis")
    random_emoji = random.choice(open(emojis_file).readlines()).strip()
    return random_emoji


def get_spotify_token():
    client_id = secrets.spotify_client_id
    client_secret = secrets.spotify_client_secret

    auth_url = "https://accounts.spotify.com/api/token"

    auth_response = requests.post(auth_url, {
            "grant_type": "client_credentials",
            "client_id": client_id,
            "client_secret": client_secret,
    })

    auth_response_data = auth_response.json()
    token = auth_response_data["access_token"]

    return token


def get_latest_album(artist_id):
    url = api_base_url + "artists/" + artist_id + "/albums"

    access_token = get_spotify_token()
    auth_header = {
        "Authorization": "Bearer {token}".format(token=access_token)
    }

    request = requests.get(url,
             headers=auth_header,
             params={"include_groups": "album", "limit": 1, "market": "SE"})
    request_data = request.json()

    for album in request_data["items"]:
        album_title = album["name"]
        album_date = album["release_date"]
        album_link = album["external_urls"]["spotify"]
        album_id = album["id"]
    
    return album_title, album_date, album_link, album_id

def get_power_analysis(album_id):
    url = api_base_url + "albums/" + album_id + "/tracks"

    access_token = get_spotify_token()
    auth_header = {
        "Authorization": "Bearer {token}".format(token=access_token)
    }

    album_request = requests.get(url,
            headers=auth_header)
    album_data = album_request.json()

    # get comma-separated list of track IDs
    track_id_list = []
    for track in album_data["items"]:
        track_id = track["id"]
        track_id_list.append(track_id)
    track_id_list = ",".join(track_id_list)

    audio_features_request = requests.get(api_base_url + "audio-features/",
             headers=auth_header,
             params={"ids": track_id_list})
    audio_features_data = audio_features_request.json()

    track_analysis = {}
    for track in audio_features_data["audio_features"]:
        track_energy = track["energy"]
        track_valence = track["valence"]

        # get track name from previous album request by matching its ID
        track_id = track["id"]
        for value in album_data["items"]:
            if value["id"] == track_id:
                track_name = value["name"]
                break

        track_analysis.update({track_name: [track_energy, track_valence]})
            
    # https://reddit.com/r/learnprogramming/comments/37iaj4/python_getting_the_maximum_value_from_dictionary/
    power_track = max(track_analysis, key=lambda k: sum(track_analysis.get(k)))

    power_track_energy = round(track_analysis[power_track][0] * 100)
    power_track_valence = round(track_analysis[power_track][1] * 100)

    analysis = (f"Baserat på energi ({power_track_energy}%) och"
                f" positivitet ({power_track_valence}%) verkar låten"
                f" \"{power_track}\" ha störst powerpotential.")

    return analysis

def check_new_albums():
    artist_log_dir = os.path.join(log_dir, "bot-metal")
    if not os.path.isdir(artist_log_dir):
        os.makedirs(artist_log_dir)

    artists = {
        "Adagio": "5QJvZ6s15Hgpjq7UKktjaZ",
        "Allen Lande": "2hxa4ytcni5FUIK8IR27tX",
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

    for artist, artist_id in artists.items():
        album_title, album_date, album_link, album_id = get_latest_album(artist_id)

        album_title = '"' + album_title + '"'
        album_year = datetime.datetime.strptime(album_date, '%Y-%m-%d').strftime('%Y')
        latest_album = album_title + " (" + album_year + ")"

        log = os.path.join(artist_log_dir, artist + ".log")

        if os.path.isfile(log):
            with open(log, "r") as f:
                latest_log = f.read()

            if latest_album != latest_log:
                random_emoji = get_random_emoji()
                power_analysis = get_power_analysis(album_id)

                msg = ( f"Nytt släpp av {artist}: {latest_album}."
                        "\n\n"
                        f"{album_link}"
                        "\n\n"
                        f"{power_analysis}"
                        "\n\n"
                        f"{random_emoji}" )

                functions.push(msg) # in case signal-cli fails
                signal_send(msg)

        with open(log, "w") as f:
            f.write(latest_album)
        

def main():
    if functions.internet():
        check_new_albums()


if __name__ == "__main__":
    try:
        main()
    except Exception as err:
        script = os.path.basename(__file__)
        err = str(err)

        msg = ( f"{script} stötte på fel:"
                "\n\n"
                f"{err}" )
        functions.push(msg)
