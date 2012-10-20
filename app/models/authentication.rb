class Authentication < ActiveRecord::Base

  belongs_to :user

  def provider_name
    if provider == 'open_id'
      'OpenID'
    elsif provider == 'google_oauth2'
      'Google'
    else
      provider.titleize
    end
  end
  attr_accessible :provider, :uid, :user_id
end
