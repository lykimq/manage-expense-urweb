/*
 * Defeat the browser back/forward cache (BFCache) for this app.
 *
 * Without this, pressing Back can restore a rendered page from BFCache
 * without ever asking the server, which bypasses our session guards
 * (Session.requireUser / Session.requireGuest in src/auth/session.ur).
 *
 * The "pageshow" event fires on both initial loads and BFCache restores;
 * the persisted flag is only true on a BFCache restore. In that case we
 * force a fresh server fetch so the current session decides what to show.
 */
window.addEventListener("pageshow", function (event) {
    if (event.persisted) {
        window.location.reload();
    }
});
