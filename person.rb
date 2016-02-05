class Person
  include RollsDice
  attr_reader :given_name, :family_name, :alive, :age, :child_bearing, :religion, :pregnant
  attr_reader :cause_of_death, :year_of_death, :year_of_birth, :months_until_birth
  attr_accessor :health

  def initialize(religion, family_name=Faker::Name.last_name, year=nil)
    @given_name = Faker::Name.first_name
    @family_name  = family_name
    @health = 175 + d(50)
    @alive = true
    @child_bearing = [true, false].sample
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
    #TODO check affected species.

    subtract_health(event.severity, event.affected_species, world.year) if check < event.severity
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
      religion.add_member(Person.new(religion, "O'#{family_name}", year))
      @pregnant = false
    elsif (age >= minimum_pregnancy_age && age <= maximum_pregnancy_age) && child_bearing
      @pregnant = true
    end
  end

  def minimum_pregnancy_age; 20; end
  def maximum_pregnancy_age; 45; end

  def to_s
    if child_bearing
      if pregnant
        pregnancy = "pregnant"
      elsif age < minimum_pregnancy_age
        pregnancy = "child"
      elsif age > maximum_pregnancy_age
        pregnancy = "elder"
      else
        pregnancy = "not_pregnant"
      end
    else
      pregnancy = "not_child_bearing"
    end
    "          #{given_name} #{family_name}:#{age}:#{pregnancy}"
  end
end