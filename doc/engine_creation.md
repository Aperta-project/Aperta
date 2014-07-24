``` rails plugin new paper_reviewer --mountable ```

1.  Move engine to /engines
1.  Edit engine gemspec file
1.  Add engine to gemfile
1.  Add engine javascript assets to application.js
1.  Delete empty directories
1.  Move existing model to engines/xxxx
1.  move specs
1.  Wrap model in ```module PaperReviewer```
1.  Add engine serializer folder and move existing serializer
1.  Wrap serailzer in ```module PaperReviewer```
1.  Move javascript assets into engine (adapters, models, serializers, templates, views/overlays, controllers)
1.  edit Journal::VALID_TASK_TYPES
1.  edit lib/tasks/task_migrations.rb
1.  update create_default_manuscript_manager_template service class


Over the past few months, the Tahi project has gained a lot of experience in streamlining the workflow management of journal paper submissions.  As one of its primary goals, the project wants to allow other journals to leverage this code within their own institutions.

Primary goals:
* obvious extension points
* modular / composable architecture
* independent (non-coupled) components
* isolated testing (engines can be tested independently)

The current approach is for each Task to live as a Rails engine gem.  The idea is that a new journal wanting to leverage Tahi code can choose an assortment of Tasks that is useful in their workflow.  If there is a need for a custom Task, it can be created in a way that conforms to the behavior of a base Task.  Tasks are shared across multiple journals as gems.

After John and I extracted out two Tasks into engines (PaperReviewerTask, ReviewerReportTask) we found two primary limiations:

1.  Difficult third party extension and maintenance
2.  High cohesion between tasks and core models
3.  Inability to forsee what core API extension points should be exposed

*Difficult third party extension and maintenance*
Given the current approach, a new journal who wishes to use Tahi would most likely do the following:

1.  fork the existing tahi repo
2.  remove any standard gems they do not want
3.  add any other task engine gems they want
3.  make modifications to existing code by reopening classes and monkey-patching
4.  create new custom task engines

When the tahi core application makes changes such as new features or security patches, a developer for this journal would need to merge changes from Tahi into their personal repo.  There is an extremely high liklihood of conflicts and breakage due to customization.  In addition, there is no ability for versioning or determining what is a major or minor change that needs merged.  This will eventually lead to journals not accepting or desiring the changes from Tahi due to the hurdles in integrating them.

A possible *solution* to this issue is to flip the extraction of task engines on its head.  Instead of providing the Tahi as a standard rails application, extract all the core models into its own gem.  (Let's call this the 'Tahi Gem').  Instead of a journal forking the Tahi application, they would 'rails new' their own journal application.  They immediately becoming the owner of this project, rather than an inheritor of an existing one.  Next, they include the tahi gem which would include all the core Tahi models (paper, adhoc task, message task, journal, etc.).  All of these models would be properly namespaced to avoid conflict along with migrations, view templates, etc.  This gem is versioned which gives an immediate upgrade path.

This also gives the Tahi project team the ability to eat their own "dogfood".  Tahi core lives in its own gem.  PLOS becomes a separate repo that serves as a consumer journal of the tahi gem.  We begin to behave as one of the journals that we have a goal of eventually serving.  We also have a clearer dividing line as to "what is core tahi and what is PLOS specific?"  It's a win-win for us and for the third party journals.

*High cohesion between tasks and core models*
Currently, there are several related issues with cohesion.  The easiest one to talk about is Task testings.  One of the desired goals is to have tests for each engine run indepently.  Unfortunately, this means that unit tests will need to stub out core models and integration / feature tests are virtually impossible because it needs a core app present.

In order to address the core model separation, a thin layer of service objects (we call them directors) were added to the plan.  Anything directly changing core Tahi models would be housed inside directors which would act almost an internal API.  Task engines would then talk to these directors to perform actions.  

The disadvantage is this approach is that there can quickly become a high level of indirection.  Take the 
