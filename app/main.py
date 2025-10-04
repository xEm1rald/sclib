import streamlit as st
import sclib
import os
from utils import download


# === Настройки страницы ===
st.set_page_config(
    page_title="sclib - SoundCloud App",
    page_icon="🎵",
    #layout="wide"
)

st.title("🎶 sclib (soundcloud-lib)")

url = st.text_input("Insert link to track / album / playlist", placeholder="https://soundcloud.com/...")

if url and url.startswith("https://soundcloud.com/"):
    try:
        client = sclib.SoundcloudAPI()
        track = client.resolve(url)

        if not track:
            st.error(f"This url is invalid")
            st.stop()

        # === Получаем данные ===
        track_type = track.kind  # "track" | "playlist"
        title = track.title
        permalink_url = track.permalink_url
        author = track.user["username"]
        author_url = track.user["permalink_url"]
        artwork_url = getattr(track, "artwork_url", None) or getattr(track, "artwork_url", "")
        artwork_url = artwork_url.replace("large", "t500x500") if artwork_url else None

        # Для треков — длина, для плейлистов — количество треков
        extra_info = None
        if track_type == "track":
            length = round(track.duration / 1000)  # в секундах
            minutes, seconds = divmod(length, 60)
            extra_info = f"⏰ {minutes}:{seconds:02d}"
        elif track_type == "playlist":
            extra_info = f"🎵 {len(track.tracks)} tracks"

        # === Отображение ===
        cols = st.columns([2, 3])
        with cols[0]:
            if artwork_url:
                st.image(artwork_url, width="stretch")
            else:
                if type(track) is sclib.Playlist:
                    try:
                        st.image(track.tracks[0].artwork_url.replace("large", "t1080x1080"), width="stretch")
                    except Exception: pass
                else:
                    st.image("https://via.placeholder.com/300x300.png?text=No+Artwork", width="stretch")

        with cols[1]:
            st.markdown(f"**Type:** `{track_type}`")
            st.markdown(f"##### **Title:** [{title}]({permalink_url})")
            st.markdown(f"##### **Author:** [{author}]({author_url})")

            if extra_info:
                st.markdown(f"##### **Info:** {extra_info}")

            if st.button("Download", key="btn", use_container_width=False, icon="⬇️"):
                _, path = download(track)
                if not os.path.exists(path):
                    st.error(f"Track cant be download")

                elif isinstance(track, sclib.Track):
                    with open(path, "rb") as f:
                        st.download_button(
                            label="Save track",
                            data=f,
                            file_name=os.path.basename(path),
                            mime="audio/mpeg"
                        )

                elif isinstance(track, sclib.Playlist):
                    with open(path, "rb") as f:
                        st.download_button(
                            label="Save album / playlist",
                            data=f,
                            file_name=os.path.basename(path),
                            mime="application/zip"
                        )

        if isinstance(track, sclib.Playlist):
            st.markdown("---")
            for i, t in enumerate(track.tracks):
                t: sclib.Track
                artwork_url = t.artwork_url
                artwork_url = artwork_url.replace("large", "t1080x1080") if artwork_url else "https://via.placeholder.com/100"

                likes = t.likes_count
                listenings = t.playback_count

                cols = st.columns([1, 6])
                with cols[0]:
                    st.image(artwork_url, width='stretch')

                with cols[1]:
                    st.markdown(f"**{i + 1}. [{t.title}]({t.permalink_url})**")
                    st.markdown(f"❤️ Likes: {likes} | 🎧 Listens: {listenings}")
                st.markdown("---")  # separator between tracks

    except Exception as e:
        st.error(f"Error occurred: {str(e)}")
