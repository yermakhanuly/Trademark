#!/bin/bash

# Create assets directory if it doesn't exist
mkdir -p assets

# Download sound effects
curl -o assets/correct.mp3 https://assets.mixkit.co/active_storage/sfx/2013/2013-preview.mp3
curl -o assets/wrong.mp3 https://assets.mixkit.co/active_storage/sfx/270/270-preview.mp3 