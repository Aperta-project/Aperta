import Ember from 'ember';
import TaskComponent from 'tahi/pods/components/task-base/component';
import Ember from 'ember';

export default TaskComponent.extend({
  flash: Ember.inject.service(),
  restless: Ember.inject.service(),

  authoringMode: false,
  successText: 'The author has been notified via email that changes are needed. They will also see your message the next time they log in to see their manuscript.',
  buttonText: 'Send Changes to Author',
  authorChangesLetter: (function() {}).property(),

  setLetter(callback) {
    this.set('model.body', {
      revisedTechCheckBody: this.get('authorChangesLetter')
    });

    this.get('model').save().then(()=> {
      this.get('flash')
          .displayMessage('success', 'Author Changes Letter has been Saved');

      callback();
    });
  },

  actions: {
    setUiLetter() {
      return this.set(
        'authorChangesLetter', this.get('model.body.revisedTechCheckBody')
      );
    },

    activateAuthoringMode() {
      this.send('setUiLetter');
      return this.set('authoringMode', true);
    },

    saveLetter(callback1) {
      this.callback = callback1;
      return this.setLetter(function() {});
    },

    sendEmail() {
      this.setLetter(()=> {
        const path = `/api/revision_tech_check/#{@get('model.id')}/send_email`;
        this.get('restless').post(path);

        this.set('authoringMode', false);
        this.get('flash').displayMessage('success', this.get('successText'));
      });
    },

    setQuestionSelectedText() {
      const owner = this.get('model');
      const text = this.get('model.nestedQuestions').filter(function(q) {
        return !q.answerForOwner(owner).get('value') && q.get('additionalData');
      }).map(function(question) {
        return question.get('additionalData');
      }).join('\n\n');

      return this.set('authorChangesLetter', text);
    }
  }
});
