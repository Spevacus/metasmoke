// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb

/* eslint-disable
  import/no-unassigned-import,
  import/newline-after-import,
  import/first
*/

require('expose-loader?$!jquery');

import Turbolinks from 'turbolinks';
import '../turbolinks_prefetch.coffee'; // The original is in coffee.
Turbolinks.start();

import '../cable';

import '../admin';
import '../api';
import '../code_status';
import '../data';
import '../domain_links';
import '../flag_conditions';
import '../flag_settings';
import '../reasons';
import '../review';
import '../stack_exchange_users';
import '../status';
import '../user_site_settings';
import '../graphs';
import '../site_settings';
import '../comments';

import { onLoad, installSelectpickers, uuid4, hashCode } from '../util';

onLoad(() => {
  $('[data-toggle="tooltip"]').tooltip();
  $('[data-toggle="popover"]').popover();

  $('.sortable-table').tablesort();

  installSelectpickers();

  $('.announcement-collapse').click(ev => {
    ev.preventDefault();

    const collapser = $('.announcement-collapse');
    const announcements = $('.announcements').children('.alert-info');
    const showing = collapser.text().indexOf('Hide') > -1;
    if (showing) {
      const text = announcements.map((i, x) => $('p', x).text()).toArray().join(' ');
      localStorage.setItem('metasmoke-announcements-read', text);
      $('.announcements:not(body)').slideUp(500);
      collapser.text('Show announcements');
    }
    else {
      localStorage.removeItem('metasmoke-announcements-read');
      $('.announcements:not(body)').slideDown(500);
      collapser.text('Hide announcements');
    }
  });

  (function () {
    const announcements = $('.announcements').children('.alert-info');
    const text = announcements.map((i, x) => $('p', x).text()).toArray().join(' ');

    const read = localStorage.getItem('metasmoke-announcements-read');
    if (read && read === text) {
      $('.announcements:not(body)').hide();
      $('.announcement-collapse').text('Show announcements');
    }
  })();

  $('.form-submit').click(ev => {
    $(ev.target).parent().submit();
  });

  const formParameterCleanups = [];

  $(document).on('submit', 'form', ev => {
    const tgt = $(ev.target);
    if (formParameterCleanups.indexOf(tgt[0]) === -1) {
      ev.preventDefault();
      $(tgt.find(':input').toArray().filter(e => $(e).val() === '')).attr('disabled', true);
      formParameterCleanups.push(tgt[0]);
      tgt.submit();
    }
  });

  $(document).on('ajax:beforeSend', 'form[data-deduplicate]', (ev, xhr) => {
    const $tgt = $(ev.target);
    if (!$tgt.data('dedup-uuid')) {
      $tgt.attr('data-dedup-uuid', uuid4());
    }

    const dedupUuid = $tgt.data('dedup-uuid');
    const data = $(ev.target).serialize();
    const requestId = `${dedupUuid}/${hashCode(data)}`;
    xhr.setRequestHeader('X-AJAX-Deduplicate', requestId);
    console.log(`ajax:beforeSend added X-AJAX-Deduplicate: ${requestId}`);
  });
});
