import 'package:direct_caller_sim_choice/direct_caller_sim_choice.dart';

final DirectCaller directCaller = DirectCaller();

void phone(String number) {
  directCaller.makePhoneCall(number, simSlot: 1);
}
