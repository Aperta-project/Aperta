`import Ember from 'ember'`

InvitationsController = Ember.Controller.extend
  overlayClass: 'overlay--fullscreen invitations-overlay'

  didCompleteAllInvitations: (->
    @send('closeOverlay') if Ember.isEmpty(@get('model'))
  ).observes('model.@each')

`export default InvitationsController`
