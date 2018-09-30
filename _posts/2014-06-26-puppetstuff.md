---
title: 'Foreman Console Troubleshooting'
category: puppet
tags: puppet foreman
---

# Foreman Console Troubleshooting

After several failures with Foreman's noVNC JS client (which is really awesome) Today I stumbled upon the newly arrived "Troubleshooting" button on the console screen. Desperate, I pressed it.

  * When using Firefox, if you use Foreman via HTTPS, Firefox might block the
    connection. To fix it, go to about:config and enable
    network.websocket.allowInsecureFromHTTPS. Same goes for Chrome, to fix it,
    go to chrome://flags/ and enable Allow insecure WebSocket from https origin

That actually worked for me. On down, infinite to go.
