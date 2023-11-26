import 'package:flutter/material.dart';
import 'store_service.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({Key? key}) : super(key: key);

  @override
  _StoreScreenState createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  final StoreService _storeService = StoreService();
  int userMoney = 0;

  @override
  void initState() {
    super.initState();
    getUserMoney();
  }

  void getUserMoney() async {
    int money = await _storeService.getUserMoney();
    setState(() {
      userMoney = money;
    });
  }

  Future<void> purchaseItem(String itemName, int itemPrice) async {
    bool confirmPurchase = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('구매 확인'),
          content: Text('\'$itemName\'을(를) 구매하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('확인'),
            ),
          ],
        );
      },
    );

    void showDeductionDialog(int deductionAmount) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('포인트 차감 알림'),
            content: Text('$deductionAmount 포인트가 차감되었습니다.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('확인'),
              ),
            ],
          );
        },
      );
    }

    if (confirmPurchase == true) {
      if (userMoney >= itemPrice) {
        await _storeService.subtractMoney(itemPrice);
        getUserMoney();
        showDeductionDialog(itemPrice);
        // 아이템처리로직추가
        // 아이템을 유저의 인벤토리에 추가하기
      } else {
        // 충분한 머니가 없는 경우에 대한 처리추가하기
        print('머니가 부족합니다!');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('상점'),
        backgroundColor: Colors.purple,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.pinkAccent,
                      Colors.deepPurpleAccent,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text(
                          "현재 보유 포인트",
                          style: TextStyle(fontSize: 15.0, color: Colors.white),
                        ),
                        const SizedBox(height: 5),
                        FutureBuilder<int>(
                          future: _storeService.getUserMoney(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return Text(
                                "${snapshot.data!}P",
                                style: const TextStyle(
                                  fontSize: 40.0,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            } else if (snapshot.hasError) {
                              return Text(
                                "Error: ${snapshot.error}",
                                style: const TextStyle(
                                  fontSize: 15.0,
                                  color: Colors.white,
                                ),
                              );
                            } else {
                              return const CircularProgressIndicator();
                            }
                          },
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          "해당 포인트는 출석과 게임 플레이를 통해 획득할 수 있습니다.",
                          style: TextStyle(fontSize: 10.0, color: Colors.white),
                        )
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "상품 목록",
                style: TextStyle(
                    fontSize: 25.0,
                    color: Colors.deepPurpleAccent,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              StoreItem(
                itemName: 'LIFE',
                itemInfo: '게임 플레이시 목숨을 추가할 수 있다.',
                itemPrice: 10,
                onItemPressed: () => purchaseItem('LIFE', 10),
              ),
              StoreItem(
                itemName: 'HINT',
                itemInfo: '게임 플레이시 단어 힌트를 얻을 수 있다.',
                itemPrice: 10,
                onItemPressed: () => purchaseItem('HINT', 10),
              ),
              StoreItem(
                itemName: 'ADD TIME',
                itemInfo: '게임 플레이 시간을 추가할 수 있다.',
                itemPrice: 10,
                onItemPressed: () => purchaseItem('ADD TIME', 10),
              ),
              StoreItem(
                itemName: 'PASS',
                itemInfo: '게임 플레이시 모르는 단어를 패스할 수 있다.',
                itemPrice: 10,
                onItemPressed: () => purchaseItem('PASS', 10),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StoreItem extends StatelessWidget {
  final String itemName;
  final String itemInfo;
  final int itemPrice;
  final VoidCallback onItemPressed;

  const StoreItem({
    required this.itemName,
    required this.itemInfo,
    required this.itemPrice,
    required this.onItemPressed,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onItemPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Color.fromARGB(255, 182, 155, 255),
              Color.fromARGB(255, 255, 131, 172),
            ],
          ),
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  itemName,
                  style: const TextStyle(
                    fontSize: 25.0,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '설명: $itemInfo',
                  style: const TextStyle(
                    fontSize: 16.0,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '가격: $itemPrice P',
                  style: const TextStyle(
                    fontSize: 16.0,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const Icon(
              Icons.attach_money,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
