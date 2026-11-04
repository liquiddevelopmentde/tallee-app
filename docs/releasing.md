# Releasing

Releases are built by GitHub Actions in `.github/workflows/release.yaml`. The
workflow lives in `.github/workflows` on purpose: Gitea Actions only reads
`.gitea/workflows` while that directory contains workflow files, so Gitea
ignores this workflow completely.

Two ways to start a release:

| Trigger | Uploads |
| --- | --- |
| `workflow_dispatch` with `dry_run: true` (default) | none, build only |
| `workflow_dispatch` with `dry_run: false` | yes, if publishing is enabled |
| push of a tag matching `v*` | yes, if publishing is enabled |

Uploads only run when **all** of these are true:

1. The repository variable `STORE_DEPLOY_ENABLED` is `true`.
2. The run is either a tag push or a manual run with `dry_run: false`.
3. The `production` environment approved the job (if reviewers are configured).

## Draft behaviour

Every upload is a draft by default — a human still has to promote it:

| Target | Default | How to make it live |
| --- | --- | --- |
| Google Play | Draft release in the `internal` track (`PLAY_RELEASE_STATUS=draft`) | Roll out the draft in the Play Console, then promote the track |
| App Store | Build uploaded to TestFlight and the version staged in `PREPARE_FOR_SUBMISSION` (via `asc release stage`) | Fill in the metadata and submit the version for review in App Store Connect |
| Gitea release | Auto-created release is a draft (`GITEA_RELEASE_DRAFT=true`) | Publish the draft release in Gitea |

Set `PLAY_RELEASE_STATUS=completed` if you want Play to roll out immediately
(for example on the `internal` track).

## Required GitHub secrets

Go to **Settings → Secrets and variables → Actions → Secrets**.

| Secret | Description |
| --- | --- |
| `API_URL` | Production API URL, written to `.env` as `API_URL_PROD` |
| `SENTRY_DSN` | Sentry DSN, written to `.env` |
| `ANDROID_KEYSTORE_BASE64` | Base64 of the Android upload keystore (`.jks`) |
| `ANDROID_KEYSTORE_PASSWORD` | Keystore password |
| `ANDROID_KEY_ALIAS` | Key alias inside the keystore |
| `IOS_CERTIFICATE_P12_BASE64` | Base64 of the Apple Distribution certificate (`.p12`) |
| `IOS_CERTIFICATE_PASSWORD` | Password of the `.p12` |
| `IOS_PROVISIONING_PROFILE_BASE64` | Base64 of the App Store provisioning profile (`.mobileprovision`) |
| `PLAY_STORE_SERVICE_ACCOUNT_JSON` | Full JSON of the Google Play service account |
| `APPSTORE_API_PRIVATE_KEY` | Contents of the App Store Connect `AuthKey_XXXXXXXXXX.p8` |
| `GITEA_TOKEN` | Gitea token with `write:repository` scope |
| `SENTRY_AUTH_TOKEN` | Optional: lets the build upload debug symbols to Sentry |

## Required GitHub variables

Go to **Settings → Secrets and variables → Actions → Variables**.

| Variable | Default | Description |
| --- | --- | --- |
| `STORE_DEPLOY_ENABLED` | unset (= disabled) | Set to `true` to allow uploads |
| `GITEA_URL` | `https://git.yannick-weigert.com` | Gitea base URL |
| `IOS_PROVISIONING_PROFILE_NAME` | – | Exact name of the provisioning profile |
| `APPSTORE_ISSUER_ID` | – | App Store Connect issuer ID |
| `APPSTORE_API_KEY_ID` | – | App Store Connect API key ID |
| `PLAY_TRACK` | `internal` | Play track to upload to |
| `PLAY_RELEASE_STATUS` | `draft` | `draft`, `completed`, `inProgress`, `halted` |
| `GITEA_RELEASE_DRAFT` | `true` | Auto-created Gitea releases stay drafts |

## Required GitHub environment

Create the environment `production` (**Settings → Environments**) and add
required reviewers. Without reviewers the upload jobs run as soon as
`STORE_DEPLOY_ENABLED` is `true`.

## Generating the secret values

Android upload keystore (create once, keep it safe):

```bash
keytool -genkey -v \
  -keystore upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload
base64 -i upload-keystore.jks | pbcopy   # -> ANDROID_KEYSTORE_BASE64
```

Apple certificate and profile:

```bash
base64 -i Certificates.p12 | pbcopy            # -> IOS_CERTIFICATE_P12_BASE64
base64 -i profile.mobileprovision | pbcopy     # -> IOS_PROVISIONING_PROFILE_BASE64
```

App Store Connect API key: **Users and Access → Integrations → App Store
Connect API → Keys**, role *App Manager*. The `.p8` file can only be downloaded
once; its contents go into `APPSTORE_API_PRIVATE_KEY`.

Google Play service account: enable the *Google Play Android Developer API*,
create a service account, download the JSON key, and invite the service account
in the Play Console with access to the app.

Gitea token: **Settings → Applications → Generate New Token** with the
`write:repository` scope.

## First-time setup order

1. Create the Android upload keystore and add all Android secrets.
2. Upload one AAB manually to the Play Console (internal testing track) so the
   package exists. Play rejects uploads for packages that were never published.
3. Create the iOS distribution certificate and App Store provisioning profile,
   add the secrets and the `IOS_PROVISIONING_PROFILE_NAME` variable.
4. Add `GITEA_TOKEN`, `GITEA_URL`, `APPSTORE_ISSUER_ID`, `APPSTORE_API_KEY_ID`.
5. Run the workflow manually with `dry_run: true` and confirm both builds pass.
6. Create the `production` environment with required reviewers.
7. Set `PLAY_TRACK=internal` and `STORE_DEPLOY_ENABLED=true`.
8. Run manually with `dry_run: false` and approve the `production` environment
   to verify the real upload path.
9. Create a tag (for example `v.0.2.0`) in Gitea and let the mirror push it to
   GitHub.

## Manual runs

For a manual run, `dry_run` defaults to `true`. If you want to publish from a
manual run, set `dry_run: false` **and** pass the existing release tag in the
`tag` input; otherwise the workflow uses the branch name and cannot find a
release.

## Known issues

- The iOS bundle identifier is inconsistent: Debug/Profile use
  `de.liquid-dev.tallee`, Release uses `de.liquiddev.tallee`. The release
  workflow targets `de.liquiddev.tallee`. Make sure the provisioning profile
  matches.
