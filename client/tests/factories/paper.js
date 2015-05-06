import FactoryGuy from "ember-data-factory-guy";

FactoryGuy.define("paper", {
  default: {
    journal: FactoryGuy.belongsTo("journal"),

    title: '',
    shortTitle: '',
    submitted: false,
    roles: [],
    relatedAtDate: "2014-09-28T13:54:58.028Z",
    editable: true,
  }
});
