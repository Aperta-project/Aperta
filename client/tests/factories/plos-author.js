import FactoryGuy from "ember-data-factory-guy";

FactoryGuy.define("plos-author", {
  default: {
    paper: FactoryGuy.belongsTo("paper"),
    plos_authors_task: FactoryGuy.belongsTo("plos-authors-task"),

    first_name: "Adam",
    position: 1,
  }
});
