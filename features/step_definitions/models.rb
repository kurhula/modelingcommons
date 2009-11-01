def person
  @person || Factory.create(:person)
end

Given /^a NetLogo model named "([^\"]*)"$/ do |model_name|
  @node = Factory.create(:node,
                         :name => model_name)

  @node_version = Factory.create(:node_version,
                                 :node => @node,
                                 :person => person)
end

Given /^a permission setting named "([^\"]*)" with a short form of "([^\"]*)"$/ do |permission_name, short_form|
  @permission_setting = Factory.create(:permission_setting,
                                       :name => permission_name,
                                       :short_form => short_form)
end


When /^I upload a model$/ do
  attach_file(:new_model_uploaded_body, File.join(RAILS_ROOT, 'features', 'upload_files', 'test.nlogo'))
  click_button "Upload model"
end
