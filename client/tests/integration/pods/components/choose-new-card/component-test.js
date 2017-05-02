import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import sinon from 'sinon';
import Ember from 'ember';

moduleForComponent('choose-new-card', 'Integration | Component | choose new card', {
  integration: true
});

const phase = Ember.Object.create({ name: 'my phase' });
const card = Ember.Object.create({ name: 'customized card', addable: true });
const draftCard = Ember.Object.create({ name: 'customized draft card', addable: false });
const save = sinon.spy();
const close = sinon.spy();

test('it shows three columns containing correct cards', function(assert) {
  this.set('phase', phase);
  this.set('cards', [card, draftCard]);
  this.on('save', save);
  this.on('close', close);

  const authorJournalTaskType = Ember.Object.create({ title: 'author jtt', roleHint: 'author' });
  const staffJournalTaskType = Ember.Object.create({ title: 'staff jtt', roleHint: 'staff' });
  const journalTaskTypes = [authorJournalTaskType, staffJournalTaskType];
  this.set('journalTaskTypes', journalTaskTypes);

  this.render(hbs`
    {{choose-new-card phase=phase
                      journalTaskTypes=journalTaskTypes
                      cards=cards
                      isLoading=false
                      onSave=(action 'save')
                      close=(action 'close')}}`);

  assert.textPresent('.author-task-cards label', 'author jtt');
  assert.textPresent('.staff-task-cards label', 'staff jtt');
  assert.textPresent('.custom-cards label', 'customized card', 'the addable card is shown');
  assert.textNotPresent('.custom-cards label', 'customized draft card', 'the non-addable card is not shown');
});

test('it shows message in custom cards column when there are no custom cards', function(assert) {
  this.set('phase', phase);
  this.on('save', save);
  this.on('close', close);

  this.render(hbs`
    {{choose-new-card phase=phase
                      journalTaskTypes=[]
                      cards=[]
                      isLoading=false
                      onSave=(action 'save')
                      close=(action 'close')}}`);

  assert.textPresent('.custom-cards', 'No cards are available');
});

test('it makes call to save all selected cards', function(assert) {
  this.set('phase', phase);
  this.set('cards', [card]);
  this.on('save', save);
  this.on('close', close);

  const authorJournalTaskType = Ember.Object.create({ title: 'author jtt', roleHint: 'author' });
  const staffJournalTaskType = Ember.Object.create({ title: 'staff jtt', roleHint: 'staff' });
  const journalTaskTypes = [authorJournalTaskType, staffJournalTaskType];
  this.set('journalTaskTypes', journalTaskTypes);

  this.render(hbs`
    {{choose-new-card phase=phase
                      journalTaskTypes=journalTaskTypes
                      cards=cards
                      isLoading=false
                      onSave=(action 'save')
                      close=(action 'close')}}`);

  // select checkbox on all cards to be added
  this.$("input[type='checkbox']").click();

  // click add
  this.$('button.button-primary').click();

  assert.ok(save.calledWith(phase, [authorJournalTaskType, staffJournalTaskType, card]), 'Should call save action');
});
