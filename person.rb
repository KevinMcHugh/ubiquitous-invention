class Person
  include RollsDice
  attr_reader :first_name, :last_name, :alive, :age, :gender, :religion, :pregnant
  attr_reader :cause_of_death, :year_of_death, :year_of_birth, :months_until_birth
  attr_accessor :health

  def initialize(religion, last_name=Faker::Name.last_name, year=nil)
    @first_name = Faker::Name.first_name
    @last_name  = last_name
    @health = 75 + d(50)
    @alive = true
    @gender = d(2) == 1 ? :man : :woman
    @religion = religion
    if year
      @year_of_birth = year
      @age = 0
    else
      @age = d(70)
      @year_of_birth = -age
    end
  end

  def alive?; alive; end

  def kill!
    @alive = false
  end

  def tick(policy, world)
    consequence_value = policy && policy.consequence || 100
    check = (100 - consequence_value)
    event = world.active_event

    subtract_health(event.severity, event.affects, world.year) if check < event.severity
    reproduce!(world.year)
    age!(world.year)
    kill! if health <= 0
  end

  def age!(year)
    @age += 1
    if (age > 45 && health > 10) || age < 80
      subtract_health(1, :old_age, year)
    else
      @health += 1
    end
  end

  def subtract_health(int, reason, year)
    return unless alive?
    @health -= int
    if health <= 0
      kill!
      @cause_of_death = reason
      @year_of_death = year
    end
  end

  def reproduce!(year)
    return unless alive?
    if pregnant
      religion.add_member(Person.new(religion, last_name, year))
      @pregnant = false
    elsif (age > 15 && age < 45) && d(2) == 2
      @pregnant = true
    end
  end
end