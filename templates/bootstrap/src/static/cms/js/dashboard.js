/*global $*/
$(function () {

    function topTiles(data) {
        var tiles = $('.tile_stats_count');

        var weekTotal = 0;
        var week2Total = 0;
        var monthTotal = 0;
        var monthBefore = 0;
        for (var i = 0; i < 60; i++) {
            var v = parseInt(data.rows[i][1]);
            if (i < 7) {
                weekTotal += v;
            }
            if (i < 14) {
                week2Total += v;
            }
            if (i < 30) {
                monthTotal += v;
            }
            if (i > 29) {
                monthBefore += v;
            }
        }
        $(tiles[0]).children('.count').text(monthTotal);
        $(tiles[1]).children('.count').text(week2Total);
        $(tiles[2]).children('.count').text(weekTotal);
        $(tiles[3]).children('.count').text(data.rows[1][1]);
        $(tiles[4]).children('.count').text(data.rows[0][1]);


    }



    $.getJSON('/analytics/data/60daySessions', function (data) {
        topTiles(data);
    });


});