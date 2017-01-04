/* the donut char from jqplot uses table for it's legend, and if they use 100% as defined by slds
 * it leaves no space for the graph, which then gacks due to negative angles in the computation
 **/
.ddcAssess .employee-chart-container table, .ddcAssess .revenue-chart-container table {
    width:auto;
}

/** 
 *  Need to override some of the jqplot css to have the slds font.  jqplot generate the html markup for the legends of the graphs.
 * */
.ddcAssess .jqplot-target {
   font-family: "Salesforce Sans", Arial, sans-serif;
   height: auto;
   width: 250px;
   position: relative;
   margin:0 auto;
}

.ddcAssess td.jqplot-table-legend {
    padding-left: 3px; 
    padding-right: 3px; 
}

#crm_learn_more {
	padding: 20px;
    width: 404px;
    display:none;
    background: #FFF;
    border-radius: 5px; 
    box-shadow: 0px 0px 4px rgba(0,0,0,0.7); 
}
#crm_learn_more li{
	margin-top: 15px;
}
#lean_overlay {
    position: fixed;
    z-index:100;
    top: 0px;
    left: 0px;
    height:100%;
    width:100%;
    background: #000;
    display: none;
}


td.count {
	text-align: right;
	font-weight: bold;
}

.legend_element {
	padding: 10px 5px 5px 35px;
	position: relative;
}

.legend_matched, .legend_unmatched, .legend_inactive, .legend_in_sync, .legend_different, .legend_duplicate,
.legend_5, .legend_6, .legend_7, .legend_8, .legend_9, .legend_10, .legend_select_match  {
	height:25px;
	width:25px;
	position: absolute;
	left:0;
	top:5px;
	border-radius: 5px;
}

.legend_matched {
	background: #5794D2;
}

.legend_unmatched {
	background: #E9E9E9;
}

.legend_inactive, .legend_select_match {
	background: #88BDFE;
}

.legend_in_sync {
	background: #0B4298;
}

.legend_different {
	background: #1783B4;
}

.legend_5 {
	background: #90EE90;
}

.legend_6 {
	background: #3CB371;
}

.legend_7 {
	background: #008000;
} 

.legend_8 {
	background: #87CEEB;
}

.legend_9 {
	background: #1E90FF;
}

.legend_10, .legend_matched {
	background: #0000FF;
}

/*------------------------ Gauges----------------------------*/

.data_health_summary {
	overflow: hidden;
	/*min-width: 1024px;*/
}

.data_health_summary_content {
	width: 270px;
	padding: 0 15px;
	box-sizing: border-box;
	margin:0 auto;
}


.scale-label-container {
	overflow: hidden;
	padding: 5px 0px 0px;
	color: #777;
}

.gauge {
	position: relative;
	width: 215px;
	overflow: visible;
	box-sizing: border-box;
	margin-right: 32px;
}
.gauge img {
	width:240px;
	height:auto
}
.indicator {
	position: absolute;
	top: -8px;
	margin-left:-7px
}

.indicator img {
	height:40px;
	width:40px;
}

ul.ratings-text {
	margin-top:15px;
}

ul.ratings-text .ratings-text-label {
	display:inline-block;
	width:40%;
}

/*------------------------ V2 Styles----------------------------*/

.divider {
	border-top:1px solid #efefef;
	margin:30px 0;
}
.row {
	overflow:hidden;
	clear:both;
}

.row.legend-row {
	margin-bottom:20px
}

.col {
	box-sizing: border-box;
	float:left;
	min-height:1px;
}

.col.col-75 { width:75%}
.col.col-25 { width:25%}
.col.col-50{ width:50%}
.col.col-66 { width:66.666666%}
.col.col-33 { width:33.333333%}

.donut-value {
	position: absolute;
	top: 50%;
	left: 50%;
	margin-left: -22px;
	margin-top: -28px;
	text-align: center;
	z-index: 9999;
	height: 44px;
	width: 48px;
}

.donut-legend {
	padding-top:50px;
}

.barchart-legend {
	padding-top:50px;
}

/*------------------------ End ---------------------------*/
.record_table th {
	text-align: center;
}

.record_table td {
	width: 15%;
}

.record_table.small td {
	font-size:18px;
	width: 16.5%;
	box-sizing: border-box;
}

.record_table.large td {
	font-size:18px;
	width: 50%;
	box-sizing: border-box;
}

.record_table.medium td {
	font-size:18px;
	width: 25%;
	box-sizing: border-box;
}

.blank_highlight {
	color: #CF0020;
}

.different_highlight {
	color: #15A648;
}

#revenue-chart, #employees-chart {
	width: 500px !important;
}

#Dunsright_chart .jqplot-data-label{
	color: white;
	font-weight: bold;
}

.jqplot-point-label {
	color: white;
	font-weight: bold;
	font-size: 14px;
}

.donut_label {
	color: white;
	font-weight: bold;
}

#industry-chart .jqplot-yaxis-tick {
	right: 0;
	top: 15px;
	text-align: right;
	width: 150px;
	white-space:normal;
	font-size: 10px;
}

#industry-chart.jqplot-target {
	height: auto;
	width: 500px;
}

#industry-chart .jqplot-point-label {
    color: #666;
}

.jqplot-data-label {
	color: white;
	font-size: 14px;
}

.marketing_sidebar {
	margin: 60px 0 0 0;
	padding-left:30px;
}

.clear {
	clear: both;
	page-break-after: always;
}

.match_rate_sidebar {
	border: 1px solid #98ECB1;
	background: #EDFFF1;
	padding: 10px;
	border-radius: 7px;
	margin-left:20px
}

.match_rate_sidebar h3{
	font-weight:bold;
	display:inline;
}
.match_rate_sidebar p {
	margin-top: 3px;
}

#did_you_know_icon {
	padding-right: 7px;
}
