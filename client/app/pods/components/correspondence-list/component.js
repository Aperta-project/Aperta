import Ember from 'ember';

export default Ember.Component.extend({
  showCorrespondenceOverlay: false,
  messageId: () => {
    if (window.location.href.includes('viewcorrespondence')){
      let parts = window.location.href.split('/');
      return parts[parts.length - 1];
    }
    else {
      return null;
    }
  },
  baseUrl: Ember.computed(function(){
    let parts = window.location.href.split('/');
    if (window.location.href.includes('viewcorrespondence')){
      return parts.slice(0,parts.length - 2).join('/');
    }
    else{
      return window.location.href;
    }
  }),
  actions: {
    showCorrespondenceOverlay(message) {
      this.set('showCorrespondenceOverlay', true);
      this.set('message', message);
      window.history.replaceState({}, null, this.get('baseUrl') + '/viewcorrespondence/' + message.id);
    },
    hideCorrespondenceOverlay() {
      this.set('showCorrespondenceOverlay', false);
      window.history.replaceState({}, null, this.get('baseUrl'));
    }
  },
  didRender() {
    let messageId = this.messageId();
    if (messageId !== null){
      this.$('#link' + messageId).click();
    }
  }
});
