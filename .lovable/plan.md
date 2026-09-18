# Transform Sanket into a Campus Intelligence Platform

## Goal
Reposition the existing Sanket product around anonymous student signals and university operations while preserving its routes, authentication, database connection, reporting pipeline, clustering, maps, evidence audit, verification, and role security.

## Product and navigation
- Update shared navigation, authentication copy, page metadata, statuses, and labels from civic/citizen/municipal language to student/campus/administration language.
- Keep all existing URLs and role checks. Present the current worker role as a responsible department or campus operations team, and the current admin role as university administration.
- Repair the existing homepage syntax error, then adapt its current layout, image treatment, map, feature cards, and process flow to “Understand the Campus. Improve the Experience.”
- Keep the interface light, professional, compact, responsive, and consistent with Sanket’s existing design tokens.

## Student home
- Evolve the existing citizen dashboard in place into a student home with clear access to Report a Problem, Campus Pulse, Nearby Problems, My Reports, Notifications, and Profile.
- Keep the existing report list and map, adding category, severity, and status filters rather than replacing the map.
- Show report authors anonymously; remove user identifiers from client-visible problem and verification queries.
- Add a My Reports view using the existing owner-scoped report query.

## Reporting and AI intelligence
- Keep the existing secure reporting and evidence pipeline, but make photos optional and simplify the form so students describe the problem and location without choosing a complex category.
- Expand existing AI classification to campus categories, severity, confidence, affected area, and a suggested responsible department. Add text-only analysis when no photo is supplied.
- Reuse the existing location/category deduplication and report-count model to group similar student signals into one campus problem.
- Update campus categories and department suggestions for Water, Wi-Fi, Mess, Transport, Cleanliness, Library, Labs/Classrooms, Parking, Safety, Electrical, and Other.

## Campus Pulse
- Add one small, protected Campus Pulse response table through a migration, with explicit grants and row-level policies. Store authenticated ownership only for abuse prevention; never expose identities to students or aggregate responses.
- Add lightweight Yes/No signal controls for the requested campus areas and anonymous aggregate counts.
- Use authenticated server functions for submissions and aggregated results so raw student-linked responses are not returned to the browser.

## Problem DNA and resolution
- Extend campus problems minimally with AI confidence, affected area, suggested department, and responsible department fields; retain all existing issue rows and statuses.
- Turn the current issue detail into a Problem DNA view showing first/latest report, related reports, affected area, recurrence, priority, responsible department, previous resolution attempts, current status, evidence, and student verification.
- Mark recurring groups using existing report/failure counts and timestamps, without claiming an unverified root cause.
- Preserve the existing evidence comparison, student verification thresholds, automatic reopen behavior, and closed/reopened states; rename the visible workflow for campus operations.

## Campus operations
- Transform the existing admin dashboard into Campus Intelligence with Active Problems, High Priority, Recurring Problems, Affected Areas, Overdue Actions, and Resolution Status.
- Derive operational-area health for Hostels, Mess, Transport, Library, Labs/Classrooms, Parking, and Other Facilities from real issue data, using green/yellow/red indicators.
- Add campus map filters without replacing the existing map component.
- Let administrators accept or manually change the suggested department, while preserving current staff assignment and resolution controls.
- Add concise Campus Insights computed from real records. Show clearly labelled `DEMO INSIGHT` examples only when real data is unavailable.

## Data and security
- Apply one additive migration for the new issue intelligence fields and Campus Pulse table; do not replace existing tables or alter authentication roles.
- Keep student identity internally linked for security and ownership, but anonymous in all student/public presentation and aggregate responses.
- Preserve private evidence access, scoped verification access, staff/admin authorization, and invitation-code role elevation.
- Update generated database types only to match the applied migration.

## Validation
- Run focused type and regression checks for reporting, clustering, Pulse submission, department assignment, verification/reopening, and existing challenge routes.
- Verify homepage, auth, student home, issue detail, operations task queue, and admin Campus Intelligence at desktop and mobile sizes.
- Confirm map sizing/filtering, optional-photo submission states, no student names or IDs in student-facing responses, and no browser/runtime errors.
