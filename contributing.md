# Interested in making Tahi better? Awesome :)

Please email us and say hello: TODO


## Contributing

When creating a new pull request, please paste in the following rubric. Please
**delete todo list items that** you feel **do not apply** to your pull request
/ review.

**If you are a first-time contributor you can ignore this rubric; your reviewer
 will help you along**

    ## Pull Request Checklist
    - [ ] ask yourself: is this PR complicated enough that you should write
          integration tests?
    - [ ] do tests pass at every commit? (to preserve ease of `git-bisect`)
    - [ ] ask yourself: do you feel that things are well abstracted?
    - [ ] do a self code review (read through `git diff` or the github UI)
    - [ ] complete all relevant todos in your code
    - [ ] self QA (make sure the app still works, along with your change)
    - [ ] get review from a team-member with knowledge of this codebase area
    - [ ] **team-member said ship it! (:ship: it)**
    - [ ] self QA again Chrome
    - [ ] self QA again Firefox
    - [ ] self QA again Safari
    - [ ] self QA again IE
    - [ ] do any changes need to be made to prod before a deploy? List them in
          the `deployer checklist`
    - [ ] the tests are passing for this branch on semaphore
    - [ ] merge! Celebrate your success!

    ## Reviewer Checklist
    - [ ] is syntax consistent with rest of code-base?
    - [ ] are database access patterns relatively efficient?
    - [ ] are client-side access patterns
    - [ ] ember style

    ## Deployer Checklist
    Changes to Tahi are deployed automatically to staging whenever tests for
    the `master` branch are passing. These items really only apply for deploys
    to `currents`, and `demo` (we don't have a production yet).
    - [ ] **>>list changes here that need to be made to prod before a deploy<<**
    - [ ] ideally these changes can be made by running a rake task or script
    - [ ] you are deploying in the morning
    - [ ] you are deploying on Monday, Tuesday, Wednesday, or Thursday.
    - [ ] you are deploying your own code
    - [ ] did the deploy
    - [ ] you are watching the BugSnag slack channel and/or `heroku logs --tail`
    - [ ] you announced the deploy with a few words summary to chatrooms
    - [ ] you have opened https://dashboard.heroku.com/apps for rollback

At some point we may consider adding this bullet point to the list:

    - [ ] changelog has been updated

codeofconduct
=============

####Tahi's Code of Conduct

*[borrowed from Code for America][cfa]*
[cfa]:https://github.com/codeforamerica/codeofconduct

The Tahi community expects that Tahi network activities, events, and digital forums:

1. Are a safe and respectful environment for all participants.
2. Are a place where people are free to fully express their identities.
3. Presume the value of others. Everyone’s ideas, skills, and contributions have
  value.
4. Don’t assume everyone has the same context, and encourage questions.
5. Find a way for people to be productive with their skills (technical and not)
  and energy. Use language such as “yes/and”, not “no/but.”
6. Encourage members and participants to listen as much as they speak.
7. Strive to build tools that are open and free technology for public use. Activities that aim to foster public use, not private gain, are prioritized.
9. Work to ensure that the community is well-represented in the planning,
  design, and implementation of academic tech. This includes encouraging
  participation  from women, minorities, and traditionally marginalized groups.
10. Actively involve community groups and those with subject matter expertise in
  the decision-making process.
11. Ensure that the relationships and conversations between community members,
  academia, and community partners remain respectful, participatory, and
  productive.
12. Provide an environment where people are free from discrimination or
  harassment.

Tahi reserves the right to ask anyone in violation of these policies not to participate in Tahi network activities, events, and digital forums.

####Tahi's Anti-Harassment Policy

This anti-harassment policy is based on <a
href="http://geekfeminism.wikia.com/wiki/Conference_anti-harassment/Policy">the
example policy</a> from the Geek Feminism wiki, created by the Ada Initiative
and other volunteers.

This policy is based on several other policies, including the Ohio LinuxFest
anti-harassment policy, written by Esther Filderman and Beth Lynn Eicher, and
the Con Anti-Harassment Project. Mary Gardiner, Valerie Aurora, Sarah Smith, and
Donna Benjamin generalized the policies and added supporting material. Many
members of LinuxChix, Geek Feminism and other groups contributed to this work.

---

All Tahi network activities, events, and digital forums and their staff,
presenters, and participants are held to an anti-harassment policy, included
below.

Tahi is dedicated to providing a harassment-free experience for everyone
regardless of gender, gender identity and expression, sexual orientation,
disability, physical appearance, body size, race, age, or religion. We do not
tolerate harassment of staff, presenters, and participants in any form. Sexual
language and imagery is not appropriate for any Tahi event or network activity,
including talks. Anyone in violation of these policies may expelled from Tahi
network activities, events, and digital forums, at the discretion of the event
organizer or forum administrator.

Harassment includes but is not limited to: offensive verbal or written comments
related to gender, gender identity and expression, sexual orientation,
disability, physical appearance, body size, race, religion; sexual images in
public spaces; deliberate intimidation; stalking; following; harassing
photography or recording; sustained disruption of talks or other events;
inappropriate physical contact; unwelcome sexual attention; unwarranted
exclusion; and patronizing language or action.

If a participant engages in harassing behavior, the organizers may take any
action they deem appropriate, including warning the offender or expulsion from
Tahi network activities, events, and digital forums.

If you are being harassed, notice that someone else is being harassed, or have
any other concerns, please contact a member of the event staff or forum
administrator immediately. You can contact them at [EVENT ORGANIZER/FORUM
ADMINISTRATOR EMAIL AND PHONE NUMBER]. Event staff or forum administrators will
be happy to help participants contact hotel/venue security or local law
enforcement, provide escorts, or otherwise assist those experiencing harassment
to feel safe for the duration of the event.

If you cannot reach an event organizer or forum administrator and/or it is an
emergency, please call 911 and/or remove yourself from the situation.

You can also contact Tahi about harassment at mike.mazur å† neo.com and feel
free to use the email template below. Tahi staff acknowledge that we are not
always in a position to evaluate a given situation due to the number of events
and the fact that our team is not always present. However, we are hopeful that
by providing these guidelines we are establishing a community that jointly
adheres to these values and can provide an environment that is welcoming to all.

We value your attendance and hope that by communicating these expectations
widely we can all enjoy a harassment-free environment.

####Email Template for Anti-Harassment Reporting

SUBJECT: Safe Space alert at [EVENT NAME]

I am writing because of harassment at a Tahi Communities event, (NAME, PLACE,
DATE OF EVENT).

You can reach me at (CONTACT INFO). Thank you.
