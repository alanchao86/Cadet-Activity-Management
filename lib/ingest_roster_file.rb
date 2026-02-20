# frozen_string_literal: true

require 'csv'

class IngestRosterFile
  def confirm_unit(name, cat, parent)
    return nil if name == ''

    unit = Unit.find_by(name:, cat:)
    unit = Unit.create!(name:, cat:, parent:) if unit.nil?

    return unit if cat == 'cmdt'

    if unit.parent.nil?
      unit.parent = parent
      unit.save!
    end

    if !parent.nil? && parent != unit.parent
      puts "Skipping on #{name} #{cat} - wanting #{parent.name}, current #{unit.parent.name}"
      return nil
    end

    unit
  end

  def create_units(row)
    is_cmdt_staff =
      row['Cadet/Unit'] == 'CORPS Staff' ||
      row['Cadet/Unit'] == 'CMDT Staff'

    outfit_only =
      row['Cadet/Major Unit'] == 'CS' ||
      row['Cadet/Unit'].include?('Staff') ||
      row['Cadet/Unit'] == 'LOA'

    if is_cmdt_staff
      confirm_unit(row['Cadet/Unit'], 'cmdt', nil)
    elsif outfit_only
      confirm_unit(row['Cadet/Outfit'], 'outfit', nil)
    else
      cmdt = confirm_unit('CMDT Staff', 'cmdt', nil)
      major = confirm_unit(row['Cadet/Major Unit'], 'major', cmdt)
      minor = confirm_unit(row['Cadet/Minor Unit'], 'minor', major)
      confirm_unit(row['Cadet/Outfit'], 'outfit', minor)
    end
  end

  def confirm_unit_name(row)
    unit = row['Cadet/Unit']
    if unit.include?('Staff') && unit != 'CORPS Staff' && unit != 'CMDT Staff'
      if unit == 'Band Staff'
        'BAND'
      else
        # Remove 'Staff' and strip trailing/leading whitespace
        unit.gsub('Staff', '').strip
      end
    elsif unit == 'LOA'
      row['Cadet/Outfit']
    else
      unit
    end
  end

  def create_users(row)
    unit = confirm_unit_name(row)
    # puts "Processing: #{row['Cadet/Email']} - First: '#{row['Cadet/First']}' - Last: '#{row['Cadet/Last']}' - Unit: '#{unit}'"

    existing_user = User.find_by(email: row['Cadet/Email'])

    return { status: :error, message: "User with email #{row['Cadet/Email']} already exists." } if existing_user

    User.create!(
      email: row['Cadet/Email'],
      first_name: row['Cadet/First'],
      last_name: row['Cadet/Last'],
      uid: nil,
      provider: 'preloaded_google',
      admin_flag: false,
      major: row['Cadet/Major Unit'],
      minor: row['Cadet/Minor Unit'],
      unit_name: row['Cadet/Unit'],
      unit_id: Unit.find_by!(name: unit).id
    )
    { status: :success }
  end

  def process_roster_row(row)
    if row['Cadet/Outfit'].nil?
      puts "Skipping #{row['Cadet/Email']}"
      return
    end
    create_units(row)
    create_users(row)
  end

  def ingest_roster_file(file_path)
    csv = CSV.open(file_path, headers: true)
    errors = []
    csv.each do |row|
      ret = process_roster_row(row)
      errors.push(ret[:message]) if ret[:status] == :error
    end
    errors
  end
end

if __FILE__ == $PROGRAM_NAME
  base_path = 'lib/assets/Overhead - Master Cadet Roster.csv'
  base_path = Regexp.last_match(1) if Regexp.last_match(1)

  IngestRosterFile.new.ingest_roster_file(base_path)
end
