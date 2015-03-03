`import FactoryGuy from "factory-guy"`

Factories = ->

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

  FactoryGuy.define 'paper-editor-task',
    default:
      title: 'Assign Editors'
      type: 'PaperEditorTask'
      completed: false

  FactoryGuy.define 'invitation',
    default:
      state: 'pending'

`export default Factories`
