import Ember from 'ember';

export default Ember.Component.extend({
  classNames: ['card-content-tech-check-email'],
  showEmailPreview: false,
  restless: Ember.inject.service('restless'),
  flash: Ember.inject.service('flash'),

  didInsertElement() {
    $(document).on('focus', '.card-content-sendback-reason textarea', () => {
      this.set('showEmailPreview', false);
      this.notifyPropertyChange('sendbacksWithReasons');
    });

    $(document).on('click', '.sendback-reason-row input', () => {
      this.set('showEmailPreview', false);
      this.notifyPropertyChange('sendbacksWithReasons');
    });
  },

  willDestroyElement() {
    this._super(...arguments);
    $(document).off('focus', '.card-content-sendback-reason textarea');
    $(document).off('click', '.sendback-reason-row input');
  },

  techChecks: Ember.computed(function() {
    return this.get('content.parent.children').filter(function(content) {
      return content.get('contentType') === 'tech-check';
    });
  }),

  sendbacks: Ember.computed(function() {
    let ret = [];

    this.get('techChecks').forEach(function(check) {
      let sendbacks = check.get('children').filter(function(content) {
        return content.get('contentType') === 'sendback-reason';
      });

      ret = ret.concat(sendbacks);
    });

    return ret;
  }),


  sendbacksWithReasons: Ember.computed(function() {
    return this.get('sendbacks').filter(function(sendback) {
      const sendbackCheckbox = sendback.get('children')[0];
      const sendbackReason = sendback.get('children')[2];

      return sendbackCheckbox.get('answers.lastObject.value') &&
        sendbackReason.get('answers.lastObject.value');
    });
  }),

  sendbackReasons: Ember.computed('sendbacksWithReasons', function () {
    return this.get('sendbacksWithReasons').map(function(sendback) {
      return sendback.get('children')[2].get('answers.lastObject.value');
    });
  }),

  emailIntroText: Ember.computed(function () {
    const introEditor = this.get('content.children')[0];
    return introEditor.get('answers.lastObject.value');
  }),

  emailFooterText: Ember.computed(function () {
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
        intro: this.get('emailIntroText'),
        sendbacks: this.get('sendbackReasons'),
        footer: this.get('emailFooterText')
      };

      const url = `/api/cards/${this.get('owner.id')}/sendback_email`;
      this.get('restless').post(url, data);
    },
  },

});
