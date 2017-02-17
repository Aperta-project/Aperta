import Ember from 'ember';
import { task as concurrencyTask } from 'ember-concurrency';

const {
  Component,
  computed,
  inject: { service },
  isEmpty,
  isEqual,
  String: { htmlSafe }
} = Ember;


// The orcid-connect component will open a popup window from Orcid.org.
//
// While the popup window is open, we disable the orcid-connect button to
// prevent the user from opening multiple popup windows.
//
// If the user closes the window before completing the Orcid OAuth flow, the
// `popupClosedListener` will detect the popup.closed property is true, and set
// the appropriate variable `oauthInProgress` to false which re-enables the
// orcid-connect button.
//
// Once the user completes the OAuth flow and accepts, or denies authentication
// with Orcid, Orcid redirects the popup back to Aperta.
//
// After redirect the popup is served minimal markup and javascript to
// immediately close the popup. Once the user is redirected back to Aperta, we
// re-enable the orcid-connect button and then proceed accordingly based on the
// success of the OAuth response.
export default Component.extend({
  classNameBindings: [':orcid-connect', ':profile-section', 'errors:error'],
  user: null,         // pass one
  orcidAccount: null, // of these in
  can: service('can'),
  journal: null,
  store: service(),

  canRemoveOrcid: null,
  notConnectedMessage: 'No ORCID ID has been linked with this author.',

  // function to use for asking the user to confirm an action
  confirm: window.confirm,

  //function to open a popup window
  open: window.open,

  // Searching for the permission on any journal because the ORCID account
  // appears on the user's profile page.  The profile page doesn't exist
  // in the context of a journal, so we need to dig through all of them to
  // see if the user can remove the link.
  setCanRemoveOrcid: concurrencyTask(function * () {
    let can = this.get('can');
    let journals = yield this.get('store').findAll('journal');
    let promises = journals.map(j => can.can('remove_orcid', j));
    let permissions = yield Ember.RSVP.all(promises);
    this.set('canRemoveOrcid', _.any(permissions));
  }),

  didInsertElement() {
    this._super(...arguments);
    this._oauthListener = Ember.run.bind(this, this.oauthListener);
    this._popupClosedListener = Ember.run.bind(this, this.popupClosedListener);
    // For ease of testing we're making it so that orcid-connect can have it's
    // orcidAccount set directly.  In that case the component is invoked with `user=null`
    if (this.get('user.orcidAccount')) {  
      if(this.get('user')) {
        this.get('user.orcidAccount').then( (account) => {
          this.set('orcidAccount', account);
       });
      }
    }
    
    if (this.get('canRemoveOrcid')=== null) {
      this.get('setCanRemoveOrcid').perform();
    }

    // if we don't have a journal (profile page) we need to find one to
    // display a contact email
    if (this.get('journal') === null) {
      this.get('store').findAll('journal').then((journals) => {
        this.set('journal', journals.get('firstObject'));
      });
    }
  },
  
  canLinkOrcid: computed('orcidAccount', 'user.id', 'currentUser.id', function() {
    const user = this.get('user.id'); // <-- promise
    const currentUser = this.get('currentUser.id');
    return this.get('orcidAccount') && isEqual(user, currentUser);
  }),

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

  reloadIfNoResponse(){
    if (this.get('isDestroyed')) { return; }
    this.set('orcidOauthResult', null);
    if (!this.get('orcidAccount.identifier')) {
      this.get('store').findRecord('orcidAccount', this.get('orcidAccount.id'), {reload: true});
    }
  },

  oauthInProgress: false,
  popupTimeoutId: null,

  buttonDisabled: computed('oauthInProgress',
                                 'orcidOauthResult',
                                 'orcid.identifier',
                                 'orcidAccount.isLoaded',
                                 function(){
    return this.get('oauthInProgress') ||
      !this.get('orcidAccount.isLoaded') ||
      (this.get('orcidOauthResult') === 'success' &&
        isEmpty(this.get('orcid.identifier')));
  }),

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
  refreshAccessToken: computed.and('accessTokenExpired', 'canLinkOrcid'),

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
      let open = this.get('open');
      window.localStorage.removeItem('orcidOauthResult');
      var popupWindow = open(
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
