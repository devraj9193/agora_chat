// import 'package:flutter/foundation.dart';
//
// import '../models/chat_models.dart';
//
// class SignalProvider with ChangeNotifier {
//   final Subscription subscription;
//   Map<String, Signal> signals = <String, Signal>{};
//
//   SignalProvider._(this.subscription) {
//     subscription.messages.listen((envelope) {
//       if (envelope.messageType == MessageType.signal) {
//         signals[envelope.channel] =
//             Signal(message: envelope.content, sender: envelope.uuid.value);
//         notifyListeners();
//       }
//     });
//   }
//   SignalProvider(PubNubInstance pn) : this._(pn.subscription);
// }
