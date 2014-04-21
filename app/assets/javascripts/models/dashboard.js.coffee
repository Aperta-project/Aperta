a = DS.attr
ETahi.Dashboard = DS.Model.extend
  assignedTasks: DS.hasMany('task', {polymorphic: true})
  submissions: DS.hasMany('paper')
  user: DS.belongsTo('user')
