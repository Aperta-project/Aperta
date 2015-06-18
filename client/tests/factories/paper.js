import FactoryGuy from "ember-data-factory-guy";

FactoryGuy.define("paper", {
  default: {
    title: '',
    shortTitle: '',
    publishingState: 'ongoing',
    roles: [],
    relatedAtDate: "2014-09-28T13:54:58.028Z",
    editable: true
  },

  traits: {

    withRoles: {
      roles: ["participant"]
    }

  }
});
