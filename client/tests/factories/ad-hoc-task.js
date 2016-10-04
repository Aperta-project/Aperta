import FactoryGuy from 'ember-data-factory-guy';

FactoryGuy.define('ad-hoc-task', {
  default: {
    title: 'Adhoc Task',
    type: 'AdHocTask',
    completed: false
  },

  traits: {

    withUnreadComments: {
      commentLooks: FactoryGuy.hasMany('comment-look', 2)
    }

  }

});
