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

- [ ] I read the code; it looks good
- [ ] I ran the code (against a review environment, ci or other common environment)
- [ ] If the PR changes code on which any other tests are dependent, I ran the dependent tests
- [ ] I have found the tests to address all explicit and implicit AC or other test standards
- [ ] I agree the author has fulfilled their tasks
- [ ] All asserts output the failing attribute, ideally in context
- [ ] All functions, classes have docstrings with all params and returns specified
- [ ] Does not rely on dynamic, or excessively positional (more than two relations) locators
- [ ] Does not rely on explicit sleeps except where absolutely necessary or dictated by the 
        complexity of working around such use. Comment why when used.
- [ ] Follows first PLOS style guidelines for Python, then PEP-8
- [ ] Code is implemented in a Python 2/3 agnostic way
- [ ] Code follows implementation guidance at: https://confluence.plos.org/confluence/display/FUNC/Implementing+your+python+end-to-end+tests

#### After the Code Review:

Reviewer tasks:

- [ ] I have moved the ticket forward in JIRA
