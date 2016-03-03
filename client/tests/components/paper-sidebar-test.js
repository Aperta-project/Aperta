import {
  moduleForComponent,
  test
} from 'ember-qunit';

import Ember from 'ember';

moduleForComponent('paper-sidebar', 'PaperSidebarComponent', {
  needs: ['component:sticky-headers', 'service:event-bus']
});

test('Returns submitted message when paper is submitted', function(assert) {
  assert.expect(2);

  let component = this.subject();
  let paper = Ember.Object.create();
  component.set('paper', paper);
  this.render();
  // Assert initial content of the component
  let initialContent = $.trim(this.$().text());
  assert.equal(initialContent, '');

  Ember.run(function() {
    //note NOT gradual engagment,
    //this is more thoroughly tested in a feature
    //spec: spec/features/gradual_engagement.rb
    paper.set('publishingState', 'submitted');
  });

  let finalContent = $.trim(this.$().text());
  assert.equal(finalContent, 'This paper has been submitted.');
});

test('Shows submit if all task completed and submittable', function(assert) {
  assert.expect(1);

  let fakeSubmittableTask = Ember.Object.create({
    isSubmissionTask: false,
    participations: []
  });

  let fakeSubmittablePaper = Ember.Object.create({
    publishingState: 'unsubmitted',
    tasks: [fakeSubmittableTask]
  });

  this.subject({paper: fakeSubmittablePaper});
  this.render();

  let buttonText = $.trim(this.$().find('button').text());
  assert.equal(buttonText, 'Submit');
});
