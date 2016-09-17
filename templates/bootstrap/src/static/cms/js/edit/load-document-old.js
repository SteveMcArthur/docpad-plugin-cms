/*global window, $, document, CKEDITOR,downshow */
var theEditor = CKEDITOR.replace('editor1', {
    height: 450,
    // Define the toolbar groups as it is a more accessible solution.
    toolbarGroups: [
        {
            "name": "basicstyles",
            "groups": ["basicstyles"]
        },
        {
            "name": "links",
            "groups": ["links"]
        },
        {
            "name": "paragraph",
            "groups": ["list", "blocks"]
        },
        {
            "name": "document",
            "groups": ["mode"]
        },
        {
            "name": "insert",
            "groups": ["insert"]
        },
        {
            "name": "styles",
            "groups": ["styles"]
        },
        {
            "name": "save",
            "groups": ["save"]
        }
    ],
    // Remove the redundant buttons from toolbar groups defined above.
    removeButtons: 'Underline,Strike,Subscript,Superscript,Anchor,Styles,Specialchar'
});
$(document).ready(function () {

    if (!downshow || !CKEDITOR) {
        alert('editor code missing');
    }

    CKEDITOR.on("instanceReady", function () {
        var btn = $('.cke_voice_label:contains("save")').parent();
        btn.addClass('save-btn');
    });



    function getPost(docId,slug) {
        var id = docId ? docId : slug;
        $.get('/load/' + id)
            .done(function (data) {
                $('#post-title').val(data.title);
                $('#slug').text(data.slug);
                $('#feature-img').attr('src', data.img);
                $('#docId').text(data.docId);
                var tags = $('#tags');
                for (var i = 0; i < data.tags.length; i++) {
                    tags.append('<li><a class="icon-cancel-circle"></a>' + data.tags[i] + "</li>");
                }

                CKEDITOR.instances.editor1.setData(data.content, {
                    callback: function () {
                        var btn = $('.cke_voice_label:contains("save")').parent();
                        btn.addClass('save-btn');
                    }
                });

            });
    }


    function postData() {
        var txt = downshow(CKEDITOR.instances.editor1.getData());
        var title = $('#post-title').val();
        var slug = $('#slug').text();
        var docId = parseInt($('#docId').text());
        var inputs = $('#tags li');
        var tags = [];
        inputs.each(function () {
            tags.push($(this).text());
        });

        //check we actually have something written
        //and that we have a title
        if (txt.length < 10) {
            alert("Write something first!");
        } else if (title.length < 2) {
            $('#title-callout').fadeIn();
            var titleCallout = function () {
                $('#title-callout').fadeOut();
                $(this).unbind('click', titleCallout);
            };
            $('#post-title').click(titleCallout);


        } else {
            $('#edit-loader').show();

            var obj = {
                content: txt,
                title: title,
                slug: slug,
                tags: tags,
                docId: docId
            };

            $.post('/save', obj)
                .done(function () {
                    $('#edit-msg').show();
                    $('#edit-loader').fadeOut(1000, function () {
                        $('#edit-msg').fadeOut(1000);
                    });
                })
                .fail(function (xhr, err, msg) {
                    $('#edit-loader').fadeOut(500);
                    $('#edit-msg').fadeOut(500);
                    alert(msg);
                });
        }

    }


    theEditor.addCommand("savePost", { // create named command
        exec: function () {
            postData();
        }
    });

    theEditor.ui.addButton('SaveButton', { // add new button and bind our command
        label: "Save",
        command: 'savePost',
        toolbar: 'save',
        icon: '/img/icon_save.png'
    });


    $('#post-send').click(function () {
        postData();
    });

    $('#add-tag').click(function () {
        var tag = $('#new-tag').val();
        if (tag) {
            $('#tags').append('<li><a class="icon-cancel-circle"></a>' + tag + "</li>");
        }
    });

    function loadImages() {
        var list = $('#image-picker ul');
        list.html("");
        $.get('/admin/images')
            .done(function (data) {
                for (var i = 0; i < data.length; i++) {
                    var url = data[i];
                    list.append('<li><img src="' + url + '"></li>');
                }
            })
            .fail(function (xhr, err, msg) {
                alert(msg);
            });
    }

    loadImages();

    $("#image-picker").dialog({
        autoOpen: false,
        width: '60%'
    });
    $('#img-panel').click(function () {
        $("#image-picker").dialog('open');
    });



    $('#feature-img').on("load", function () {
        var h = this.naturalHeight;
        var w = this.naturalWidth;
        $('#imgdim').text("Dimensions: " + w + " x " + h);

    });

    $('.new-btn').css('display', 'inline');
    
    


    var qry = window.location.search;
    var items = window.location.pathname.split('/');
    var docIdStr = items[items.length - 1];
    var docId = parseInt(docIdStr);
    if(isNaN(docId)){
        docId = null;
    }
    var slug = qry.substr(0,6) == '?slug=' ? qry.substr(6) : null;
    if(slug[0] === "/"){
        slug = slug.substr(1);
    }
    getPost(docId,slug);
    



});