JIRA issue: https://jira.plos.org/jira/browse/APERTA-

#### What this PR does:

Explain in a few sentences what functionality changed, and how. Don't be afraid
to give a little extra detail. The Reviewer is going to read the original
ticket, but this can point them in the right direction.

Can your changes be *seen* by a user? Then add a screenshot. Is it an
interaction?  Perhaps a quick recording?

#### Special instructions for Review or PO:

Is there anything out of the ordinary in how the AC for the ticket needs to be evaluated?
Does the reviewer have to run a rake task? Is there specific seed data they should use?
If PO needs specific guidance on how to evaluate this feature please add that information to the JIRA ticket itself (add a link here if needed)

#### Notes

Are there any surprises? Anything that was particularly difficult, or clever, or
made you nervous, and should get particular attention during review? Call it
out. 


#### Major UI changes

Were there major UI changes? Add a screenshot here -- and please let the QA team know that changes are imminent. They would love a little extra time to prepare the QA test suite.

---

#### Code Review Tasks:

**Author tasks** (delete tasks that don't apply to your PR, this list should be finished before code review):

- [ ] If I made any UI changes, I've let QA know.
- [ ] If I changed the database schema, I enforced database constraints.
- [ ] If I created a migration, I updated the base data.yml seeds file. [instructions](https://developer.plos.org/confluence/display/TAHI/Seeds+maintenance)
- [ ] I have ensured that the Heroku Review App has successfully deployed and is ready for PO UAT.

If I modified any environment variables:
- [ ] I made a pull request to change the files on the [molten repo](https://github.com/PLOS/molten/tree/dev/pillar/aperta) {PR LINK}
- [ ] I double-checked the `app.json` file to make sure that the heroku review apps are still inheriting the correct environment variables from staging

If I need to migrate existing data:
- [ ] If a data-migration rake task is needed, the task is found in `lib/tasks/data-migrations` within the `data:migrate` namespace. Example task name: `aperta_9999_migration_description`
- [ ] If there are steps to take outside of `rake db:migrate` for Heroku or other environments, I added copy-pastable instructions to [the confluence release page](https://developer.plos.org/confluence/display/TAHI/Deployment+information+for+Release)
- [ ] I verified the data-migration's results on a copy of production data (complicated migrations should also have real specs)
- [ ] I've talked through the ramifications of the data-migration with Product Owners in regards to deployment timing
- [ ] If I created a data migration, I added pre- and post-migration assertions.

**Reviewer tasks** (these should be checked or somehow noted before passing on to PO):
- [ ] I read through the JIRA ticket's AC before doing the rest of the review
- [ ] I ran the code (in the review environment or locally). I agree the running code fulfills the Acceptance Criteria as stated on the JIRA ticket
- [ ] I read the code; it looks good
- [ ] I have found the tests to be sufficient for both positive and negative test cases

