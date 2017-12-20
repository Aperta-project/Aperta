import Ember from 'ember';

export default Ember.Component.extend({
  classNames: ['card-content-tech-check-email'],
  showEmailPreview: false,
  restless: Ember.inject.service('restless'),
  flash: Ember.inject.service('flash'),
  previewError: false,

  emailPreview: null,
  emailSending: false,

  didInsertElement() {
    $(document).on('focus', '.card-content-sendback-reason textarea', () => {
      this.set('showEmailPreview', false);
    });

    $(document).on('click', '.sendback-reason-row input', () => {
      this.set('showEmailPreview', false);
    });

    $(document).on('click', '.sendback-reason-row .fa-pencil', () => {
      this.set('showEmailPreview', false);
    });
  },

  willDestroyElement() {
    this._super(...arguments);
    $(document).off('focus', '.card-content-sendback-reason textarea');
    $(document).off('click', '.sendback-reason-row input');
    $(document).off('click', '.sendback-reason-row .fa-pencil');
  },

  emailNotAllowed: Ember.computed('owner.paper.publishingState', function () {
    return this.get('emailSending') || !this.get('owner.paper.isSubmitted');
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

  _templateConfig(endpoint) {
    return {
      url: `/api/tasks/${this.get('owner.id')}/${endpoint}`,
      data: {
        ident: 'preprint-sendbacks',
      }
    };
  },

  _hasEmptySendbacks() {
    const sendbacks = this.get('content.parent.children')
      .filterBy('contentType', 'tech-check').get('firstObject.children');

    return sendbacks.any((sendback) => {
      const children = sendback.get('children');
      const sendbackActive = children[0].get('answers.firstObject.value');
      const reason = children[2].get('answers.firstObject.value');

      return sendbackActive && (!reason || reason.length === 0);
    });

  },

  actions: {
    generatePreview() {
      this.set('previewError', false);

      if (this._hasEmptySendbacks()) {
        return this.set('previewError', true);
      }

      const config = this._templateConfig('render_template');

      this.get('restless').put(config.url, config.data).then((data)=> {
        this.set('emailPreview', data.letter_template.body);
        this.set('showEmailPreview', true);
      });
    },

    sendChangeRequestEmail() {
      this.set('emailSending', true);
      const config = this._templateConfig('sendback_email');

      this.get('restless').put(config.url, config.data).then(()=> {
        const flash = this.get('flash');
        flash.displaySystemLevelMessage('success', 'Sendback reasons email sent');
        this.get('owner.paper').reload();
        this.set('emailSending', false);
      });
    },
  }
});
