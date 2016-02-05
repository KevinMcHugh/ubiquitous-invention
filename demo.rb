module RollsDice
  def d(int)
    Random.rand(int) + 1
  end
end

class Religion
  attr_reader :world, :name, :faithful, :policies
  def initialize(world)
    @world = world
    @name = Faker::Name.first_name
    @faithful = 100.times.map { Person.new(self) }
    @policies = 3.times.map { Policy.new }
  end

  def long_string
    "Religion #{name}, \n" +
      "     Policies #{policies.map(&:inspect)}\n" +
      "     Alive: #{number_of_living_faithful}/ #{faithful.count}"
  end

  def inspect; name;end

  def number_of_living_faithful
    faithful.count(&:alive?)
  end

  def add_member(person)
    @faithful << person
  end

  def tick
    return unless number_of_living_faithful > 0

    policy = policies.find { |p| p.act == world.active_event.affected_species }
    faithful.each { |p| p.tick(policy, world) }
    puts "   The followers of #{name} number #{number_of_living_faithful}."
  end
end

class Policy
  def self.acts
    # TODO none of this works as it should.
    []
  end

  def self.consequences
    []
  end

  attr_reader :act, :consequence
  def initialize
    @act = self.class.acts.sample
    @consequence = self.class.consequences.sample
  end

  def inspect
    "#{act} => #{consequence}"
  end
end

class World
  def self.species
    [:chicken, :cow, :fish, :pork, :vegetables]
  end

  attr_reader :active_event, :religions, :year
  def initialize
    @year = 0
    @religions = []
  end

  def add_religion
    r = Religion.new(self)
    religions << r
    r
  end

  def population
    religions.map(&:number_of_living_faithful).reduce(:+)
  end

  def people
    religions.flat_map(&:faithful)
  end

  def species; self.class.species; end

  def tick
    @year += 1
    @active_event = Plague.new(self)
    puts "Year #{year}: #{@active_event.to_s}"

    religions.each(&:tick)

    causes_of_death = people.find_all { |p| p.year_of_death == year }.map(&:cause_of_death)
    causes_of_death.inject(Hash.new(0)) { |h, e| h[e] += 1 ; h }.each_pair do |cause, count|
      puts "  #{count} have died due to #{cause}"
    end
    newly_born_or_not = {true => [], false => []}
      .merge(people
      .find_all(&:alive?)
      .group_by { |p| p.year_of_birth == year })

    puts "    #{newly_born_or_not[true].count} are born this year."
    puts "    #{newly_born_or_not[false].count} survive."
    puts "  Total population is #{population}"
    age_brackets = people.find_all(&:alive?).map {|p| p.age / 10 }
    age_counts = Hash.new(0)
    age_brackets.each do |age|
      age_counts[age] += 1
    end

    # puts "    #{age_counts.sort.to_h}"
    puts people.find_all(&:alive?).sort_by(&:age).map(&:to_s)
  end
end

class Event
  include RollsDice
end

class Plague < Event
  attr_reader :affected_species, :viability, :severity
  def initialize(world)
    @affected_species = world.species.sample([0,0,1,1,1,2].sample)
    @viability = d(50)
    @severity = d(20)
    @severity *= 5 if affected_species.include?(:human)
  end

  def to_s
    if affected_species.any?
      "A plague strikes #{affected_species}! Viability is #{viability}% and Severity is #{severity}%."
    end
  end
end

require 'faker'
require 'pp'
require 'pry'
require_relative 'person'
world = World.new
1.times do
  r = world.add_religion
  puts r.long_string
  r
end

100.times do |i|
  break if world.population <= 0
  world.tick
end
