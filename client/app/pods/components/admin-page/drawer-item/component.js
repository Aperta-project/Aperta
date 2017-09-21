import Ember from 'ember';
import JournalAdminMixin from 'tahi/mixins/components/journal-administratable';

export default Ember.Component.extend(JournalAdminMixin, {
  classNames: ['admin-drawer-item'],

  initials: Ember.computed('journal.initials', function() {
    if (this.get('journal')) {
      return this.get('journal.initials');
    } else {
      return 'all';
    }
  }),

  title: Ember.computed('journal.name', function() {
    if (this.get('journal')) {
      return this.get('journal.name');
    } else {
      return 'All My Journals';
    }
  }),

  linkId: Ember.computed('journal', function() {
    if (this.get('journal')) {
      return this.get('journal.id');
    } else {
      return 'all';
    }
  }),

  // the `canAdminJournal` property can be found in the mixin referenced at the top
  linkValue: Ember.computed('canAdminJournal', function() {
    const linkBase = 'admin.journals.';

    if(this.get('canAdminJournal')) {
      return linkBase + 'workflows';
    } else {
      return linkBase + 'users';
    }
  }),
});
