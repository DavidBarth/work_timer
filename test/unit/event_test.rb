require 'test_helper'

class EventTest < ActiveSupport::TestCase
  should belong_to(:project)
  should validate_presence_of(:project)
  should validate_presence_of(:start)
  
  should 'allow start time before end time' do
    event = Factory.build(:event, :start => 1.hour.ago, :end => Time.now)
    assert event.valid?
  end
  
  should 'not allow start time after end time' do
    event = Factory.build(:event, :end => 1.hour.ago, :start => Time.now)
    assert !event.valid?
    assert event.errors[:end]
  end
  
  should 'not allow multiple current events' do
    current_event = Factory.build(:event, :end => nil)
    event = Event.new(:start => Time.now, :comment => 'Second event')
    assert !event.valid?
    assert event.errors[:base]
  end
end
