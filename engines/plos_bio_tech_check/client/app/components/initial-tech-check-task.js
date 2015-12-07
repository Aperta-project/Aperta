import TaskComponent from 'tahi/pods/components/task-base/component';
import Ember from 'ember';

const SUCCESS_TEXT = `The author has been notified via email that changes are
                      needed. They will also see your message the next time
                      they log in to see their manuscript.`;

export default TaskComponent.extend({
  flash: Ember.inject.service(),
  restless: Ember.inject.service(),

  authoringMode: false,
  buttonText: 'Send Changes to Author',
  authorChangesLetter: null,

  init() {
    this._super(...arguments);

    this.set(
      'authorChangesLetter',
      this.get('task.changesForAuthorTask.body.initialTechCheckBody')
    );
  },

  setLetter(callback) {
    this.set('task.body', {
      initialTechCheckBody: this.get('authorChangesLetter')
    });

    this.get('task').save().then(()=> {
      this.get('flash').displayMessage(
        'success', 'Author Changes Letter has been Saved'
      );
      callback();
    });
  },

  actions: {
    setUiLetter() {
      this.set(
        'authorChangesLetter', this.get('task.body.initialTechCheckBody')
      );
    },

    activateAuthoringMode() {
      this.send('setUiLetter');
      return this.set('authoringMode', true);
    },

    saveLetter() {
      this.setLetter(function() {});
    },

    sendEmail() {
      this.setLetter(()=> {
        const taskId = this.get('task.id');
        const path = '/api/initial_tech_check/' + taskId + '/send_email';
        this.get('restless').post(path);

        this.set('authoringMode', false);
        this.get('flash').displayMessage('success', SUCCESS_TEXT);
      });
    },

    setQuestionSelectedText() {
      const owner = this.get('task');

      const text = owner.get('nestedQuestions').filter(function(q) {
        return !q.answerForOwner(owner).get('value') && q.get('additionalData');
      }).map(function(question) {
        return question.get('additionalData');
      }).join('\n\n');

      return this.set('authorChangesLetter', text);
    }
  }
});
