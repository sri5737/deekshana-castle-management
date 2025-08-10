# GitHub Pages Deployment (Flutter Web)

This repo includes a GitHub Actions workflow that builds the Flutter web app in `flutter_app/` and deploys it to GitHub Pages.

- Workflow: `.github/workflows/deploy-pages.yml`
- Output: published from `flutter_app/build/web` artifact
- Base href: set to `/deekshana-castle-management/`

If you fork or rename the repo, update the `--base-href` in the workflow to match `/<your-repo-name>/`.

Single Page App 404 handling is added by copying `index.html` to `404.html` during the build step.

## Enable Pages
1. Push to `main` or `registration-module`.
2. In GitHub → Settings → Pages, set Source to "GitHub Actions".
3. After the first successful run, your site will be available at:
   https://<your-username>.github.io/deekshana-castle-management/
