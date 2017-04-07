# Change Log
All notable changes to this project will be documented in this file. Follow
guidelines from here: https://github.com/olivierlacan/keep-a-changelog

## ## [x.x.x] - {yyyy-mm-dd}
### Added
### Changed
### Deprecated
### Removed
### Fixed
### Security

## ## [1.40.0] - {2017-04-06}
### Added
* Inject the Git Commit ID in <meta> tag for easier debugging
* Similarity Check Task Card (UI Only)
### Changed
* Edited CSS (color and hover features) for manuscript list on dashboard to be
* Revise Manuscript card changed to Response to Reviewers, it's attachments are now owned by decisions.
more user friendly.
* Updated mathjax cdn to use cloudflare.
* The confirmation dialogues for removing cards from a paper and a manuscript manager template are
now clearer about what's going to occur
### Deprecated
### Removed
### Fixed
### Security

## ## [1.39.1] - {2017-03-30}
### Added
### Changed
### Deprecated
### Removed
### Fixed
* Funders can now be added and updated
### Security

## ## [1.39.0] - {2017-03-29}
### Added
* The footer discussion cannot be seen by Reviewers and other external users in
  individual card view
* Billing staff now have more viewing access than just to the Billing card
* Users can now save lists on Safari for Ad Hoc cards
* Reviewer Report status available on invitation list
### Changed
* File name for PDF Downloads have been updated to follow the format "[short doi] - [author last name] - [version].pdf"
### Deprecated
### Removed
### Fixed
* Fixed bug that always returned the latest version of a manuscript regardless of the version that was requested.
### Security

## ## [1.38.0] - {2017-03-09}
### Added
* Users can now change the initial participants on a discussion topic.
* Source file is sent to APEX along with PDF manuscripts
* The manuscript upload card prompts for a backing source file if a PDF manuscript is uploaded.
* Source files show can be downloaded
* Added "Confirm Authorship" button to email to co authors.
* Added PDF submissions for PLOS Biology
* Require source files on PDF manuscripts that are in revision or have major versions greater than 0
* Warn users to save work externally when server health check fails
### Changed
* Changed new manuscript filetype text for pdf-enabled journals to mention the need for a sourcefile upload backing pdf manuscripts
* Temporarily disabled coauthor notification
* Change in figure task workflow to remove period from title
### Deprecated
### Removed
### Fixed
### Security

## ## [1.37.0] - {2017-02-16}
### Added
* Users can now change the initial participants on a discussion topic
* Feature flags for hiding/showing partial features.
### Changed
* Reset review status on revision submission event
* Don’t automatically destroy resource tokens
* Changed figure cards for PDF submissions
* Changes to topic creation (See APERTA-8247)
### Deprecated
### Removed
### Fixed
* Handle submission as a single transaction (More details in APERTA-8415)
### Security

## ## [1.36.1] - {2017-02-09}
### Added
### Changed
### Deprecated
### Removed
### Fixed
* Reviewer Reports that were accepted, but not submitted prior to 1.36.0 were not covered in the previous data migration.
  This fix addresses those issues with an additional data migration
### Security

## ## [1.36.0] - {2017-02-07}
### Added
* Logging outbound email sends to database, including status and forensics, to troubleshoot silent failures
* Aperta can now use the title, abstract, and body HTML extracted from PDFs.
* Display review status at the top of the task
### Changed
* Users can download previous versions of a Manuscript
### Deprecated
### Removed
### Fixed
* Users can now select and copy text from invitation letters when there is more than one invitation.
* Paper submissions that are invalid because of missing images are no longer allowed to successfully be saved.
  (Submission & initial submission are now transactions, so failing activity feed entries cause submission to fail.)
### Security

## ## [1.34.0] - {2017-01-06}
### Added
* Added warning notifications when browser clients are unable to establish a WebSocket connection
* The first affiliate field on the billing task is now required
* Added a PDF viewer in the manuscript versions view when the "Now Viewing" version is a PDF file
### Changed
* The sign-on page has more specific rules regarding notifying users that they're using unsupported browsers
### Deprecated
### Removed
### Fixed
* ORCID-Connect works with users with accented letters in their names.
### Security

## ## [1.33.0] - {2017-01-03}
### Added
### Changed
* The Discussion participant list displays names in place of avatars
* ORCID-Connect button will re-enable when the ORCID popup is closed before authenticating with ORCID.
* Changes are automatically saved in the Intitial Decision Task
### Deprecated
### Removed
### Fixed
* Show supporting information file upload errors to users
* Recipients are no longer accidentally shared between different email blocks on the same adhoc task
* Deleting a paper tracker query now updates the dashboard
### Security

