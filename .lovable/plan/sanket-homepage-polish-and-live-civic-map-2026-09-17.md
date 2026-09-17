# Sanket homepage polish and live civic map

## Scope
Improve only the existing `/` homepage. Preserve every current button destination, sign-in behavior, route, API, database flow, and all non-homepage pages.

## Homepage design
- Rework the first screen into a polished light civic-tech composition with a shorter Sanket message and the existing two calls to action unchanged.
- Generate and use one bright, realistic civic visual showing several issue types together—for example damaged roads, broken streetlights, water leaks, waste, unsafe public infrastructure, and accessibility concerns—without tying Sanket to one city or region.
- Keep the image secondary to the copy using restrained overlays, readable contrast, responsive cropping, and subtle motion that respects reduced-motion settings.

## Working Google map
- Add a homepage-specific Google Maps component so the shared map used by dashboards remains untouched.
- Use the existing Google Maps Platform connector and its browser map-rendering key; the project currently has no linked Google Maps connection, so link the available connector rather than creating a second mapping implementation.
- Load Maps JavaScript asynchronously with its callback and tracking channel, use a fixed responsive map height, disable built-in POI clicks, and show a clear fallback if Maps cannot load.
- Plot clearly labeled **DEMO / SIMULATED DATA** across varied locations and categories with red Critical, orange High, blue Standard, and green Resolved markers.
- Clicking a marker opens a small detail panel with issue title, category, location, status, and priority. No database records or existing issue behavior will change.

## Compact supporting content
- Keep the four requested feature cards, each reduced to icon, title, and one sentence.
- Add a compact responsive visual flow: Citizen Reports → AI Understanding → Evidence Check → Related Reports Consolidated → Priority → Authority Action → Citizen Verification.
- Preserve Sanket’s current light-theme tokens, typography, header, footer, and button components while refining spacing, card radius, and shadows only on the homepage.

## Validation
- Check the homepage at desktop and mobile widths for readable text, stable image/map sizing, marker interaction, map fallback, and no overlap.
- Confirm both existing homepage buttons still navigate to their current destinations.
- Confirm the homepage has no browser errors and that no non-homepage files or behavior changed beyond the new homepage-only visual/map assets.
