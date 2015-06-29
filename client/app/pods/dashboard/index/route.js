import Ember from 'ember';
import RESTless from 'tahi/services/rest-less';

export default Ember.Route.extend({
  model() {
    return Ember.RSVP.hash({
      papers: this.store.findAll('paper'),
      invitations: this.store.findAll('invitation')
    });
  },

  setupController(controller, model) {
    this.store.findAll('comment-look').then(function(commentLooks) {
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
      RESTless.putModel(invitation, '/reject').then(function() {
        invitation.reject();
      });
    },

    acceptInvitation(invitation) {
      RESTless.putModel(invitation, '/accept').then(function() {
        invitation.accept();

        // Force the user's papers to load
        this.store.find('paper');
      }.bind(this));
    },

    showNewPaperOverlay() {
      return this.store.findAll('journal').then((journals)=> {
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
