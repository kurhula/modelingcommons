# Class to model people (users) of the system

class Person < ActiveRecord::Base
  SALT_SECRET = 'NetLogo is a really cool modeling environment!'

  has_many :postings
  has_many :logged_actions
  has_many :tags
  has_many :tagged_nodes
  has_many :recommendations
  has_many :email_recommendations
  has_many :spam_warnings

  has_many :memberships
  has_many :groups, :through => :memberships, :order => "lower(name) ASC"

  has_attached_file :avatar, :styles => { :medium => "200x200>", :thumb => "40x40>" }, :default_url => "/images/default-person.png"

  attr_protected :avatar_file_name, :avatar_content_type, :avatar_size

  attr_accessor :password_confirmation

  validates_presence_of :first_name
  validates_presence_of :last_name
  validates_presence_of :email_address
  validates_email :email_address, :level => 1
  validates_presence_of :password
  validates_uniqueness_of :email_address, :case_sensitive => false
  validates_confirmation_of :password

  named_scope :created_since, lambda { |since| { :conditions => ['created_at >= ? ', since] }}
  named_scope :phone_book, :order => "last_name, first_name"

  after_validation_on_create :generate_salt_and_encrypt_password
  after_validation_on_update :encrypt_updated_password

  def nodes
    Node.find(NodeVersion.fields(:node_id).all(:conditions => {:person_id => id}).map {|nv| nv.node_id})
  end

  def node_versions
    NodeVersion.fields(:id, :node_id, :person_id, :description, :created_at, :updated_at).all(:conditions => { :person_id => id}, :order => :updated_at)
  end

  def attachments
    NodeAttachment.all(:conditions => { :person_id => id})
  end

  def models
    nodes
  end

  def fullname
    @fullname ||= "#{first_name} #{last_name}"
  end

  def phonebook_name
    @phonebook_name ||= "#{last_name}, #{first_name} (#{email_address})"
  end

  def administrated_groups
    groups.select {|group| group.is_administrator?(self) }
  end

  def spam_warning(model)
    spam_warnings.select { |sw| sw.node_id == model.id }.first || nil
  end

  def latest_action_time
    LoggedAction.maximum('logged_at', :conditions => ["person_id = ?", id])
  end

  def Person.search(term)
    all(:conditions => [ "position( ? in lower(first_name || last_name) ) > 0 ", term])
  end

  def Person.generate_salt(timestamp)
    Digest::SHA1.hexdigest("#{SALT_SECRET}--#{timestamp}")
  end

  def Person.encrypted_password(the_salt, plaintext)
    Digest::SHA1.hexdigest("#{the_salt}--#{plaintext}")
  end

  private

  def generate_salt_and_encrypt_password
    return unless new_record? 

    timestamp = created_at || Time.now
    self.salt = Person.generate_salt(timestamp)
    self.password = Person.encrypted_password(salt, password)
  end

  def encrypt_updated_password
    self.password = Person.encrypted_password(salt, password)
  end

end
