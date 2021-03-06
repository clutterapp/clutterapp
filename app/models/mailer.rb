# derived from Railscasts #124: Beta Invites <http://railscasts.com/episodes/124-beta-invites>
class Mailer < ActionMailer::Base
  
  def invite(invite, signup_url)
    subject    'Clutter Invite'
    recipients invite.recipient_email
    from       'no-reply@clutterapp.com'
    body       :invite => invite, :signup_url => signup_url
    
    invite.update_attribute(:sent_at, Time.now)
  end
  
end