`import Ember from 'ember';`
`import layout from '../templates/components/invitations-display';`

InvitationsDisplay = Ember.Component.extend
  layout: layout
  tagName: 'table'
  classNames: ['invitees']

  previousDecisions: Em.computed 'latestDecision', ->
    @get('decisions').without @get('latestDecision')

  previousDecisionsWithFilteredInvitations: Em.computed 'previousDecisions', ->
    @get('previousDecisions').map (decision) =>
      decision.set 'filteredInvitations', decision.get('invitations').filterBy('invitationType', @get('invitationType'))
      decision

  actions:
    destroyInvitation: (invitation) ->
      @sendAction 'onDestroyInvitation', invitation

`export default InvitationsDisplay`
