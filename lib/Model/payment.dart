import 'package:capstone/Model/User.dart';
import 'package:capstone/Screen/Receipt.dart';
import 'package:capstone/Widget/BasketTile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/* 아임포트 결제 모듈을 불러옵니다. */
import 'package:iamport_flutter/iamport_payment.dart';
/* 아임포트 결제 데이터 모델을 불러옵니다. */
import 'package:iamport_flutter/model/payment_data.dart';

class Payment extends StatelessWidget {
  final UserModel userModel;
  final int sumPrice;
  final String name;
  final List<BasketTile> list;
  Payment(this.userModel, this.sumPrice, this.name, this.list);

  @override
  Widget build(BuildContext context) {
    return IamportPayment(
      /* 웹뷰 로딩 컴포넌트 */
      initialChild: Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.fromLTRB(0.0, 30.0, 0.0, 0.0),
                child: Text('잠시만 기다려주세요...', style: TextStyle(fontSize: 20.0)),
              ),
            ],
          ),
        ),
      ),
      /* [필수입력] 가맹점 식별코드 */
      userCode: 'imp21490057', //iamport는 됨
      /* [필수입력] 결제 데이터 */
      data: PaymentData.fromJson({
        'pg':
            'kakaopay.INIpayTest', // PG사 이니시스 = html5_inicis, 카카오페이 = kakaopay.INIpayTest
        'payMethod': 'card', // 결제수단
        'name': name, // 주문명
        'merchantUid': 'mid_${DateTime.now().millisecondsSinceEpoch}', // 주문번호
        'amount': sumPrice, // 결제금액
        // 'buyerName': userModel.name, // 구매자 이름
        // 'buyerTel': userModel.phoneNum, // 구매자 연락처
        // 'buyerEmail': userModel.email, // 구매자 이메일
        // 'buyerAddr': userModel.addr, // 구매자 주소
        // 'buyerPostcode': userModel.postCode, // 구매자 우편번호
        'appScheme': 'example', // 앱 URL scheme
        'display': {
          'cardQuota': [2, 3] //결제창 UI 내 할부개월수 제한
        }
      }),
      /* [필수입력] 콜백 함수 */
      callback: (Map<String, String> result) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => ReceiptScreen(list : list, sumPrice : sumPrice, result: result,)));
      },
    );
  }
}
