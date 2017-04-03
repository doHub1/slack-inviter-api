# Accepted invites Exporter
class AcceptedInvitesExporter
  attr_accessor :page, :agent

  def initialize
    @page = nil
    @agent = Mechanize.new
  end

  def get_inviter_id(user_id)
    move_to_invites_page
    export_inviter_id(user_id)
  end

  private

  def login
    team_subdomain = ENV['TEAM_SUBDOMAIN']
    email          = ENV['EMAIL']
    password       = ENV['PASSWORD']

    invites_page_url = "https://#{team_subdomain}.slack.com/admin/invites"

    page = agent.get(invites_page_url)
    return if page.title.include?('Invitations')

    page.form.email = email
    page.form.password = password
    @page = page.form.submit
  end

  def move_to_invites_page
    counter = 0
    login
    counter += 1
    loop do
      break if page.title.include?('Invitations')
      if counter > 3
        fail 'login_failed'
      end
      if page.form && page.form['signin_2fa']
        fail '2factor_auth_not_supported'
      else
        logger.info 'Login failure. Try again.'
        login
        counter += 1
      end
    end
  end

  def export_inviter_id(user_id)
    accepted_invites = page.body.scan(/boot_data.accepted_invites = (.+?\]);/)
    invites = JSON.parse(accepted_invites[0][0])
    inviter_id = 'user_not_found'
    invites.map do |invite|
      if invite['user']['id'] == user_id
        inviter_id = invite['inviter']['id']
      end
    end
    return inviter_id
  rescue
    raise 'internal_server_error'
  end
end
