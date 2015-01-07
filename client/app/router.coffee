`import Ember from 'ember'`
`import config from './config/environment'`

Router = Ember.Router.extend
  location: config.locationType

Router.map ->
  @route('dashboard', path: '/')
  @route('flow_manager')

  @resource 'paper', { path: '/papers/:publisher_prefix/:suffix' }, ->
    @route('edit')
    @route('manage')

  @resource 'paper', { path: '/papers/:paper_id' }, ->
    @route('edit')
    @route('manage')

  @route('task', { path: '/papers/:paper_id/tasks/:task_id' })
  @route('profile', { path: '/profile' })

  @resource('affiliation')
  @resource('author')

  @resource 'admin', ->
    @resource 'journal_user', path: '/journal_users/:journal_id'
    @resource 'admin.journal', path: '/journals/:journal_id', ->
      @resource 'manuscript_manager_template', path: '/manuscript_manager_templates', ->
        @route('new')
        @route('edit', path: '/:manuscript_manager_template_id/edit')
      @route('flow_manager', path: '/roles/:role_id/flow_manager')

`export default Router`
