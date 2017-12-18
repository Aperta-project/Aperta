import Ember from 'ember';
import TaskComponent from 'tahi/pods/components/task-base/component';

export default TaskComponent.extend({
  flash: Ember.inject.service(),
  restless: Ember.inject.service(),

  // Set in tech check task this inherits from base
  // emailEndpoint
  // bodyKey

  authoringMode: false,
  buttonText: 'Send Changes to Author',
  authorChangesLetter: null,
  successText: `The author has been notified via email that changes are
                needed. They will also see your message the next time they
                log in to see their manuscript.`,
  emailSending: false,

  emailNotAllowed: Ember.computed('task.paper.publishingState', function () {
    return this.get('emailSending') ||
      !(this.get('task.paper.publishingState') === 'submitted');
  }),

  setLetter(callback) {
    const data = {};
    data[this.get('bodyKey')] = this.get('authorChangesLetter');
    this.set('task.body', data);

    this.get('task').save().then(()=> {
      this.get('flash').displayRouteLevelMessage(
        'success', 'Author Changes Letter has been Saved'
      );
      callback();
    });
  },

  actions: {
    setUiLetter() {
      return this.set(
        'authorChangesLetter', this.get('task.body.' + this.get('bodyKey'))
      );
    },

    activateAuthoringMode() {
      this.send('setUiLetter');
      return this.set('authoringMode', true);
    },

    saveLetterBody(contents) {
      this.set('authorChangesLetter', contents);
    },

    saveLetter() {
      return this.setLetter(function() {});
    },

    sendEmail() {
      this.set('emailSending', true);
      this.setLetter(()=> {
        const taskId = this.get('task.id');
        const endpoint = this.get('emailEndpoint');
        const path = '/api/' + endpoint + '/' + taskId + '/send_email';
        this.get('restless').post(path).then(()=> {
          this.get('task.paper').reload();
          this.set('emailSending', false);
        });

        this.set('authoringMode', false);
        this.get('flash').displayRouteLevelMessage('success', this.get('successText'));
      });
    },

    setQuestionSelectedText() {
      const owner = this.get('task');

      const text = owner.get('nestedQuestions').sortBy('position').filter(function(q) {
        return !q.answerForOwner(owner).get('value') && q.get('additionalData');
      }).map(function(question) {
        return question.get('additionalData');
      }).join('<br><br>');

      this.set('authorChangesLetter', text);
    }
  }
});
