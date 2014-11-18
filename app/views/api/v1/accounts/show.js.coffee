<% if @error %>
content = "Unauthorised Access to Account"
<% else %>
content = "<%= escape_javascript(render(:partial => 'transaction_account')) %>"
<% end %>
$('#<%= @options[:element_name] %>').html(content)