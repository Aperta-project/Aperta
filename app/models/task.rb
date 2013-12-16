class Task < ActiveRecord::Base
  PERMITTED_ATTRIBUTES = []

  after_initialize :initialize_defaults

  validates :title, :role, presence: true

  class << self
    attr_reader :_default_title, :_default_role

    %w(title role).each do |attr|
      define_method attr do |default_attr|
        instance_variable_set :"@_default_#{attr}", default_attr
      end
    end
  end

  belongs_to :assignee, class_name: 'User'
  belongs_to :phase

  delegate :task_manager, to: :phase

  protected

  def initialize_defaults
    self.title = self.class._default_title if title.blank?
    self.role = self.class._default_role if role.blank?
  end
end
