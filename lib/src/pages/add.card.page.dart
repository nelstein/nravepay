import 'package:flutter/material.dart' hide State, ConnectionState;
import 'package:nravepay/nravepay.dart';
import 'package:nravepay/src/base/base.dart';
import 'package:nravepay/src/blocs/blocs.dart';
import 'package:nravepay/src/paymanager/card.paymanager.dart';
import 'card.payment.page.dart';

class AddCardPage extends StatefulWidget {
  @override
  _AddCardPageState createState() => _AddCardPageState();
}

class _AddCardPageState extends BaseState<AddCardPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation _animation;
  final _slideUpTween = Tween<Offset>(begin: Offset(0, 0.4), end: Offset.zero);

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 600));
    _animation = CurvedAnimation(
        parent: Tween<double>(begin: 0, end: 1).animate(_animationController),
        curve: Curves.fastOutSlowIn);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget buildChild(BuildContext context) {
    var column = CardPaymentWidget(
      manager: CardTransactionManager(
        context: context,
      ),
    );

    Widget child = SingleChildScrollView(
      child: AnimatedSize(
        duration: Duration(milliseconds: 400),
        curve: Curves.fastOutSlowIn,
        alignment: Alignment.topCenter,
        vsync: this,
        child: StreamBuilder<TransactionState>(
          stream: TransactionBloc.instance.stream,
          builder: (_, snapshot) {
            var transactionState = snapshot.data;
            late Widget w;
            if (!snapshot.hasData) {
              w = column;
            } else {
              switch (transactionState!.state) {
                case State.initial:
                  w = column;
                  break;
                case State.pin:
                  w = PinWidget(
                    onPinInputted: transactionState.callback,
                  );
                  break;
                case State.otp:
                  w = OtpWidget(
                    onPinInputted: transactionState.callback,
                    message: transactionState.data,
                  );
                  break;
                case State.avsSecure:
                  w = BillingWidget(
                      onBillingInputted: transactionState.callback);
              }
            }
            return w;
          },
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Card Payment',
          style: Theme.of(context).textTheme.headline6,
        ),
      ),
      body: StreamBuilder<ConnectionState>(
          stream: ConnectionBloc.instance.stream,
          builder: (context, snapshot) {
            return OverlayLoading(
              active:
                  snapshot.hasData && snapshot.data == ConnectionState.waiting,
              child: AnimatedSize(
                vsync: this,
                duration: Duration(milliseconds: 400),
                curve: Curves.linear,
                child: FadeTransition(
                  opacity: _animation as Animation<double>,
                  child: SlideTransition(
                    position:
                        _slideUpTween.animate(_animation as Animation<double>),
                    child: child,
                  ),
                ),
              ),
            );
          }),
    );
  }
}
