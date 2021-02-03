// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

import Rails from "@rails/ujs"
import Turbolinks from "turbolinks"
import * as ActiveStorage from "@rails/activestorage"
import "channels"

import 'jquery'
import 'popper.js'
import 'bootstrap'
import 'bootstrap-table'
import 'chartkick'
import 'chart.js'
import 'stylesheets/application'

global.$ = require('jquery')
$.extend($.fn.bootstrapTable.defaults, $.fn.bootstrapTable.locales['fr-fr']);
$.extend($.fn.bootstrapTable.defaults, {
  pageSize: 5,
  pageList: [5, 10, 100, 1000],
  pagination: true,
  classes: 'table table-hover table-no-bordered',
  sidePagination: 'server',
  showColumns: true
});
Rails.start()
Turbolinks.start()
ActiveStorage.start()
