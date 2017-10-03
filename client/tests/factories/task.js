import FactoryGuy from "ember-data-factory-guy";

FactoryGuy.define("task", {
  default: {
    title: "Adhoc Task",
    type: "Task",
    completed: false,
    viewable: true
  },

  traits: {

    withUnreadComments: {
      commentLooks: FactoryGuy.hasMany("comment-look", 2)
    }

  }

});
