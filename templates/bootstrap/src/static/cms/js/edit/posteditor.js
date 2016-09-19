/*global window, $,  CKEDITOR,downshow */
var finishedFn = function(){};
function posteditor(el, opts,callback) {
    
    if(!el){
        el = $('textarea#editor1').get(0);
        if(!el){
            el = $('textarea').get(0);
        }
    }
    
    if (!CKEDITOR) {
        alert('CKEDITOR missing!');
    }
    finishedFn  = callback || finishedFn;
    this.config = {
        loadURL: '/load/' || opts.loadURL,
        saveURL: '/save' || opts.saveURL,
        downshow: downshow || opts.downshow,
        titleEl: '#post-title' || opts.titleEl,
        slugEl: '#slug' || opts.slugEl,
        featureImgEl: '#feature-img' || opts.slugEl,
        docidEl: '#docId' || opts.docidEl,
        tagsEl: '#tags' || opts.tagsEl,
        titleCallout: '#title-callout' || opts.titleCallout,
        editMsgEl: '#edit-msg' || opts.editMsgEl,
        editLoaderEl: '#edit-loader' || opts.editLoaderEl,
        imagesURL: '/cms/images' || opts.imagesURL,
        imagePickerEl: '#image-picker ul' || opts.imagePickerEl,
        editDateEl : '#last-edit span' || opts.editDateEl,
        authorEl : '#author span' || opts.authorEl
    };
    this.init(el);

    var qry = window.location.search;
    var items = window.location.pathname.split('/');
    var docIdStr = items[items.length - 1];
    var docId = parseInt(docIdStr);
    if (isNaN(docId)) {
        docId = null;
    }
    var slug = qry.substr(0, 6) == '?slug=' ? qry.substr(6) : null;
    if (slug && slug[0] === "/") {
        slug = slug.substr(1);
    }
    var id = docId || slug;
    this.getPost(id);

}
posteditor.prototype.getPost = function (id) {
    var cfg = this.config;
    $.get(cfg.loadURL + id)
        .done(function (data) {
            $(cfg.titleEl).val(data.title);
            $(cfg.slugEl).text(data.slug);
            $(cfg.featureImgEl).attr('src', data.img);
            $(cfg.docidEl).text(data.docId);
            $(cfg.authorEl).text(data.author);
            var editDate = new Date(data.editdate);
            $(cfg.editDateEl).text(editDate.toDateString());
            var tags = $(cfg.tagsEl);
            for (var i = 0; i < data.tags.length; i++) {
                tags.append('<li><a href="#"><i class="fa fa-times-circle-o"></i></a>' + data.tags[i] + "</li>");
            }

            CKEDITOR.instances.editor1.setData(data.content, {
                callback: function () {
                    var btn = $('.cke_voice_label:contains("save")').parent();
                    btn.addClass('save-btn');
                    finishedFn();
                    
                }
            });
        

        });

};
posteditor.prototype.postData = function () {
    var cfg = this.config;
    var txt = cfg.downshow(this.editor.getData());
    var title = $(cfg.titleEl).val();
    var slug = $(cfg.slugEl).text();
    var docId = parseInt($(cfg.docidEl).text());
    var author = $(cfg.authorEl).text();
    var img = $(cfg.featureImgEl).text();
    var inputs = $(cfg.tagsEl + ' li');
    var tags = [];
    inputs.each(function () {
        tags.push($(this).text());
    });

    //check we actually have something written
    //and that we have a title
    if (txt.length < 10) {
        alert("Write something first!");
    } else if (title.length < 2) {
        $(cfg.titleCallout).fadeIn();
        var titleCallout = function () {
            $(cfg.titleCallout).fadeOut();
            $(this).unbind('click', titleCallout);
        };
        $(cfg.titleEl).click(titleCallout);


    } else {
        $(cfg.editLoaderEl).show();

        var obj = {
            content: txt,
            title: title,
            author: author,
            slug: slug,
            tags: tags,
            docId: docId,
            img: img
        };

        $.post(cfg.saveURL, obj)
            .done(function () {
                $(cfg.editMsgEl).show();
                $(cfg.editLoaderEl).fadeOut(1000, function () {
                    $(cfg.editMsgEl).fadeOut(1000);
                });
            })
            .fail(function (xhr, err, msg) {
                $(cfg.editLoaderEl).fadeOut(500);
                $(cfg.editMsgEl).fadeOut(500);
                alert(msg);
            });
    }


};

if (!console) {
    console = {};
} 
console.log = console.log || function(){};

posteditor.prototype.loadImages = function () {
    var cfg = this.config;
    var list = $(cfg.imagePickerEl);
    list.html("");
    $.get(cfg.imagesURL)
        .done(function (data) {
            for (var i = 0; i < data.length; i++) {
                var url = data[i];
                list.append('<li><img src="' + url + '"></li>');
            }
        })
        .fail(function (xhr, err, msg) {
            console.log("Images not found");
            console.log(msg);
        });

};

posteditor.prototype.init = function (el) {
    this.editor = CKEDITOR.replace(el, {
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

    CKEDITOR.on("instanceReady", function () {
        var btn = $('.cke_voice_label:contains("save")').parent();
        btn.addClass('save-btn');
    });
    var self = this;
    this.editor.addCommand("savePost", { // create named command
        exec: function () {
            self.postData();
        }
    });

    this.editor.ui.addButton('SaveButton', { // add new button and bind our command
        label: "Save",
        command: 'savePost',
        toolbar: 'save',
        icon: '/cms/img/icon_save.png'
    });

    $('#post-send').click(function () {
        self.postData();
    });


    $('#add-tag').click(function () {
        var tag = $('#new-tag').val();
        if (tag) {
            $('#tags').append('<li><a class="icon-cancel-circle"></a>' + tag + "</li>");
        }
    });

    this.loadImages();

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


};