# Change Log
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/). Follow
guidelines from here: https://github.com/olivierlacan/keep-a-changelog

## [Unreleased][unreleased]
### Added
- Ability to diff form based cards, such as the Additional Information card, in versioning mode

### Changed
- NestedQuestions have unique identifiers
- Revamped the Summporting Information task.

### Deprecated
-

### Removed
-

### Fixed
-

### Security
-

## [1.3.6] - 2015-12-08
### Added
- Users can view old versions of the paper's metadata.
- FTP to APEX ability for QA and developers. Other features will integrate with this feature to expose this functionality to the user.
- Authors can now upload manuscripts that were saved as .doc files

### Changed
- compressed application request logging to a single line
- overlays changed to ember components (excluding tasks) https://developer.plos.org/confluence/display/TAHI/How+Overlays+Work

### Fixed
- images embedded into an uploaded word document will show correctly on the manuscript page

## [1.3.5] - 2015-11-11
### Added
- Button to easily link to creating a new CAS account

### Changed

- Add host prefix to feedback email
- Moved primary navigation to top of screen

### Deprecated
-

### Removed
- Intelligibility Question from the ReviewerReportTask

### Fixed
- Fixed display of form errors on Production Metadata Card
- Updated sidekiq and newrelic gems that have known memory leaks

### Security
-

## [1.3.4] - 2015-10-29
### Added
- Add inline figures to downloaded PDF
- Show HTML for paper title within email

### Changed
- New Manuscript Overlay edits Paper title in place of short title
- Upgraded to ruby 2.2.3

### Removed
- VisualEditor
- Followers from author activity feed

### Fixed
- Fixed display of labels on Authors card
- Assign DOIs to all papers
- Document conversion creates TEI comments
- Proper handling of errors from iHat
- Inability to mark author card as 'complete'

## [1.3.3] - 2015-10-01
### Added
- Super Admin: run `rake plos_billing:retry_salesforce_case_for_paper[:paper_id]` to resend Salesforce Case data for 1 Paper
- Preliminary Salesforce integration
- General improvements to real-time updating
- Auto-population of submitting author on add author card

### Changed
- Improvements to workflow drag & drop ordering
- Improvement to invite reviewer process when more than one reviewer

### Removed
- Removed PLOS authors model, task column moved to user table

### Fixed
- Numerous bug fixes


## [1.3.2] - 2015-09-17
### Changed
- Increased the number and fidelity of Workflow Activity Feed messages
- Editor: started an integration test-suite in the editor repository which is run with CircleCI: https://circleci.com/gh/Tahi-project/tahi-editor-ve

### Fixed
- Editor: (regression) collection overlays can be opened again

## [1.3.1] - 2015-09-01
### Added
- Anyone with access to the "Assign Team" card can now assign and un-assign users to a manuscript

### Changed
- Update to [Rails 4.2.4](https://github.com/rails/rails/compare/v4.2.3...v4.2.4)
- Update to [Ember 1.13.9](https://github.com/emberjs/ember.js/releases/tag/v1.13.9)
- Card names have been changed.

### Fixed
- Fixed NED integration
- Show `.png`s when `.tiff` or `.eps` file types are uploaded as figures / adhoc attachments
- Title Placeholders are now fixed in Visual Editor.
- Refactored sidebar template into the paper-sidebar component

## [1.3.0] - 2015-08-26
### Added
- Autosuggest ember component
- Select box ember component
- Reviewer Reports can now be submitted, and can't be edited after that
- Ability to view and diff old versions of manuscripts.
- Reviewers can be invited that are currently not in the system
- Lock down submission cards when MS is not editable
- Ability to withdraw a manuscript.
- Anyone with access to the "Assign Team" card can now assign and un-assign users to a manuscript
- Manuscript supporting information files appear as links in download

### Changed
- Upgraded to Ember 1.13 [Aperta Transition Guide](https://github.com/Tahi-project/tahi/wiki/Aperta-Ember-1.13-Transition-Guide)
- Make card previews (green boxes with task name) into hyperlinks to allow for right click / ctrl click to open cards in a new tab
- Changed Typography to use fonts that have better rendering and more glyphs
- Allow non-image file types to be attached to feedback form and downloaded upon receipt of email.
- Send paper admin an email when an editor accepts invitation.
- Add edit/delete/replace functionality to Ad-Hoc attachments.
- Update 'notify_editor' email styles
- Control bar has been refactored into a component

### Fixed
- No longer perform unfiltered searches in Flow Manager
- No longer shows publishable checkbox in Figures, since it only applies to Supporting Information Files
- Display comments as written, instead of escaping non-alphanumeric characters.
- No longer adding trailing whitespace and persisting empty strings on Journals
- Creating a journal with a logo no longer raise an error
- Abstract in Reviewer invitation emails no longer show HTML tags

## [1.2.0] - 2015-08-04
### Added
- Countries endpoint through NED (Ringold)
- Ability to download attachments on adhoc cards
- Ability for any user in system to become a reviewer on a paper
- Whitelabel application so that application name can be changed via configuration
- Invitations of new user
- Institutions are now fetched from NED (Ringold)
- Introduce Auto Suggest List component
- Customizable letter on invite editor card
- Visual Editor supports MathJax
- Searching for editors using name or email
- More information included when sending an editor invitation

### Changed
- Gussied up Figures and Supporting Information thumbnails
- Register Decision card now has 'Minor Revision' and 'Major Revision' options instead of 'Revise'
- Upgraded to CAS v2 which properly handles redirection back to main application
- Update notify_invited email formatting
- Updated Puma to 2.12.2
- Billing card copy and typos. Using countries endpoint
- Improve email text
- PLOS Bio InitialTechCheckTask has become the new TechCheckTask
- Upgraded Puma to 2.12.2
- Upgraded Sidekiq to 3.4.2
- Upgraded ember cli rails to 0.3.4
- Upgrade to latest PlosBioTechCheck
- Upgrade to latest VisualEditor

### Removed
- Minor check publishing state
- TahiStandardTasks::TechCheckTask is removed

### Fixed
- Decreased memory consumption on `admin/journal` by decreasing amount of serialized data
- Update all Devise error messages to Aperta's basic alert-warning styles (red)

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

[unreleased]: https://github.com/tahi-project/tahi/compare/v1.3.1...HEAD
[1.3.1]: https://github.com/tahi-project/tahi/compare/v1.3.0...v1.3.1
[1.3.0]: https://github.com/tahi-project/tahi/compare/v1.2.0...v1.3.0
[1.2.0]: https://github.com/tahi-project/tahi/compare/v1.1.1...v1.2.0
[1.1.1]: https://github.com/tahi-project/tahi/compare/v1.1.0...v1.1.1
[1.1.0]: https://github.com/tahi-project/tahi/compare/v1.0.1...v1.1.0
[1.0.1]: https://github.com/tahi-project/tahi/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/Tahi-project/tahi/tree/v1.0.0
