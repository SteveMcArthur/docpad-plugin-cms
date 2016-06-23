/*global $*/
$(function () {

    function getReadme(name) {
        $.get('/admin/plugins/' + name+"/readme")
            .done(function (data) {
                var converter = new showdown.Converter();
                var html = converter.makeHtml(data);
                $('#plugin-desc').html(html);
            })
            .fail(function (xhr, err, msg){
                alert(msg);
        });
    }

    $('.readme-btn').click(function (ev) {
        ev.preventDefault();
        var name = $(this).attr('data-id');
        getReadme(name);
    });

});