# Release tooling

These two files used to live in `/tmp`, which is wiped periodically — twice now
that has cost a rebuild in the middle of a submission. They belong in the repo.

- **`ExportOptions.plist`** — passed to `xcodebuild -exportArchive`.
- **`asc_api.py`** — signs an ES256 JWT and calls the App Store Connect API.
  Needs `pyjwt` and the `.p8` key at `~/.appstoreconnect/private_keys/`.

## Credentials stay out of this repo

It is public. The issuer and key IDs live in `~/.appstoreconnect/keys.json`:

    {"issuer": "...", "keyId": "..."}

`asc_api.py` reads that file, or `ASC_ISSUER_ID` / `ASC_KEY_ID` from the
environment. Export both before running the `xcodebuild` commands below.

## Cutting a build

    xcodebuild archive -project MorningReset/MorningReset.xcodeproj \
      -scheme MorningReset -destination 'generic/platform=iOS' \
      -archivePath /tmp/build.xcarchive

    xcodebuild -exportArchive -archivePath /tmp/build.xcarchive \
      -exportPath /tmp/export -exportOptionsPlist scripts/ExportOptions.plist \
      -allowProvisioningUpdates \
      -authenticationKeyPath ~/.appstoreconnect/private_keys/AuthKey_$ASC_KEY_ID.p8 \
      -authenticationKeyID $ASC_KEY_ID \
      -authenticationKeyIssuerID $ASC_ISSUER_ID

`-allowProvisioningUpdates` and the three auth flags are not optional: without
them the export fails on the widget extension's provisioning profile.

## Prices are only true in App Store Connect

`MorningReset/MorningReset.storekit` configures the simulator and nothing else.
It has drifted from the live prices before. Read them from the API:

    GET /v1/subscriptions/{id}/prices?filter[territory]=USA&include=subscriptionPricePoint

## A new subscription group needs its own localizations

A product can have a complete localization and still sit at MISSING_METADATA:
the **group** needs one too, in every language `CFBundleLocalizations` declares
(currently en, tr, es). `POST /v1/subscriptionGroupLocalizations`.
