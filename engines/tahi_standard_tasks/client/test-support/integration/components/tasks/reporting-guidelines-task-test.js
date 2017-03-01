import { test, moduleForComponent } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import { manualSetup, make } from 'ember-data-factory-guy';
import { createCard } from 'tahi/tests/factories/card';
import { createAnswer } from 'tahi/tests/factories/answer';
import registerCustomAssertions from 'tahi/tests/helpers/custom-assertions';
import FakeCanService from 'tahi/tests/helpers/fake-can-service';
import page from 'tahi/tests/pages/reporting-guidelines-task';

moduleForComponent('reporting-guidelines-task', 'Integration | Component | reporting guidelines task', {
  integration: true,
  afterEach() {
    page.removeContext(this);
  },
  beforeEach() {
    page.setContext(this);
    registerCustomAssertions();
    manualSetup(this.container);
    createCard('TahiStandardTasks::ReportingGuidelinesTask');
    let task = make('reporting-guidelines-task');

    // TODO APERTA-9226 remove the useless assignments here ('whatever') and 
    // modify the text on the card content that createCard above ^^ put into the store
    let setText = (ident, text) => {
      this.container.lookup('service:store').peekCardContent(ident).set('text', text);
    };

    setText('reporting_guidelines--clinical_trial', 'Whatever');
    setText('reporting_guidelines--systematic_reviews', 'Check if you can');
    setText('reporting_guidelines--systematic_reviews--checklist', 'Provide a completed PRISMA checklist as supporting information.' );
    setText('reporting_guidelines--meta_analyses', 'Whatever' );
    setText('reporting_guidelines--meta_analyses--checklist', 'Provide a meta analysis checklist');
    setText('reporting_guidelines--diagnostic_studies', 'Whatever' );
    setText('reporting_guidelines--epidemiological_studies', 'Whatever' );
    setText('reporting_guidelines--microarray_studies', 'Whatever' );

    // All task components check if the user has permission to edit
    this.registry.register('service:can', FakeCanService);
    let fake = this.container.lookup('service:can');
    fake.allowPermission('edit', task);

    this.set('task', task);
  }
});

let template = hbs`{{reporting-guidelines-task
                      task=task}}`;

test('Systematic reviews shows a file uploader when checked', function(assert) {
  this.render(template);
  assert.equal(page.questions().count, 6, 'there should be 6 question items on the page');

  let sytematicData = page.systematicReviews.additionalData;
  assert.ok(sytematicData.isHidden, 'additional systematic data initially hidden');
  page.systematicReviews.check();
  assert.ok(sytematicData.isVisible, 'additional systematic data shown when checked');
  assert.ok(sytematicData.questionText.match(/Provide a completed PRISMA checklist/));
});

test('Meta analyses both shows a file uploader when checked', function(assert) {
  this.render(template);

  let metaAnalyses = page.metaAnalyses.additionalData;
  assert.ok(metaAnalyses.isHidden, 'additional metaanalyses data initially hidden');
  page.metaAnalyses.check();
  assert.ok(metaAnalyses.isVisible, 'additional metaanalyses data shown when checked');
  assert.ok(metaAnalyses.questionText.match(/Provide a meta analysis checklist/));
});

test('With an existing attachment, supporting guidelines shows it.', function(assert) {
  let task = this.get('task');
  createAnswer(task, 'reporting_guidelines--systematic_reviews', { value: true });
  createAnswer(
    task,
    'reporting_guidelines--systematic_reviews--checklist',
    { attachments: [make('question-attachment', {filename: 'test-upload.jpg'})] });

  this.render(template);
  assert.equal(page.systematicReviews.additionalData.attachmentName, 'test-upload.jpg');
});

test('With an existing attachment, meta analyses shows it.', function(assert) {
  let task = this.get('task');

  createAnswer(task, 'reporting_guidelines--meta_analyses', { value: true });
  createAnswer(
    task,
    'reporting_guidelines--meta_analyses--checklist',
    { attachments: [make('question-attachment', {filename: 'test-upload.jpg'})] });

  this.render(template);
  assert.equal(page.metaAnalyses.additionalData.attachmentName, 'test-upload.jpg');
});
