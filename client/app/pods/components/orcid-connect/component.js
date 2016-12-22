import Ember from 'ember';

const {
  Component,
  computed,
  inject: { service },
  isEmpty,
  isEqual,
  String: { htmlSafe }
} = Ember;

export default Component.extend({
  classNameBindings: [':orcid-connect', ':profile-section', 'errors:error'],
  user: null,         // pass one
  orcidAccount: null, // of these in
  can: service('can'),
  journal: null,
  store: service(),

  canRemoveOrcid: null,

  // function to use for asking the user to confirm an action
  confirm: window.confirm,

  // Searching for the permission on any journal because the ORCID account
  // appears on the user's profile page.  The profile page doesn't exist
  // in the context of a journal, so we need to dig through all of them to
  // see if the user can remove the link.
  setCanRemoveOrcid: function() {
    let can = this.get('can');
    this.get('store').findAll('journal').then((journals) => {
      let promises = journals.map(j => can.can('remove_orcid', j));
      Ember.RSVP.all(promises)
      .then(permissions => this.set('canRemoveOrcid', _.any(permissions)));
    });
  },

  didInsertElement() {
    this._super(...arguments);
    this._oauthListener = Ember.run.bind(this, this.oauthListener);
    this._popupClosedListener = Ember.run.bind(this, this.popupClosedListener);
    if(this.get('user')) {
      this.get('user.orcidAccount').then( (account) => {
        this.set('orcidAccount', account);
      });
    }

    if (this.get('canRemoveOrcid') === null) {
      this.setCanRemoveOrcid();
    }
    // if we don't have a journal (profile page) we need to find one to
    // display a contact email
    if (this.get('journal') === null) {
      this.get('store').findAll('journal').then((journals) => {
        this.set('journal', journals.get('firstObject'));
      });
    }
  },

  willDestroyElement() {
    this._super(...arguments);
    window.removeEventListener('storage', this._oauthListener, false);
    this.removePopupClosedListener();
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

  removePopupClosedListener() {
    if (this.get('popupTimeoutId')){
      window.clearInterval(this.popupTimeoutId);
      this.set('popupTimeoutId', null);
    }
  },

  popupClosedListener(popupWindow) {
    if (popupWindow.closed === false) { return; }
    this.set('oauthInProgress', false);
    this.removePopupClosedListener();
  },

  orcidConnectEnabled: computed('orcidAccount', 'user.id', 'currentUser.id', function() {
    const user = this.get('user.id'); // <-- promise
    const currentUser = this.get('currentUser.id');
    return this.get('orcidAccount') && isEqual(user, currentUser);
  }),

  reloadIfNoResponse(){
    if (this.get('isDestroyed')) { return; }
    this.set('orcidOauthResult', null);
    if (!this.get('orcidAccount.identifier')) {
      this.get('store').findRecord('orcidAccount', this.get('orcidAccount.id'), {reload: true});
    }
  },

  oauthInProgress: false,
  popupTimeoutId: null,

  buttonText: computed('oauthInProgress', 'orcidOauthResult', function() {
    if (this.get('oauthInProgress')) {
      if (this.get('orcidOauthResult') === null){
        return 'Connecting to ORCID...';
      } else if (this.get('orcidOauthResult') === 'success') {
        return 'Retrieving ORCID ID...';
      }
    }

    return htmlSafe('Connect or create your ORCID ID <span class="orcid-connect-required">*</span>');
  }),

  orcidOauthResult: null,

  accessTokenExpired: computed.equal('orcidAccount.status', 'access_token_expired'),

  actions: {
    removeOrcidAccount(orcidAccount) {
      let confirm = this.get('confirm');
      if(confirm("Are you sure you want to remove your ORCID record?")){
        orcidAccount.clearRecord();
        this.set('oauthInProgress', false);
        this.set('orcidOauthResult', null);
      }
    },

    openOrcid() {
      window.localStorage.removeItem('orcidOauthResult');
      var popupWindow = window.open(
        this.get('orcidAccount.oauthAuthorizeUrl'),
        '_blank',
        'toolbar=no, scrollbars=yes, width=500, height=630, top=500, left=500'
      );
      this.set('orcidOauthResult', null);
      this.set('oauthInProgress', true);
      this.set('popupTimeoutId',  window.setInterval(this._popupClosedListener, 250, popupWindow));
      window.addEventListener('storage', this._oauthListener, false);
    }
  }
});
