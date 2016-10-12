import Ember from 'ember';

export default Ember.Component.extend({
  classNames: ['orcid-connect', 'profile-section'],
  user: null,         // pass one
  orcidAccount: null, // of these in
  store: Ember.inject.service(),

  didInsertElement() {
    this._super(...arguments);
    this._oauthListener = Ember.run.bind(this, this.oauthListener);
    window.addEventListener('storage', this._oauthListener, false);
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
      window.localStorage.removeItem('orcidOauthResult');
      window.removeEventListener('storage', this._oauthListener, false);
  },

  reloadIfNoResponse(){
    if (this.get('isDestroyed')) { return; }

    if (!this.get('orcidAccount.identifier')) {
      this.get('store').findRecord('orcidAccount', this.get('orcidAccount.id'), {reload: true});
    }
  },

  button_text: Ember.computed('button_disabled', 'orcidOauthResult', function() {
    if (this.get('button_disabled')) {
      if (this.get('orcidOauthResult') === null){
        return 'Connecting to ORCID...';

      } else if (this.get('orcidOauthResult') === 'success') {
        Ember.run.later(this, 'reloadIfNoResponse', 10000);
        return 'Retrieving ORCID ID...';

      } else if (this.get('orcidOauthResult') === 'failure') {
        this.set('button_disabled', null);
        this.set('orcidOauthResult', null);
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
      this.set('button_disabled', false);
      this.set('orcidOauthResult', null);
    },

    openOrcid() {
      window.localStorage.removeItem('orcidOauthResult');
      window.open(
        this.get('orcidAccount.oauthAuthorizeUrl'),
        '_blank',
        'toolbar=no, scrollbars=yes, width=500, height=630, top=0, left=0'
      );
      this.set('button_disabled', true);
    }
  }
});
