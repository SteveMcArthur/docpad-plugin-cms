/*global $,document, Chart */
var countryCodes=["AF","AL","DZ","AO","AG","AR","AM","AU","AT","AZ","BS","BH","BD","BB","BY","BE","BZ","BJ","BT","BO","BA","BW","BR","BN","BG","BF","BI","KH","CM","CA","CV","CF","TD","CL","CN","CO","KM","CD","CG","CR","CI","HR","CY","CZ","DK","DJ","DM","DO","EC","EG","SV","GQ","ER","EE","ET","FJ","FI","FR","GA","GM","GE","DE","GH","GR","GD","GT","GN","GW","GY","HT","HN","HK","HU","IS","IN","ID","IR","IQ","IE","IL","IT","JM","JP","JO","KZ","KE","KI","KR","UNDEFINED","KW","KG","LA","LV","LB","LS","LR","LY","LT","LU","MK","MG","MW","MY","MV","ML","MT","MR","MU","MX","MD","MN","ME","MA","MZ","MM","NA","NP","NL","NZ","NI","NE","NG","NO","OM","PK","PA","PG","PY","PE","PH","PL","PT","QA","RO","RU","RW","WS","ST","SA","SN","RS","SC","SL","SG","SK","SI","SB","ZA","ES","LK","KN","LC","VC","SD","SR","SZ","SE","CH","SY","TW","TJ","TZ","TH","TL","TG","TO","TT","TN","TR","TM","UG","UA","AE","GB","US","UY","UZ","VU","VE","VN","YE","ZM","ZW"];
$(function () {

    if (!Chart) {
        alert("No Chart Object!!");
    }

    Chart.defaults.global.legend = {
        enabled: false
    };

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

    function geoChart(data) {
        var mapData = {};

        for (var k=0; k<countryCodes.length;k++) {
            mapData[countryCodes[k]] = 0;
        }
        
        var countryItems = $('.countries_list tr');
        var total = data.totalsForAllResults["ga:sessions"];
        var numCountries = data.totalResults;

        for (var i = 0; i < data.rows.length; i++) {
            mapData[data.rows[i][1]] = parseInt(data.rows[i][2]);
            if(i < 5){
                var tds = $(countryItems[i]).children('td');
                tds[0].innerHTML = data.rows[i][0]; //the country
                tds[1].innerHTML = data.rows[i][2] + " visits"; //the value
            }
        }
        
        $('#country-view h2.line_30').text(total+' visits from '+numCountries+" countries");
        


        $('#world-map-gdp').vectorMap({
            map: 'world_mill_en',
            backgroundColor: 'transparent',
            zoomOnScroll: false,
            series: {
                regions: [{
                    values: mapData,
                    scale: ['#E6F2F0', '#149B7E'],
                    normalizeFunction: 'polynomial'
            }]
            },
            onRegionTipShow: function (e, el, code) {
                el.html(el.html() + ' (Visits - ' + mapData[code] + ')');
            }
        });
    }

    function getChartData(data) {
        var labels = $.map(data.rows, function (item) {
            return item[0].substr(0, 30);
        });
        var chartValues = $.map(data.rows, function (item) {
            return parseInt(item[1]);
        });
        var chartData = {
            labels: labels,
            datasets: [{
                backgroundColor: "#26B99A",
                data: chartValues
            }]
        };

        return chartData;
    }

    function charts(data) {

        var chartData = getChartData(data);
        var ctx = document.getElementById("chart30").getContext("2d");
        new Chart(ctx, {
            type: 'horizontalBar',
            data: chartData
        });
        $.getJSON('/analytics/data/7daysPageviews', function (data) {
            var d = getChartData(data);
            var ctx = document.getElementById("chart7").getContext("2d");
            new Chart(ctx, {
                type: 'horizontalBar',
                data: d
            });
            $.getJSON('/analytics/data/yesterdayPageviews', function (data) {
                var d = getChartData(data);
                var ctx = document.getElementById("chartyesterday").getContext("2d");
                new Chart(ctx, {
                    type: 'horizontalBar',
                    data: d
                });
                $.getJSON('/analytics/data/30dayCountry', function (data) {
                    geoChart(data);
                });
            });
        });
    }

    $.getJSON('/analytics/data/60daySessions', function (data) {
        topTiles(data);
    });

    $.getJSON('/analytics/data/30daysPageviews', function (data) {
        charts(data);
    });

});