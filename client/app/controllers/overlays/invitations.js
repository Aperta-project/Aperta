import Ember from 'ember';

export default Ember.Controller.extend({
  overlayClass: 'overlay--fullscreen invitations-overlay',

  didCompleteAllInvitations: function() {
    if(Ember.isEmpty(this.get('model'))) {
      this.send('closeOverlay');
    }
  }.observes('model.@each')
});
