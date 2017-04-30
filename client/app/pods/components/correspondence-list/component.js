import Ember from 'ember';

export default Ember.Component.extend({
  showCorrespondenceOverlay: window.location.href.includes('viewcorrespondence'),
  baseUrl: () => {
    let parts = window.location.href.split('/');
    if (window.location.href.includes('viewcorrespondence')){
      return window.location.href.split('/').slice(0,parts.length - 2).join('/');
    }
    else{
      return window.location.href;
    }
  },
  actions: {
    showCorrespondenceOverlay(message) {
      this.set('showCorrespondenceOverlay', true);
      this.set('message', message);
      window.history.replaceState({}, null, this.baseUrl() + '/viewcorrespondence/' + message.id);
    },
    hideCorrespondenceOverlay() {
      this.set('showCorrespondenceOverlay', false);
      window.history.replaceState({}, null, this.baseUrl());
    }
  }
});
