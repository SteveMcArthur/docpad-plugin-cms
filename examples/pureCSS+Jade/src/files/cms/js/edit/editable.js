/* global window, document, CKEDITOR, $ */
CKEDITOR.replace('editor1', {
    height: 450
});

$(document).ready(function () {

    $('#permalink-host').text(window.location.protocol + "//" + window.location.hostname + "/");
    $("#edit-slug").click(function () {
        var $this = $(this);
        if ($this.attr('editing') != '1') {
            $this.text('Save').attr('editing', 1);
            var txt = $('#editable-slug').text();
            var input = $('<input class="editing" />').val(txt);
            $('#editable-slug').replaceWith(input);
        } else {
            $this.text('Edit').removeAttr('editing');
            var txt = $('input.editing').val();
            var div = $('<span id="editable-slug" title="Click to edit this part of the permalink" />').text(txt);

            $('input.editing').replaceWith(div);
        }
    });

    var tagInput = $(".tm-input").tagsManager();

    function getPost(slug) {
        var docURL = '/admin/load/' + slug;
        docURL = docURL.replace("//","/");
        $.ajax({
            url: docURL
        }).done(function (data) {
            $('#post-title').val(data.title);
            var origSlug = data.slug;
            var slug = origSlug;
            if(slug.substr(0,1) === "/"){
                slug = slug.substr(1,slug.length);
            }
            $('#editable-slug').text(slug).attr('data-slug',origSlug);
            CKEDITOR.instances['editor1'].setData(data.contentRenderedWithoutLayouts);
            var tags = data.meta.tags;
            if (typeof tags === "string") {
                tags = tags.split(",");
            }
            for (var i = 0; i < tags.length; i++) {
                tagInput.tagsManager('pushTag', tags[i]);
            }

        });


    }


    var slug = window.location.hash.replace('#','');
    
    if(slug){
        getPost(slug);
    }

});