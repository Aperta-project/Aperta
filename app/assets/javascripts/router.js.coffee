# For more information see: http://emberjs.com/guides/routing/
ETahi.Router.map ()->
  @resource 'paper', { path: '/papers/:paper_id' }, ->
    @route('manage')
    @route('task', {path: '/tasks/:task_id'})
  @resource 'phase', path: '/phases/:phase_id'

ETahi.Router.reopen({
  rootURL: '/ember/'
})

