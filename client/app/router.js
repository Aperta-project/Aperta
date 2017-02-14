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

  this.route('profile', { path: '/profile' });

  this.route('admin', function() {
    this.route('journals', function() {});

    this.route('journal', { path: '/journals/:journal_id' }, function() {
      this.route('manuscript_manager_template', { path: '/manuscript_manager_templates' }, function() {
        this.route('new');
        this.route('edit', { path: '/:manuscript_manager_template_id/edit' });
      });

    });
    this.route('feature-flags');
  });
});

export default Router;