## ## [1.32.0] - {2016-12-16}
### Added
* Added the ability for billing staff to view the paper tracker.
* Added the ability to upload pdfs if the pdf_allowed feature flag is flipped on
* Added the ability to upload pdfs via the manuscript upload task
* Added a PDF viewer to display uploaded PDF manuscripts
* Withdrawn banner now shows on workflow view.
* Reviewer numbers will be automatically assigned to newly created papers
* Added cap cleanup:dumps & rake db:dump:cleanup
* An attachment analysis report will be emailed to the Aperta Dev Team each day so we can identify attachment processing failures sooner.
* Staff can now view connected ORCID accounts for paper creators
### Changed
* Invitations no longer enter their edit state by default
* Updated URLs to expose the manuscript's short DOI.  Papers can now be referenced
  by /papers/JOURNAL.DOI .  The app was updated to use these as the preferred links.
* A user can now mark a card as incomplete at any time when it is in an editable state
* The entire DOI prefix (publisher + journal) is checked for uniqueness instead of
  the parts.
### Deprecated
### Removed
### Fixed
* Do not check validations in DownloadAttachmentWorker
* Deleting all the text for a question's answer will no longer cause an error on subsequent
  changes to that that answer.
* Attached images with capitalized filenames will now preview correctly

## ## [1.31.1] - {2016-12-7}
### Fixed
* Emails will be sent to the inviter for when a reviewer accepts/declines an invitation and does not have an account in Aperta.
* Add back missing attachment blocks for many ad hoc tasks
* Recipients can be properly removed from adhoc emails.
* Do not send emails to Staff Admin(s) when Salesforce sync retries are exhausted; reinstate Salesforce syncing errors
  to email Site Admin(s) instead.

## ## [1.30.1] - {2016-11-29}
### Added
### Changed
### Deprecated
### Removed
### Fixed
- do not send journal staff admins emails for paper submission, editor invite accepted, tech check fixed events, or salesforce sync'ing errors
- Do not sync paper data with salesforce if the paper has not been submitted.
### Security

## [1.30.0] - {2016-11-18}
### Added
- Early Article Posting cards have been added to workflows, to allow authors to opt into
  allowing manuscripts to be published before all proofreading and copyediting is done.
- Invitations can now be reordered through drag and drop. This also enforces
  rules automatically for which invitations can be reordered and into which groups
- A user can connect their ORCID account with their author profile via the Authors cards on a manuscript
- Display of article type in invitations
- Caching of unsaved Discussion responses
- Ad-hoc cards have editing and managing permissions
- ORCID validation on the Authors Task
- ORCID IDs are included in the metadata export to Apex
- ORCID IDs can only be removed by PLOS staff
### Changed
### Deprecated
### Removed
- Removed 'Assign Admin' card
- Removed 'Available Task Types' section in journal administration
### Fixed
- Emails are properly rendered in all clients
### Security

## [1.29.0] - {2016-11-03}
### Added
* A user can connect their ORCID account with their author profile via the Authors cards on a manuscript
### Changed
### Deprecated
### Removed
### Fixed
### Security

## [1.28.0] - {2016-10-21}
### Added
- Manuscript diffing has been enhanced. Words that have changed are now highlighted
  inside of changed sentences.
### Changed
- Updated Figures, Supporting Information Files, and Title and Abstract to use new R&P
- Cover Editors and Handling Editors can no longer view or edit the Billing card
- Cover Editors and Handling Editors can no longer edit any Reviewer Reports
### Deprecated
### Removed
### Fixed
- Reporting Guidelines: PRISMA uploads for systematic review and meta-analyses work again
- Uploaded files by dropping them into the browser now longer triggers all visible file uploaders
- PLOS Biology name is no longer hard coded in letter templates
- Fixed issue where roles couldn't be assigned in the admin page in some journals
- Fixed ad-hoc email component to expand properly
- Fixed scrolling on manuscript page
- Notifications when FTP uploads fail are now being emailed out to the Journal Staff Admins for associated papers
### Security

## [1.27.0] - {2016-10-6}
### Added
### Changed
### Deprecated
### Removed
### Fixed
- Feedback with attachments will now send successfully
## Security

## [1.26.0] - {2016-09-22}
### Added
- Users can cancel figure and adhoc uploads
- Uploads that fail processing will show an error
### Changed
### Deprecated
### Removed
### Fixed
- At-mentions in discussions are no longer shown as escaped html notification emails
- Users can once again add group authors
- Users can cancel manuscript withdraw again
### Security

## [1.25.1] - {2016-09-16}
### Added
- Rescinding invitations will not delete them from the UI
- Show statuses for when invitations were rescinded
- Ad-Hoc cards allow any type of file upload
### Removed
- Users can no longer add system-generated tasks (Revise Manuscript, Changes For Author, Reviewer Report) to a workflow
### Fixed
- Journal admin: the button to add a new MMT works again
- Can rescind invitations again

## [1.25.0] - {2016-09-14}
### Added
- Email invitation changes can now be saved
- Added billing role
- Keeps all uploaded manuscripts
- Can view old versions of figures and supporting information
- Aperta is now configured to clean out temporary files every 24 hours on the backend.
- Queuing Alternates and subqueues for Invite Reviewers and Invite Editors tasks
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
### Changed
- Upgrade to ruby 2.2.4
- Change paper tracker submitted search fields from SUBMITTED to VERSION DATE, and FIRST SUBMITTED to SUBMISISON DATE.
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
