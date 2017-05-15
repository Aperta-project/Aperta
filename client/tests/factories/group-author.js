import FactoryGuy from "ember-data-factory-guy";

FactoryGuy.define("group-author", {
  default: {
    paper: FactoryGuy.belongsTo("paper"),
    task: {},

    first_name: "Adam",
    position: 1,

    nestedQuestions: [
      {id: 911, ident: 'group-author--published_as_corresponding_author'},
      {id: 912, ident: 'group-author--contributions--conceptualization' },
      {id: 915, ident: 'group-author--contributions--investigation'},
      {id: 916, ident: 'group-author--contributions--visualization'},
      {id: 917, ident: 'group-author--contributions--methodology'},
      {id: 919, ident: 'group-author--contributions--resources'},
      {id: 920, ident: 'group-author--contributions--supervision'},
      {id: 921, ident: 'group-author--contributions--software'},
      {id: 922, ident: 'group-author--contributions--data-curation'},
      {id: 923, ident: 'group-author--contributions--project-administration'},
      {id: 924, ident: 'group-author--contributions--validation'},
      {id: 925, ident: 'group-author--contributions--writing-original-draft'},
      {id: 926, ident: 'group-author--contributions--writing-review-and-editing'},
      {id: 927, ident: 'group-author--contributions--funding-acquisition'},
      {id: 928, ident: 'group-author--contributions--formal-analysis'},
      {id: 929, ident: 'group-author--government-employee'}
    ]
  }
});
