import Ember from 'ember';

export default Ember.Route.extend({
  restless: Ember.inject.service('restless'),

  model() {
    return Ember.RSVP.hash({
      papers: this.store.find('paper'),
      invitations: this.store.find('invitation')
    });
  },

  setupController(controller, model) {
    this.store.find('comment-look').then(function(commentLooks) {
      return controller.set('unreadComments', commentLooks);
    });
    controller.set('papers', this.store.filter('paper', function(p) {
      return Ember.isPresent(p.get('roles'));
    }));
    return this._super(controller, model);
  },

  actions: {
    didTransition() {
      this.controllerFor('dashboard.index').set('pageNumber', 1);
      return true;
    },

    rejectInvitation(invitation) {
      this.get('restless').putModel(invitation, '/reject').then(function() {
        invitation.reject();
      });
    },

    acceptInvitation(invitation) {
      this.get('restless').putModel(invitation, '/accept').then(function() {
        invitation.accept();

        // Force the user's papers to load
        this.store.find('paper');
      }.bind(this));
    },

    showNewPaperOverlay() {
      return this.store.find('journal').then((journals)=> {
        this.controllerFor('overlays/paper-new').setProperties({
          journals: journals,
          model: this.store.createRecord('paper', {
            journal: null,
            paperType: null,
            editable: true,
            body: ''
          })
        });

        this.send('openOverlay', {
          template: 'overlays/paper-new',
          controller: 'overlays/paper-new'
        });
      });
    },

    viewInvitations() {
      this.send('openOverlay', {
        template: 'overlays/invitations',
        controller: 'overlays/invitations'
      });
    }
  }
});
