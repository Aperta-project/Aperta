# So You Think You Can Deploy?

Welcome to the Deployment Guide. We are going to discuss the steps necessary to
complete a full deployment cycle, from development, through release testing,
production release, and how to handle hotfixes.

This guide is designed so that everyone on the team can be familiar and
comfortable with each step in the deploy cycle. It is preferrable that most of
the deployment tasks are performed as a pair. It helps reduce mistakes as well
as transfer this knowledge more effectively.

# Before a Deploy

It's been a few weeks since the last deployment. The developers have been
[working efficiently](./git-process.txt) to produce high quality code. As they
merge their accepted feature branches into `master`, the QA team takes over and
begins integration and regression testing on the staging environment.

The Product Team begins to make the final calls on which features and bugfixes
are the last to make it into the next release. This is the final call for all
PRs to board the release train. There will normally be a meeting between the
Product Team, QA, and any developers with PRs nearing final approval.

#### Sample Deploy Meeting:

**Jeffrey (QA):** "We really would like APERTA-5432 to make it into this release. It
fixes an important bug and Aaron says it is nearly finished Code Review."

**Alex (Dev):** "Yeah, there's no reason that couldn't be sent over to Product Owner
Acceptance after this meeting."

**Gina (Product Team):** "Great, I'll eagerly await the Review link."

**Glenn (Product Team):** "Do we need to get the new Seed Data in?"

**Jeffrey (QA):** "No, that isn't necessary."

**Matt (Dev):** "There's one last PR that we wanted to get in. TechCheck is
currently broken. Zach is reviewing that now, it should be done in an hour or
two."

**Glenn (Product Team):** "Yeah, that is an important one. We want that, but we
don't want to hold up the release."

**Matt (Dev):** "Okay, I can submit a hotfix to the release branch as soon as its
done. We don't hold anything up and the release will contain the fix."

**Gina (Product Team):** "Great, that sounds like a plan. Anyone else have
anything?"

# Cut a Release Branch

Now that the final call has been made on which features make it in, it's time to
cut the release. We are going to create a new release branch from `master`.

### The Simple Case: Latest Master is Releasable

First we need to checkout the `master` branch and pull down the latest changes.
It is important to make sure that we have the latest code and cut the release
from the right place:

```bash
$ git checkout master
$ git pull
$ git status
On branch master
Your branch is up-to-date with 'origin/master'.
nothing to commit, working directory clean
...
$ git show HEAD
git show HEAD
commit e1623b43dea4c68c33768e2ba312dc08d442700e
...
```

Now that we think we have the latest code on our local `master` branch, double
check that. Make sure the working directory is clean. The currently checked out
SHA **must** match the SHA from `origin/master`. If it doesn't that means we
aren't up to date and we will branch from the wrong commit.

Let's double check that we have the last few PRs we needed, and not any others:

```bash
$ git log --oneline --merges
e1623b4 Merge pull request #1834 from Tahi-project/bugfix/dashboard-paper-title
9035265 Merge #1813 into master
ff599bb Merge pull request #1828 from Tahi-project/bugs/APERTA-3495-reviewer-candidates
b88e089 Merge pull request #1831 from Tahi-project/bugs/APERTA-5426-slow-page-load-nested-questions
c8d7f31 Merge pull request #1818 from Tahi-project/feature/APERTA-3522-add_roles_to_dashboard
1f708e1 Merge pull request #1829 from Tahi-project/bugs/APERTA-3495-author-labels
f7e07ed Merge pull request #1789 from Tahi-project/chore/remove-visual-editor
35b895d Merge pull request #1824 from Tahi-project/feature/5377-one-less-question
2a04a2d Merge pull request #1816 from Tahi-project/chore/add-git-process-docs
```

Feel free to use your favorite`git log`-ish command, or Git gui, to perform this
check. This is a final sanity check before we cut our release. It is expected
that you, as the responsible Deployer that you are, are passingly familiar with
the most recent PRs being worked on.

If there are missing PRs, try:

- `git pull`ing again. There might have been a conflict when pulling. Or
  perhaps you overlooked a network error?

- Maybe the PR hasn't actually been merged yet. Go check the PR page and
  make sure it has been merged. Miscommunication around who pushes the Merge
  Button can lead to delays.

If there are extra commits that shouldn't be there then skip ahead the section
on "Less Simple Case: Latest Master Contains Unreleaseable Commits".

The last step before creating a release branch is to double check the actual
release number. This is going to be the previous release + 0.1. If our last
release was 1.3, the next release is 1.4. This strategy of 1.(X+1) isn't
difficult, but it doesn't hurt to make sure you've got the number right.

