`import FactoryGuy from "factory-guy"`

Factories = ->
  FactoryGuy.clear()
  FactoryGuy.define 'journal',
    default:
      name: "PLOS Yeti",
      paperTypes: ["Research"]

  FactoryGuy.define 'paper',
    default:
      journal: FactoryGuy.belongsTo('journal')

  FactoryGuy.define 'phase',
    default:
      position: 1
      name: "Assign Editor"

  FactoryGuy.define 'paper-reviewer-task',
    default:
      title: 'Invite Reviewers'
      type: 'PaperReviewerTask'
      completed: false

  FactoryGuy.define 'paper-editor-task',
    default:
      title: 'Assign Editors'
      type: 'PaperEditorTask'
      completed: false

  FactoryGuy.define 'plos-authors-task',
    default:
      title: 'Add Authors'
      type: 'PlosAuthorsTask'
      completed: false

  FactoryGuy.define 'reviewer-recommendations-task',
    default:
      title: 'Reviewer Recommendations'
      type: 'ReviewerRecommendationsTask'
      completed: false

  FactoryGuy.define 'invitation',
    default:
      state: 'invited'

`export default Factories`
