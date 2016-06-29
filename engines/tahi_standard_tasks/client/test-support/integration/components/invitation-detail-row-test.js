import {moduleForComponent, test} from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import Ember from 'ember';

moduleForComponent('invitation-detail-row',
                    'Integration | Component | invitation detail row', {
                      integration: true,
                      beforeEach: function() {
                        this.set('update-date', new Date('January 01, 2016'));
                        this.set('destroyAction', () => {return;});
                        this.set('invitation', Ember.Object.create({
                          title: 'Awesome Paper!',
                          updatedAt: this.get('update-date'),
                          state: 'pending',
                          accepted: false,
                          email: 'jane@example.com',
                          invitee: Ember.Object.create({
                            fullName: 'Jane McEdits'
                          })
                        }));
                      }
                    });

let template = hbs`{{invitation-detail-row
                      invitation=invitation
                      destroyAction=destroyAction}}`;

test('displays invitation information', function(assert){
  this.render(template);

  assert.textPresent('.invitation-updated-at',
                     moment(this.get('update-date')).format('LLL'));
  assert.textPresent('.invitation-state', 'pending');
});

test('displays invitee information when present', function(assert){
  this.render(template);
  assert.elementFound('.invitee-thumbnail');
  assert.textPresent('.invitee-full-name', 'Jane McEdits');
  assert.textNotPresent('.invitee-full-name', 'jane@example.com');
});

test('displays invitation email when no invitee present', function(assert){
  this.set('invitation.invitee', null);
  this.render(template);
  assert.textNotPresent('.invitee-full-name', 'Jane McEdits');
  assert.textPresent('.invitee-full-name', 'jane@example.com');
});

test('displays remove icon if invite not accepted and given destroyAction',
  function(assert){
    this.render(template);
    assert.elementFound('.invite-remove');
  }
);

test('does not display remove icon if invite accepted',
  function(assert){
    this.set('invitation.accepted', true);
    this.render(template);
    assert.elementNotFound('.invite-remove');
  }
);

test('does not display remove icon if invite not accepted and no destroyAction',
  function(assert){
    this.set('destroyAction', null);
    this.render(template);
    assert.elementNotFound('.invite-remove');
  }
);
