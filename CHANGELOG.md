# Change Log
All notable changes to this project will be documented in this file. Follow
guidelines from here: https://github.com/olivierlacan/keep-a-changelog

## [{version}] - {release_date}
### Added
- Email invitation changes can now be saved
- Added billing role
### Changed
### Deprecated
### Removed
- Production staff, publishing services, and staff admin can no longer view the billing card
### Fixed
- Emails are not sent when a decision is rescinded
### Security

## [1.24.1] - {2016-09-08}
### Fixed
- Staff members can now upload a manuscript after a paper has been submitted

## [1.24.0] - {2016-08-30}
### Added
- Decisions can be rescinded
- Heroku deploys are quicker now with a single line command
- Add permission to view decisions
- Email invitation changes can now be saved
- Added billing role
- Can view old versions of figures and supporting information
### Changed
- Upgrade to ruby 2.2.4
### Deprecated
### Removed
### Fixed
- New billing institutions will now be added in alphabetical order
- Fixed race condition between creating a token, and requesting it when creating or replacing attachments.
### Security

## [1.23.0] - {2016-08-16}
### Added
- Abstract included in APEX export.
- Email staff when a paper is withdrawn
- Register Decision Task can now select from multiple letter templates.
- Adds a consistent way to handle variables in letter templates to support editability down the line.
- Registering a decision removes existing reviewers and open reviewer invitations
- Daily export of billing log
- Admins can view and edit journal roles assigned to users
- AE country is included in Apex export
- Discussion Topic title validation
### Changed
- Soft deleting questions and answers. Answers are retained even when questions are marked
  as deleted
### Deprecated
### Removed
### Fixed
- Attachments ( Figures, SI files, etc. ) will be available without downtime during deploy.
- Fixed comparing versions to highlight sentence changes instead of entire document
- Fix frontend code to allow for multiple rounds of revision
- Emails with html-like text ( <, >, etc) will no longer be truncated
- Display of initial decision infobox after creating paper and click of question mark icon
### Security

## [1.5.0] - {2016-07-20}
### Added
- Cover Letter tasks are now versioned
- Front matter reviewer reports are included in "ALL REVIEWS COMPLETE" paper tracker queries.
### Changed
### Deprecated
### Removed
### Fixed
- Require only a single click to register a decision
- Reviewer recommendations display full reason in accordion and workflow view.
### Security

## [1.4.18] - {2016-07-06}
### Added
- Autosuggested at-mentions in discussion topics
- Reviewers can decline invites without an Aperta account and without having to sign in
### Changed
### Deprecated
### Removed
### Fixed
- Versioning bar now appears again in versioning mode
### Security

## [1.4.17] - {2016-06-24}
### Fixed
- Tasks were not rendering correctly on some manuscript pages
- Manuscript and accordion scroll independently
## [1.4.16] - {2016-06-22}
### Added
- Ability for invited reviewer to provide decline reason and suggested
  reviewers when declining invitation.
- Ability to remove user roles via CSV file.
### Changed
- The Figure task has been reworked.  It's now much simpler to reorder figures after uploading.
### Deprecated
### Removed
### Fixed
### Security

## [1.4.15] - {2016-06-15}
### Added
- Activity feed items for withdraw and reactivate of a manuscript
- Title and Abstract task to allow internal staff to view and edit the
  title and abstract of any paper.
### Changed
- Institutional accounts are not pulled from a static list for easier updating
### Deprecated
### Removed
- Notification when an invitation was recinded
### Fixed
- Ad-hoc cards on manuscript manager templates can be edited
- Figures placement improvements
### Security

## [1.4.14] - {2016-06-08}
### Added
- Aperta validates its environment when booting and fails fast with human
  readable error messages when not-valid. This is a non-user facing addition.
- Added The Francis Crick Institute to institutional accounts
- Added Front Matter Reviewer Report for non-Research Article papers. Can be enabled/disabled by a journal admin when editing a Manuscript Manager Template.
### Changed
- Replaced EM GUID as a value that we export in the billing log in favor of NED
  ID. Sent NED ID and email for corresponding author in billing log
- Updated dois to the format 10.1371/journal.pbio.2000001 instead of
  10.1371/pbio.2000001
- Allow all characters in usernames
### Deprecated
### Removed
### Fixed
### Security

## [1.4.13] - {2016-05-31}
### Added
### Changed
- Show discussion participants' emails when selecting and on hover
### Deprecated
### Removed
- epub conversion and download
### Fixed
- EPS file previews no longer have inverted colors
- Figure placement is now much more flexible with respect to delimiters
- When uploading multiple figures, figures will now place more reliably
### Security

## [1.4.12] - 2016-05-25
### Added
- Generates a multiple line billing log file csv based on accepted papers that integrates EM GUID and
  information from various cards
### Removed
- Removed University of Ottawa as an institutional account participant
- Invitations can no longer be assigned via invitation codes.
### Fixed
- Fixed figures in PDFs spanning multiple pages

## [1.4.11] - 2016-05-19
### Fixed
- Fixed errors during PDF generation

## [1.4.10] - 2016-05-18
### Added
- Diffing of Reviewer Candidates
- Authors will see the feedback form whenever they submit a paper
- Add manifest to Apex export
- Apex export will include title and DOI of applicable related articles
- Add basic paper information to task overlay header
### Changed
- Update RTC and FTC text.
- Billing task institutions and countries synced with EM

## [1.4.9] - 2016-05-13
### Deprecated
### Removed
### Fixed
### Security

## [1.4.9] - 2016-06-13

### Fixed
-Fixed bug preventing changes for author card from being completed

