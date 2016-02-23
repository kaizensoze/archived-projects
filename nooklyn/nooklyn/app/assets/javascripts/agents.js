$(function() {
	$("#agent-filter").on("keyup", function() {
		var nameQuery = $(this).val().toLowerCase();

		$(".agents-card").each(function(i, v) {
			var name = $(this).data("name").toLowerCase();
			if (nameQuery === "" || name.search(nameQuery) >= 0) {
				$(this).show();
			} else {
				$(this).hide();
			}
		});
	});
});
