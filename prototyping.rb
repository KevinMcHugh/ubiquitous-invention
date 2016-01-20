module Practice
  def self.maybe_affect(person)
    affect(person) if enabled?(behavior)
  end

  def self.all
    [Practice::RitualBathing, Practice::Meditation]
  end

  module RitualBathing
    include Practice
    def self.affect(person)
      person.filth = 0
      person.stress -= 3
    end
  end

  module Meditation
    include Practice
    def self.affect(person)
      person.stress -= Random.rand(3)
      # improve relationships slightly?
    end
  end
end


class Religion
  include Practice::RitualBathing
  include Practice::Meditation
  attr_reader :enabled_behaviors, :people

  def initialize(ritual_bathing=false)
    @enabled_behaviors = { ritual_bathing: ritual_bathing }
  end

  def enabled?(behavior)
    enabled_behaviors[behavior]
  end

  def tick
    people.each do |person|
      Practice.all.each { |b| b.maybe_affect(person) }
    end
  end
end