import Ember from 'ember';

export default Ember.Component.extend({
  classNameBindings: [':message-comment', 'isNew:animation-pulse'],
  isNew: false,

  // passed into component
  reply: null,

  checkAge: function() {
    Ember.run.scheduleOnce('afterRender', this, function() {
      let createdAt = this.get('reply.createdAt');
      if(Ember.isEmpty(createdAt)) { return; }

      // if created in the last 2 seconds, set to isNew
      let diff = Math.floor(Date.now() / 1000) - Math.floor(createdAt.getTime() / 1000);
      if(diff < 2) {
        this.set('isNew', true);
      }
    });
  }.observes('reply.createdAt').on('didInsertElement'),
});
