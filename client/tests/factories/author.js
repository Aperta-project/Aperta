import FactoryGuy from "ember-data-factory-guy";

FactoryGuy.define("author", {
  default: {
    paper: FactoryGuy.belongsTo("paper"),
    task: {},

    first_name: "Adam",
    position: 1,

    nestedQuestions: [
      {id: 911, ident: 'author--published_as_corresponding_author'},
      {id: 912, ident: 'author--deceased'},
      {id: 913, ident: 'author--contributions--conceptualization'},
      {id: 914, ident: 'author--contributions--conceptualization'},
      {id: 915, ident: 'author--contributions--investigation'},
      {id: 916, ident: 'author--contributions--visualization'},
      {id: 917, ident: 'author--contributions--methodology'},
      {id: 919, ident: 'author--contributions--resources'},
      {id: 920, ident: 'author--contributions--supervision'},
      {id: 921, ident: 'author--contributions--software'},
      {id: 922, ident: 'author--contributions--data-curation'},
      {id: 923, ident: 'author--contributions--project-administration'},
      {id: 924, ident: 'author--contributions--validation'},
      {id: 925, ident: 'author--contributions--writing-original-draft'},
      {id: 926, ident: 'author--contributions--writing-review-and-editing'},
      {id: 927, ident: 'author--contributions--funding-acquisition'},
      {id: 928, ident: 'author--contributions--formal-analysis'},
      {id: 929, ident: 'author--government-employee'}
    ]
  }
});
