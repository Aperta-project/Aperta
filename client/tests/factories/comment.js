import FactoryGuy from "ember-data-factory-guy";

FactoryGuy.define("comment", {
  default: {
    bodyHtml: 'Lorem ipsum dolar',
  },

  traits: {

    unread: {
      commentLook: FactoryGuy.belongsTo("comment-look")
    }

  }
});
