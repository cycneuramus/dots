#!/usr/bin/env python3

import datetime
import os
import random
import re
import subprocess

import requests

import functions
import mysecrets

home_dir = os.getenv("HOME")
bin_dir = os.path.join(home_dir, "bin")
log_dir = os.path.join(home_dir, "log")

api_base_url = "https://api.spotify.com/v1/"
signal_cli = os.path.join(bin_dir, "signal-cli/bin/signal-cli")


def get_api_auth_header() -> dict:
    client_id = mysecrets.spotify_client_id
    client_secret = mysecrets.spotify_client_secret

    auth_url = "https://accounts.spotify.com/api/token"

    response = requests.post(auth_url, {"grant_type": "client_credentials",
                                        "client_id": client_id,
                                        "client_secret": client_secret})

    response_data = response.json()
    token = response_data["access_token"]

    auth_header = {"Authorization": "Bearer " + token}

    return auth_header


def get_latest_album(artist_id: str) -> dict:
    url = api_base_url + "artists/" + artist_id + "/albums"
    auth_header = get_api_auth_header()

    request = requests.get(url,
                           headers=auth_header,
                           params={"include_groups": "album",
                                   "limit": 1,
                                   "market": "SE"})
    request_data = request.json()

    for album in request_data["items"]:
        title = album["name"]
        date = album["release_date"]
        link = album["external_urls"]["spotify"]
        id_ = album["id"]

    latest_album = {"title": title,
                    "date": date,
                    "link": link,
                    "id": id_}

    return latest_album


def get_power_analysis(album_id: str) -> str:
    url = api_base_url + "albums/" + album_id + "/tracks"
    auth_header = get_api_auth_header()

    album_tracks_request = requests.get(url,
                                        headers=auth_header)
    album_tracks_data = album_tracks_request.json()

    # get comma-separated list of track IDs for API request
    track_id_list = []
    for track in album_tracks_data["items"]:
        track_id_list.append(track["id"])
    track_id_list = ",".join(track_id_list)

    audio_features_request = requests.get(api_base_url + "audio-features/",
                                          headers=auth_header,
                                          params={"ids": track_id_list})
    audio_features_data = audio_features_request.json()

    tracks_analysis = {}
    for track in audio_features_data["audio_features"]:
        # get track name from previous album request by matching the track ID
        for value in album_tracks_data["items"]:
            if value["id"] == track["id"]:
                track_name = value["name"]
                break

        tracks_analysis.update({track_name: [track["energy"],
                                             track["valence"],
                                             track["mode"]]})

    # https://redd.it/37iaj4
    # get track with highest combined sum of list values in dict
    power_track_name = max(tracks_analysis,
                           key=lambda k:
                           sum(tracks_analysis.get(k)))

    power_track_energy = round(tracks_analysis[power_track_name][0] * 100)
    power_track_valence = round(tracks_analysis[power_track_name][1] * 100)

    if tracks_analysis[power_track_name][2] == 0:
        power_track_mode = "Den tycks dock inte innehålla så mycket dur."
    else:
        power_track_mode = "Den tycks även innehålla en del dur."

    power_analysis = (f"Baserat på energi ({power_track_energy}%) och"
                      f" positivitet ({power_track_valence}%) verkar låten"
                      f" \"{power_track_name}\" ha störst powerpotential."
                      f" {power_track_mode}")

    return power_analysis


def check_new_albums() -> list:
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
        "Jonathan Lundberg": "6t3AHrm1phB25xs2XpST7p",
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

    new_albums = []
    for artist, artist_id in artists.items():
        latest_album = get_latest_album(artist_id)

        album_title = '"' + latest_album["title"] + '"'
        album_year = datetime.datetime.strptime(latest_album["date"],
                                                '%Y-%m-%d').strftime('%Y')
        album_link = latest_album["link"]
        album_id = latest_album["id"]

        latest_album_summary = album_title + " (" + album_year + ")"

        log = os.path.join(artist_log_dir, artist + ".log")
        if os.path.isfile(log):
            with open(log, "r") as f:
                latest_log = f.read()

            if latest_album_summary != latest_log:
                new_albums.append({"artist": artist,
                                   "latest_album": latest_album_summary,
                                   "album_id": album_id,
                                   "album_link": album_link})

        with open(log, "w") as f:
            f.write(latest_album_summary)

    return new_albums


def get_random_emojis() -> str:
    emojis_file = os.path.join(bin_dir, "emojis")

    with open(emojis_file) as f:
        emojis_list = random.sample(f.readlines(), 3)
    emojis_str = "  ".join(emojis_list).replace("\n", "")

    return emojis_str


def craft_signal_msg(new_album: dict) -> str:
    artist = new_album["artist"]
    latest_album = new_album["latest_album"]
    album_id = new_album["album_id"]
    album_link = new_album["album_link"]

    power_analysis = get_power_analysis(album_id)
    random_emojis = get_random_emojis()

    new_album_msg = (f"Nytt släpp av {artist}: {latest_album}."
                     "\n\n"
                     f"{album_link}"
                     "\n\n"
                     f"{power_analysis}"
                     "\n\n"
                     f"{random_emojis}")

    return new_album_msg


def get_signal_recipient() -> str:
    # private mode (send to self)
    recipient = mysecrets.phone_number
    return recipient

    # oversharing mode (send to group with self as fallback)
    cmd = [signal_cli, "listGroups"]
    result = subprocess.run(cmd, capture_output=True, text=True)
    signal_groups = result.stdout

    for line in signal_groups.splitlines():
        cols = line.split()
        if mysecrets.signal_target_group in line:
            group_id = cols[1]
            break

    if group_id:
        recipient = group_id
    else:
        recipient = mysecrets.phone_number

    return recipient


def signal_send(msg: str, recipient: str):
    sender = mysecrets.phone_number
    phone_num_regex = re.compile("^\\+[1-9][0-9]{6,14}$")

    if phone_num_regex.match(recipient):
        recipient_type = "contact"
    else:
        recipient_type = "group"

    if recipient_type == "contact":
        cmd = [signal_cli, "-u", sender, "send", "-m", msg, recipient]
    elif recipient_type == "group":
        cmd = [signal_cli, "-u", sender, "send", "-m", msg, "-g", recipient]

    subprocess.run(cmd, stdout=subprocess.DEVNULL)


def main():
    if not functions.internet():
        exit()

    new_albums = check_new_albums()

    if new_albums:
        signal_recipient = get_signal_recipient()

        for new_album in new_albums:
            signal_msg = craft_signal_msg(new_album)
            signal_send(signal_msg, signal_recipient)

            functions.push(signal_msg)  # in case signal-cli fails


if __name__ == "__main__":
    try:
        main()
    except Exception as err:
        script = os.path.basename(__file__)
        err = str(err)

        err_msg = (f"{script} stötte på fel:"
                   "\n\n"
                   f"{err}")

        print(err)
        functions.push(err_msg)
