import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:pothole_detection_realtime/Views/ObjectDetectorView.dart';
import 'package:pothole_detection_realtime/Widgets/chartData.dart';

class HomeScreenElements extends StatelessWidget {
  const HomeScreenElements({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        // Chart
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Container(
            width: double.infinity,
            height: 250,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.01),
                    spreadRadius: 10,
                    blurRadius: 3,
                    // changes position of shadow
                  ),
                ]),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Stack(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(
                      top: 10,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Your Contribution",
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                              color: Color(0xff67727d)),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "430 Potholes",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 25,
                          ),
                        )
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width - 40,
                      height: 150,
                      child: LineChart(
                        mainData(),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
        // Spaced
        const SizedBox(
          height: 20,
        ),
        // Stream camera or Maps Button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            GestureDetector(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.45,
                height: MediaQuery.of(context).size.height * 0.15,
                child: const Card(
                  color: Colors.white,
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.blueGrey, width: 0.5),
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt_outlined),
                      Text(
                        'RealTime\n Object Detection',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 17,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              onTap: () {
                // Navigator.of(context).push(MaterialPageRoute(
                //     builder: (context) => const ObjectDetectionTF()));
              },
            ),
            GestureDetector(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.45,
                height: MediaQuery.of(context).size.height * 0.15,
                child: const Card(
                  color: Colors.white,
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.blueGrey, width: 0.5),
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.pin_drop),
                      Text(
                        'Maps',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 17,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              onTap: () {
                // Get.to(const ObjectDetectorView());
              },
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: GestureDetector(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.45,
              height: MediaQuery.of(context).size.height * 0.15,
              child: const Card(
                color: Colors.white,
                elevation: 1,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.blueGrey, width: 0.5),
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt_outlined),
                    Text(
                      'Google ML Kit',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 17,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const ObjectDetectorView()));
            },
          ),
        ),
      ],
    );
  }
}
