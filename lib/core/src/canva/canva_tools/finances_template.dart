import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:newregentspace/core/src/canva/canva.dart';

class FinancesTemplate extends StatelessWidget {
  const FinancesTemplate({
    super.key,
    required this.primaryapptheme,
  });

  final Color primaryapptheme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Container(
            width: 175,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: primaryapptheme,
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Solomon',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Text(
                        'Prepaid- 5235829243',
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w200,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Manage account',
                    style: TextStyle(
                      fontSize: 6,
                      fontWeight: FontWeight.w200,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 5,),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Usageinfo(amount: '20,000.00', rating: 'Kes', servicetype: 'Airtime',),
                Usageinfo(amount: '4000', rating: 'Mms', servicetype: 'Voice Bundle',),
                Usageinfo(amount: '2,903.00', rating: 'Mb', servicetype: 'Data Bundle',),
              ],
            ),
          ),
          SizedBox(height:6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            color: Colors.black,
                            width: 1,
                          ),
                          color: primaryapptheme,
                        ),
                        child: Text(
                          "History",
                          style: TextStyle(fontSize: 10),
                        ),
                      ),
                      SizedBox(width:10),
              Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            color: Colors.black,
                            width: 1,
                          ),
                          color: primaryapptheme,
                        ),
                        child: Text(
                          "Schedule payments",
                          style: TextStyle(fontSize: 10),
                        ),
                      ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical:8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "Recent Transactions",
                  style: TextStyle(fontSize: 10),
                ),
              ],
            ),
          ),
          Expanded(
                      child: ListView.builder(
                        itemCount: 5,
                        itemBuilder: (BuildContext context, int index) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Container(
          padding: EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: Colors.black12, width:1)
          ),
          child: Row(
            children: [
              // Image
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[100],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Icon(Icons.wallet_outlined, size: 8,)
                ),
              ),
    
              SizedBox(width: 12),
    
              // Title and Time
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'loan payment',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      '12:00pm',
                      style: TextStyle(
                        fontSize: 8,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
    
              // Amount
              Text(
                '+3,000',
                style: TextStyle(
                  fontSize: 7,
                  color:Colors.red ,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        )
    );
                        },
                      ),
                    )
        ],
      ),
    );
  }
}
