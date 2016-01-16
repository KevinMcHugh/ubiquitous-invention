class Person
  attr_reader :name, :alive
  attr_accessor :religion, :health

  def initialize
    @name = Faker::Name.name
    @health = 75 + Random.rand(50)
    @alive = true
  end

  def alive?
    alive
  end

  def kill!
    @alive = false
  end
end

class Religion
  attr_reader :name, :faithful, :policies
  def initialize(name)
    @name = name
    @faithful = 100.times.map { Person.new }
    @faithful.each { |f| f.religion = self }
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

require 'faker'
require 'pp'
require 'pry'
religions = 5.times.map do
  r = Religion.new(Faker::App.name)
  puts r.long_string
  r
end

100.times do |i|
  event = Policy.acts.sample
  difficulty = Random.rand(100)
  population = religions.map(&:number_of_living_faithful).reduce(:+)

  break if population <= 0
  puts "Year #{i}: A plague strikes those who #{event}. Severity is #{difficulty}%"
  religions.each do |r|
    if r.number_of_living_faithful > 0
      policy = r.policies.find { |p| p.act == event }
      consequence_value = policy && policy.consequence || 100
      check = (100 - consequence_value)
      pre = r.number_of_living_faithful
      if check < difficulty
        r.faithful.each { |person| person.health -= 0.10 * difficulty }
      end
      r.faithful.each { |person| person.kill! if person.health <= 0 }
      post = r.number_of_living_faithful
      puts "   The faithful of #{r.name} number #{post}. #{pre - post} have died in the plague."
    end
  end
end