Assuming you've reached this point, you've approved your `master` branch's
contents as ready for release. Branches are cheap, so let's do that now:

```bash
$ git checkout --branch release/1.4
$ git push origin release/1.4
```

Boom! You've cut the release. That was easy! Any hotfixes be applied +to the
`release/1.4` branch from this point out. Now you are ready to start deployment,
see "Deploy the Release Candidate" below.

### Less Simple Case: Latest Master Contains Unreleaseable Commits

To be written...

# Deploy the Release Candidate

Now that we have a release branch cut, we can deploy it to the release-candidate
environment. This is where the final pre-release testing will take place.
Defects discovered here will be logged, prioritized, and possibly hotfixed for
this release.

#### Deployment Notes

First thing to do is check the [Deployment
Notes](https://developer.plos.org/confluence/display/TAHI/Deployment+information+for+Aperta+v.1.3.4)
for any extra deployment tasks.  This will commonly be one-off rake tasks that
need to be run in order to migrate data. These are important to keep track of
since they commonly will be *required* for the site to function properly after a
schema or functionality change. This list is updated for each deploy by
developers who require such tasks to be run as part of their feature
development.

Example:

1. `heroku run rake one_off:migrate_participations_activity_to_workflow --app
   APP_NAME`
1. `heroku run rake data:migrate:questions-to-nested-questions:migrate_all --app
   APP_NAME`

Keep track of these. They will need to be run manually after the migrations are
run.

#### Deployment Permissions

The release-candidate environment is currently hosted on Heroku. As such, you
will need to make sure that you have the proper permissions to deploy to the
release-candidate Heroku App. Again, sounds basic, but it's a good thing to
check. The Heroku Toolbelt has an inconvenient habit of logging you out when you
least expect it.

#### Watch the Logs

We use Papertrail to aggregate logs for each of the environments. Since we're
about to deploy, let's open up the logs for the release-candidate environment
*before* the deploy. This saves time and helps catch any hiccups in the deploy
process before they spiral out of control.

#### Continuous Integration

Remember when we pushed our branch a few steps back? Well our CI server runs all
the tests on all new branches. If you are following along with this guide
closely, it might even be close to being finished by now. Just make sure the
tests pass before you push broken code to the release-candiate environment and
announce it to everyone.

#### Warn the Team

Let everyone know you're about to deploy. Open up Hipchat and make sure to use
the (siren) emoji for maximum awareness:

> I'm going to deploy the 1.4 Release to release-candidate! (siren)

#### Push It

It's finally time.

```bash
$ git push release-candidate release/1.4:master
$ heroku run rake db:migrate --app tahi-release-candidate
$ # run any tasks from the Deployment Notes
```

Watch the logs. Make sure things work correctly. After all the tasks are run,
open it up in your browser. Login. Make sure it works at a basic level. Even
these basic manual checks save you from an embarassing release announcement.

#### Declare Release Victory

Let everyone know you're finished deploying. Open up Hipchat and make sure to use
the (success) emoji for maximum celebration:

> I've finished deploying the 1.4 Release to release-candidate! (success)

# Apply a Hotfix to Release Candidate

# Deploy Production

# Apply a Hotfix to Production

# Summary

Now that you've reached the end, here's a template for a Deploy Checklist. This
is the Clif Notes version of the Deployment Guide.

#### Cut a New Release

```
- [ ] Determine the last PRs for the Release
- [ ] Update local `master` to match `origin/master`
- [ ] `$ git checkout --branch release/1.X`
- [ ] `$ git push origin release/1.X`
```

#### Deploy to Release Candidate

```
- [ ] Grab the Deployment Notes
- [ ] Open Papertrail
- [ ] Wait for CI to Pass
- [ ] Warn the Team in Hipchat (siren)
- [ ] `$ git push release-candidate release/1.4:master`
- [ ] `$ heroku run rake db:migrate --app tahi-release-candidate`
- [ ] Execute tasks from Deployment Notes
- [ ] Declare Victory in Hipchat (success)
```

#### Deploy to Production

```
- [ ] Grab the Deployment Notes
- [ ] Open Papertrail
- [ ] Wait for CI to Pass
- [ ] Warn the Team in Hipchat (siren)
- [ ] `$ git push lean-workflow release/1.4:master`
- [ ] `$ heroku run rake db:migrate --app tahi-lean-workflow`
- [ ] Execute tasks from Deployment Notes
- [ ] Declare Victory in Hipchat (success)
```
