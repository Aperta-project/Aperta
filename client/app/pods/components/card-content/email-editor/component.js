import Ember from 'ember';
import ValidationErrorsMixin from 'tahi/mixins/validation-errors';
import { PropTypes } from 'ember-prop-types';

export default Ember.Component.extend(ValidationErrorsMixin, {
  classNames: ['card-content', 'card-content-email-editor'],
  restless: Ember.inject.service('restless'),
  flash: Ember.inject.service('flash'),
  propTypes: {
    content: PropTypes.EmberObject.isRequired,
    owner: PropTypes.EmberObject.isRequired,
    answer: PropTypes.EmberObject.isRequired,
    disabled: PropTypes.bool.isRequired,
    repetition: PropTypes.oneOfType([PropTypes.null, PropTypes.EmberObject]).isRequired
  },

  emailToField: null,
  emailToSubject: null,
  emailToBody: null,

  init() {
    this._super(...arguments);
    const config = this._templateConfig('load_email_template');

    let templateName = this.get('content.letterTemplate');

    this.get('restless').get(config.url, {letter_template_name: templateName}).then((data)=> {
      this.set('emailToField', data.to);
      this.set('emailToSubject', data.subject);
      this.set('emailToBody', data.body);
    });
  },

  _templateConfig(endpoint) {
    return {
      url: `/api/tasks/${this.get('owner.id')}/${endpoint}`
    };
  },

  paper: Ember.computed('paper', function() {
    return this.get('owner').get('paper');
  }),

  buttonLabel: Ember.computed('content.buttonLabel', function() {
    let label = this.get('content.buttonLabel');
    return label ? label : 'Send Email';
  }),

  answer: Ember.computed('content', 'owner', function(){
    return this.get('content').get('answers').findBy('owner', this.get('owner'));
  }),

  emailAnswer: Ember.computed('content', 'owner', function(){
    let answer = this.get('answer');
    if(answer) {
      let value = answer.get('value');
      let emailJSON = value ? JSON.parse(value) : undefined;
      return emailJSON;
    }
    return answer;
  }),

  inputClassNames: ['form-control'],

  actions: {
    updateAnswer(contents) {
      this.set('emailToBody', contents);
    },

    valueChanged(e) {
      let value = e.target ? e.target.value : e;
      this._super(value);
    },

    maybeHideError() {
      if (Ember.isBlank(this.get('answerProxy'))) {
        this.set('hideError', true);
      }
    },

    sendEmail() {
      const config = this._templateConfig('send_message_email');
      let owner = this.get('owner');
      var emailMessage = {
        recipients: [this.get('emailToField')],
        subject: this.get('emailToSubject'),
        body: this.get('emailToBody')};

      if(!this.get('emailToField') || !this.get('emailToSubject') || !this.get('emailToBody')) {
        return;
      }

      this.get('restless').put(config.url, emailMessage).then((data)=> {
        this.set('emailToField', data.to.toString());
        this.set('emailToSubject', data.subject);
        this.set('emailToBody', data.body);
        var emailResult = JSON.stringify(data);
        let content = this.get('content');
        let answer = content.get('answers').findBy('owner', owner) || content.createAnswerForOwner(owner);
        answer.set('value', emailResult);
        answer.save();
      });
    }
  }
});
