# Model for an individual node in our graph

require 'bluecloth'

class Node < ActiveRecord::Base
  attr_accessible :parent_id, :name, :updated_at, :group_id, :visibility_id, :changeability_id, :group, :visibility, :changeability, :wants_help
  acts_as_tree :order => "name"

  belongs_to :group

  belongs_to :visibility, :class_name => "PermissionSetting", :foreign_key => :visibility_id
  belongs_to :changeability, :class_name => "PermissionSetting", :foreign_key => :changeability_id

  has_many :postings, :order => 'updated_at'
  has_many :active_postings, :class_name => "Posting", :conditions => "deleted_at is null", :order => 'updated_at'

  has_many :tagged_nodes
  has_many :tags, :through => :tagged_nodes

  has_many :email_recommendations
  has_many :recommendations
  has_many :spam_warnings

  has_many :collaborations
  has_many :collaborators, :through => :collaborations, :source => 'person'

  has_many :non_member_collaborations
  has_many :non_member_collaborators, :through => :non_member_collaborations

  has_many :logged_actions

  has_many :node_projects
  has_many :projects, :through => :node_projects

  has_many :versions
  has_many :attachments

  validates :name, :presence => true
  validates :visibility_id, :presence => true, :numericality => true
  validates :changeability_id, :presence => true, :numericality => true

  default_scope :include => [:visibility, :changeability, :tagged_nodes, :tags, :group]

  scope :created_since, lambda { |since| { :conditions => ['created_at >= ? ', since] }}
  scope :updated_since, lambda { |since| { :conditions => ['updated_at >= ? ', since] }}

  # ------------------------------------------------------------
  # Grab children of various sorts
  # ------------------------------------------------------------

  def Node.sna_nodes
    uri = Person.find_by_email_address('uri@northwestern.edu')

    sna_nodes = Node.all.
      reject {|n| n.authors.size == 1 and n.authors.first == uri }.
      reject {|n| n.group_id == 2}.
      reject {|n| n.created_at < 3.years.ago}.
      sort_by {|n| n.id}
  end

  def current_version
    versions.all.empty? ? nil : versions.all.sort_by { |v| v.created_at }.reverse.first
  end

  # Create methods for the different attachment types
  Attachment::TYPES.keys.each do |attachment_type|

    define_method(attachment_type.to_sym) do
      Attachment.first(:conditions => { :content_type => attachment_type, :node_id => id},
                       :order => 'created_at DESC')
    end

    define_method("#{attachment_type}s".to_sym) do
      Attachment.all(:conditions => { :content_type => attachment_type, :node_id => id},
                     :order => 'created_at DESC')
    end
  end


  # ------------------------------------------------------------
  # Info from the latest version
  # ------------------------------------------------------------

  def description
    @description ||= current_version.description
  end

  def person
    current_version.person unless current_version.nil?
  end

  def most_recent_author
    @most_recent_author ||= person
  end

  def authors
    people
  end

  def people
    collaborators
  end

  def all_collaborators
    collaborators + non_member_collaborators
  end

  def all_collaborators_sentence
    all_collaborators.map {|c| c.fullname}.to_sentence
  end

  def all_collaborations
    collaborations + non_member_collaborations
  end

  def people_sentence
    people.map {|person| ActionController::Base.helpers.person_link(person)}.join(", ") 
  end


  def author?(person)
    people.member?(person)
  end

  # ------------------------------------------------------------
  # Get the contents of a model file
  # ------------------------------------------------------------

  def contents
    @contents ||= (current_version ? current_version.contents : nil)
  end

  def netlogo_version
    @netlogo_version ||= current_version.netlogo_version
  end

  def netlogo_version_for_applet
    applet_directory = "#{Rails.root}/public/applet/"
    netlogo_version.gsub(/^(\d+\.\d+).*/, '\1')
  end

  def applet_class
    applet_jar_version = netlogo_version_for_applet

    logger.warn "[applet_class] Version is '#{applet_jar_version}'"

    if applet_jar_version.to_f < 4.1
      "org.nlogo.window.Applet"
    else
      "org.nlogo.lite.Applet"
    end
  end

  def info_tab
    current_version.info_tab || "Info tab is empty."
  end

  def markup_info_tab
    logger.warn "[Node#markup_info_tab] Processing Info tab for model #{name}, ID #{id}"
    text = info_tab

    # Handle headlines
    text.gsub! /([-_.?A-Z ]+)\n--+/ do
      "<h3>#{$1}</h3>"
    end

    # Handle URLs
    text.gsub! /(https?:\/\/[-\/_.~%?='\w:]+\w)/ do
      "<a target=\"_blank\" href=\"#{$1}\">#{$1}</a>"
    end

    # Handle newlines
    text.gsub!("\n", "</p>\n<p>")
  end

  def bluecloth_info_tab
    logger.warn "[Node#bluecloth_info_tab] Processing Info tab for model #{name}, ID #{id}"
    text = BlueCloth.new(info_tab).to_html

    text.gsub! /(?<!")(https?:\/\/[-\/_.~%?='\w]+\w)/ do
      "<a target=\"_blank\" href=\"#{$1}\">#{$1}</a>"
    end
  rescue Exception => e
    logger.warn "[Node#bluecloth_info_tab] Exception: #{e.inspect}"
    markup_info_tab
  end

  def info_tab_html
    if netlogo_version.to_i >= 5
      bluecloth_info_tab
    else
      markup_info_tab
    end
  end

  def procedures_tab()
    current_version.procedures_tab || "Procedures tab is empty."
  end

  def procedures_tab_html
    text = procedures_tab

    # Italicize comments
    text.gsub! /(;.*)\n/ do
      "<span class=\"proc-comment\">#{$1}</span>\n"
    end

    # Make "to" and "to-report" stand out
    text.gsub! /^\s*(to(-report)?) / do
      "\n<span class=\"proc-to\">#{$1}</span> "
    end

    # Make "end" stand out
    text.gsub! /^\s*end\b/ do
      "<span class=\"proc-end\">end</span> "
    end

    "<pre>#{text}</pre>"
  end

  def filename
    name.gsub('/', '_').gsub(' ', '_')
  end

  def dimensions

    # This algorithm is really horrible and nasty.  It was taken
    # almost precisely from the Perl code in model.cgi, on
    # ccl.northwestern.edu.  I have a feeling that I could clean it up
    # a lot, but that'll take a bit of time, so I'll just keep it this
    # way for now.

    dividers = 0
    getdimens = -1
    gotfirstdimens = 0
    width = 0
    height = 0

    contents.each_line do |line|

      # Handle dividers
      if line =~ /\@\#\$\#\@\#\$\#\@/
        dividers = dividers + 1

        if (dividers == 1) and (gotfirstdimens == 0)
          getdimens = 0
          gotfirstdimens = 1
        end

        next
      end

      # Handle whitespace
      if line =~ /^\s*$/ and dividers == 1
        getdimens = 0
        next
      end

      # Handle dimensions
      if line =~ /CC-WINDOW/
        getdimens = -1
      end

      if getdimens >= 0

        if (getdimens == 3 and line.to_i >= width and line =~ /^\d+/)
          width = line.to_i
        end

        if (getdimens == 4 and line.to_i >= height and line =~ /^\d+/)
          height = line.to_i
        end

        getdimens = getdimens + 1
      end
    end

    # Height buffer
    height = height + 31

    # Width buffer
    width = width + 31

    { :height => height, :width => width}
  end

  def can_be_read_by?(person)
    author?(person)
  end

  def download_name
    name.gsub(/[\s\/]/, '_')
  end

  def zipfile_name
    "#{download_name}.zip"
  end

  def zipfile_name_full_path
    "#{Rails.root}/public/modelzips/#{zipfile_name}"
  end

  def world_visible?
    visibility.short_form == 'a'
  end

  def author_visible?
    visibility.short_form == 'u'
  end

  def group_visible?
    visibility.short_form == 'g'
  end

  def permission_description
    if world_visible?
      "public"
    elsif group.present? and group_visible?
      "group-visible (to '#{group.name}')"
    elsif group.blank? and group_visible?
      "group-visible"
    else
      "private"
    end
  end

  def url
    "http://modelingcommons.org/browse/one_model/#{id}"
  end

  def visible_to_user?(person)
    # If everyone can see this model, then deal with the simple case
    return true if world_visible?

    # If only the author can see this model, then allow anyone who has
    # contributed to the model to see it
    return true if author?(person)

    # If only the group can see this model, then check if the user is logged in
    # and a member of the group
    return true if group and group_visible? and group.members.member?(person)

    # If the user is an administrator, then let them see the model
    return true if person and person.administrator?

    return false
  end

  def changeable_by_user?(person)
    return false if person.nil?

    return true if person.administrator?

    return true if author?(person)

    return true if group and group_changeable? and group.members.member?(person)

    return false
  end

  def world_changeable?
    changeability.is_anyone?
  end

  def author_changeable?
    changeability.is_owner?
  end

  def group_changeable?
    changeability.is_group?
  end

  def world_visible?
    visibility.is_anyone?
  end

  def author_visible?
    visibility.is_owner?
  end

  def group_visible?
    visibility.is_group?
  end

  def cannot_be_run_as_applet?
    return true if name =~ /3D/
    return true if netlogo_version =~ /3D/
    return true if procedures_tab =~ /hubnet-/
  end

  def self.get_anonymous_models
    find_by_sql("SELECT * FROM nodes_visible_to_anonymous_users()")
  end

  def self.search(search_term, person)
    all(:conditions => [ "position( ? in lower(nodes.name) ) > 0 ", search_term],
        :include => :visibility).select { |node| node.visible_to_user?(person)}
  end

  def create_zipfile
    Zippy.create zipfile_name_full_path do |io|
      io["#{download_name}.nlogo"] = contents.to_s

      attachments.each do |attachment|
        io[attachment.filename] = attachment.contents.to_s
      end

    end

    zipfile_name_full_path
  end

  def self.all_time_most_viewed(limit = 20)
    LoggedAction.find_by_sql(["SELECT count, node_id
                                 FROM Model_View_Counts
                             ORDER BY count DESC
                                LIMIT ?;", limit])
  end

  def self.most_viewed(limit = 20)
    LoggedAction.find_by_sql(["SELECT COUNT(DISTINCT ip_address), node_id
                                                FROM Model_Views
                                               WHERE logged_at >= NOW() - interval '2 weeks'
                                            GROUP BY node_id
                                            ORDER BY count DESC
                                               LIMIT ?;", limit])
  end

  def self.most_downloaded(limit = 20)
    LoggedAction.find_by_sql(["SELECT COUNT(DISTINCT ip_address), node_id
                                                   FROM Model_Downloads
                                                  WHERE logged_at >= NOW() - interval '2 weeks'
                                               GROUP BY node_id
                                               ORDER BY count DESC
                                                  LIMIT ?;", limit])
  end

  def views
    LoggedAction.find_by_sql(["SELECT COUNT(DISTINCT ip_address) FROM Model_Views WHERE node_id = ?", id]).first.count.to_i
  end

  def views_last_week
    LoggedAction.find_by_sql(["SELECT COUNT(DISTINCT ip_address) FROM Model_Views WHERE logged_at > now() - interval '1 week' and node_id = ?", id]).first.count.to_i
  end

  def runs
    LoggedAction.find_by_sql(["SELECT COUNT(DISTINCT ip_address) FROM Model_Runs WHERE node_id = ?", id]).first.count.to_i
  end

  def runs_last_week
    LoggedAction.find_by_sql(["SELECT COUNT(DISTINCT ip_address) FROM Model_Runs WHERE logged_at > now() - interval '1 week' and  node_id = ?", id]).first.count.to_i
  end

  def downloads
    LoggedAction.find_by_sql(["SELECT COUNT(DISTINCT ip_address) FROM Model_Downloads WHERE node_id = ?", id]).first.count.to_i
  end

  def downloads_last_week
    LoggedAction.find_by_sql(["SELECT COUNT(DISTINCT ip_address) FROM Model_Downloads WHERE logged_at > now() - interval '1 week' and node_id = ?", id]).first.count.to_i
  end

  def contains_any_of?(text, words)
    lowercase_text = text.downcase
    words.split.detect { |word| lowercase_text.index(word) }
  end

  def unanswered_questions
    active_postings.select { |p| p.is_question? }
  end

end
