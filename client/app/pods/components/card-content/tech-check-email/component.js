import Ember from 'ember';

export default Ember.Component.extend({
  classNames: ['card-content-tech-check-email'],
  showEmailPreview: false,
  restless: Ember.inject.service('restless'),
  flash: Ember.inject.service('flash'),

  preview: null,

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
    return this.get('sendbacks').filter((sendback) => {
      const sendbackCheckbox = sendback.get('children')[0];
      const sendbackReason = sendback.get('children')[2];
      const owner = this.get('owner');

      return sendbackCheckbox.answerForOwner(owner).get('value') &&
        sendbackReason.answerForOwner(owner).get('value');
    });
  }),

  sendbackReasons: Ember.computed('sendbacksWithReasons', function () {
    return this.get('sendbacksWithReasons').map((sendback) => {
      const owner = this.get('owner');
      const reason = sendback.get('children')[2];
      return reason.answerForOwner(owner).get('value');
    });
  }),

  intro: Ember.computed(function () {
    const editors = this.get('content.children');
    const intro = editors.filterBy('ident', 'tech-check-email--email-intro')[0];
    return intro.answerForOwner(this.get('owner'));
  }),

  footer: Ember.computed(function () {
    const editors = this.get('content.children');
    const footer = editors.filterBy('ident', 'tech-check-email--email-footer')[0];
    return footer.answerForOwner(this.get('owner'));
  }),

  emailIntroText: Ember.computed('intro.value', function () {
    return this.get('intro.value');
  }),

  emailFooterText: Ember.computed('footer.value', function () {
    return this.get('footer.value');
  }),

  textObserver: Ember.observer('emailFooterText', 'emailIntroText', function() {
    this.set('showEmailPreview', false);
  }),

  actions: {
    generatePreview() {
      const url = `/api/tasks/${this.get('owner.id')}/sendback_preview`;

      let data = {
        intro: this.get('emailIntroText'),
        sendbacks: this.get('sendbackReasons'),
        footer: this.get('emailFooterText')
      };

      this.get('restless').put(url, data).then((data)=> {
        this.set('preview', data.x);
        this.set('showEmailPreview', true);
      });
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
  }
});
