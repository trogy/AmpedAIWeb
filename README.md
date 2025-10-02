# Amped AI Web

## Amped AI

Amped AI is a fully AI-generated radio station. Every track, every show, every voice you hear is created by AI—from upbeat morning chatter to late-night playlists.

The goal is simple: to re-imagine what a radio station can be when it’s powered end-to-end by artificial intelligence.

### What you’ll hear

- Original AI-generated music across pop, rock, indie, and more.
- AI radio hosts who guide you through mornings, afternoons, and weekends with natural banter and show handovers.
- Real news, weather, and alerts pulled from trusted sources—never faked.

### Why it exists

Amped AI isn’t trying to replace human radio. It’s an experiment in creativity and technology—exploring how far AI can push the boundaries of broadcasting while still feeling like real radio.

### Website

This repository powers the Amped AI website. The site provides:

- Information about the station and its shows
- Links to the live stream
- Updates and background on the project

Amped AI Web is a static landing page, and the single `index.html` file powers the entire experience—from the hero live player down to the ethics statement—so you can host the site anywhere that can serve plain HTML, CSS, and JavaScript. The layout highlights the live stream, featured AI-hosted shows, the upcoming schedule, a recent tracks feed, and a transparent disclosure of the station's AI practices. The page is specifically designed to work with an AzuraCast backend, consuming its public APIs to keep content, metadata, and scheduling information in sync with the live broadcast.

## Quick Start

1. **Clone or download the repository.**
2. **Preview locally.**
   - Open `index.html` directly in a browser, _or_
   - Serve it with any static host (e.g., `python -m http.server`, `npx http-server`, `php -S localhost:8000`).
3. **Optional live reloading.** Use tooling such as VS Code's Live Server extension, Browsersync, or Vite's `vite preview --host` to automatically refresh when you edit the file.

## Configuration (`index.html`)

All runtime configuration lives in the `<script>` block near the end of `index.html`.

### `CONFIG` object

| Field | Description |
| --- | --- |
| `streamURL` | Direct URL to the audio stream served by AzuraCast. It is injected into the HTML5 `<audio>` element and reloaded when the user hits play or when metadata refreshes. |
| `apiBase` | Base URL for your AzuraCast API (e.g., `https://your-station.example.com/api`). All other endpoint requests are built from this root. |
| `station` | Station shortcode used for the `nowplaying` API. This should match the `shortcode` defined in AzuraCast. |
| `stationId` | Numeric station ID used for schedule queries (`/station/{id}/schedule`). |
| `timeZone` | IANA time zone string applied when formatting the schedule and now playing timestamps. |
| `liveLabel` | Text shown beside the player when the backend indicates a live broadcast. |

### `SHOWS` array

`SHOWS` controls the featured show grid. Each entry follows this shape:

```js
{
  title: "Show name",
  time: "Airtime label",
  image: "relative/path/to/artwork.png",
  imageText: "Accessible text overlay",
  desc: "Short description that appears in the card."
}
```

Artwork assets such as `logo.png`, `AMWM.png`, and other show images live alongside `index.html`. Reference them by filename (e.g., `image: "AMWM.png"`) or a relative path if you organize assets into folders.

## Backend Integration (AzuraCast)

The page relies on two AzuraCast REST endpoints:

- **Now Playing:** `GET ${CONFIG.apiBase}/nowplaying/${CONFIG.station}` (with a fallback to `GET ${CONFIG.apiBase}/nowplaying`). This powers the live metadata, artwork, and recent track list.
- **Schedule:** `GET ${CONFIG.apiBase}/station/${CONFIG.stationId}/schedule`. The response is filtered to show the upcoming shows in the timetable section.

Ensure the AzuraCast instance exposes these endpoints publicly and that Cross-Origin Resource Sharing (CORS) is enabled so the browser can fetch data directly. Authentication is not required for public stations, but API keys or IP restrictions may apply depending on your deployment.

## Project Structure

```
AmpedAIWeb/
├── index.html     # Single-page site containing markup, styles, configuration, and scripts
├── README.md      # Project documentation (this file)
└── LICENSE.md     # License information
```

Any additional assets (logos, show art, etc.) should be placed alongside `index.html` or in subdirectories you reference with relative paths.

## Customization & Theming

- Tweak the `CONFIG` and `SHOWS` objects to point at your own streams and programming.
- Update hero copy, section headings, or AI ethics content directly in `index.html`.
- Modify the CSS variables declared in the `:root` selector to change colors, spacing, and shadows. The page supports both dark and light themes via the `data-theme` attribute and the built-in theme toggle.
- Replace or expand artwork assets referenced by the featured show cards and metadata artwork.

## Deployment

Because the site is a single static file, you can deploy it to any static hosting provider, including GitHub Pages, Netlify, Vercel (static export), Amazon S3 + CloudFront, or your own Nginx/Apache server. Upload `index.html` and accompanying assets, ensure caching headers suit your update cadence, and point DNS to your host.

## Contributing

Issues and pull requests are welcome. Please fork the repository, make changes in a feature branch, and open a pull request describing your updates.

## License

Distributed under the terms of [`LICENSE.md`](LICENSE.md). Review the license before distributing or modifying the project.
