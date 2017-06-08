// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require moment.min.js
//= require_directory .

$(document).on('turbolinks:load', function() {

  $('.sortable-table').tablesort();

  $('.selectpicker').selectpicker();

  $(".admin-report").click(function(ev) {
    ev.preventDefault();
    var reason = prompt("Why does this post need admin attention?");
    if(reason === null) return;
    $.ajax({
      'type': 'POST',
      'url': '/posts/needs_admin',
      'data': {
        'id': $(this).data('post-id'),
        'reason': reason
      }
    })
    .done(function(data) {
      if(data === "OK") {
        alert("Post successfully reported for admin attention.");
      }
    })
    .fail(function(jqXHR, textStatus, errorThrown) {
      alert("Post was not reported: status " + jqXHR.status);
      console.error(jqXHR.responseText);
    });
  });

  $(".admin-report-done").click(function(ev) {
    ev.preventDefault();
    $.ajax({
      'type': 'POST',
      'url': '/admin/clear_flag',
      'data': {
        'id': $(this).data("flag-id")
      },
      'target': $(this)
    })
    .done(function(data) {
      if(data === "OK") {
        alert("Marked done.");
        $(this.target).parent().parent().siblings().addBack().siblings(".flag-" + $(this.target).data("flag-id")).first().prev().remove();
        $(this.target).parents("tr").remove();
      }
    })
    .fail(function(jqXHR, textStatus, errorThrown) {
      alert("Failed to mark done: status " + jqXHR.status);
      console.error(jqXHR.responseText);
    });
  });

  $(".announcement-collapse").click(function(ev) {
      ev.preventDefault();

      const collapser = $(".announcement-collapse");
      var announcements = $(".announcements").children(".alert-info");
      var showing = collapser.text().indexOf("Hide") > -1;
      if (showing) {
          var text = announcements.map((i, x) => $('p', x).text()).toArray().join(' ');
          localStorage.setItem('metasmoke-announcements-read', text);
          $('.announcements').slideUp(500);
          collapser.text('Show announcements');
      }
      else {
          localStorage.removeItem('metasmoke-announcements-read');
          $('.announcements').slideDown(500);
          collapser.text('Hide announcements');
      }
  });

  (function() {
      var announcements = $(".announcements").children(".alert-info");
      var text = announcements.map((i, x) => $('p', x).text()).toArray().join(' ');

      var read = localStorage.getItem('metasmoke-announcements-read');
      if (read && read === text) {
          $(".announcements").hide();
          $('.announcement-collapse').text('Show announcements');
      }
  })();

});
