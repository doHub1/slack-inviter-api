require 'cgi'
require 'base64'

# Private file Exporter
class PrivateFileExporter
  attr_accessor :page, :agent

  def initialize
    @page = nil
    @agent = Mechanize.new
  end

  def get_private_file(encoded_private_file_url)
    private_file_url = CGI.unescape(encoded_private_file_url)
    login
    private_file_content(private_file_url)
  end

  private

  def login
    team_subdomain = ENV['TEAM_SUBDOMAIN']
    email          = ENV['EMAIL']
    password       = ENV['PASSWORD']

    files_page_url = "https://#{team_subdomain}.slack.com/files"

    page = agent.get(files_page_url)
    return if page.title.include?('Files')

    page.form.email = email
    page.form.password = password
    @page = page.form.submit
  end

  def private_file_content(private_file_url)
    private_file = agent.get(private_file_url)

    filename = private_file.filename
    content_type = private_file.response['content-type']
    content_length = private_file.response['content-length']
    base64_encoded_private_file = Base64.encode64(private_file.body)

    {
      message: 'success',
      filename: filename,
      content_type: content_type,
      content_length: content_length,
      private_file_base64: base64_encoded_private_file
    }
  rescue Mechanize::ResponseCodeError => e
    raise 'internal_server_error' unless e.response_code == '404'
    { message: 'file_not_found' }
  rescue
    raise 'internal_server_error'
  end
end
