import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:chatgpt_course/constants/constants.dart';
import 'package:chatgpt_course/services/assets_manager.dart';
import 'package:flutter/material.dart';
import '../widgets/text_widget.dart';
import 'package:text_to_speech/text_to_speech.dart';

class ChatWidget extends StatelessWidget {
  const ChatWidget(
      {super.key,
      required this.msg,
      required this.chatIndex,
      this.shouldAnimate = false});


  final String msg;
  final int chatIndex;
  final bool shouldAnimate;

  @override
  Widget build(BuildContext context) {
    TextToSpeech tts = TextToSpeech();
    String language = 'en';
    tts.setLanguage(language);
    return Column(
      children: [
        Material(
          color: chatIndex == 0 ? scaffoldBackgroundColor : Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  chatIndex == 0
                      ? AssetsManager.userImage
                      : AssetsManager.botImage,
                  height: 30,
                  width: 30,
                ),
                const SizedBox(
                  width: 8,
                ),
                Expanded(
                  child: chatIndex == 0
                      ? TextWidget(
                          label: msg,
                        )
                      : shouldAnimate
                          ? DefaultTextStyle(
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16),
                              child: Text(msg),
                              // AnimatedTextKit(
                              //     isRepeatingAnimation: false,
                              //     repeatForever: false,
                              //     displayFullTextOnTap: true,
                              //     totalRepeatCount: 1,
                              //     animatedTexts: [
                              //       TyperAnimatedText(
                              //         msg.trim(),
                              //       ),
                              //     ]),
                            )
                          : Text(
                              msg.trim(),
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16),
                            ),
                ),
              ],
            ),
          ),
        ),
        Container(height: 1,width: MediaQuery.of(context).size.width - 10,color: Colors.black,)
      ],
    );
  }
}
