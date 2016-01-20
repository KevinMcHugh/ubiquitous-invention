module RollsDice
  def d(int)
    Random.rand(int) + 1
  end
end
class Person
  include RollsDice
  attr_reader :name, :alive, :age, :gender, :religion, :months_until_birth, :pregnant
  attr_accessor :health

  def initialize(religion)
    @name = Faker::Name.name
    @health = 75 + d(50)
    @alive = true
    @age = d(70)
    @gender = d(2) == 1 ? :man : :woman
    @religion = religion
  end

  def alive?; alive; end

  def kill!
    @alive = false
  end

  def tick(policy, active_event)
    consequence_value = policy && policy.consequence || 100
    check = (100 - consequence_value)

    if check < active_event.severity
      @health -= active_event.severity
    end

    kill! if health <= 0
  end

  def age!
    @age += 1
    if (age > 45 && health > 10) || age < 80
      health -= 1
    else
      health += 1
    end
  end

  def reproduce!
    if (age > 15 && age < 45) && d(2) == 1 && !pregnant
      @pregnant = true
      @months_until_birth = 9
    end
  end
end

class Religion
  attr_reader :world, :name, :faithful, :policies
  def initialize(world)
    @world = world
    @name = Faker::App.name
    @faithful = 100.times.map { Person.new(self) }
    @policies = 3.times.map { Policy.new }
  end

  def long_string
    "Religion #{name}, \n" +
      "     Policies #{policies.map(&:inspect)}\n" +
      "     Alive: #{number_of_living_faithful}/ #{faithful.count}"
  end

  def inspect
    name
  end

  def number_of_living_faithful
    faithful.count(&:alive?)
  end

  def tick
    return unless number_of_living_faithful > 0
    pre = number_of_living_faithful

    policy = policies.find { |p| p.act == world.active_event.affects }
    faithful.each { |p| p.tick(policy, world.active_event) }
    post = number_of_living_faithful
    puts "   The faithful of #{name} number #{post}. #{pre - post} have died in the plague."
  end
end

class Policy
  def self.acts
    [:eat_pork, :eat_beef, :eat_vegetarian, :eat_dairy, :eat_seafood]
  end

  def self.consequences
    [5, 10, 25, 50, 75]
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

  def tick
    @year += 1
    @active_event = Event.new
    puts "Year #{year}: A plague strikes those who #{active_event.affects}. Severity is #{active_event.severity}%"
    religions.each(&:tick)
  end
end

class Event
  include RollsDice
  attr_reader :affects, :severity
  def initialize
    @affects = Policy.acts.sample
    @severity = d(100)
  end
end

require 'faker'
require 'pp'
require 'pry'
world = World.new
religions = 5.times.map do
  r = world.add_religion
  puts r.long_string
  r
end

100.times do |i|
  break if world.population <= 0

  world.tick
end
