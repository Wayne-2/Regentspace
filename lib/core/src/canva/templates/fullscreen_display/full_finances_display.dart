import 'package:flutter/material.dart';
import 'package:newregentspace/core/src/canva/widgets/usageinfo.dart';

class FullFinancesDisplay extends StatelessWidget {
  const FullFinancesDisplay({
    super.key,
    required this.primaryapptheme,
  });

  final Color primaryapptheme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14.0),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 100,
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
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'Prepaid- 5235829243',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Manage account',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 5,),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Usageinfo(amount: '20,000.00', rating: 'Kes', servicetype: 'Airtime', fontsize: 14,),
                Usageinfo(amount: '4000', rating: 'Mms', servicetype: 'Voice Bundle',fontsize: 14,),
                Usageinfo(amount: '2,903.00', rating: 'Mb', servicetype: 'Data Bundle',fontsize: 14,),
              ],
            ),
          ),
          SizedBox(height:10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
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
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                      SizedBox(width:10),
              Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
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
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical:10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "Recent Transactions",
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
          Expanded(
                      child: ListView.builder(
                        itemCount: 5,
                        itemBuilder: (BuildContext context, int index) {
    return Padding(
      padding: const EdgeInsets.all(7.0),
      child: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: Colors.black12, width:1)
          ),
          child: Row(
            children: [
              // Image
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[100],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Icon(Icons.wallet_outlined, size: 13,)
                ),
              ),
    
              SizedBox(width: 14),
    
              // Title and Time
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'loan payment',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      '12:00pm',
                      style: TextStyle(
                        fontSize: 12,
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
                  fontSize: 14,
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
