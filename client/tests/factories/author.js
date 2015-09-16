import FactoryGuy from "ember-data-factory-guy";

FactoryGuy.define("author", {
  default: {
    paper: FactoryGuy.belongsTo("paper"),
    authors_task: {},

    first_name: "Adam",
    position: 1,
  }
});
