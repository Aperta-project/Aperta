import Ember from 'ember';

export default Ember.Component.extend({
  classNameBindings: [':message-comment', 'isNew:animation-pulse'],
  isNew: false,

  // passed into component
  reply: null
});
