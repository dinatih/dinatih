# frozen_string_literal: true

# bin/rails app:template LOCATION=~/rails_bootstrap_template.rb
# https://rossta.net/blog/webpacker-with-bootstrap.html
run 'yarn add bootstrap'
run 'yarn add jquery popper.js'

file 'app/javascript/css/site.scss', <<~CODE
  @import "~bootstrap/scss/bootstrap.scss";
CODE

inject_into_file 'app/javascript/packs/application.js', before: 'Rails.start()' do
  <<~CODE
    import 'jquery'
    import 'popper.js'
    import 'css/site'
  CODE
end
