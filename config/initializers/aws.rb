require 'aws'

# Configure access.
config = Rails.application.config
if config.enable_aws
  AWS.config({
    :logger            => Rails.logger,
    :access_key_id     => Rails.application.secrets.aws_access_key_id || ENV['AWS_ACCESS_KEY'],
    :secret_access_key => Rails.application.secrets.aws_secret_key || ENV['AWS_SECRET_KEY']
  })
end