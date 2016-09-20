/*global $, posteditor*/
$(function () {
    function afterFn() {
        var items = $('#published li');
        items.each(function () {
            var item = $(this);
            if (item.find('span').text() !== "") {
                item.removeClass('hide');
            }
        });
    }

    var editor = new posteditor(null, null,afterFn);
});