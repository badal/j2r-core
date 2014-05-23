function createDetailsLinks() {
    $('.for_details .details').
        before("<span class='showDetails'>[<a href='#' class='toggleDetails'>Plus de détails</a>]</span>");
    $('.toggleDetails').toggle(function() {
       $(this).parent().nextAll('.details').slideDown(100);
       $(this).text("Moins de détails");
    },
    function() {
        $(this).parent().nextAll('.details').slideUp(100);
        $(this).text("Plus de détails");
    });
}

function linkSummaries() {
  $('.summary_signature').click(function() {
    document.location = $(this).find('a').attr('href');
  });
}

function framesInit() {
  if (window.top.frames.main) {
    document.body.className = 'frames';
    $('#menu .noframes a').attr('href', document.location);
    $('html head title', window.parent.document).text($('html head title').text());
  }
}

function summaryToggle() {
  $('.summary_toggle').click(function() {
    localStorage.summaryCollapsed = $(this).text();
    $(this).text($(this).text() == "contracter" ? "détailler" : "contracter");
    var next = $(this).parent().parent().nextAll('ul.summary').first();
    if (next.hasClass('compact')) {
      next.toggle();
      next.nextAll('ul.summary').first().toggle();
    } 
    else if (next.hasClass('summary')) {
      var list = $('<ul class="summary compact" />');
      list.html(next.html());
      list.find('.summary_desc, .note').remove();
      list.find('a').each(function() {
        $(this).html($(this).find('strong').html());
        $(this).parent().html($(this)[0].outerHTML);
      });
      next.before(list);
      next.toggle();
    }
    return false;
  });
  if (localStorage) {
    if (localStorage.summaryCollapsed == "contracter") $('.summary_toggle').click();
    else localStorage.summaryCollapsed = "détailler";
  }
}

$(framesInit);
$(createDetailsLinks);
$(linkSummaries);
$(summaryToggle);
