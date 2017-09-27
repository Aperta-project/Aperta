import Ember from 'ember';

export default Ember.Component.extend({
  classNames: ['card-content-tech-check-email'],
  showEmailPreview: false,

  didInsertElement() {
    $(document).on('focus', '.card-content-sendback-reason textarea', () => {
      this.set('showEmailPreview', false);
      this.notifyPropertyChange('sendbacksWithReasons');
    });
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

  sendbackReasonFields: Ember.computed(function() {
    return this.get('sendbacks').map(function(sendback) {
      return sendback.get('children')[2];
    });
  }),

  sendbacksWithReasons: Ember.computed(function() {
    return this.get('sendbackReasonFields').filter(function(reason) {
      return reason.get('answers.lastObject.value');
    });
  }),

  // content.parent.children.@each.children.@each.children.@each.answers.@each.value
  sendbackReasons: Ember.computed('sendbacksWithReasons', function () {
    return this.get('sendbacksWithReasons').map(function(sendback) {
      return sendback.get('answers.lastObject.value');
    });
  }),

  intro: Ember.computed(function () {
    return this.get('content.children')[0];
  }),

  footer: Ember.computed(function () {
    return this.get('content.children')[1];
  }),

  emailIntroText: Ember.computed('intro.answers.lastObject.value', function () {
    return this.get('intro.answers.lastObject.value');
  }),

  emailFooterText: Ember.computed('footer.answers.lastObject.value', function () {
    return this.get('footer.answers.lastObject.value');
  }),

  textObserver: Ember.observer('intro.answers.lastObject.value', 'footer.answers.lastObject.value', function() {
    this.set('showEmailPreview', false);
  }),

  actions: {
    showPreview() {
      this.set('showEmailPreview', true);
    },

    sendChangeRequestEmail() {
      //some ajax request ??
      // this.set('showEmailPreview', true);
    },
  },

});
