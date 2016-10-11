import Ember from 'ember';

export default Ember.Component.extend({
  classNames: ['orcid-connect', 'profile-section'],

  orcidAccount: null,  // pass this in
  store: Ember.inject.service(),

  reloadIfNoResponse(){
    if (!this.get('orcidAccount.identifier')) {
      this.get('store').findRecord('orcidAccount', this.get('orcidAccount.id'), {reload: true});
    }
  },

  button_text: Ember.computed('button_disabled', 'orcidOauthResult', function() {
    if (this.get('button_disabled')) {
      if (this.get('orcidOauthResult') === null){
        return 'Connecting to ORCID...';

      } else if (this.get('orcidOauthResult') === 'success') {
        setTimeout(this.reloadIfNoResponse.bind(this), 10000);
        return 'Retrieving ORCID ID...';

      } else if (this.get('orcidOauthResult') === 'failure') {
        Ember.run.next(this, ()=>{
          this.set('button_disabled', null);
          this.set('orcidOauthResult', null);
        });
        return 'Connect or create your ORCID ID';
      }
    } else {
      return 'Connect or create your ORCID ID';
    }
  }),

  orcidOauthResult: null,

  accessTokenExpired: Ember.computed('orcidAccount.status', function() {
    return this.get('orcidAccount.status') == 'access_token_expired';
  }),

  actions: {
    removeOrcidAccount(orcidAccount) {
      orcidAccount.clearRecord();
      this.set('button_disabled', false);
      this.set('orcidOauthResult', null);
    },

    openOrcid() {
      window.localStorage.removeItem('orcidOauthResult');
      var popup = window.open(this.get('orcidAccount.oauthAuthorizeUrl'), "_blank", "toolbar=no, scrollbars=yes, width=500, height=630, top=0, left=0");
      this.set('button_disabled', true);
      addListener(this)
    },

    randomOrcidId(orcidAccount) {
      orcidAccount.chooseRandomId();
    }
  }
});

var actualOauthListener = null;

function oauthListener(event) {
  if (event.type === 'storage' && event.key === 'orcidOauthResult') {
    this.set('orcidOauthResult', event.newValue);
    window.localStorage.removeItem('orcidOauthResult');
    removeListener(actualOauthListener);
  }
}

function removeListener(listener){
  window.removeEventListener('storage', actualOauthListener, false);
  actualOauthListener = null;
}

function addListener(binding) {
  if (actualOauthListener) {
    removeListener(actualOauthListener);
  }
  actualOauthListener = oauthListener.bind(binding);
  window.addEventListener('storage', actualOauthListener, false);
}
