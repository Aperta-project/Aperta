import FactoryGuy from "ember-data-factory-guy";

FactoryGuy.define("comment-look", {
  default: {
    paper: FactoryGuy.belongsTo("paper"),
    task: FactoryGuy.belongsTo("ad-hoc-task"),
    comment: FactoryGuy.belongsTo("comment"),
  }
});
