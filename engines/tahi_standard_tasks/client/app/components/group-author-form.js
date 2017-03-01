import Ember from 'ember';
import { contributionIdents } from 'tahi/models/group-author';
import CommonAuthorForm from 'tahi/mixins/components/common-author-form';

export default Ember.Component.extend(CommonAuthorForm, {
  classNames: ['author-form', 'group-author-form'],

  authorContributionIdents: contributionIdents
});
