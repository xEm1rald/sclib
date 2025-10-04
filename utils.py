from sclib import Track, Playlist
import config
import os
from zipfile import ZipFile

fp = "{artist} - {title}.mp3"

def download(track: Track | Playlist) -> tuple[Track | Playlist, str]:
    storage = config.TEMP_DOWNLOAD_DIRECTORY
    os.makedirs(storage, exist_ok=True)

    loads = {}

    if isinstance(track, Track):
        artist, title = track.user.get('permalink', 'None'), track.permalink
        filename = fp.format(artist=artist, title=title)
        filepath = os.path.join(storage, filename)

        if os.path.exists(filepath):
            return track, filepath

        with open(filepath, 'wb+') as file:
            try:
                track.write_mp3_to(file)
            except Exception as e:
                print(str(e))

        if os.path.getsize(filepath) == 0:
            os.remove(filepath)

        return track, filepath

    elif isinstance(track, Playlist):
        playlist = track
        to_zip = []
        for i, track in enumerate(playlist.tracks):
            track.album = playlist.title  # set album name
            artist = track.user.get('permalink', 'None')  # set artist name
            title = track.permalink  # set title
            track.track_no = i+1 # track number
            filename = fp.format(artist=artist, title=title)
            filepath = os.path.join(storage, filename)

            if os.path.exists(filepath):
                to_zip.append(filepath)
                continue

            with open(filepath, 'wb+') as file:
                try:
                    track.write_mp3_to(file)
                except Exception as e:
                    print(str(e))

            if os.path.getsize(filepath) == 0:
                os.remove(filepath)
                continue

            to_zip.append(filepath)

        zip_name = f"{playlist.permalink}.zip"
        zip_path = os.path.join(storage, zip_name)
        with ZipFile(zip_path, "w") as zipf:
            for file in to_zip:
                zipf.write(file)

        return track, zip_path

    return loads