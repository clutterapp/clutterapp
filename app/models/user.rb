require 'digest/sha1'

class User < ActiveRecord::Base
  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken
  
  validates_presence_of     :login
  validates_length_of       :login,    :within => 6..40
  validates_uniqueness_of   :login
  validates_format_of       :login,    :with => Authentication.login_regex, :message => Authentication.bad_login_message
  
  validates_format_of       :name,     :with => Authentication.name_regex,  :message => Authentication.bad_name_message, :allow_nil => true
  validates_length_of       :name,     :maximum => 100
  
  validates_presence_of     :email
  validates_length_of       :email,    :within => 6..100 #r@a.wk
  validates_uniqueness_of   :email
  validates_format_of       :email,    :with => Authentication.email_regex, :message => Authentication.bad_email_message
  
  
  
  # derived from Railscasts #124: Beta Invites <http://railscasts.com/episodes/124-beta-invites>
  
  validates_presence_of   :invite_id, :message => 'is required'
  validates_uniqueness_of :invite_id
  
  has_many :sent_invites, :class_name => 'Invite', :foreign_key => 'sender_id'
  belongs_to :invite
  
  before_create :set_starting_invite_limit
  
  
  before_validation_on_create :create_default_pile_if_not_exists
  
  
  
  has_one :pile, :foreign_key => 'owner_id'
  
  
  
  # HACK HACK HACK -- how to do attr_accessible from here?
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :login, :email, :name, :password, :password_confirmation, :invite_token
  
  
  
  def to_param
    login
  end
  
  
  
  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  #
  # uff.  this is really an authorization, not authentication routine.
  # We really need a Dispatch Chain here or something.
  # This will also let us return a human error message.
  #
  def self.authenticate(login, password)
    return nil if login.blank? || password.blank?
    u = find_by_login(login) # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end
  
  
  def login=(value)
    write_attribute :login, (value ? value.downcase : nil)
  end
  
  
  def email=(value)
    write_attribute :email, (value ? value.downcase : nil)
  end
  
  
  def invite_limit=(value)
    write_attribute :invite_limit, (value == INFINITY ? nil : value)
  end
  
  
  
  # derived from Railscasts #124: Beta Invites <http://railscasts.com/episodes/124-beta-invites>
  
  def invite_token
    invite.token if invite
  end
  
  
  def invite_token=(token)
    self.invite = Invite.find_by_token(token)
  end
  
  
  def invites_remaining
    if invite_limit.nil?
      INFINITY
    else
      invite_limit - invite_sent_count
    end
  end
  
  
  protected
  
  DEFAULT_INVITATION_LIMIT = INFINITY
  
  def set_starting_invite_limit
    self.invite_limit = DEFAULT_INVITATION_LIMIT
  end
  
  def create_default_pile_if_not_exists
    self.create_pile unless self.pile
  end
  
end