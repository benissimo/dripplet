# == Schema Information
# Schema version: 20100613162817
#
# Table name: users
#
#  id                        :integer(4)      not null, primary key
#  login                     :string(40)
#  name                      :string(100)     default("")
#  email                     :string(100)
#  crypted_password          :string(40)
#  salt                      :string(40)
#  created_at                :datetime
#  updated_at                :datetime
#  remember_token            :string(40)
#  remember_token_expires_at :datetime
#  activation_code           :string(40)
#  activated_at              :datetime
#  state                     :string(255)     default("passive")
#  deleted_at                :datetime
#  first_ip                  :string(15)      not null
#  last_ip                   :string(15)      not null
#  note                      :text
#  water_points_count        :integer(4)      default(0)
#  up_scores                 :integer(4)      default(0)
#  locale                    :string(255)     default("en")
#  batch_id                  :string(255)
#

require 'digest/sha1'

class User < ActiveRecord::Base
  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken
  include Authorization::StatefulRoles
  validates_presence_of     :login
  validates_length_of       :login,    :within => 3..40
  validates_uniqueness_of   :login
  validates_format_of       :login,    :with => Authentication.login_regex, :message =>:bad_login
  #validates_format_of       :login,    :with => Authentication.login_regex, :message => Authentication.bad_login_message


  validates_format_of       :name,     :with => Authentication.name_regex, :allow_nil => true #,  :message => Authentication.bad_name_message, :allow_nil => true
  validates_length_of       :name,     :maximum => 100

  validates_presence_of     :email
  validates_length_of       :email,    :within => 6..100 #r@a.wk
  validates_uniqueness_of   :email
  validates_format_of       :email,    :with => Authentication.email_regex, :message =>:bad_email
  #validates_format_of       :email,    :with => Authentication.email_regex, :message => Authentication.bad_email_message


  # HACK HACK HACK -- how to do attr_accessible from here?
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :login, :email, :name, :password, :password_confirmation, :note, :avatar, :locale

  # begin custom app associations
  has_many :comments, :dependent => :destroy
  has_many :votes, :dependent => :destroy
  has_many :water_points, :dependent => :destroy
  has_many :group_members, :dependent => :destroy
  has_many :groups, :through => :group_members
  has_one  :avatar, :dependent => :destroy
  # end custom app associations

  # begin custom app scopes
  named_scope :active, :conditions => {:state => "active" }
  named_scope :normal, :conditions => "NOT (login = 'admin')"
  # end custom app scopes


  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  #
  # uff.  this is really an authorization, not authentication routine.  
  # We really need a Dispatch Chain here or something.
  # This will also let us return a human error message.
  #
  def self.authenticate(login, password)
    return nil if login.blank? || password.blank?
    u = find_in_state :first, :active, :conditions => {:login => login.downcase} # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  def login=(value)
    write_attribute :login, (value ? value.downcase : nil)
  end

  def email=(value)
    write_attribute :email, (value ? value.downcase : nil)
  end


  #### custom
  def calculate_up_scores
    up_scores = 0
    self.water_points.each do |w|
      up_scores = up_scores + w.up_score
    end
    up_scores
  end


  def send_new_password
    logger.info("user.send_new_password called")
    pass = self.regenerate_password
    UserMailer.deliver_new_password(self,pass)
  end


  protected
    
    def make_activation_code
        self.deleted_at = nil
        self.activation_code = self.class.make_token
    end

    def regenerate_password
      logger.info("user.regenerate_password called")
      self.password_confirmation = self.password = ActiveSupport::SecureRandom.base64(6)
      self.save(false)
      self.password
    end


end
