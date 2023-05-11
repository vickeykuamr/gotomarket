import 'package:flutter/material.dart';
import 'package:flutter_charts/flutter_charts.dart';

class MyDashboard extends StatefulWidget {
  const MyDashboard({Key? key}) : super(key: key);

  @override
  State<MyDashboard> createState() => _MyDashboardState();
}

class _MyDashboardState extends State<MyDashboard> {

  var selectStation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body:
      Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height,
        margin: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonHideUnderline(
              child: Container(
                 width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(color: Colors.orange.shade300,
                    borderRadius: BorderRadius.circular(10.0),border: Border.all(color: Colors.black26,width: 2)),
                // width: 124,
                margin: const EdgeInsets.only(top: 10.0),
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: DropdownButton(
                  dropdownColor: Colors.orange.shade300,
                  borderRadius: BorderRadius.circular(10.0),
                  style: const TextStyle(color: Colors.black),
                  hint: const Text('Dashboard'),
                  value: selectStation,
                  items:["Dashboard","Sources"].map((e) {
                    return DropdownMenuItem(
                        value: e,
                        child: Text(e));
                  }).toList(),
                  onChanged: (Object? value) {
             setState(() {
             selectStation=value.toString();
             });
                  },
                ),
              ),
            ),const SizedBox(height: 10,),
           (selectStation.toString()=='Dashboard') ?Row(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               Expanded(child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Row(
                     children: const [
                       Icon(Icons.cloud_upload_outlined),SizedBox(width: 5.0,),
                       Text(' Past 7 Days',),
                     ],
                   ),const SizedBox(height: 10,),
                   Row(
                     children: [
                       const SizedBox(width: 70,
                           child: Text('Answered')),
                       Container(padding: const EdgeInsets.all(4.0),
                         alignment: Alignment.center,width: 50,color:Colors.green.shade400,child: const Text('70'),)
                     ],
                   ),const SizedBox(height: 10,),
                   Row(
                     children: [
                       const SizedBox(width: 70,
                           child: Text('Missed')),Container(padding: const EdgeInsets.all(4.0),
                         alignment: Alignment.center,width: 50,color:Colors.red.shade400,child: const Text('59'),)
                     ],
                   ),const SizedBox(height: 10,),
                   Row(
                     children: [
                       const SizedBox(width: 70,child: Text('Dropped')),Container(padding: const EdgeInsets.all(4.0),
                         alignment: Alignment.center,width: 50,color:Colors.yellow.shade400,child: const Text('21'),)
                     ],
                   ),const SizedBox(height: 10,),
                   Row(  children: [
                     const SizedBox(width: 70,child: Text('Total')),Container(padding: const EdgeInsets.all(4.0),
                       alignment: Alignment.center,width: 50,color:Colors.blue.shade400,child: const Text('150'),)
                   ],),
                 ],
               )),
               SizedBox(
                   width: 200,
                   height: 200,
                   child: chartToRun()),
             ],
           ): sourceWidget(),

          ],
        ),
      ),
    );

  }
  bool check=true;

  Widget sourceWidget(){
    return  Center(
      child: Container(

    )
    );
  }
  Widget chartToRun() {
    LabelLayoutStrategy? xContainerLabelLayoutStrategy;
    ChartData chartData;
    ChartOptions chartOptions = const ChartOptions();
    chartOptions = const ChartOptions(
      dataContainerOptions: DataContainerOptions(
        startYAxisAtDataMinRequested: true,
      ),
    );
    chartData = ChartData(
      dataRows: const [
        [10.0, 25.0, 30.0, 35.0],
        [10.0, 40.0, 20.0, 25.0],
      ],
      xUserLabels: const ['Jan', 'Feb', 'Mar', 'Apr',],
      dataRowsLegends: const [
        'Off zero 1',
        'Off zero 2',
      ],
      chartOptions: chartOptions,
    );
    var verticalBarChartContainer = VerticalBarChartTopContainer(
      chartData: chartData,
      xContainerLabelLayoutStrategy: xContainerLabelLayoutStrategy,
    );

    var verticalBarChart = VerticalBarChart(
      painter: VerticalBarChartPainter(
        verticalBarChartContainer: verticalBarChartContainer,
      ),
    );
    return verticalBarChart;
  }
}
