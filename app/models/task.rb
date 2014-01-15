class Task < ActiveRecord::Base
  PERMITTED_ATTRIBUTES = []

  default_scope { order("completed ASC") }

  after_initialize :initialize_defaults

  delegate :paper, to: :phase
  delegate :task_manager, to: :phase

  validates :title, :role, presence: true

  belongs_to :assignee, class_name: 'User'
  belongs_to :phase

  class << self
    attr_reader :_default_title, :_default_role

    %w(title role).each do |attr|
      define_method attr do |default_attr|
        instance_variable_set :"@_default_#{attr}", default_attr
      end
    end
  end

  protected

  def initialize_defaults
    self.title = self.class._default_title if title.blank?
    self.role = self.class._default_role if role.blank?
  end
end
