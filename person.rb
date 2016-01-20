class Person
  include RollsDice
  attr_reader :name, :alive, :age, :gender, :religion, :months_until_birth, :pregnant
  attr_reader :cause_of_death, :year_of_death
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

  def tick(policy, world)
    consequence_value = policy && policy.consequence || 100
    check = (100 - consequence_value)
    event = world.active_event

    subtract_health(event.severity, event.affects, world.year) if check < event.severity

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

  def reproduce!
    if (age > 15 && age < 45) && d(2) == 1 && !pregnant
      @pregnant = true
      @months_until_birth = 9
    end
  end
end