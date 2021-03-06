# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

require 'diff/lcs'
require 'diff/lcs/hunk'
require 'diff/lcs/string'
require 'graphviz_r'

class ApplicationController < ActionController::Base
  before_filter :get_person
  before_filter :log_one_action

  def get_person
    person_id = session[:person_id]
    @person = Person.find_by_id(person_id, :include => {:memberships => :group})
  end

  def require_login
    if @person.nil?
      respond_to do |format|
        format.html do 
          flash[:notice] = "You must log in before proceeding."
          redirect_to :controller => :account, :action => :login
          
        end
        format.json do 
          response = {:status => 'NOT_LOGGED_IN'}
          render :json => response
        end
      end
      return false
    end
  end

  def require_administrator
    if not @person.administrator?
      flash[:notice] = "Only administrators may visit this URL."
      redirect_to :controller => :account, :action => :login
      return false
    end
  end

  def log_one_action(message='(No message)')
    # Get the person ID
    if @person.nil?
      person_id = nil
    else
      person_id = @person.id
    end

    # Get the node ID
    if @model
      node_id = @model.id
    elsif @node
      node_id = @node.id
    else
      node_id = nil
    end

    browser_info = request.env['HTTP_USER_AGENT'] || 'No browser info passed'
    ip_address = request.remote_ip || 'No IP address passed'

    safe_params = params.dup
    safe_params.delete('password') 
    safe_params.delete('password_confirmation') 

    loggable_params = safe_params.to_json rescue "(Cannot log params)"
    loggable_session = session.to_json rescue "(Cannot log session)"
    loggable_flash = flash.to_json rescue "(Cannot log flash)"
    loggable_cookies = cookies.to_json rescue "(Cannot log cookies)"

    LoggedAction.create!(:person_id => person_id,
                         :controller => params[:controller],
                         :action => params[:action],
                         :logged_at => Time.now(),
                         :message => message,
                         :ip_address => ip_address,
                         :browser_info => browser_info,
                         :url => request.fullpath,
                         :params => loggable_params,
                         :session => loggable_session,
                         :cookies => loggable_cookies,
                         :flash => loggable_flash,
                         :referrer => request.env['HTTP_REFERER'],
                         :node_id => node_id,
                         :is_searchbot => is_searchbot(browser_info) 
                         )
  rescue Exception => e
    logger.warn "Error logging: #{e.inspect}"
  end

  def is_searchbot(browser_info_string)
    browser_info_string =~ /bot|yandex|baidu|yahoo|search|crawl|spider/i ? true : false
  end

  def check_visibility_permissions
    return true if @model.nil? or @model.visible_to_user?(@person)

    flash[:notice] = "You do not have permission to view this model."

    if @person
      redirect_to :controller => :account, :action => :mypage
    else
      redirect_to :controller => :account, :action => :login
    end
  end

  def check_changeability_permissions
    if @model.nil?

      if params[:new_document] and params[:new_document][:parent_node_id]
        @model = Node.find(params[:new_document][:parent_node_id])

      elsif params[:new_version] and params[:new_version][:node_id]
        @model = Node.find(params[:new_version][:node_id])
      end

    end

    if @model.nil?
      logger.warn "[check_changeability_permissions] Error -- model is nil.  Cannot upload."
      flash[:notice] = "Error detected; cannot upload.  Please notify the site administrator."
      return false
    end

    # This only applies if the node is a model
    # If there's no model, then allow everything
    return true unless @model

    # If there's no person, then allow nothing
    return false unless @person

    # If everyone can see this model, then deal with the simple case
    return true if @model.changeability.short_form == 'a'

    # If only the author can see this model, then deal with the simple case
    # Note that the "user" permission works for anyone who has already submitted
    # a version to this model.  Otherwise, things get a bit sticky.  I think.
    return true if @model.changeability.short_form == 'u' and
      @model.author?(@person)

    # If only the group can see this model, then get the model's group, and
    # determine if @person is a member of the group.
    if @model.group
      return true if @model.changeability.short_form == 'g' and @model.group.members.member?(@person)
    end

    flash[:notice] = "You do not have permission to modify this model."
    redirect_to :controller => :account, :action => :mypage
    return false
  end

  def shelter 
  end

  def get_model_from_id_param
    if params[:id].blank?
      flash[:notice] = "No model ID provided"
      redirect_to :back
      return
    end

    @model = Node.find(params[:id])
    @node = @model
  rescue
    flash[:notice] = "No model with ID '#{params[:id]}'"
    redirect_to :controller => :account, :action => :mypage
  end

  def all_whats_new
    how_new_is_new = 2.weeks.ago

    @recent_members = Person.created_since(how_new_is_new)
    @recent_models = Node.created_since(how_new_is_new)
    @updated_models = Node.updated_since(how_new_is_new)
    @recent_postings = Posting.created_since(how_new_is_new)
    @recent_tags = Tag.created_since(how_new_is_new)
    @recent_tagged_models = TaggedNode.created_since(how_new_is_new)

    @all_whats_new = [@recent_members, @recent_models, @updated_models, @recent_postings,
                      @recent_tags, @recent_tagged_models].flatten.sort_by {|new_item| new_item.updated_at}.reverse
  end

  def all_news
    limit = 10
    db_search_factor = 2 # fetch search_factor * limit records from db before filtering to see if user has read permission
    how_new_is_new = 2.weeks.ago
    
    @recent_questions = Posting.
      created_since(how_new_is_new).
      unanswered_questions.
      all(:limit => limit * db_search_factor).
      select { |question| question.node.visible_to_user?(@person) and !question.deleted_at }[0..limit - 1]
    
    @all_model_events = Node.
      updated_since(how_new_is_new).
      all(:order => 'updated_at DESC', 
          :limit => limit * db_search_factor).
      select { |node| node.visible_to_user?(@person)}[0..limit - 1]
    

    # all-time most-viewed models
    @all_time_most_viewed = Node.
      all_time_most_viewed(limit * db_search_factor).
      select {|node_count| node_count.node.visible_to_user?(@person)}[0..limit - 1]

    # most-viewed models
    @most_viewed = Node.
      most_viewed(limit * db_search_factor).
      select{|node_count| !node_count.node.nil? && node_count.node.visible_to_user?(@person)}[0..limit - 1]

    # most-downloaded models
    @most_downloaded = Node.
      most_downloaded(limit * db_search_factor).
      select {|node_count| node_count.node and node_count.node.visible_to_user?(@person)}[0..limit - 1]


    # most-applied tags
    @most_popular_tags = TaggedNode.count(:group => "tag_id",
                                          :order => "count_all DESC",
                                          :conditions => "created_at > (now() - interval '2 weeks')",
                                          :limit => limit).map { |tag| {:tag => Tag.find(tag[0]), :num_tags => tag[1]}}

    # most-recommended models
    @most_recommended_models = Recommendation.count(:group => "node_id",
                                                    :order => "count_all DESC",
                                                    :conditions => "created_at > (now() - interval '2 weeks')",
                                                    :limit => limit * db_search_factor).map { |node| {
        :node => Node.find(node[0]),
        :recommendations => node[1]
      }}.select { |node_array| node_array[:node].visible_to_user?(@person) }[0..limit - 1]

  end
  
end
