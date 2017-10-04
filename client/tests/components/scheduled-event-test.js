import {
  moduleForComponent,
  test
} from 'ember-qunit';

import FactoryGuy from 'ember-data-factory-guy';
import { manualSetup } from 'ember-data-factory-guy';
import hbs from 'htmlbars-inline-precompile';
import moment from 'moment';

moduleForComponent('review-status', 'Integration | Component | Scheduled Event', {
  integration: true,

  beforeEach() {
    manualSetup(this.container);
    let dueDate = moment('2020-08-19', 'YYYY-MM-DD');
    this.set('dueDate', dueDate);
  }
});

test('renders future scheduled differences properly', function (assert) {
  let scheduledEvents = [
    FactoryGuy.make('scheduled-event', {
      name: 'Pre Event',
      dispatchAt: moment(this.get('dueDate')).add(2, 'days')
    }),
  ];
  this.set('events', scheduledEvents);
  this.render(hbs`{{scheduled-events events=events dueDate=dueDate}}`);
  assert.textPresent('.scheduled-event p', '2 days after due date');
});

test('renders past scheduled differences properly', function (assert) {
  let scheduledEvents = [
    FactoryGuy.make('scheduled-event', {
      name: 'Pre Event',
      dispatchAt: moment(this.get('dueDate')).subtract(2, 'days')
    }),
  ];
  this.set('events', scheduledEvents);
  this.render(hbs`{{scheduled-events events=events dueDate=dueDate}}`);
  assert.textPresent('.scheduled-event p', '2 days before due date');
});
