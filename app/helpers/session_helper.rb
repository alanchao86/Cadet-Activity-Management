# frozen_string_literal: true

module SessionHelper
  def find_or_create_user(auth)
    # User already set up?
    u = User.find_by(uid: auth['uid'], provider: auth['provider'])
    return u if u

    # User pre-loaded in the database, but not set up for authentication yet?
    # Not sure if this is secure or not
    u = check_preloaded_database(auth)
    return u if u

    # User never seen before?
    create_new_user(auth)
  end

  def check_preloaded_database(auth)
    u = User.find_by(email: auth.dig('info', 'email'))
    return unless u
    raise 'email already associated with a uid??' if u.uid

    u.uid = auth['uid']
    u.provider = auth['provider']
    u.save! if u.changed?
    u
  end

  def create_new_user(auth)
    first_name, last_name = parsed_names(auth)
    User.create!(
      uid: auth['uid'], provider: auth['provider'],
      email: auth.dig('info', 'email'),
      first_name:,
      last_name:,
      unit: Unit.find_by(name: 'Unassigned Outfit'),
      profile_picture: auth.dig('info', 'image'),
      admin_flag: false
    )
  end

  private

  def parsed_names(auth)
    info = auth['info'] || {}
    first_name = info['first_name'].to_s.strip
    last_name = info['last_name'].to_s.strip
    full_name_parts = info['name'].to_s.strip.split(/\s+/)

    first_name = full_name_parts.first.to_s if first_name.blank?
    last_name = full_name_parts[1..].join(' ').to_s if last_name.blank?

    first_name = info['email'].to_s.split('@').first.to_s if first_name.blank?
    last_name = 'N/A' if last_name.blank?

    [first_name, last_name]
  end
end
