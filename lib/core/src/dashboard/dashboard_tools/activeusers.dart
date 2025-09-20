import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ActiveUsersPage extends StatelessWidget {
  const ActiveUsersPage({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFFEBEBEB),
        appBar: AppBar(
          backgroundColor:  Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            "Active Users",
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
            SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                child: Material(
                  elevation: 1.5,
                  shadowColor: const Color.fromARGB(75, 158, 158, 158),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white,
                    ),
                    height: 311,
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 7, 0, 0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 10),
                          Text("Chart Analysis for the month", style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 16
                          ),),
                          SizedBox(
                            height: 150,
                            width: double.infinity,
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return LineChartWidget(
                                  width: constraints.maxWidth,
                                  height: constraints.maxHeight,
                                );
                              },
                            ),
                          ),
                          SizedBox(height: 5),
                          Text("Users with daily active usage of app", style: TextStyle(
                            fontWeight: FontWeight.w400, fontSize: 14
                          ),),
                          SizedBox(height: 5),
                          ActiveUsers(
                            imagePaths: [
                              'assets/images/pic1.png',
                              'assets/images/pic2.png',
                              'assets/images/pic3.png',
                              'assets/images/pic4.png',
                              'assets/images/pic5.png',
                              'assets/images/pic6.png',
                            ],
                          )

                        ],
                      ),
                    ),
                  ),
                ),
              ),
          
              SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                child: Material(
                  elevation: 1.5,
                  shadowColor: const Color.fromARGB(82, 158, 158, 158),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white,
                    ),
                    height: 200,
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                      child: Column(
                        children: [
                          SizedBox(height: 25),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text("Summary of users activity", style: TextStyle(
                                  fontWeight: FontWeight.w500, fontSize: 16
                              ),),
                            ],
                          ),
                          SizedBox(height: 15),

                          Row(
                            children: [
                              Text('50%', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w400, color: Color(0xFF0C00B2))),
                              SizedBox(width: 10),
                              Text("Purchased Mobile data", style: TextStyle(fontSize: 17, fontWeight: FontWeight.w400, color: Color(0xFF1F1F1F)),)
                            ],
                          ),
                          SizedBox(height: 15),
                          Row(
                            children: [
                              Text('30%', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w400, color: Color(0xFF0C00B2)),),
                              SizedBox(width: 10),
                              Text("Purchased cable TV service", style: TextStyle(fontSize: 17, fontWeight: FontWeight.w400, color: Color(0xFF1F1F1F)),)
                            ],
                          ),
                          SizedBox(height: 15),

                          Row(
                            children: [
                              Text('10%', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w400, color: Color(0xFF0C00B2)),),
                              SizedBox(width: 10),
                              Text("Paid Electricity bill", style: TextStyle(fontSize: 17, fontWeight: FontWeight.w400, color: Color(0xFF1F1F1F)),)
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ]
          ),
        )
    );}}





class ActiveUsers extends StatelessWidget {
  final List<String> imagePaths;

  const ActiveUsers({
    super.key,
    required this.imagePaths,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60, // enough to fit 48px avatar + padding
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: imagePaths.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          return CircleAvatar(
            radius: 24, // 48/2
            backgroundImage: AssetImage(imagePaths[index]),
            backgroundColor: Colors.grey[200],
          );
        },
      ),
    );
  }
}


class LineChartWidget extends StatelessWidget {
  final double width;
  final double height;

  const LineChartWidget({super.key, required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height * 0.6, // Responsive height
      child: LineChart(
        LineChartData(
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
          ),
          borderData: FlBorderData(show: true),
          lineBarsData: [
            LineChartBarData(
              spots: [
                FlSpot(0, 1),
                FlSpot(1, 1.5),
                FlSpot(2, 1.4),
                FlSpot(3, 3.4),
                FlSpot(4, 2),
              ],
              isCurved: true,
              barWidth: 3,
              color: Colors.redAccent,
              dotData: FlDotData(show: true),
            ),
          ],
        ),
      ),
    );
  }
}