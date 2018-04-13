/**
 * Copyright (c) 2018 Public Library of Science
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
*/

import Ember from 'ember';
import ValidationErrorsMixin from 'tahi/mixins/validation-errors';
import { PropTypes } from 'ember-prop-types';
import QAIdent from 'tahi/mixins/components/qa-ident';

export default Ember.Component.extend(QAIdent, ValidationErrorsMixin, {
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
      this.set('emailToField', data.letter_template.to);
      this.set('emailToSubject', data.letter_template.subject);
      this.set('emailToBody', data.letter_template.body);
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
      let emailJSON = value ? JSON.parse(value).letter_template : undefined;
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
        this.set('emailToField', data.letter_template.to.toString());
        this.set('emailToSubject', data.letter_template.subject);
        this.set('emailToBody', data.letter_template.body);
        var emailResult = JSON.stringify(data);
        let content = this.get('content');
        let answer = content.get('answers').findBy('owner', owner) || content.createAnswerForOwner(owner);
        answer.set('value', emailResult);
        answer.save();
      });
    }
  }
});
