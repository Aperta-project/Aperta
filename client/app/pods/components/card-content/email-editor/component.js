import Ember from 'ember';
import ValidationErrorsMixin from 'tahi/mixins/validation-errors';
import { PropTypes } from 'ember-prop-types';

export default Ember.Component.extend(ValidationErrorsMixin, {
  classNameBindings: ['card-content', 'card-content-email-editor'],
  //passed-in stuff
  category: null,
  letterValue: null,
  updateTemplate: null,
  restless: Ember.inject.service('restless'),
  flash: Ember.inject.service('flash'),
  propTypes: {
    content: PropTypes.EmberObject.isRequired,
    owner: PropTypes.EmberObject.isRequired,
    disabled: PropTypes.bool,
    repetition: PropTypes.oneOfType([PropTypes.null, PropTypes.EmberObject]).isRequired
  },

  init() {
    this._super(...arguments);
    const config = this._templateConfig('load_email_template');

    var templateName = this.get('content.letterTemplate');
    Ember.Logger.info('email template name:', templateName);

    this.get('restless').get(config.url, {letter_template_name: templateName}).then((data)=> {
      this.set('emailToField', data.to);
      this.set('emailToSubject', data.subject);
      this.set('emailToBody', data.body);
    });
  },

  _templateConfig(endpoint) {
    return {
      url: `/api/tasks/${this.get('owner.id')}/${endpoint}`,
      data: {
        intro: this.get('emailIntroText'),
        footer: this.get('emailFooterText')
      }
    };
  },

  generatePreview() {
    const config = this._templateConfig('sendback_preview');

    this.get('restless').put(config.url, config.data).then((data)=> {
      this.set('emailPreview', data.body);
      this.set('showEmailPreview', true);
    });
  },
  inputClassNames: ['form-control'],

  actions: {
    updateAnswer(contents) {
      this.set('letterValue', contents);
    },

    valueChanged(e) {
      // super to valueChanged in ValidateTextInput mixin.
      // a text input will have a string so we give it the string. Rich text editor won't have that and needs the event
      let value = e.target ? e.target.value : e;
      this._super(value);
    },

    maybeHideError() {
      if (Ember.isBlank(this.get('answerProxy'))) {
        this.set('hideError', true);
      }
    }
  }
});
