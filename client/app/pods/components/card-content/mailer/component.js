import Ember from 'ember';

export default Ember.Component.extend({
  classNames: ['card-content-tech-check-email'],
  showEmailPreview: false,
  restless: Ember.inject.service('restless'),
  flash: Ember.inject.service('flash'),

  // didInsertElement() {
  //   $(document).on('focus', '.card-content-sendback-reason textarea', () => {
  //     this.set('showEmailPreview', false);
  //     this.notifyPropertyChange('sendbacksWithReasons');
  //   });

  //   $(document).on('click', '.sendback-reason-row input', () => {
  //     this.set('showEmailPreview', false);
  //     this.notifyPropertyChange('sendbacksWithReasons');
  //   });
  // },

  // willDestroyElement() {
  //   this._super(...arguments);
  //   $(document).off('focus', '.card-content-sendback-reason textarea');
  //   $(document).off('click', '.sendback-reason-row input');
  // },

  // techChecks: Ember.computed(function() {
  //   return this.get('content.parent.children').filter(function(content) {
  //     return content.get('contentType') === 'tech-check';
  //   });
  // }),

  // sendbacks: Ember.computed(function() {
  //   let ret = [];

  //   this.get('techChecks').forEach(function(check) {
  //     let sendbacks = check.get('children').filter(function(content) {
  //       return content.get('contentType') === 'sendback-reason';
  //     });

  //     ret = ret.concat(sendbacks);
  //   });

  //   return ret;
  // }),


  // sendbacksWithReasons: Ember.computed(function() {
  //   return this.get('sendbacks').filter((sendback) => {
  //     const sendbackCheckbox = sendback.get('children')[0];
  //     const sendbackReason = sendback.get('children')[2];
  //     const owner = this.get('owner');


  //     return sendbackCheckbox.answerForOwner(owner).get('value') &&
  //       sendbackReason.answerForOwner(owner).get('value');
  //   });
  // }),

  // sendbackReasons: Ember.computed('sendbacksWithReasons', function () {
  //   return this.get('sendbacksWithReasons').map((sendback) => {
  //     const owner = this.get('owner');
  //     const reason = sendback.get('children')[2];
  //     return reason.answerForOwner(owner).get('value');
  //   });
  // }),

  // emailIntroText: Ember.computed(function () {
  //   const introEditor = this.get('content.children')[0];
  //   return introEditor.get('answers.lastObject.value');
  // }),

  // emailFooterText: Ember.computed(function () {
  //   const footerEditor = this.get('content.children')[1];
  //   return footerEditor.get('answers.lastObject.value');
  // }),

  emailBody: Ember.computed(function () {
    //replace below with ident based version
    const footerEditor = this.get('content.children')[1];
    return footerEditor.get('answers.lastObject.value');
  }),

  textObserver: Ember.observer('intro.answers.lastObject.value', 'footer.answers.lastObject.value', function() {
    this.set('showEmailPreview', false);
  }),

  actions: {
    showPreview() {
      this.set('showEmailPreview', true);
    },

    sendChangeRequestEmail() {
      let data = {
        task: this.get('owner'),
        body: this.get('emailBody')
        // user/to?
      };

      const url = `/api/tasks/${this.get('owner.id')}/send_message`;
      this.get('restless').post(url, data);
    },
  },

});
