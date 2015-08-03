# Change Log
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/). Follow
guidelines from here: https://github.com/olivierlacan/keep-a-changelog

## [Unreleased][unreleased]
### Added
- Autosuggest ember component

### Changed
- Gussied up Figures and Supporting Information thumbnails
- Register Decision card now has 'Minor Revision' and 'Major Revision' options instead of 'Revise'

### Deprecated
-

### Removed
-

### Fixed
-

### Security
-


## [1.1.1] - 2015-07-14
### Changed
- Updated PLOS Bio Tech Check gem

## [1.1.0] - 2015-07-14
### Added
- NED/Akita profile information integration (turned OFF until further development work).
- Editorial Dashboard (“Paper Tracker”): Available to all users with the Flow Manager permission. Located under hamburger menu.
- Make Admin follower on the Changes for Author card.
- Versioning of the Manuscript: Backend work only.  UI/UX in process for later release.
- Enhancements to Style Guide.
- Add spinner to /admin page when journals are loading so users know something is happening.
- Added copy when paper creation is taking place so user knows something is happening.
- Moved calls being made to the Event Stream from happening in process to a background sidekiq worker, increasing performance, and lessening complexity when there is a failure.

### Changed
- Move “Submit” button to top of right rail.
- Change Contributors in upper nav to ‘Collaborators”.
- Update Register Decision card to use a button instead of the Complete checkbox to send email.
- Thai’s Manuscript Editor now supports more sophisticated locking mechanism for concurrent editing.

### Fixed
- Fixed inconsistent paper locking mechanism.
- Fixed styling of certain emails.
- Fixed various line breaks and formatting across the app.
- Fixed Select2 image asset issue.
- Removed 255 character limit on Figures.
- Removed gray scroll line from right edge of manuscript body.
- Aligned left toolbar items in editor with Manuscript body.
- Workflow columns now have spacing at the bottom.
- Fixed: [Error with POST request to /api/papers. Server returned 500: Internal Server Error.] when trying to create a paper.
- Financial Disclosure card was not returning to the default state of nothing selected if all existing funders were removed.
- Fixed issue where badging display was cut off the UI in half view.
- Refresh required before subsequent feedback can be submitted.
- Fixed issue where Upload Manuscript card could not be completed.
- Author could not open Figures card after submitting a paper.
- Site admins were receiving pusher error connecting to channels without direct relationship.
- Author wasn’t being added as a participant in Changes for Author created from ITC.
- Author card erroneously created two entries for one new author.
- Revision Decision notification email didn’t include decision text.
- Revisions links on “Reviewer Report” card did not denote which version/revision.
- Change caption in Figures to a text type column.
- Fixed issue where manuscript could not be uploaded.
- Fixed issue where user was unable to open Figures card after submitting a paper.
- Fixed issue where user had trouble finding the editable area within the editor, this is now tall enough so a click anywhere in the white-space below the title initiates editing.

### Known Issues
- Some manuscripts are still failing in iHat, the document conversion service. We are working iteratively through documents to improve the error rate.
- Uploading a Manuscript may require the user to reload the paper screen.

## [1.0.1] - 2015-07-08
### Added
- Added Skylight.io.
- Added Object Count logger.

### Changed
- Updated Ruby version to 2.2.2.

## [1.0.0] - 2015-06-29

_Changes too big to document, initial release_

[unreleased]: https://github.com/tahi-project/tahi/compare/v1.1.1...HEAD
[1.1.1]: https://github.com/tahi-project/tahi/compare/v1.1.0...v1.1.1
[1.1.0]: https://github.com/tahi-project/tahi/compare/v1.0.1...v1.1.0
[1.0.1]: https://github.com/tahi-project/tahi/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/Tahi-project/tahi/tree/v1.0.0
