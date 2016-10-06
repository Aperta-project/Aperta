import { test, moduleForComponent } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import { manualSetup, make } from 'ember-data-factory-guy';
import registerCustomAssertions from 'tahi/tests/helpers/custom-assertions';
import FakeCanService from 'tahi/tests/helpers/fake-can-service';
import Ember from 'ember';

let createQA = (task, ident, answerValue) => {
  let answer = make('nested-question-answer', {value: answerValue, owner: task});
  let question = make('nested-question', {
    ident: ident,
    answers: [answer],
    owner: task
  });

  task.get('nestedQuestions').addObject(question);
};

moduleForComponent('reporting-guidelines-task', 'Integration | Component | reporting guidelines task', {
  integration: true,
  beforeEach() {
    registerCustomAssertions();
    manualSetup(this.container);
    let task = make('reporting-guidelines-task');

    createQA(task, 'reporting_guidelines--clinical_trial', 'Whatever' );
    createQA(task, 'reporting_guidelines--systematic_reviews', 'Systematic Reviews' );
    createQA(task, 'reporting_guidelines--systematic_reviews--checklist', 'Provide a completed PRISMA checklist as supporting information.' );
    createQA(task, 'reporting_guidelines--meta_analyses', 'Whatever' );
    createQA(task, 'reporting_guidelines--meta_analyses--checklist', 'Whatever' );
    createQA(task, 'reporting_guidelines--diagnostic_studies', 'Whatever' );
    createQA(task, 'reporting_guidelines--epidemiological_studies', 'Whatever' );
    createQA(task, 'reporting_guidelines--microarray_studies', 'Whatever' );

    this.registry.register('service:can', FakeCanService);
    let fake = this.container.lookup('service:can');
    fake.allowPermission('edit', task);

    this.set('task', task);
  }
});

let template = hbs`{{reporting-guidelines-task
                      task=task}}`;

test('Supporting Guideline is a meta data card, contains the right questions and sub-questions', function(assert) {
  const findQuestionLi = function(questionText) {
    return $('.question .item').filter(function(i, el) {
      return Ember.$(el).find('label').text().trim() === questionText;
    });
  };

  this.render(template);
  assert.equal($('.question .item').length, 6);
  var questionLi = findQuestionLi('Systematic Reviews');
  // assert.ok(!questionLi.find('.additional-data input[type=file]').length);

  $('input[name="reporting_guidelines--systematic_reviews"]').click();
  questionLi = findQuestionLi('Systematic Reviews');
  assert.equal(0, questionLi.find('.additional-data.hidden').length);
  // assert.ok(questionLi.find('.additional-data input[type=file]').length);
  // const additionalDataText = questionLi.find('.additional-data').text();
  // assert.ok(additionalDataText.indexOf('Select & upload') > -1);
  // return assert.ok(additionalDataText.indexOf('Provide a completed PRISMA checklist as supporting information.') > -1);
});
