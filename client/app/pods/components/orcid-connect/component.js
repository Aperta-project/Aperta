import Ember from 'ember';

export default Ember.Component.extend({
  classNames: ['orcid-connect', 'profile-section'],
  user: null,         // pass one
  orcidAccount: null, // of these in
  store: Ember.inject.service(),

  didInsertElement() {
    this._super(...arguments);
    this._oauthListener = Ember.run.bind(this, this.oauthListener);
    if(this.get('user')) {
      this.get('user.orcidAccount').then( (account) => {
        this.set('orcidAccount', account);
      });
    }
  },

  willDestroyElement() {
    this._super(...arguments);
    window.removeEventListener('storage', this._oauthListener, false);
  },

  oauthListener(event) {
    if (event.type === 'storage' && event.key === 'orcidOauthResult') {
      this.set('orcidOauthResult', event.newValue);
      this.set('oauthInProgress', false);
      window.localStorage.removeItem('orcidOauthResult');
      Ember.run.later(this, 'reloadIfNoResponse', 10000);
      window.removeEventListener('storage', this._oauthListener, false);
    }
  },

  reloadIfNoResponse(){
    if (this.get('isDestroyed')) { return; }
    this.set('orcidOauthResult', null);
    if (!this.get('orcidAccount.identifier')) {
      this.get('store').findRecord('orcidAccount', this.get('orcidAccount.id'), {reload: true});
    }
  },

  oauthInProgress: false,

  buttonDisabled: Ember.computed('oauthInProgress',
                                 'orcidOauthResult', 
                                 'orcid.identifier',
                                 'orcidAccount.isLoaded',
                                 function(){
    return this.get('oauthInProgress') ||
      !this.get('orcidAccount.isLoaded') ||
      (this.get('orcidOauthResult') === 'success' &&
        Ember.isEmpty(this.get('orcid.identifier')));
  }),

  buttonText: Ember.computed('oauthInProgress', 'orcidOauthResult', function() {
    if (this.get('oauthInProgress')) {
      if (this.get('orcidOauthResult') === null){
        return 'Connecting to ORCID...';

      } else if (this.get('orcidOauthResult') === 'success') {
        return 'Retrieving ORCID ID...';

      } else if (this.get('orcidOauthResult') === 'failure') {

        return 'Connect or create your ORCID ID';
      }
    } else {
      return 'Connect or create your ORCID ID';
    }
  }),

  orcidOauthResult: null,

  accessTokenExpired: Ember.computed.equal('orcidAccount.status', 'access_token_expired'),

  actions: {
    removeOrcidAccount(orcidAccount) {
      orcidAccount.clearRecord();
      this.set('oauthInProgress', false);
      this.set('orcidOauthResult', null);
    },

    openOrcid() {
      window.localStorage.removeItem('orcidOauthResult');
      window.open(
        this.get('orcidAccount.oauthAuthorizeUrl'),
        '_blank',
        'toolbar=no, scrollbars=yes, width=500, height=630, top=500, left=500'
      );
      this.set('orcidOauthResult', null);
      this.set('oauthInProgress', true);
      window.addEventListener('storage', this._oauthListener, false);
    }
  }
});
