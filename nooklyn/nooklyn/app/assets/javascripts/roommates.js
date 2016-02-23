$(function() {

  function isElementVisible(el) {
    var rect = el.getBoundingClientRect();

    return (
      rect.top >= 0 &&
      rect.left >= 0 &&
      rect.bottom <= $(window).height() &&
      rect.right <= $(window).width()
    );
  }


  $(".roommate-card-filter").on('keyup change', function() {
    $("div.roommate_card").each(function() {
      var cardBudget, minBudget, maxBudget;

      cardBudget = $(this).data("budget");
      minBudget = parseFloat($("#minimum-budget").val());
      maxBudget = parseFloat($("#maximum-budget").val());

      if (minBudget > cardBudget || maxBudget < cardBudget) {
        $(this).hide();
        if (($(this).data('marker') != null)) {
          return $(this).data('marker').setVisible(false);
        }
      } else {
        $(this).show();
          if (($(this).data('marker') != null)) {
            return $(this).data('marker').setVisible(true);
          }
      }
    });
  });


  $('.rm_container').each(function(_, elem) {

    var timer = null;
    $(window).on('scroll', function(e) {

      if (timer !== null) {
        clearTimeout(timer);
      }

      timer = setTimeout(function() {

        ids = [];

        $('.roommate_card').each(function(_, el) {
          var isVisible = isElementVisible(el)
          if (isVisible) {
            var elId = $(el).attr('id');
            var matePostId = parseInt(elId.split('_')[2]);
            ids.push(matePostId);
          }
        });

        if (ids.length > 0) {
          $.ajax({
            type: "POST",
            url: "/mate_posts/nudge",
            data: {
              "mate_post_ids": ids
            },
            dataType: 'json'
          });
        }
      }, 150);
    });

  });
});
