import FactoryGuy from "ember-data-factory-guy";

FactoryGuy.define("journal", {
  sequences: {
    journalName: function(num) {
      return `PLOS Yeti ${num}`;
    }
  },

  default: {
    name: FactoryGuy.generate("journalName"),
    paperTypes: ["Research"]
  }
});
