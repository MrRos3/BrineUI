#!/bin/sh
# Brine's cross-platform builder includes required attribution in every bundle.
set -eu
exec node scripts/build.mjs
