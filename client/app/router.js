import Ember from 'ember';
import config from './config/environment';

const Router = Ember.Router.extend({
  location: config.locationType,
  rootURL: config.rootURL
});

Router.map(function() {
  this.route('dashboard', { path: '/' }, function() {});

  this.route('paper_tracker', function() {});

  this.route('paper', { path: '/papers/:paper_shortDoi' }, function() {
    this.route('index', { path: '/' }, function() {
      this.route('discussions', function() {
        this.route('new',  { path: '/new' });
        this.route('show', { path: '/:topic_id' });
      });
    });

    this.route('versions', { path: '/versions' });

    this.route('correspondence', { path: '/correspondence' }, function() {
      this.route('viewcorrespondence',  { path: '/viewcorrespondence/:id' });
    });


    this.route('workflow', function() {
      this.route('discussions', function() {
        this.route('new',  { path: '/new' });
        this.route('show', { path: '/:topic_id' });
      });
    });

    this.route('task', { path: '/tasks' }, function() {
      this.route('index', { path: '/:task_id' });
      this.route('version', { path: '/:task_id/version' });
    });
  });

  this.route('discussions', function() {
    this.route('paper', {path: '/:paper_shortDoi'}, function() {
      this.route('index', {path: '/'});
      this.route('new', { path: '/new'});
      this.route('show', { path: '/:topic_id' });
    });
  });

  this.route('profile', { path: '/profile' });

  this.route('admin', function() {
    this.route('cc', function() {
      this.route('journals', { path: '/journals/:journal_id' }, function() {
        this.route('cards');
        this.route('workflows');
        this.route('users');
        this.route('settings');
        this.route('emailtemplates');
      });
      this.route('card', { path: '/card/:card_id' }, function() {
        this.route('preview', { path: '/' });
        this.route('edit');
        this.route('permissions');
        this.route('history');
      });
      this.route('edit_email', { path: 'journals/emailtemplates/:email_id/edit' });
    });
    this.route('mmt', function() {
      this.route('journal', { path: '/journals/:journal_id' }, function() {
        this.route('manuscript_manager_template', { path: '/manuscript_manager_templates' }, function() {
          this.route('new');
          this.route('edit', { path: '/:manuscript_manager_template_id/edit' });
        });
      });
    });
    this.route('feature_flags');
  });
});

export default Router;
