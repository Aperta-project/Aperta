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

---

#### Code Review Tasks:

Reviewer tasks:

- [ ] I skimmed the code; it makes sense
- [ ] I read the code; it looks good
- [ ] I ran the code (in the review environment or ci)
- [ ] I performed a 5 minute walkthrough of the site looking for oddities
- [ ] I have found the tests to be sufficient and complete
- [ ] I agree the code fulfills the Acceptance Criteria
- [ ] I agree the author has fulfilled their tasks
- [ ] All asserts output the failing attribute, ideally in context
- [ ] All functions, classes have docstrings with all params and returns specified
- [ ] Does not rely on dynamic, or excessively positional locators (or bug filed)
- [ ] Does not rely on explicit sleeps except where absolutely necessary or dictated by the 
        complexity of working around such use. Comment why when used.
- [ ] Follows first PLOS style guidelines for Python, then PEP-8

#### After the Code Review:

Reviewer tasks:

- [ ] I have moved the ticket forward in JIRA
