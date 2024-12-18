import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp/common/utils/colors.dart';
import 'package:whatsapp/common/widgets/loader.dart';
import 'package:whatsapp/features/auth/controller/auth_controller.dart';
import 'package:whatsapp/features/call/controller/call_controller.dart';
import 'package:whatsapp/features/call/screens/call_pickup_screen.dart';
import 'package:whatsapp/features/chat/widgets/bottom_chat_field.dart';
import 'package:whatsapp/models/user_model.dart';
import 'package:whatsapp/features/chat/widgets/chat_list.dart';

import '../../group/screens/group_profile_screen.dart';

class MobileChatScreen extends ConsumerWidget {
  static const String routeName = '/mobile-chat-screen';
  final String name;
  final String uid;
  final bool isGroupChat;
  final String profilePic;
  final List<UserModel> members;
  const MobileChatScreen({
    Key? key,
    required this.name,
    required this.uid,
    required this.isGroupChat,
    required this.profilePic,
  this.members = const <UserModel>[],
  }) : super(key: key);

  void makeCall(WidgetRef ref, BuildContext context) {
    ref.read(callControllerProvider).makeCall(
          context,
          name,
          uid,
          profilePic,
          isGroupChat,
        );
  }
  void openGroupProfile(BuildContext context) {
    Navigator.pushNamed(context, GroupProfileScreen.routeName, arguments: {
      'groupName': name,
      'profilePic': profilePic,
      'members': members,
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    print("AS>>>>> ${members}");
    return CallPickupScreen(
      scaffold: Scaffold(
        appBar: AppBar(
          backgroundColor: appBarColor,
          title: isGroupChat
              ? Text(name)
              : StreamBuilder<UserModel>(
                  stream: ref.read(authControllerProvider).userDataById(uid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Loader();
                    }
                    return Column(
                      children: [
                        Text(name),
                        Text(
                          snapshot.data!.isOnline ? 'online' : 'offline',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    );
                  }),
          centerTitle: false,
          actions: [
            if(!isGroupChat)
            IconButton(
              onPressed: () => makeCall(ref, context),
              icon: const Icon(Icons.video_call),
            ),
            // IconButton(
            //   onPressed: () {},
            //   icon: const Icon(Icons.call),
            // ),
            // IconButton(
            //   onPressed: () {},
            //   icon: const Icon(Icons.more_vert),
            // ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'Group Profile') {
                  openGroupProfile(context);
                }
              },
              itemBuilder: (BuildContext context) {
                return [
                  if (isGroupChat)
                    const PopupMenuItem<String>(
                      value: 'Group Profile',
                      child: Text('Group Profile'),
                    ),
                  const PopupMenuItem<String>(
                    value: 'Settings',
                    child: Text('Settings'),
                  ),
                ];
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: ChatList(
                recieverUserId: uid,
                isGroupChat: isGroupChat,
                members:members
              ),
            ),
            BottomChatField(
              recieverUserId: uid,
              isGroupChat: isGroupChat,
            ),
          ],
        ),
      ),
    );
  }
}
