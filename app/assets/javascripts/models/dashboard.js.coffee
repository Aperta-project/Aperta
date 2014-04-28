a = DS.attr
ETahi.Dashboard = DS.Model.extend
  assignedTasks: DS.hasMany('cardThumbnail')
  submissions: DS.hasMany('litePaper')
  user: DS.belongsTo('user')
