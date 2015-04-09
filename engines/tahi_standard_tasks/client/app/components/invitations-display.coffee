`import Ember from 'ember';`
`import layout from '../templates/components/invitations-display';`

InvitationsDisplay = Ember.Component.extend
  layout: layout
  tagName: 'table'
  classNames: ['invitees']
  previousDecisions: Em.computed 'latestDecision', ->
    @get('decisions').without @get('latestDecision')

  actions:
    destroyInvitation: (invitation) ->
      @sendAction 'onDestroyInvitation', invitation

`export default InvitationsDisplay`