## [1.4.8] - 2016-05-12

### Added
- Related Articles task
- Templates for devs creating new tasks
### Removed
- Abstract from reviewer invite email footer
### Fixed
- Prevent errors while adding discussion participants
- Properly switch between inviting by user and inviting by email

## [1.4.7] - 2016-05-06

### Changed
- Removed ability of the author/collaborator to manage collaborators

## [1.4.6] - 2016-04-29
### Added
-

### Changed
-

### Deprecated
-

### Removed
-

### Fixed
- Ensure the entire manuscript displays if it is re-uploaded with extant figures

## [1.4.5] - 2016-04-27
### Added
- Reviewers can be removed using the Assign Team card
- Freelance editors can be assigned as Cover Editor and/or Handling Editor
- Staff Admins can edit tasks even in paper states where the task is normally
  uneditable by authors

### Changed
### Deprecated
### Removed
- Sending of email to Academic Editor on paper resubmission

### Fixed
- Ensure that cards created after paper creation have the correct permissions
- Prevent duplication errors in generating new DOIs
- Ensure that Supporting Information no editable when the paper is editable

### Security

## [1.4.4] - 2016-04-05
### Added
- Added a loading state for manuscript conversion
- Authors card supports diffing

### Changed
- Mentions in discussions are now case-insensitive

### Removed
- Sending of email to Academic Editor for completed review

### Fixed
- Problem with discussion reply attribution not showing up
- Staff members should now be able to send manuscripts to apex

## [1.4.3] - 2016-04-05
### Added
- Attachments to Revise Manuscript Task
- New columns added to Paper Tracker to display publishing status, Handling Editor and Cover Editor
- Funders now have an "additional comments" field
- Email report to admin counting papers in states
- Authors card supports diffing

### Changed
-

### Deprecated
-

### Removed
- Roles section of Admin page removed to avoid confusion since it only applied to old roles
- Flow Manager

### Fixed
- PDF generation now works when a paper has figures.
- Single-sign-on sessions should now properly end upon Aperta logout
- Problem with discussion reply attribution not showing up

### Security
-

## [1.4.2] - 2016-03-24
### Added
- Figures display in the manuscript
- Manuscript editorial state is updated on SFDC on submit, accept, reject, withdraw
- Group Author form on Authors task

### Changed
- Institution field will search as you type
- The Assign Team card has been updated to work with the new roles and permissions
- PLOS branding for login page, dashboard, manuscript page and workflow page

### Deprecated
-

### Removed
- Appeal button
- Figure caption (temporary)
- Password reset buttons

### Fixed
- Document upload success message now displays to the uploader, not the creator of a paper.

### Security
-

## [1.4.1] - 2016-03-08
### Added
- Adding shared saved searches to Paper tracker
- Applying new Roles and Permissions to Invite Editor Task
- Applying new Roles and Permissions to Production Metadata Task
- Applying new Roles and Permissions to Reviewer Candidates Task
- Applying new Roles and Permissions to Competing Interests Task
- Applying new Roles and Permissions to Upload Manuscript Task
- Applying new Roles and Permissions to Financial Disclosure Task
- Applying new Roles and Permissions to Final Tech Check Task
- Applying new Roles and Permissions to Cover Letter Task
- Applying new Roles and Permissions to Register Decision Task
- Applying new Roles and Permissions to Authors Task
- Creating Cover Editor role
- Creating Bio Invite AE Task

### Changed
- Authors Task UI changes and new questions
- Update manuscript fields sent to Salesforce
- Update PFA case fields sent to Salesforce

### Deprecated
-

### Removed
-

### Fixed
- Fixing an issue where all Discussion Topics appeared across all Papers
- Fixing copy and pasting of line breaks in Discussion Replies
- Updating broken links in Figures, Data Availability and Competing Interests Tasks
- Replacing the current descriptive text under Question 5 with the descriptive text under Question 4

### Security
-

## [1.4.0] - 2016-02-23
### Added
- Paper tracker search: by user and role, anyone, no one, and any role
- Billing Task validations
- Applying new roles and permissions to paper tracker
- Applying new roles and permissions to paper discussions
- Applying new roles and permissions to ethics card
- Academic Editor role for the PLOS Bio journal has been implemented with new roles and permissions
- Journal admins will receive an email if a manuscript fails to be sent to Salesforce after ~1.5 days

### Changed
- The Authors card now enforces validations
- The Supporting Information now enforces validations

### Fixed
- Fixing an issue where the content stored on an adhoc card was not be preserved
- Fixing an issue where an email was not being sent out to collaborators when they were added to a paper

## [1.3.9] - 2016-02-10
### Added
- Paper tracker search: by title, DOI, status, and task status

### Changed
- The billing card has been moved to the new roles and permissions framework. This is being inherited by many of the other cards as well.

## [1.3.8] - 2016-01-26
### Added
- New component attachment-manager to handle attachments, to be used on used on multiple cards.
- New component attachment-item to be used within attachment-manager, to handle previews of attachment, replace and deletion
- New component s3-file-uploader that wraps the jquery fileupload plugin to make direct uploads to Amazon S3
- Email notifications on discussion forum posts and participations
- Discussion Notifications displayed when user is added as participant
- Ability to upload multiple Related Manuscripts to indicate what information has been published elsewhere

### Changed
- Revamped the Supporting Information task.
- Figures use non-expiring resource proxy urls
- Additional Information card uses standard file uploader

## [1.3.7] - 2015-12-29
### Added
- Ability to diff form based cards, such as the Additional Information card, in versioning mode

### Changed
- NestedQuestions have unique identifiers

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


