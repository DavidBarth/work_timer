class Event < ActiveRecord::Base
  belongs_to :project

  default_scope order('start DESC')
  scope :current, where('end IS NULL').order('start DESC')
  scope :completed, where('end IS NOT NULL').order('end DESC')
  
  validates_presence_of :project
  validates_presence_of :start

  validate :check_start_and_end
  validate :only_one_current_event, :on => :create

  def check_start_and_end
    if self.end.present?
      errors.add(:end, 'must come after the start time') if self.end.present? && self.end < self.start
    end
  end
  
  def only_one_current_event
    errors.add(:base, 'Cannot start a new current event while another is running') if Event.current.size > 0
  end
  
  def stop!
    if self.end.nil?
      update_attributes(:end => Time.now)
      true
    else
      false
    end
  end
  
  def resume!
    # only allow ended events to be resumed
    if self.end
      new_event = self.clone
      new_event.start = Time.now
      new_event.end = nil
      new_event.save
    else
      false
    end
  end
  
  def expanded_title
    "#{self.project.client.name}: #{self.project.title}"
  end
end
