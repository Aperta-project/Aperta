JIRA issue: link-to-jira

#### What this PR does:

Explain in a few sentences what functionality changed, and how. Don't be afraid
to give a little extra detail. The Reviewer is going to read the original
ticket, but this can point them in the right direction.

Can your changes be *seen* by a user? Then add a screenshot. Is it an
interaction?  Perhaps a quick recording?

#### Notes

Are there any surprises? Anything that was particularly difficult, or clever, or
made you nervous, and should get particular attention during review? Call it
out. Does the reviewer have to run a rake task?


#### Major UI changes

Were there major UI changes? Add a screenshot here -- and please let the QA team know that changes are imminent. They would love a little extra time to prepare the QA test suite.

---

#### Code Review Tasks:

Author tasks:  

- [ ] If I created a migration, I updated the base data.yml seeds file. [instructions](https://developer.plos.org/confluence/display/TAHI/Seeds+maintenance)
- [ ] If a data-migration rake task is needed, the task is found in `lib/tasks/data-migrations` within the `data:migrate` namespace. Example task name: `aperta_9999_migration_description`
- [ ] If I created a data-migration task, I added copy-pastable instructions to run it on heroku to [the confluence release page](https://developer.plos.org/confluence/display/TAHI/Deployment+information+for+Release)
- [ ] If I modified any environment variables, I made a pull request to change the files on the [molten repo](https://github.com/PLOS/molten/tree/dev/pillar/aperta)
- [ ] If I made any UI changes, I've let QA know. 

Reviewer tasks:

- [ ] I skimmed the code; it makes sense
- [ ] I read the code; it looks good
- [ ] I ran the code (in the review environment or locally)
- [ ] I performed a 5 minute walkthrough of the site looking for oddities
- [ ] I have found the tests to be sufficient
- [ ] I like the CHANGELOG entry
- [ ] I agree the code fulfills the Acceptance Criteria
- [ ] I agree the author has fulfilled their tasks

#### After the Code Review:

Author tasks:

- [ ] The Product Team has reviewed and approved this feature
