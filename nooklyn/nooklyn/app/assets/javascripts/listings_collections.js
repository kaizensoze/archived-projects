// $(function() {
//   $(".nooklyn_listing_square.removable").on("click", "button", function() {
//       var listing_id = $(this).parents("div").attr("id").split("_").pop();
//       var collection_id = $(this).parents("form").attr("id").split("_").pop();
//       var data = { listing_id: listing_id };
//       var postUrl = "/listings_collections/" + collection_id + "/remove_listing";

//       $.ajax(postUrl, {type: 'POST', dataType: 'json', data: data}).done(function() {
//         $("#listing_" + listing_id).fadeOut();
//       })

//       return false;
//   });
// });
