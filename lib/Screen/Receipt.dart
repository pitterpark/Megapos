import 'package:capstone/Model/Market.dart';
import 'package:capstone/Model/User.dart';
import 'package:capstone/Screen/HomeScreen.dart';
import 'package:capstone/Widget/BasketTile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';



class ReceiptScreen extends StatelessWidget {
  final List<BasketTile> list;
  final int sumPrice;
  final Map<String, String> result;

  const ReceiptScreen({Key key, this.list, this.sumPrice, this.result}) : super(key: key);


  // ignore: non_constant_identifier_names
  bool getIsSuccessed(Map<String, String> ReceiptScreen) {
    if (ReceiptScreen['imp_success'] == 'true') {
      return true;
    }
    if (ReceiptScreen['success'] == 'true') {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    bool isSuccessed = getIsSuccessed(result);

    final _market = context.watch<Market>();
    final _user = context.watch<UserModel>();
    final now = DateTime.now();
    writeReceipt(context, _market, _user, now);
    subStock(context, _market);

    return isSuccessed ? WillPopScope(
      onWillPop: () {
        return Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => HomeScreen()), (route) => false);
      },
      child: Scaffold(
        appBar: AppBar(
          actions: [
            TextButton(
              onPressed: (){
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => HomeScreen()), (route) => false);
              },
              child: Text("확인",
                style: TextStyle(
                    color: Colors.white
                ),),
            )
          ],
          backgroundColor: Colors.deepPurple,
          title: Text("결제내역",
              style: TextStyle(
                  fontFamily: 'Jalnan',
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 25
              )
          ),
          centerTitle: true,
        ),
        body: IntrinsicHeight(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10, top: 10),
                  child: Text(_market.name,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10, top: 5),
                  child: Text(_market.contact,
                    style: TextStyle(
                        fontSize: 18
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10, top: 5),
                  child: Text(_market.address,
                    style: TextStyle(
                        fontSize: 18
                    ),
                  ),
                ),

                Divider(color: Colors.black, thickness: 1.0,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text('상품명'),
                    Text('수량'),
                    Text('가격')
                  ],
                ),
                Divider(color: Colors.black, thickness: 1.0,),
                Container(
                  height: MediaQuery.of(context).size.height * 0.5,
                  child: ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (context, index){
                      return Container(
                          margin: EdgeInsets.only(top: 8.0),
                          child : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                flex:1,
                                child: Text(list[index].selectedItem.item.name,
                                  textAlign: TextAlign.center,),
                              ),
                              Expanded(
                                flex:1,
                                child: Text('${list[index].selectedItem.count}',
                                    textAlign: TextAlign.center),
                              ),
                              Expanded(
                                flex:1,
                                child: Text('${list[index].selectedItem.sumPrice}',
                                    textAlign: TextAlign.center),
                              ),
                            ],
                          )
                      );
                    },
                  ),
                ),
                Divider(color: Colors.black, thickness: 1.0,),
                Divider(color: Colors.black, thickness: 1.0,),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text('$sumPrice원',
                    style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold
                    ),),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Text('${now.year}년 ${now.month}월 ${now.day}일 ${now.hour}시 ${now.minute}분'),
                )
              ],
            ),
          ),
        ),
      ),
    )
    :
    Scaffold(
      body: Center(child: Text("결제 실패"))
    );
  }

  Future<void> writeReceipt(BuildContext context, Market market, UserModel user, DateTime now){
    print('유저넘버 : ${user.userNo}');

    CollectionReference firestore = FirebaseFirestore.instance
        .collection('User')
        .doc(user.userNo)
        .collection('Receipt');

    List<String> shopList = [];
    for(int i= 0; i < list.length; i++){
      shopList.add("${list[i].selectedItem.item.name}, ${list[i].selectedItem.count}, ${list[i].selectedItem.sumPrice}");
    }

    return firestore
        .add({
      'MarketName' : market.name,
      'Time' : '${now.year}.${now.month}.${now.day}.${now.hour}.${now.minute}',
      'List' : shopList,
      'Price' : sumPrice
        })
        .then((value) => print("Add"))
        .catchError((error) => print("Error"));
  }

  //판매 갯수만큼 재고량 빼기
  Future<void> subStock(BuildContext context, Market market){
    CollectionReference firestore = FirebaseFirestore.instance
        .collection('Store')
        .doc(market.marketNo)
        .collection('Product');
    
    for(int i=0; i < list.length; i++){
      firestore.doc(list[i].itemNo)
          .update({
        'Stock' : list[i].selectedItem.item.stock - list[i].selectedItem.count
      }).then((value) => print("Stock Updated"))
          .catchError((error) => print("Sub Stock Error"));
    }
  }

}
